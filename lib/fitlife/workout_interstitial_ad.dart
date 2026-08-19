import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'privacy_consent.dart';

/// Shows an interstitial only at the natural end of a completed workout.
///
/// Google's SDK owns the close control and any countdown shown on the ad.
/// A release unit ID is deliberately supplied at build time, so the app never
/// ships a Google test ad to real users by accident.
class WorkoutInterstitialAd {
  WorkoutInterstitialAd._();

  static final instance = WorkoutInterstitialAd._();

  static const _androidTestUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const _androidProductionUnitId = String.fromEnvironment(
    'WORKOUT_INTERSTITIAL_AD_UNIT_ID',
  );

  InterstitialAd? _ad;
  bool _loading = false;

  String? get _adUnitId {
    if (kDebugMode) return _androidTestUnitId;
    if (_androidProductionUnitId.trim().isEmpty) return null;
    return _androidProductionUnitId;
  }

  /// Starts loading early, while the user is doing a workout. This never
  /// delays the completion screen if an ad is unavailable.
  Future<void> preload() async {
    final adUnitId = _adUnitId;
    if (kIsWeb ||
        !Platform.isAndroid ||
        adUnitId == null ||
        _loading ||
        _ad != null ||
        !PrivacyConsent.instance.canRequestAds) {
      return;
    }

    _loading = true;
    await MobileAds.instance.initialize();
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          _loading = false;
        },
      ),
    );
  }

  /// Returns true only after a full-screen ad was shown and closed.
  Future<bool> showIfReady() async {
    final ad = _ad;
    if (ad == null) {
      unawaited(preload());
      return false;
    }

    _ad = null;
    final completed = Completer<bool>();
    var wasShown = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => wasShown = true,
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        if (!completed.isCompleted) completed.complete(wasShown);
        unawaited(preload());
      },
      onAdFailedToShowFullScreenContent: (failedAd, _) {
        failedAd.dispose();
        if (!completed.isCompleted) completed.complete(false);
        unawaited(preload());
      },
    );
    ad.show();
    return completed.future;
  }
}
