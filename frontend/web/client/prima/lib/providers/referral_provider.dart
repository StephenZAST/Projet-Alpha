import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/referral_service.dart';

class ReferralProvider with ChangeNotifier {
  final ReferralService _referralService;
  String? _referralCode;
  bool _isLoading = false;
  String? _error;

  ReferralProvider(this._referralService);

  String? get referralCode => _referralCode;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReferralCode() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _referralCode = await _referralService.getReferralCode();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> shareReferralCode() async {
    if (_referralCode == null) return;

    await Share.share(
      'Utilisez mon code de parrainage pour Alpha : $_referralCode et gagnez des points de fidélité !',
      subject: 'Code de parrainage Alpha',
    );
  }
}
