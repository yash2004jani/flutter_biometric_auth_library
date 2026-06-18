import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  Future<BiometricType?> getPreferredBiometricType() async {
    final available = await getAvailableBiometrics();
    if (available.contains(BiometricType.face)) return BiometricType.face;
    if (available.contains(BiometricType.iris)) return BiometricType.iris;
    if (available.contains(BiometricType.fingerprint)) return BiometricType.fingerprint;
    if (available.contains(BiometricType.strong)) return BiometricType.strong;
    if (available.contains(BiometricType.weak)) return BiometricType.weak;
    return null;
  }

  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = true,
    String? signInTitle,
    String? cancelButton,
    bool forceFingerprint = false,
    bool forceFace = false,
  }) async {
    try {
      // Note: On Android, face unlock is often considered "weak" (Class 2).
      // Setting biometricOnly to false often allows these "weak" biometrics to be 
      // used in the system prompt.
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Changed to false to support "Weak" Face Unlock on Android
          useErrorDialogs: true,
        ),
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: signInTitle ?? 'Biometric Authentication',
            cancelButton: cancelButton ?? 'Cancel',
            biometricHint: forceFingerprint ? 'Use Fingerprint' : (forceFace ? 'Use Face Unlock' : null),
          ),
          IOSAuthMessages(
            cancelButton: cancelButton ?? 'Cancel',
          ),
        ],
      );
    } catch (e) {
      return false;
    }
  }
}
