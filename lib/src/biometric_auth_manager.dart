import 'package:flutter/material.dart';
import 'biometric_service.dart';
import 'pin_auth_service.dart';
import 'widgets/pin_input_view.dart';

enum AuthResult { success, failure, pinFallback, canceled }

class BiometricAuthManager {
  final BiometricService _biometricService;
  final PinAuthService _pinAuthService;

  BiometricAuthManager({
    BiometricService? biometricService,
    PinAuthService? pinAuthService,
  })  : _biometricService = biometricService ?? BiometricService(),
        _pinAuthService = pinAuthService ?? PinAuthService();

  Future<AuthResult> authenticate(
    BuildContext context, {
    required String localizedReason,
    bool usePinFallback = true,
    String? pinDescription,
    bool forceFingerprint = false,
    bool forceFace = false,
  }) async {
    final isBiometricAvailable = await _biometricService.isAvailable();

    if (isBiometricAvailable) {
      // Determine what to show in the hint
      String? title;
      if (forceFingerprint) title = 'Fingerprint Authentication';
      if (forceFace) title = 'Face Authentication';

      final success = await _biometricService.authenticate(
        localizedReason: localizedReason,
        signInTitle: title,
        biometricOnly: true,
        forceFingerprint: forceFingerprint,
        forceFace: forceFace,
      );

      if (success) {
        return AuthResult.success;
      }
    }

    if (usePinFallback && await _pinAuthService.isPinSet()) {
      if (!context.mounted) return AuthResult.failure;
      final pinSuccess = await _showPinOverlay(context, description: pinDescription);
      return pinSuccess ? AuthResult.success : AuthResult.failure;
    }

    return AuthResult.failure;
  }

  Future<bool> _showPinOverlay(BuildContext context, {String? description}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => PinInputView(
          onVerified: (pin) async {
            return await _pinAuthService.verifyPin(pin);
          },
          description: description ?? 'Enter PIN to continue',
        ),
      ),
    );
    return result ?? false;
  }
}
