import 'package:mrs/applogoWidget.dart';
import 'package:flutter/material.dart';


import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mrs/user_state.dart';
import 'package:velocity_x/velocity_x.dart';


import 'config/colors.dart';
import 'home/backend/Home_Controller.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  HomeContr homeC=new HomeContr();

  changeScreen(){
    // Future.delayed(Duration(seconds: 1),(){
      Navigator.popAndPushNamed(context, '/userState');
    // });
  }
  @override
  void initState(){
    super.initState();
    _loadData();
  }
  void _loadData()async{
     await homeC.updateIsLate();
     changeScreen();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorss.darkmainColor,
      body: Center(
        child: Column(
          children: [
            Center(child: applogoWidget()),
            11.heightBox,
            Center(child: Text("Lab Assistant",style: TextStyle(fontSize: 26,color: Colors.white,fontWeight: FontWeight.bold),))
          ],
        ),
      ),
    );
  }
}
