import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:knowhen/core/l10n/generated/app_localizations.dart';

/// Shows a short message to the user. Replaceable so tests don't need the toast plugin.
typedef ToastShower = void Function(String message);

void _defaultShowToast(String message) {
  Fluttertoast.showToast(msg: message);
}

class AuthService {
  /// [l10n] defaults to Portuguese, the only language the app ships: this runs from `main()`, before any
  /// `BuildContext` exists.
  AuthService({FirebaseAuth? auth, ToastShower showToast = _defaultShowToast, AppLocalizations? l10n})
      : _auth = auth,
        _showToast = showToast,
        _l10n = l10n ?? lookupAppLocalizations(const Locale('pt'));

  final FirebaseAuth? _auth;
  final ToastShower _showToast;
  final AppLocalizations _l10n;

  /// A sign-in failure is shown as a friendly message; the technical error only goes to the debug log.
  Future<void> signInUserAnonymously() async {
    try {
      await (_auth ?? FirebaseAuth.instance).signInAnonymously();
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      _showToast(_l10n.authSignInError);
    }
  }
}
