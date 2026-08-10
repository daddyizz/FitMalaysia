import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Coordinates Google's User Messaging Platform consent flow for mobile ads.
class PrivacyConsent extends ChangeNotifier {
  PrivacyConsent._();

  static final instance = PrivacyConsent._();

  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;
  Future<void>? _gathering;

  bool get canRequestAds => _canRequestAds;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  /// Updates consent at every launch and presents Google's form only when needed.
  Future<void> gather() => _gathering ??= _gatherConsent();

  Future<void> _gatherConsent() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    final completed = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((_) async {
          await _refreshState();
          if (!completed.isCompleted) completed.complete();
        });
      },
      (_) async {
        await _refreshState();
        if (!completed.isCompleted) completed.complete();
      },
    );
    await completed.future;
  }

  Future<void> showPrivacyOptions() async {
    if (!_privacyOptionsRequired) return;

    final completed = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((_) async {
      await _refreshState();
      if (!completed.isCompleted) completed.complete();
    });
    await completed.future;
  }

  Future<void> _refreshState() async {
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    _privacyOptionsRequired =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
            PrivacyOptionsRequirementStatus.required;
    notifyListeners();
  }
}
