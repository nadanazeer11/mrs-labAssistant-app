
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
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
  HomeContr hmc=new HomeContr();
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
      body: widgetOptions[indexx],
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
                      title:const Text('Create User',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color:Colors.white),),
                      leading: Icon(FeatherIcons.user,color: Colors.white,),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ):Container(),
                    Divider(
                      height: 4,
                      color: Colors.black,
                    ),
                    createP==true?ListTile(
                      title:const Text('Create Project',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color:Colors.white),),
                      leading: Icon(FeatherIcons.folder,color: Colors.white,),
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
                title:const Text('Change Password',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color:Colors.white),),
                leading: Icon(FeatherIcons.logOut,color: Colors.white,),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                tileColor: AppColorss.darkmainColor,
                title:const Text('Log Out',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color:Colors.white),),
                leading: Icon(FeatherIcons.logOut,color: Colors.white,),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
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
