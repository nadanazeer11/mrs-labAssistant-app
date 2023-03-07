import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:mrs/colors.dart';

import '../models/Project.dart';
import '../widgets/Project_item.dart';

class HP extends StatefulWidget {
  const HP({Key? key}) : super(key: key);

  @override
  State<HP> createState() => _HPState();
}

class _HPState extends State<HP> {
  @override
  final List<Map<String, dynamic>> projects = [
    {'name': 'Human Interface robot', 'deadline': '2023-03-31'},
    {'name': 'Human Interface Lab assistant', 'deadline': '2023-04-15'},
    {'name': 'Human Interface robfor medical assistance', 'deadline': '2023-05-01'},
  ];
  DateTime n=DateTime.now();
  final List<Project> p=[
    Project(id:"S",title: "Introduction to cs",description: "ahlaf",enddate: DateTime.now(),startdate: DateTime.now(),users: ["1","@"]),
    Project(id:"S",title: "Introduction to cs",description: "ahlaf",enddate: DateTime.now(),startdate: DateTime.now(),users: ["1","@"]),
    Project(id:"S",title: "Introduction to cs",description: "ahlaf",enddate: DateTime.now(),startdate: DateTime.now(),users: ["1","@"])
  ];
  final List<Map<String, dynamic>> tasks = [
    {'name': 'Assign lab to human exception', 'deadline': '2023-03-15'},
    {'name': 'Read from dialog and watch', 'deadline': '2023-04-01'},
    {'name': 'Ask chatgpt for assistance', 'deadline': '2023-04-15'},
  ];
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


  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(11,16,0,2),
              child: Row(
                children: [
                  Text(
                    'Your Projects',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  IconButton(onPressed: (){}, icon: Icon(Icons.arrow_right,size: 39,))
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: p.length,
              itemBuilder: (BuildContext context, int i) {
                return Project_item(p[i].id,p[i].title,p[i].enddate);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11,16,0,0),
              child: Row(
                children: [
                  Text(
                    'Your Tasks',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  IconButton(onPressed:(){}, icon:Icon(Icons.arrow_right,size: 39,))
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(tasks[index]['name']),
                      subtitle: Text('Deadline: ${tasks[index]['deadline']}'),
                    ),
                    Divider(height: 1,color: AppColorss.darkmainColor,indent: 20,endIndent: 20,)

                  ],
                );
              },
            ),
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

    );
  }
}
