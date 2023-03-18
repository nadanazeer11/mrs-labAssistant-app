

import 'package:flutter/material.dart';
import 'package:mrs/models/Project.dart';

import '../../common.dart';
import '../../config/colors.dart';
import '../backend/Home_Controller.dart';
import '../widgets/project_item.dart';

class OurProjects extends StatefulWidget {
  const OurProjects({Key? key}) : super(key: key);

  @override
  State<OurProjects> createState() => _OurProjectsState();
}

class _OurProjectsState extends State<OurProjects> {
  String loggedInName="";
  String? loggedInId;
  String? _error;
  HomeContr homeC=new HomeContr();
  String ? filter;
  List<String> _options = ['Option 1', 'Option 2', 'Option 3'];
  String? _selectedOption;
  bool late=false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder <List<Project>>(
      stream: homeC.getProjects(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          List<Project> ?allProjects=snapshot.data;
          return Padding(
            padding: const EdgeInsets.fromLTRB(8,28,8,8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Your Projects",style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),),
                    PopupMenuButton(
                      icon: Icon(Icons.filter_alt_rounded,color: AppColorss.darkmainColor,),
                      itemBuilder: (BuildContext context)=>[
                        PopupMenuItem(
                          child: Text('My Projects'),
                          value: "Me",
                        ),
                        PopupMenuItem(
                          child: Text("Late Projects"),
                          value: "Late",
                        ),
                        PopupMenuItem(
                          child: Text('Upcoming Projects'),
                          value: "Upcoming",
                        ),
                        PopupMenuItem(
                          child: Text('Done Projects'),
                          value: "Done",
                        ),

                      ],
                      // color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (value) {
                        debugPrint('your p${value}');
                        setState(() {
                          filter=value;
                        });
                      },
                    ),
                    SizedBox(width: 10,),
                    filter!=null ? GestureDetector(
                      onTap: (){setState(() {
                        filter=null;
                      });},
                      child: Text("Clear Filter",style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: AppColorss.darkmainColor,fontWeight: FontWeight.bold,
                          fontSize: 23),),
                    ):Container()
                  ],
                ),
                SizedBox(height: 14,),
                SingleChildScrollView(
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: allProjects?.length??0,
                      itemBuilder: (context,index){
                        Project? project=allProjects![index];
                        if(filter==null){
                          return Column(
                            children: [
                              Project_item(id: project?.id,project:project),

                            ],
                          );
                        }
                        else if(filter=="Late"){

                          if(project?.isLate!=null){
                            if(project?.isLate==true){

                              setState(() {
                                late=true;
                              });
                              return Column(
                                children: [
                                  Project_item(id: project?.id,project:project),
                                  // Text('User name: ${project?.isDone}')
                                ],
                              );
                            }
                          }

                        }
                        else if(filter=="Done"){
                          if(project?.isDone!=null){
                            if(project?.isDone==true){
                              return Column(
                                children: [
                                  Project_item(id: project?.id,project:project),
                                  // Text('User name: ${project?.isDone}')
                                ],
                              );
                            }
                          }
                        }
                        else if(filter=="Upcoming"){
                          if(project?.isDone!=null &&project?.isLate!=null){
                            if(project?.isDone==false && project?.isLate==false){
                              return Column(
                                children: [
                                  Project_item(id: project?.id,project:project),
                                  // Text('User name: ${project?.isDone}')
                                ],
                              );
                            }
                          }
                        }
                        else if(filter=="Me"){
                        List<String> users= project?.users ?? ["e"];
                          if( project?.users!=null){
                            if(users.contains(loggedInName)){
                              return Column(
                                children: [
                                  Project_item(id: project?.id,project:project),
                                  // Text('User name: ${project?.isDone}')
                                ],
                              );
                            }
                          }
                        }

                      }),
                ),
              ],
            ),
          );

        }
        return Container();
      },
    );
  }



  @override
  void initState() {
    _getLoggedInName();
    _getLoggedInId();
  }
  void _getLoggedInName()async{
    try {
      String x=await getLoggedInName();
      debugPrint("ana f your projects${x}");
      setState(() {
        loggedInName=x;
        _error="";
      });
      debugPrint("ana f your projects $x ");

    }
    catch(e){
      setState(() {
        _error="Failed to get logged in user";
      });
    }
  }
  void _getLoggedInId() async{
    try {
      String x=await getIdofUser();
      debugPrint("ana f your projects $x ");
      setState(() {
        loggedInId=x;
        _error="";
      });

    }
    catch(e){
      setState(() {
        _error="Failed to get logged in user";
      });
    }
  }

}
