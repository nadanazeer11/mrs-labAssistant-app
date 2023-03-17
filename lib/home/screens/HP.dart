
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:mrs/config/colors.dart';
import 'package:mrs/home/screens/OurProjects.dart';

import '../../config/text_styles.dart';
import '../widgets/project_item.dart';
import 'YourProjects.dart';

class HP extends StatefulWidget {
  const HP({Key? key}) : super(key: key);

  @override
  State<HP> createState() => _HPState();
}

class _HPState extends State<HP> {
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
    return
      Scaffold(
      appBar: AppBar(
        backgroundColor:AppColorss.lightmainColor ,
        elevation: 0,
        title:Text("MRS",style:subHeadingStyle) ,
        actions: [
          IconButton(onPressed: (){

          }, icon:Icon(Icons.filter_list_outlined))
        ],
      ),
     body:Column(children:[ widgetOptions[indexx],
       ElevatedButton(onPressed:(){
         Navigator.pushNamed(context, '/addProject');
       }, child: Text("add task"))
     ]),
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
    );
  }
}
