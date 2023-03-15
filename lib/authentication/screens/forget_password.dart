import 'package:flutter/material.dart';

import '../../config/colors.dart';

class ForgetPassword extends StatefulWidget {
   ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final  emailController=TextEditingController();


  final _formForgetPassword=GlobalKey<FormState>();

  void dispose() {
    emailController.dispose();

    super.dispose();
  }
  void _submitFP(){
    final isValid=_formForgetPassword.currentState!.validate();
  }
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key:_formForgetPassword ,
          child: Column(children: [
            Container(
              width: w,
              height: h * 0.25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/mrsrb.png"),
                  // fit:BoxFit.fill
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                Text("Forgot Password",style:  TextStyle(fontSize: 40,color: AppColorss.darkmainColor),),
                SizedBox(height: 45,)
                , Container(
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
                  SizedBox(height: 34,),
                  ElevatedButton(onPressed: (){
                    _submitFP();
                  }, child:  Text('Submit'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Color(0xFF005466),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize: Size(170, 40)
                      )),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
