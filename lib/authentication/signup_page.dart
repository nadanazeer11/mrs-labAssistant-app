import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs/colors.dart';
import 'package:mrs/consts/consts.dart';
import 'package:mrs/main.dart';
import 'package:mrs/screens/home_page.dart';
import 'package:mrs/widgets/big_text.dart';
import 'package:mrs/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:mrs/controllers/auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var controller=Get.put(AuthController());
  //text controllers
  var nameController=TextEditingController();
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  bool _allFieldsEntered = false;

  void _checkFieldsEntered() {
    if (nameController.text.isNotEmpty &&
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
    nameController.addListener(_checkFieldsEntered);
    emailController.addListener(_checkFieldsEntered);
    passwordController.addListener(_checkFieldsEntered);
  }
  void dispose() {
    nameController.dispose();
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
        body:SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width:w,
                height:h*0.25,
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
                    Big_text(text: "Join Us",size: 40,color: AppColorss.darkmainColor,),
                    SmallText(text: "Create Your Account",color: Colors.grey,size: 22,),
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
                            hintText: "Email",
                            prefixIcon: Icon(Icons.email,color: AppColorss.darkmainColor,),
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
                          controller: nameController),
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
                          controller: passwordController
                      ),
                    ),
                    SizedBox(height: 18,)
                  ],
                ),
              ),
              SizedBox(height: 18),
              ElevatedButton(
                  onPressed: _allFieldsEntered ? ()async {
                    try{
                      bool unique = await controller.isUsernameUnique(nameController.text);
                      if(unique){
                        await controller.signupMethod(context: context,
                            email: emailController.text,
                            password: passwordController.text).then((value){
                          return controller.storeUserData(
                              email: emailController.text,
                              password: passwordController.text,
                              name: nameController.text
                          ).then((value){
                            Get.offAll(()=>MainHome());
                          });
                        });
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('This username already exists'),
                          ),
                        );
                      }
                    }
                    catch(e){
                      auth.signOut();
                      VxToast.show(context, msg: "Error Occured ,Please try again");
                    }
                  } :
                  (){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fill out all fields'),
                      ),
                    );
                  },
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                    backgroundColor:_allFieldsEntered? Color(0xFF005466):Colors.grey,
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
                  Text("Already Have An Account?",
                      style:TextStyle(
                          color:Colors.grey[500],
                          fontSize:20
                      )),
                  TextButton(onPressed: (){
                    Get.back();
                  }, child: Text( "Log in",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      )
                  )
                  )]),
              ),



            ],

          ),
        )
    );
  }
}



