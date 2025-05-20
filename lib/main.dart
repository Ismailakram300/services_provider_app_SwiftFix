
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:serviceapp/MobileScreens/extra.dart';
import 'package:serviceapp/MobileScreens/login.dart';
import 'package:serviceapp/MobileScreens/offers.dart';
import 'package:serviceapp/MobileScreens/splash_screen.dart';
import 'MobileScreens/Worker_Screens/show_request_details.dart';
import 'firebase_options.dart';

void main() async {


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Servizo',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white,),
          useMaterial3: true,
        ),
        home:  SplashScreen());
       // home: ShowRequest());



    //  home: login_w());
  }
  }


