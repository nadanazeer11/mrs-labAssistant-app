import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrs/config/colors.dart';

import '../backend/authenticate.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Authenticate authenticate=Authenticate();
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  bool _obsecureText=true;
  final _formLogin=GlobalKey<FormState>();
  bool _loading=false;
  String errorMessage="";
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _isMounted = false;
    super.dispose();
  }
  void _submitLogin()async{
    final isValid=_formLogin.currentState!.validate();
    int error=-100;
    FirebaseAuthException? res;
    if(isValid){
      if (_isMounted) {
        setState(() {
          _loading = true;
        });
        try {
          res = await authenticate.loginMethod(
              emailController.text.trim().toLowerCase(),
              passwordController.text.trim());
          if (res != null) {
            if (res.code == 'invalid-email') {
              setState(() {
                _loading = false;
                errorMessage = "Invalid Email";
              });
            }
            else if (res.code == "user-not-found") {
              setState(() {
                _loading = false;
                errorMessage = "User not found";
              });
            }
            else if (res.code == "wrong-password") {
              setState(() {
                _loading = false;
                errorMessage = "Wrong Password";
              });
            }
            else {
              setState(() {
                _loading = false;
                errorMessage = "Error in connection,please try again";
              });
            }
          }
          else {
            setState(() {
              _loading = false;
              errorMessage = "";
            });
            try{
              await authenticate.checkToken(emailController.text.trim().toLowerCase());

            }
            catch(e){
              setState(() {
                _loading = false;
                errorMessage = "Error loading token of device,please try again";
              });

            }
            Navigator.popAndPushNamed(context, '/home');
          }
        }
        catch (e) {
          setState(() {
            _loading = false;
            errorMessage = "Error in connection,please try again";
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key:_formLogin,
          child: Column(
            children: [
              Container(
                width: w,
                height: h * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/mrsrb.png"),
                    // fit:BoxFit.fill
                  ),
                ),
              ),
              Container(
                  width: w,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( "Welcome Back",style: TextStyle(fontSize: 40,color: AppColorss.darkmainColor)),
                      Text("Sign in to Your Account",style: TextStyle(fontSize: 20,color: Colors.grey)),
                      SizedBox(height: 8,),
                      Center(child:Text(errorMessage,style: TextStyle(color:Colors.red,fontSize: 19),),),
                      SizedBox(height: 27,),
                      Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10,
                                  offset: Offset(1, 1),
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 7
                              )
                            ],

                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                              controller:emailController,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(new RegExp(r"\s"))
                              ],
                            decoration:InputDecoration(
                                hintText: "Email",
                                prefixIcon: Icon(
                                    Icons.email,color: AppColorss.darkmainColor),
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
                                ),
                                errorBorder:UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)
                                )

                            ),
                            validator:(value){
                              if(value!.isEmpty || !value.contains("@")){
                                return "Please enter a valid Email address";
                              }
                              else{
                                return null;
                              }

                            }
                          )
                      ),
                      SizedBox(height: 30,),
                      Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10,
                                  offset: Offset(1, 1),
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 7
                              )
                            ],

                          ),
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(new RegExp(r"\s"))
                            ],
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _obsecureText,
                            controller:passwordController,
                              validator:(value){
                                if(value!.isEmpty){
                                  return "Please enter a password";
                                }
                                else{
                                  return null;
                                }

                              },
                            decoration:InputDecoration(
                                suffix: GestureDetector(onTap: (){
                                  setState(() {
                                    _obsecureText=!_obsecureText;
                                  });
                                },child: Icon(_obsecureText?  Icons.visibility: Icons.visibility_off,color: AppColorss.darkmainColor),),
                                hintText: "Password",
                                prefixIcon: Icon(
                                    Icons.password,color: AppColorss.darkmainColor),
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
                          )
                      ),
                    ],
                  )
              ),
              SizedBox(height: 18),
              ElevatedButton(onPressed: (){ _submitLogin();}, child:
              _loading ?CircularProgressIndicator(): Text('Log In'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Color(0xFF005466),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: Size(170, 40)
                  )),
              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}
