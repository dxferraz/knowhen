import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  Future<void> signInUserAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      debugPrint("Signed in with temporary account. UID: ${userCredential.user!.uid}");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}

class StorageService {
  Future<File?> downloadImage(String year, String month) async {
    try {
      final storageRef = FirebaseStorage.instance.ref("/historical_facts/$year");
      final downloadRef = storageRef.child('$month.webp');
      final downloadUrl = await downloadRef.getDownloadURL();
      return File.fromUri(Uri.parse(downloadUrl));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return null;
    }
  }
}
