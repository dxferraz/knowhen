import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowhen/core/services/firebase_service.dart';

import '../../helpers/pump_app.dart';

class _FakeUserCredential extends Fake implements UserCredential {}

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  _FakeFirebaseAuth({this.error});

  final Object? error;
  int signInCalls = 0;

  @override
  Future<UserCredential> signInAnonymously() async {
    signInCalls++;
    final error = this.error;
    if (error != null) throw error;
    return _FakeUserCredential();
  }
}

void main() {
  test('entra de forma anônima e não mostra mensagem', () async {
    final auth = _FakeFirebaseAuth();
    final toasts = <String>[];

    await AuthService(auth: auth, showToast: toasts.add).signInUserAnonymously();

    expect(auth.signInCalls, 1);
    expect(toasts, isEmpty);
  });

  test('quando o login falha, mostra a mensagem amigável e não o erro técnico', () async {
    final auth = _FakeFirebaseAuth(error: FirebaseAuthException(code: 'network-request-failed', message: 'raw: xyz'));
    final toasts = <String>[];

    await AuthService(auth: auth, showToast: toasts.add).signInUserAnonymously();

    expect(toasts, [l10n.authSignInError]);
    expect(toasts.single, isNot(contains('network-request-failed')));
    expect(toasts.single, isNot(contains('raw: xyz')));
  });
}
