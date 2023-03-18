import 'package:flutter/material.dart';
import 'package:mrs/config/colors.dart';
import 'package:mrs/models/Users.dart';
import 'package:mrs/authentication/backend/authenticate.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Authenticate authenticate=Authenticate();
  var emailController=TextEditingController();
  var passwordController=TextEditingController();
  var usernameController=TextEditingController();
  bool _obsecureText=true;
  bool _loading=false;
  final _formSignup=GlobalKey<FormState>();
  String errorMessage="";
  void dispose() {
     emailController.dispose();
     passwordController.dispose();
     usernameController.dispose();
     super.dispose();
   }
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    void _submitSignUp()async{
      debugPrint("f");
      final isValid=_formSignup.currentState!.validate();
      if(isValid){
        bool username;
        bool email;
        bool result;
        setState(() {
          _loading=true;
        });
        Userr user=new Userr(name:usernameController.text,email: emailController.text,password:passwordController.text,projects: [],tasks: [],createP:false,addU:true);
        try{
          email=await authenticate.emailCheck(user.email);
          if(!email){
            try{
              username=await authenticate.userNameCheck(user.name);
              if(!username){
                try{
                  setState(() {
                    _loading=false;
                  });
                   result=await authenticate.signupMethod(user);
                   if(result){
                     Navigator.popAndPushNamed(context, '/home');
                     setState(() {
                       _loading=false;
                       errorMessage="";
                     });
                   }
                   else{
                     setState(() {
                       _loading=false;
                       errorMessage="Please try again1";
                     });
                   }
                }
                catch(e){
                  setState(() {
                    _loading=false;
                    errorMessage="Please try again2";
                  });
                }
              }
              else{
                setState(() {
                  _loading=false;
                  errorMessage="Username already taken";
                });
              }
            }
            catch(e){
              setState(() {
                _loading=false;
                errorMessage="Please try again3";
              });
            }
          }
          else{
            setState(() {
              _loading=false;
              errorMessage="Email already in use";
            });
          }
        }
        catch(e){
          setState(() {
            _loading=false;
            errorMessage="Please try again4";
          });
        }


      }
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key:_formSignup,
          child: Column(
            children: [
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
              Container(
                  width: w,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( "Join Us",style: TextStyle(fontSize: 40,color: AppColorss.darkmainColor)),
                    Text("Create Your Account",style: TextStyle(fontSize: 20,color: Colors.grey)),
                    SizedBox(height: 15,),
                    Center(child:Text(errorMessage,style: TextStyle(color:Colors.red,fontSize: 19),),),
                    SizedBox(height: 35,),
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
                          controller:usernameController,
                          validator:(value){
                            if(value!.isEmpty){
                              return "Please enter a valid name";
                            }
                            else{
                              return null;
                            }

                          },
                          decoration:InputDecoration(
                              hintText: "UserName",
                              prefixIcon: Icon(
                                  Icons.person,color: AppColorss.darkmainColor),
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
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _obsecureText,
                          controller:passwordController,
                          validator:(value){
                            if(value!.isEmpty || value.length<7){
                              return "Password should be at least 7 characters";
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
                              ),
                              errorBorder:UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)
                              )
                          ),
                        )
                    ),

              ],
                )
              ),
              SizedBox(height: 22),
              _loading ? Container(child: Center(child: CircularProgressIndicator(),),):ElevatedButton(onPressed: (){
                _submitSignUp();
              }, child:  Text('Sign Up'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Color(0xFF005466),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: Size(170, 40)
                  )),
              SizedBox(height: 10,),
              Padding(
                  padding:const EdgeInsets.fromLTRB(68, 0, 0, 0),
                  child: Row(
                    children: [
                      Text("Already Have An Account?",
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 20
                          )),
                      TextButton(onPressed: () {
                        Navigator.popAndPushNamed(context,'/');}, child: Text("Log in",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          )
                      )
                      )
                    ],
                  ),

              )
            ],
          ),
        ),
      ),
    );
  }
}
