import 'package:mrs/widgets/applogo_widget.dart';
import 'package:flutter/material.dart';
import 'package:mrs/colors.dart';
import 'package:mrs/consts/consts.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../authentication/login_page.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  changeScreen(){
    Future.delayed(Duration(seconds: 4),(){
      Get.to(()=> const LoginPage());
    });
  }
  void initState(){
    changeScreen();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorss.darkmainColor,
      body: Center(
        child: Column(
          children: [
            Center(child: applogoWidget()),
            10.heightBox,
            Center(child: Text("Lab Assistant",style: TextStyle(fontSize: 26,color: Colors.white,fontWeight: FontWeight.bold),))
          ],
        ),
      ),
    );
  }
}
