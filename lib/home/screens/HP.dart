import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mrs/authentication/backend/authenticate.dart';
import 'package:mrs/config/colors.dart';
import 'package:mrs/home/backend/Home_Controller.dart';
import 'package:mrs/home/screens/OurProjects.dart';

import '../../common.dart';
import '../../config/text_styles.dart';
import '../../inventory/backend/inventContr.dart';
import '../../inventory/screens/inventory5.dart';
import 'package:http/http.dart' as http;


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
  bool _isMounted = false;
  InventContr invC=InventContr();
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
  bool ?inventoryM;
  String? loggedInId;
  bool isLoading = true;
  bool isTrue = false;
  String loggedInName = "";
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? token = " ";
  static final List <Widget> widgetOptions=<Widget>[
    OurProjects(),
    Inventory5()
  ];
  int indexx=0;
  void onItemTapped(int index){
    setState((){
      indexx=index;
      debugPrint("the index$index");
    });
  }
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token) {
              debugPrint("my token is $token");
          setState(() {
            token = token;
          });
        }
    );
  }
  void loadFCM() async {
    if (!kIsWeb) {
      channel =  AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // t
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

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
      // body: isLoading!=true && isTrue==true?SingleChildScrollView(
      //   child: widgetOptions[indexx],
      // ):isLoading==true?Center(
      //   child: CircularProgressIndicator(),
      // ):
      // Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       Container(
      //         width: w * 0.12,
      //         height: h * 0.12,
      //         decoration: BoxDecoration(
      //           image: DecorationImage(
      //             image: AssetImage("assets/warning.png"),
      //             // fit:BoxFit.fill
      //           ),
      //         ),
      //       ),
      //       Text("An unexpected error occured", style: TextStyle(fontSize: 20)),
      //       Text(
      //         "in getting user data.",
      //         style: TextStyle(fontSize: 20),
      //       ),
      //       Text(
      //         "please try logging out!",
      //         style: TextStyle(fontSize: 20),
      //       )
      //     ],
      //   ),
      // ),
      body:ElevatedButton( onPressed: (){
        sendPushMessage();
      }, child: Text("Send notification"),),
      floatingActionButton:isLoading!=true&& isTrue==true?inventoryM==true&& indexx==1? FloatingActionButton.extended(onPressed: () {
        Navigator.pushNamed(context, '/addItem');
      },
        elevation: 10,
        hoverElevation: 20,
        backgroundColor: AppColorss.lightmainColor,
        label:Text("Add"),
        icon: Icon(Icons.add,color: Colors.white,),

      ):null : null,
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
        BottomNavigationBarItem(icon: Icon(FluentSystemIcons.ic_fluent_toolbox_regular),
          activeIcon: Icon(FluentSystemIcons.ic_fluent_toolbox_filled),label: "tools",),

      ],
    ),
     drawer: Drawer(
        child:  Column(
          children: [
            // Text("id ${loggedInId}"),
            Expanded(
              child: Container(
                // color: AppColorss.darkmainColor,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                     DrawerHeader(
                      decoration: BoxDecoration(
                        //color: Colors.blue,
                      ),
                      child:     Container(
                        width: w,
                        height: h * 0.3,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/mrsrb.png"),
                            // fit:BoxFit.fill
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 4,
                      color: Colors.black,
                    ),
                    ListTile (
                      title: Text('$loggedInName',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w400,color:Colors.black),),
                      leading: Icon(Icons.alternate_email,color: Colors.black,size: 30,),

                    ),
                    Divider(
                      height: 4,
                      color: Colors.black,
                    ),
                    isLoading!=true&& isTrue==true? createU==true?ListTile(
                      title:const Text('Create User',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w400,color:Colors.black),),
                      leading: Icon(FeatherIcons.user,color: Colors.black,size: 30,),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/createU');
                      },
                    ):Container():Container(child:Text("error load again")),
                    Divider(
                      height: 4,
                      color: Colors.black,
                    ),
                    isLoading!=true&& isTrue==true?createP==true?ListTile (
                      title:const Text('Create Project',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w400,color:Colors.black),),
                      leading: Icon(FeatherIcons.folder,color: Colors.black,size: 30,),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/addProject');
                      },
                    ):Container():Container(child:Text("error load again")),
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
    debugPrint("init of home paaaaaaaaaage");
     requestPermission();
     // FirebaseMessaging.instance.subscribeToTopic("Animal");
    loadFCM();
    List<String> userTokens = ['user1_token', 'user2_token'];

