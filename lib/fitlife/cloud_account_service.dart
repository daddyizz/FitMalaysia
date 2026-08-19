import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_store.dart';

class CloudSignInResult {
  const CloudSignInResult({
    required this.user,
    this.cloudData,
    this.googleDisplayName,
  });

  final User user;
  final Map<String, dynamic>? cloudData;
  final String? googleDisplayName;

  bool get hasCloudBackup => cloudData != null;
}

class CloudAccountService extends ChangeNotifier {
  CloudAccountService._();

  static final instance = CloudAccountService._();
  static const adminEmail = 'dady.izz85@gmail.com';

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _partnerOfferSubscription;
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
  bool get isPartnerOfferAdmin =>
      user?.email?.trim().toLowerCase() == adminEmail;

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
      _watchGlobalPartnerOffer();
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
      final googleDisplayName = googleUser.displayName?.trim();
      if (googleDisplayName != null &&
          googleDisplayName.isNotEmpty &&
          signedInUser.displayName != googleDisplayName) {
        await signedInUser.updateDisplayName(googleDisplayName);
      }
      final cloudData = await _download(signedInUser.uid);
      _pendingBackupChoice = true;
      return CloudSignInResult(
        user: signedInUser,
        cloudData: cloudData,
        googleDisplayName: googleDisplayName ?? signedInUser.displayName,
      );
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

  Future<void> updateGlobalPartnerOffer({
    required String url,
    required bool enabled,
    required int launchDelaySeconds,
    required int notNowCooldownMinutes,
    required int viewedCooldownHours,
  }) async {
    if (!isPartnerOfferAdmin || _firestore == null) {
      throw StateError('Sign in with the administrator account to edit offers.');
    }
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty || Uri.tryParse(trimmedUrl)?.hasScheme != true) {
      throw StateError('Enter a valid https:// link.');
    }
    await _firestore!.collection('app_config').doc('partner_offer').set({
      'url': trimmedUrl,
      'enabled': enabled,
      'launchDelaySeconds': launchDelaySeconds,
      'notNowCooldownMinutes': notNowCooldownMinutes,
      'viewedCooldownHours': viewedCooldownHours,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': user?.email,
    });
    _store?.updatePartnerOffer(
      url: trimmedUrl,
      enabled: enabled,
      launchDelaySeconds: launchDelaySeconds,
      notNowCooldownMinutes: notNowCooldownMinutes,
      viewedCooldownHours: viewedCooldownHours,
    );
  }

  void _watchGlobalPartnerOffer() {
    final firestore = _firestore;
    if (firestore == null) return;
    _partnerOfferSubscription?.cancel();
    _partnerOfferSubscription = firestore
        .collection('app_config')
        .doc('partner_offer')
        .snapshots()
        .listen(
          (document) {
            final data = document.data();
            final url = data?['url'];
            final enabled = data?['enabled'];
            if (url is String && url.trim().isNotEmpty && enabled is bool) {
              _store?.updatePartnerOffer(
                url: url,
                enabled: enabled,
                launchDelaySeconds:
                    data?['launchDelaySeconds'] as int? ?? 15,
                notNowCooldownMinutes:
                    data?['notNowCooldownMinutes'] as int? ?? 15,
                viewedCooldownHours:
                    data?['viewedCooldownHours'] as int? ?? 24,
              );
            }
          },
          onError: (_) {
            // Global offers remain optional. Local defaults continue offline.
          },
        );
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
    _partnerOfferSubscription?.cancel();
    _store?.removeListener(_onStoreChanged);
    super.dispose();
  }
}
