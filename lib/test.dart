// import 'package:mrs/authentication/login_page.dart';
// import 'package:mrs/authentication/signup_page.dart';
// import 'package:mrs/authentication/newLogin.dart';
// import 'package:mrs/colors.dart';
// import 'package:mrs/dimensions.dart';
// import 'package:mrs/screens/create_project.dart';
// import 'package:mrs/screens/homeP.dart';
// import 'package:mrs/screens/project_descrip.dart';
// import 'package:mrs/screens/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'consts/consts.dart';
// import 'controllers/homeP_controller.dart';
//
// class X extends StatefulWidget {
//   const X({Key? key}) : super(key: key);
//
//   @override
//   State<X> createState() => _XState();
// }
//
// class _XState extends State<X> {
//   @override
//   var nameController=TextEditingController();
//   var emailController=TextEditingController();
//   var passwordController=TextEditingController();
//   var controller=Get.put((HomePcontroller));
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           TextField(
//             controller: nameController,
//           ),
//           TextField(
//             controller: emailController,
//           ),
//           TextField(
//             controller: passwordController,
//           ),
//           ElevatedButton(onPressed: controller.s(title:nameController.text,genre:emailController.text), child: Text("j"))
//
//         ],
//       ),
//     );
//   }
// }
//
