import 'package:mrs/authentication/signup_page.dart';
import 'package:mrs/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs/colors.dart';
import 'package:mrs/consts/consts.dart';
import 'package:mrs/main.dart';
import 'package:mrs/screens/home_page.dart';
import 'package:mrs/widgets/big_text.dart';
import 'package:mrs/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:mrs/controllers/auth_controller.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var controller=Get.put(AuthController());
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  bool _allFieldsEntered = false;

  void _checkFieldsEntered() {
    if (
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      setState(() {
        _allFieldsEntered = true;
      });
    } else {
      setState(() {
        _allFieldsEntered = false;
      });
    }
  }
  void initState() {
    super.initState();
    emailController.addListener(_checkFieldsEntered);
    passwordController.addListener(_checkFieldsEntered);
  }
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body:Column(
        children: [
          Container(
              width:w,
              height:h*0.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:AssetImage("assets/mrsrb.png"),


                   // fit:BoxFit.fill
                ),

              ),
          ),
          Container(
            width:w,
            margin: const EdgeInsets.only(left: 20,right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Big_text(text: "Welcome Back",size: 40,color: AppColorss.darkmainColor,),
                SmallText(text: "Sign in to your account",color: Colors.grey,size: 22,),
                SizedBox(height: 45,),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        offset: Offset(1,1),
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 7
                      )
                    ]
                  ),
                  child:
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Username",
                      prefixIcon: Icon(Icons.person,color: AppColorss.darkmainColor,),
                      focusedBorder: (OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 1.0
                        )
                      )),
                        enabledBorder: (OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0
                            )
                        )),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)
                      )
                    ),
                    controller: emailController,
                  ),
                ),
                SizedBox(height: 30,),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10,
                            offset: Offset(1,1),
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 7
                        )
                      ]
                  ),
                  child:
                  TextField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password_outlined,color: AppColorss.darkmainColor,),
                        hintText: "Password",
                        focusedBorder: (OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0
                            )
                        )),
                        enabledBorder: (OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white,
                                width: 1.0
                            )
                        )),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)
                        )
                    ),
                    controller: passwordController,
                  ),
                ),
                SizedBox(height: 18,),
                Row(
                  children: [
                    Expanded(child: Container()),
                  //  SmallText(text: "Forgot Your Password?",color: Colors.grey,size: 18,),
                    TextButton(onPressed: (){}, child:SmallText(text: "Forgot Your Password?",color: Colors.grey,size: 18,)
                    )
                  ],
                ),
        ],
            ),
          ),
          SizedBox(height: 18),
          ElevatedButton(
         onPressed:(){
           _allFieldsEntered ? ()async{
            await controller.loginMethod(context: context,email: emailController,password: passwordController).then((value){
              if(value!=null){
                Get.offAll(()=>MainHome());
              }else{
                Get.offAll(()=>LoginPage());
              }
            });
           }:(){
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Please fill all fields!'),
               ),
             );

           };
         },
            child: Text('LogIn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF005466),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
                minimumSize: Size(170, 40)
            ),
          ),
          SizedBox(height:10,),
          Padding(
            padding: const EdgeInsets.fromLTRB(68,0,0,0),
            child: Row(children: [
              Text("Don't Have an account?",
              style:TextStyle(
                    color:Colors.grey[500],
                    fontSize:20
                  )),
              TextButton(onPressed: (){
              Get.to(()=> const SignUpPage());
              }, child: Text( "Create",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                )
              )
              )]),
          ),



      ],

      )
    );
  }
}
