import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkombe_flutter/Authentication/pages/login.dart';
import 'package:inkombe_flutter/pages/scan_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inkombe_flutter/Authentication/pages/main_page.dart';
import 'package:inkombe_flutter/pages/splash_screen.dart';
import 'package:inkombe_flutter/services/cattle_repository.dart';
import 'package:inkombe_flutter/services/cattle_sync_service.dart';
import 'package:inkombe_flutter/services/network_service.dart';
import 'firebase_options.dart';

List<CameraDescription>? cameras;
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await CattleRepository.init();

  // Start listening to network changes for automatic sync
  NetworkService.onNetworkStatusChange.listen((isOnline) {
    if (isOnline) {
      print('Device came online - triggering sync');
      CattleSyncService.processSyncQueue();
    } else {
      print('Device went offline - working locally');
    }
  });

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
      home:const SplashScreen(),
    );

  }
}


