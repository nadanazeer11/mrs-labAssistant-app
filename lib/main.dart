import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mrs/authentication/screens/createU.dart';
import 'package:mrs/authentication/screens/forget_password.dart';
import 'package:mrs/authentication/screens/signup_screen.dart';
import 'package:mrs/createProject/screens/create_project.dart';
import 'package:mrs/home/screens/HP.dart';
import 'package:mrs/projectDescription/Screens/fileScreen.dart';
import 'package:mrs/projectDescription/Screens/imgScree.dart';
import 'package:mrs/projectDescription/Screens/project_description.dart';
import 'package:mrs/user_state.dart';

import 'authentication/screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/':(context)=>  UserState(),
        '/signUp':(context)=>const SignupScreen(),
        '/forgetPassword':(context)=>ForgetPassword(),
        '/home':(context)=>HP(),
        '/addProject':(context)=>Create_Project(),
        '/projectDetails':(context)=>ProjDescrip(),
        '/createU':(context)=>CreateU(),
        '/fileScreen':(context)=>fileScreen(),
        '/imgScreen':(context)=>imgScreen()
      }
    );
  }
}


