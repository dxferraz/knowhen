import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  Future<void> signInUserAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