// Subscribe the users to the "posts" topic.

    // FirebaseMessaging.instance.subscribeToTopic(userTokens, 'posts').then((response) {
    //   print('Subscribed ${response.successCount} users to the "posts" topic.');
    // }).catchError((error) {
    //   print('Error subscribing users to the "posts" topic: $error');
    // });
    listenFCM();
    getToken();
    _isMounted = true;
    _loadData2();

  }
  void dispose() {
    // cancel any async operations here
    _isMounted = false;
    super.dispose();
  }
  void _loadData()async{
   // await hmc.updateIsLate();
    await _getLoggedInId();
    await _createP();
    await _createU();
    await _inventoryM();


  }
 void _loadData2() async{
   if (_isMounted) {
     setState(() {
       isLoading = true;
     });
     try {
       String x = await getIdofUser();
       debugPrint("ana f your projects $x ");
       debugPrint("logged in id $x");
       setState(() {
         loggedInId = x;
       });
       try {
         setState(() {
           isLoading = true;
         });
         bool x = await hmc.isCreateP(loggedInId);
         setState(() {
           createP = x;
         });
         debugPrint("f$createP");
         try {
           setState(() {
             isLoading = true;
           });
           bool x = await hmc.isCreateU(loggedInId);
           setState(() {
             createU = x;
           });
           debugPrint("f$createU");
           try {
             setState(() {
               isLoading = true;
             });
             bool x = await hmc.isInventoryM(loggedInId);
             setState(() {
               inventoryM = x;
             });
             debugPrint("finished loading the home screen");
             try {
               String name = await getLoggedInName();
               setState(() {
                 loggedInName = name;
                 isTrue = true;
                 isLoading = false;
               });
               debugPrint("inventoryM $inventoryM");
             }
             catch (e) {
               setState(() {
                 isLoading = false;
               });
             }
           }
           catch (e) {
             setState(() {
               isLoading = false;
             });
           }
         }
         catch (e) {
           setState(() {
             isLoading = false;
           });
         }
       }
       catch (e) {
         setState(() {
           isLoading = false;
         });
       }
     }
     catch (e) {
       setState(() {
         isLoading = false;
       });
     }
   }
 }
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint("background message");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: 'launch_background',
            importance: Importance.high
          ),
        ),
      );
    }
  }
  void sendPushMessage() async {
    try {
      debugPrint("enter send push message");
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAj11i4V8:APA91bHghfWBgt7-fyPnshItM_nM7CESH3tZnO5mAQ9TMA6GJSbyFg9_PTNp4-YQ56v6BIePSufVw4R_wiIW_C5AilRIIteuEV-5ZesQSwGCI1sPu2k6btlvW7a3crBDRXs1tbd4cfix',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'Test Body',
              'title': 'Test Title 2'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": "/topics/Animal",
          },
        ),
      );
      debugPrint("exit send push notif");
    }
    catch (e) {
      debugPrint("error push notification");
    }
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('An error occurred.Please try again!s'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('An error occurred.Please try again!s'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('An error occurred.Please try again!s'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }
  Future<void> _inventoryM()async{
    try{
      bool x=await hmc.isInventoryM(loggedInId);
      setState(() {
        inventoryM=x;
      });
      debugPrint("inventoryM $inventoryM");
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
