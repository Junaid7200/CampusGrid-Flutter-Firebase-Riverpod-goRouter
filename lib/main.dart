import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/core/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CampusGridApp());
}










/*
WidgetsFlutterBinding.ensureInitialized() Explained

Flutter has TWO parts:

Your Dart code (business logic, UI)
Native platform channels (communication with Android/iOS APIs)
What the binding does:

Creates the communication bridge between Dart and native code
Normally, runApp() does this automatically
But when you do async stuff before runApp(), the bridge isn't ready yet
Why you need it:

Firebase needs to talk to native Android/iOS code to initialize
Without the binding initialized, Firebase can't communicate with the platform
This line says: "Set up the bridge NOW, before I run async code"
Analogy: It's like making sure your phone's Bluetooth is turned on before trying to connect to a device. The binding is the "Bluetooth radio" that needs to be on for Dart and native code to communicate.


*/