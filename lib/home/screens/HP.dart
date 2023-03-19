import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:mrs/authentication/backend/authenticate.dart';
import 'package:mrs/config/colors.dart';
import 'package:mrs/home/backend/Home_Controller.dart';
import 'package:mrs/home/screens/OurProjects.dart';

import '../../common.dart';
import '../../config/text_styles.dart';
import '../widgets/project_item.dart';
import 'YourProjects.dart';

class HP extends StatefulWidget {
  const HP({Key? key}) : super(key: key);

  @override
  State<HP> createState() => _HPState();
}

class _HPState extends State<HP> {
  String ?errorPass;
  bool wrongpass=false;
  HomeContr hmc=new HomeContr();
  var _oldPassContr=TextEditingController();
  var _newPassContr=TextEditingController();
  Authenticate authenticate=Authenticate();
  final changeP=GlobalKey<FormState>();
  Future<bool> _submitChangeP()async{
    final isValid=changeP.currentState!.validate();
    if(isValid){
      String currentPassword=_oldPassContr.text;
      String newPassword=_newPassContr.text;
      try{
        FirebaseAuthException? res=await authenticate.changePassword(currentPassword, newPassword, loggedInId);
        if(res!=null){
          if(res.code=='wrong-password'){
            showPlatformDialog(
              context: context,
              builder: (context) => BasicDialogAlert(
                title: Text("Authentication Error"),
                content:
                Text("Wrong old password entered"),
                actions: <Widget>[
                  BasicDialogAction(
                    title: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
          else{
            debugPrint("in else");
            showPlatformDialog(
              context: context,
              builder: (context) => BasicDialogAlert(
                title: Text("Authentication Error"),
                content:
                Text("${res.code}"),
                actions: <Widget>[
                  BasicDialogAction(
                    title: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          }
          return false;
        }
        else{
          debugPrint("no erro");
          setState(() {
            errorPass=null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password Successfully changed'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      }
      catch(e){
        debugPrint("in catchhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred.Please try again!s'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }


    }
    else{
      debugPrint("this else whuch means not valid");
      return false;
    }
  }
  bool ?createP;
  bool ?createU;
  String? loggedInId;
  static final List <Widget> widgetOptions=<Widget>[
    OurProjects(),
  ];
  int indexx=0;
  void onItemTapped(int index){
    setState((){
      indexx=index;
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return
      Scaffold(
      appBar:
      AppBar(
        backgroundColor:AppColorss.lightmainColor ,
        elevation: 0,
        title:Text("MRS",style:subHeadingStyle) ,
        actions: [
          IconButton(onPressed: (){

          }, icon:Icon(Icons.filter_list_outlined))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            widgetOptions[indexx],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: onItemTapped,
      currentIndex: indexx,
      elevation:10,
      selectedItemColor: Colors.blueGrey,
      unselectedItemColor: const Color(0xFF526480),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(icon: Icon(FluentSystemIcons.ic_fluent_home_regular),
          activeIcon: Icon(FluentSystemIcons.ic_fluent_home_filled),label: "home",),
        BottomNavigationBarItem(icon: Icon(FluentSystemIcons.ic_fluent_search_regular),
            activeIcon: Icon(FluentSystemIcons.ic_fluent_search_filled),label: "search"),
        BottomNavigationBarItem(icon: Icon(FluentSystemIcons.ic_fluent_ticket_regular),
            activeIcon: Icon(FluentSystemIcons.ic_fluent_ticket_filled),label: "ticket"),
        BottomNavigationBarItem(icon: Icon(FluentSystemIcons.ic_fluent_person_regular),
            activeIcon: Icon(FluentSystemIcons.ic_fluent_person_filled),label: "person")
      ],
    ),
      drawer: Drawer(
        child:  Column(
          children: [
            Expanded(
              child: Container(
                color: AppColorss.darkmainColor,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        //color: Colors.blue,
                      ),
                      child: Text('Drawer Header'),
                    ),
                    createU==true?ListTile(
                      title:const Text('Create User',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w400,color:Colors.white),),
                      leading: Icon(FeatherIcons.user,color: Colors.white,size: 30,),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/createU');
                      },
                    ):Container(),
                    Divider(
                      height: 4,
                      color: Colors.black,
                    ),
                    createP==true?ListTile(
                      title:const Text('Create Project',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w400,color:Colors.white),),
                      leading: Icon(FeatherIcons.folder,color: Colors.white,size: 30,),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/addProject');
                      },
                    ):Container(),
                    Divider(
                      height: 4,
                      color: Colors.black,
                    ),

                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                tileColor: AppColorss.darkmainColor,
                title:const Text('Change Password',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w400,color:Colors.white),),
                leading: Icon(Icons.password,color: Colors.white,size: 30,),
                onTap: () {
                  Navigator.pop(context);
                  showPlatformDialog(
                    context: context,
                    builder: (c) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return BasicDialogAlert(
                          title: Column(
                            children: [
                              Text("Change Password"),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Form(
                              key: changeP,
                              child: Column(
                                children: [
                                  FractionallySizedBox(
                                    widthFactor: 0.8,
                                    child: TextFormField(
                                        controller: _oldPassContr,
                                        decoration: InputDecoration(
                                          labelText: 'Current Password',
                                          hintText: 'Enter Your current password',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Enter your old password";
                                          }
                                          return null;
                                        }),
                                  ),
                                  SizedBox(
                                    height: 14,
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: 0.8,
                                    child: TextFormField(
                                        controller: _newPassContr,
                                        decoration: InputDecoration(
                                          labelText: 'New Password',
                                          hintText: 'Enter Your New Password',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty || value!.length < 6) {
                                            return "Password should be at least 6 characters";
                                          }
                                          return null;
                                        }),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            BasicDialogAction(
                              title: Text(
                                "Yes",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () async {
                                bool x = await _submitChangeP();
                                if (x == true) {
                                  Navigator.pop(context);
                                  _oldPassContr.clear();
                                  _newPassContr.clear();
                                } else {

                                }
                              },
                            ),
                            BasicDialogAction(
                              title: Text(
                                "No",
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _oldPassContr.clear();
                                _newPassContr.clear();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  );

                },
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                tileColor: AppColorss.darkmainColor,
                title:const Text('Log Out',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w400,color:Colors.white),),
                leading: Icon(FeatherIcons.logOut,color: Colors.white,size: 30,),
                onTap: () {
                  Navigator.pop(context);
                  showPlatformDialog(
                    context: context,
                    builder: (c) => BasicDialogAlert(
                      title: Text("Log Out"),
                      content:
                      Text("Are you sure you want to log out?"),
                      actions: <Widget>[
                        BasicDialogAction(
                          title: Text("Yes",style: TextStyle(color: Colors.black),),
                          onPressed: () async {
                             await authenticate.logoutMethod();
                            debugPrint("logout");
                            Navigator.popAndPushNamed(context, '/');
                            //Navigator.pop(c);
                          },
                        ),
                        BasicDialogAction(
                          title: Text("No",style: TextStyle(color: Colors.black),),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),

                      ],
                    ),
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void show(){
    showPlatformDialog(
      context: context,
      builder: (c) => BasicDialogAlert(
        title: Column(
          children: [
            Text("Change Password"),
          ],
        ),
        content:SingleChildScrollView(
          child: Form(
            key:changeP,
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: TextFormField(
                      controller: _oldPassContr,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter Users Email',
                        border: OutlineInputBorder(
                        ),
                      ),
                      validator:(value) {
                        if (value!.isEmpty) {
                          return "Enter your old password";
                        }
                        return null;
                      }),
                ),
                SizedBox(height: 14,),
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: TextFormField(
                      controller: _newPassContr,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter Your New Password',
                        border: OutlineInputBorder(

                        ),
                      ),
                      validator:(value) {
                        if (value!.isEmpty || value!.length<6) {
                          return "Password should be at least 6 characters";
                        }
                        return null;
                      }),
                ),
                SizedBox(height: 5,),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          BasicDialogAction(
            title: Text("Yes",style: TextStyle(color: Colors.black),),
            onPressed: () async {
              bool x=await _submitChangeP();
              if(x==true){
                Navigator.pop(context);
              }
              //Navigator.pop(c);
            },
          ),
          BasicDialogAction(
            title: Text("No",style: TextStyle(color: Colors.black),),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _loadData();

  }
  void _loadData()async{
    await _getLoggedInId();
    await _createP();
    await _createU();
  }
  Future<void> _getLoggedInId() async{
    try {
      String x=await getIdofUser();
      debugPrint("ana f your projects $x ");
      debugPrint("logged in id $x");
      setState(() {
        loggedInId=x;
      });

    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.Please try again!s'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _createP()async{
    try{
      bool x=await hmc.isCreateP(loggedInId);
      setState(() {
        createP=x;
      });
      debugPrint("f$createP");
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.Please try again!s'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _createU()async{
    try{
      bool x=await hmc.isCreateU(loggedInId);
      setState(() {
        createU=x;
      });
      debugPrint("f$createU");
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.Please try again!s'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
