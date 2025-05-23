import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkombe_flutter/Authentication/pages/login.dart';
import 'package:inkombe_flutter/pages/scan_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inkombe_flutter/Authentication/pages/main_page.dart';
import 'firebase_options.dart';

List<CameraDescription>? cameras;
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inkombe',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:const MainPageRouter(),
    );

  }
}


