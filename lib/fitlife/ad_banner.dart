import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'privacy_consent.dart';

/// A low-interruption banner used at natural breaks in the app's feeds.
/// All development and profile builds use Google's test unit. Only release
/// Android builds use FitMalaysia's production banner unit.
class FeedAdBanner extends StatefulWidget {
  const FeedAdBanner({super.key});

  @override
  State<FeedAdBanner> createState() => _FeedAdBannerState();
}

class _FeedAdBannerState extends State<FeedAdBanner> {
  static const _androidTestUnitId = 'ca-app-pub-3940256099942544/9214589741';
  static const _androidProductionUnitId =
      'ca-app-pub-4110950503958596/2401217451';
  static const _slotHeight = 66.0;

  BannerAd? _bannerAd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    PrivacyConsent.instance.addListener(_requestAdIfAllowed);
    _requestAdIfAllowed();
  }

  Future<void> _requestAdIfAllowed() async {
    if (kIsWeb ||
        !Platform.isAndroid ||
        _isLoading ||
        _bannerAd != null ||
        !PrivacyConsent.instance.canRequestAds) {
      return;
    }
    setState(() => _isLoading = true);
    await MobileAds.instance.initialize();
    if (!mounted) return;

    // A standard banner has a predictable 50dp height. Adaptive banners can
    // reserve a much taller platform-view slot than their visible creative.
    final size = AdSize.banner;

    final ad = BannerAd(
      adUnitId: kReleaseMode ? _androidProductionUnitId : _androidTestUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          final banner = ad as BannerAd;
          if (!mounted) {
            banner.dispose();
            return;
          }
          setState(() {
            _bannerAd = banner;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _isLoading = false);
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    PrivacyConsent.instance.removeListener(_requestAdIfAllowed);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _bannerAd;
    // Reserve the final banner size as soon as an ad is requested. Without
    // this, the feed shifts down by 66px after AdMob responds and can look as
    // though content has slipped underneath the floating navigation bar.
    if (banner == null) {
      return _isLoading
          ? const SizedBox(height: _slotHeight)
          : const SizedBox.shrink();
    }

    return SizedBox(
      height: _slotHeight,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ),
      ),
    );
  }
}
