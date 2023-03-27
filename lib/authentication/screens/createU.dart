import 'package:flutter/material.dart';

import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../models/Users.dart';
import '../backend/authenticate.dart';

class CreateU extends StatefulWidget {
  const CreateU({Key? key}) : super(key: key);

  @override
  State<CreateU> createState() => _CreateUState();
}

class _CreateUState extends State<CreateU> {
  Authenticate authenticate=Authenticate();
  bool CreateU=false;
  bool CreateP=false;
  final _formU=GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _loading=false;
  bool emailTaken=false;
  bool userNameTaken=false;
  bool inventoryM=false;
  void _submitSignUp()async{
    debugPrint("f");
    final isValid=_formU.currentState!.validate();
    if(isValid){
      bool username;
      bool email;
      bool result;
      Userr user=new Userr(name:_usernameController.text,
          email: _emailController.text,
          password:_passwordController.text,
          projects: [],tasks: [],createP:CreateP,
          addU:CreateU,inventoryM: inventoryM);
      try{
        debugPrint("in try");
        setState(() {
          _loading=true;
        });
        email=await authenticate.emailCheck(_emailController.text);
        username=await authenticate.userNameCheck(_usernameController.text);
        if(email){
          debugPrint("email taken");
          setState(() {
            emailTaken=true;
            _loading=false;
          });
        }
        else{
          debugPrint("email doesnt exist");
          setState(() {
            emailTaken=false;
            _loading=false;
          });
          if(!username){
            setState(() {
              userNameTaken=false;
              _loading=false;
            });
            try{
              debugPrint("passed all tests");
              result=await authenticate.signupMethod(user);
              debugPrint("passed but couldnt create");
              if(result){
                setState(() {
                  _loading=false;
                  CreateU=false;
                  CreateP=false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User Successfully created!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                _usernameController.clear();
                _emailController.clear();
                _passwordController.clear();
              }
              else{
                setState(() {
                  _loading=false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error in creating user'),
                                  backgroundColor: Colors.red,
                                ),
                              );
              }
            }
            catch(e){
              setState(() {
                _loading=false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error in creating user!'),
                  backgroundColor: Colors.red,
                ),
              );
            }

          }
        }
        if(username){
          setState(() {
            _loading=false;
          });
          setState(() {
            userNameTaken=true;
          });
        }

      }
      catch(e){
        setState(() {
          _loading=false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error in creating user,please try again'),
            backgroundColor: Colors.red,
          ),
        );
      }

    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor:AppColorss.lightmainColor ,
        elevation: 0,
        title:Text("MRS",style:subHeadingStyle) ,
        actions: [
          IconButton(onPressed: (){}, icon:Icon(Icons.filter_list_outlined))
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formU,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0,28,0,0),
            child: Column(
              children: [
                Text("Create User",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                const SizedBox(height: 35,),
                FractionallySizedBox(
                widthFactor: 0.8,
                child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter Users Email',
                  border: OutlineInputBorder(

                  ),
                ),
                    validator:(value) {
                      if (value!.isEmpty || !value.contains("@")) {
                        return "Please enter a valid Email address";
                      }
                        return null;
                    }),
            ),
                emailTaken==true?Text("*Email is taken",style: TextStyle(color: Colors.red),):Container(),

                const SizedBox(height: 35,),
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'UserName',
                      hintText: 'Enter Users UserName',
                      border: OutlineInputBorder(
                      ),
                    ),
                      validator:(value) {
                        if (value!.isEmpty) {
                          return "Please enter a userName";
                        }
                          return null;
                      }
                  ),

                ),
                userNameTaken==true?Text("*Username is taken",style: TextStyle(color: Colors.red),):Container(),

                const SizedBox(height: 35,),
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Users Password',
                      border: OutlineInputBorder(
                      ),
                    ),
                  validator: (value){
                      if(value!.isEmpty || value.length<6){
                        return "Password should be at least 6 characters";
                      }
                      return null;
                  },
                  ),
                ),
                const SizedBox(height:30),
                Text("Privelages",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w400),),
                SwitchListTile(
                  title:const Text("Create Projects",style: TextStyle(fontSize: 20,color: Color.fromRGBO(62, 68, 71, 1)),),
                  onChanged: (bool value){
                    setState(() {
                      CreateP=value;
                    });},
                  value: CreateP,
                  activeColor: AppColorss.darkmainColor,
                ),
                const SizedBox(height: 10,),
                SwitchListTile(
                  title:const Text("Create Users",style: TextStyle(fontSize: 20,color: Color.fromRGBO(62, 68, 71, 1)),),
                  onChanged: (bool value){
                    setState(() {
                      CreateU=value;
                    });},
                  value: CreateU,
                  activeColor: AppColorss.darkmainColor,
                ),
                SwitchListTile(
                  title:const Text("Manage Inventory",style: TextStyle(fontSize: 20,color: Color.fromRGBO(62, 68, 71, 1)),),
                  onChanged: (bool value){
                    setState(() {
                      inventoryM=value;
                    });},
                  value: inventoryM,
                  activeColor: AppColorss.darkmainColor,
                ),
                const SizedBox(height: 10,),
                _loading ? Container(child: Center(child: CircularProgressIndicator(),),):
                ElevatedButton(onPressed: (){
                  _submitSignUp();
                }, child:  Text('Create User'),
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
          ),
        ),
      ),

    );
  }
}

