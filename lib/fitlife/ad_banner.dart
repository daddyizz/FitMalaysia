import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'privacy_consent.dart';

/// A single, low-interruption banner shown only at the end of the Home feed.
/// All development and profile builds use Google's test unit. Only release
/// Android builds use FitMalaysia's production banner unit.
class HomeAdBanner extends StatefulWidget {
  const HomeAdBanner({super.key});

  @override
  State<HomeAdBanner> createState() => _HomeAdBannerState();
}

class _HomeAdBannerState extends State<HomeAdBanner> {
  static const _androidTestUnitId = 'ca-app-pub-3940256099942544/9214589741';
  static const _androidProductionUnitId =
      'ca-app-pub-4110950503958596/2401217451';

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
    _isLoading = true;
    await MobileAds.instance.initialize();
    if (!mounted) return;

    final width = (MediaQuery.sizeOf(context).width - 32).truncate();
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) {
      _isLoading = false;
      return;
    }

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
          _isLoading = false;
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
    if (banner == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        children: [
          Text(
            'ADVERTISEMENT',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .45),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ],
      ),
    );
  }
}
