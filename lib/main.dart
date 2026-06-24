import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:real_beauty_ai/app.dart';
import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/firebase_options.dart';
import 'package:real_beauty_ai/services/local_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  await LocalStore.instance.init();
  configureDependencies();
  runApp(const App());
}
