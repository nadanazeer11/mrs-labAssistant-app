import 'package:mrs/widgets/big_text.dart';
import 'package:mrs/widgets/small_text.dart';
import 'package:flutter/material.dart';
import './../colors.dart';
//import './fillHome.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'dart:ui';
class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  static final List <Widget> widgetOptions=<Widget>[
    const Text("Create Project"),
    const Text("Home2"),
    const Text("Home3"),
    const Text("Home5"),
  ];
  int indexx=0;
  void onItemTapped(int index){
    setState((){
      indexx=index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container(
        child: Container(
          margin: EdgeInsets.only(top:35,bottom: 15),
          padding: EdgeInsets.only(left: 20,right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SmallText(text: "MRS",color: AppColorss.lightmainColor,size:29,),
              Container(
                width: 45,
                height: 45,
                child: Icon(Icons.search,
                color: Colors.white,),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColorss.lightmainColor
                ),
              )
            ],
          ),
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
    );
  }
}
