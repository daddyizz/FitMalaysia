import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_store.dart';

class CloudSignInResult {
  const CloudSignInResult({required this.user, this.cloudData});

  final User user;
  final Map<String, dynamic>? cloudData;

  bool get hasCloudBackup => cloudData != null;
}

class CloudAccountService extends ChangeNotifier {
  CloudAccountService._();

  static final instance = CloudAccountService._();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  StreamSubscription<User?>? _authSubscription;
  FitLifeStore? _store;
  Timer? _syncTimer;
  bool _pendingBackupChoice = false;

  bool initialized = false;
  bool available = false;
  bool busy = false;
  String? lastError;
  DateTime? lastSyncAt;

  User? get user => _auth?.currentUser;
  bool get signedIn => user != null;

  Future<void> initialize() async {
    if (initialized) return;
    initialized = true;
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    try {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      await GoogleSignIn.instance.initialize();
      _authSubscription = _auth!.authStateChanges().listen((_) {
        notifyListeners();
      });
      available = true;
    } catch (error) {
      lastError = _friendlyError(error);
    }
    notifyListeners();
  }

  void attachStore(FitLifeStore store) {
    if (identical(_store, store)) return;
    _store?.removeListener(_onStoreChanged);
    _store = store;
    store.addListener(_onStoreChanged);
  }

  Future<CloudSignInResult> signInWithGoogle() async {
    if (!available || _auth == null || _firestore == null) {
      throw StateError(
        lastError ?? 'Cloud backup is not available on this device yet.',
      );
    }
    busy = true;
    lastError = null;
    notifyListeners();
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final result = await _auth!.signInWithCredential(credential);
      final signedInUser = result.user;
      if (signedInUser == null) {
        throw StateError('Google Sign-In did not return an account.');
      }
      final cloudData = await _download(signedInUser.uid);
      _pendingBackupChoice = true;
      return CloudSignInResult(user: signedInUser, cloudData: cloudData);
    } catch (error) {
      lastError = _friendlyError(error);
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> fetchCloudBackup() async {
    final currentUser = user;
    if (currentUser == null) return null;
    return _download(currentUser.uid);
  }

  Future<void> keepThisDeviceData() async {
    _pendingBackupChoice = false;
    final store = _store;
    if (store != null && store.onboarded) await uploadNow();
  }

  Future<void> restoreBackup(Map<String, dynamic> data) async {
    final store = _store;
    if (store == null) return;
    _pendingBackupChoice = false;
    await store.restoreCloudData(data);
    lastSyncAt = DateTime.now();
    notifyListeners();
  }

  Future<void> uploadNow() async {
    final currentUser = user;
    final store = _store;
    if (currentUser == null ||
        store == null ||
        !store.onboarded ||
        _pendingBackupChoice) {
      return;
    }
    busy = true;
    lastError = null;
    notifyListeners();
    try {
      await _backupDocument(currentUser.uid).set({
        'schemaVersion': 1,
        'updatedAt': FieldValue.serverTimestamp(),
        'payload': store.exportCloudData(),
      });
      lastSyncAt = DateTime.now();
    } catch (error) {
      lastError = _friendlyError(error);
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _syncTimer?.cancel();
    _pendingBackupChoice = false;
    await Future.wait([
      if (_auth != null) _auth!.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
    notifyListeners();
  }

  Future<void> deleteAccountAndCloudData() async {
    final currentUser = user;
    if (currentUser == null) return;
    busy = true;
    notifyListeners();
    try {
      await _backupDocument(currentUser.uid).delete();
      await _firestore!.collection('users').doc(currentUser.uid).delete();
      await currentUser.delete();
      await GoogleSignIn.instance.signOut();
    } catch (error) {
      lastError = _friendlyError(error);
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  DocumentReference<Map<String, dynamic>> _backupDocument(String uid) =>
      _firestore!
          .collection('users')
          .doc(uid)
          .collection('backups')
          .doc('current');

  Future<Map<String, dynamic>?> _download(String uid) async {
    final document = await _backupDocument(uid).get();
    if (!document.exists) return null;
    final payload = document.data()?['payload'];
    if (payload is! Map) return null;
    lastSyncAt = DateTime.now();
    return Map<String, dynamic>.from(payload);
  }

  void _onStoreChanged() {
    if (!signedIn || _pendingBackupChoice || !(_store?.onboarded ?? false)) {
      return;
    }
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 2), () {
      unawaited(uploadNow().catchError((_) {}));
    });
  }

  String _friendlyError(Object error) {
    if (error is GoogleSignInException) {
      return switch (error.code) {
        GoogleSignInExceptionCode.canceled => 'Google Sign-In was cancelled.',
        _ => 'Google Sign-In failed. Please try again.',
      };
    }
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'network-request-failed' =>
          'No internet connection. Your local data is still safe.',
        'requires-recent-login' =>
          'Please sign out, sign in again, then retry this action.',
        'operation-not-allowed' =>
          'Google Sign-In is being activated. Please try again shortly.',
        _ => error.message ?? 'Account action failed. Please try again.',
      };
    }
    return error.toString().replaceFirst('Bad state: ', '');
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _authSubscription?.cancel();
    _store?.removeListener(_onStoreChanged);
    super.dispose();
  }
}
