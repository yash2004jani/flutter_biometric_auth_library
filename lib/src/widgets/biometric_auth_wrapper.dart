import 'package:flutter/material.dart';
import '../biometric_service.dart';

class BiometricAuthWrapper extends StatelessWidget {
  final Widget child;
  final Widget? biometricIndicator;
  final String localizedReason;
  final VoidCallback onAuthenticated;
  final Function(Object)? onError;
  final BiometricService? biometricService;

  const BiometricAuthWrapper({
    super.key,
    required this.child,
    required this.localizedReason,
    required this.onAuthenticated,
    this.biometricIndicator,
    this.onError,
    this.biometricService,
    this.useFaceIcon = false,
  });

  final bool useFaceIcon;

  Future<void> _authenticate() async {
    final service = biometricService ?? BiometricService();
    try {
      final success = await service.authenticate(
        localizedReason: localizedReason,
      );
      if (success) {
        onAuthenticated();
      }
    } catch (e) {
      onError?.call(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (biometricIndicator != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: _authenticate,
              child: biometricIndicator,
            ),
          )
        else
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _authenticate,
                child: Icon(useFaceIcon ? Icons.face : Icons.fingerprint),
              ),
            ),
          ),
      ],
    );
  }
}
