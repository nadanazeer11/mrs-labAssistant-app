import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mrs/authentication/screens/createU.dart';
import 'package:mrs/authentication/screens/forget_password.dart';
import 'package:mrs/authentication/screens/signup_screen.dart';
import 'package:mrs/createProject/screens/create_project.dart';
import 'package:mrs/home/screens/HP.dart';
import 'package:mrs/inventory/screens/AddItem.dart';

import 'package:mrs/projectDescription/Screens/fileScreen.dart';
import 'package:mrs/projectDescription/Screens/imgScree.dart';
import 'package:mrs/projectDescription/Screens/project_description.dart';
import 'package:mrs/splash_screen.dart';
import 'package:mrs/user_state.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  debugPrint('Handling a background message ${message.messageId}');
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    //  home:Login(),
      routes:{
        // '/':(context)=>Inventory5()
        '/':(context)=>SplashScreen(),
        '/userState':(context)=>  UserState(),
        '/signUp':(context)=>const SignupScreen(),
        '/forgetPassword':(context)=>ForgetPassword(),
        '/home':(context)=>HP(),
        '/addProject':(context)=>Create_Project(),
        '/projectDetails':(context)=>ProjDescrip(),
        '/createU':(context)=>CreateU(),
        '/fileScreen':(context)=>fileScreen(),
        '/imgScreen':(context)=>imgScreen(),
        '/addItem':(context)=>AddItem()
      }
    );
  }
}


