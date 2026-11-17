import 'package:local_auth/local_auth.dart';

abstract class BiometricService {
  Future<bool> authenticate();
}

class AuthenticationFailure implements Exception {
  const AuthenticationFailure(this.message);
  final String message;
}

class LocalBiometricService implements BiometricService {
  final _auth = LocalAuthentication();

  @override
  Future<bool> authenticate() async {
    try {
      if (!await _auth.canCheckBiometrics) {
        throw const AuthenticationFailure(
          'Biometria indisponível neste aparelho.',
        );
      }
      if ((await _auth.getAvailableBiometrics()).isEmpty) {
        throw const AuthenticationFailure(
          'Cadastre o Face ID ou Touch ID nas configurações do aparelho.',
        );
      }
      return await _auth.authenticate(
        localizedReason: 'Autentique-se para acessar suas notas privadas.',
        biometricOnly: true,
        persistAcrossBackgrounding: false,
      );
    } on LocalAuthException catch (error) {
      final message = switch (error.code) {
        LocalAuthExceptionCode.noBiometricHardware =>
          'Este aparelho não possui biometria disponível.',
        LocalAuthExceptionCode.noBiometricsEnrolled =>
          'Cadastre uma biometria nas configurações do aparelho.',
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout =>
          'Biometria bloqueada. Desbloqueie o aparelho e tente novamente.',
        _ => 'Não foi possível autenticar. Tente novamente.',
      };
      throw AuthenticationFailure(message);
    }
  }
}
