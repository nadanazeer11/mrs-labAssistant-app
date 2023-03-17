import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mrs/home/backend/Home_Controller.dart';
import 'package:mrs/home/models/all.dart';
import 'package:mrs/models/Project.dart';

import '../../common.dart';
import '../../config/colors.dart';
import '../widgets/project_item.dart';

class YourProjects extends StatefulWidget {
  const YourProjects({Key? key}) : super(key: key);

  @override
  State<YourProjects> createState() => _YourProjectsState();
}

class _YourProjectsState extends State<YourProjects> {
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
    if(loggedInId!=null){
      return StreamBuilder<MyProjects>(
        stream: homeC.getMyProjectsStream(loggedInId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MyProjects? myProjects = snapshot.data;
            int ? x=myProjects?.projects?.length;
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
                          PopupMenuItem(
                            child: Text('Created By Me'),
                            value: "Me",
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
                        itemCount: myProjects?.projects?.length??0,
                        itemBuilder: (context,index){
                          return StreamBuilder<Project>(
                              stream: homeC.getProjectDetails(myProjects?.projects[index]),
                              builder:(context,projSnap){
                                 // homeC.get(myProjects?.projects[index]);
                                if(projSnap.hasData){

                                  Project? project=projSnap.data;
                                  if(filter==null){
                                    return Column(
                                      children: [
                                        Project_item(id: myProjects?.projects[index],project:project),
                                        // Text('User name: ${project?.isDone}')
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
                                            Project_item(id: myProjects?.projects[index],project:project),
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
                                            Project_item(id: myProjects?.projects[index],project:project),
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
                                            Project_item(id: myProjects?.projects[index],project:project),
                                            // Text('User name: ${project?.isDone}')
                                          ],
                                        );
                                      }
                                    }
                                  }
                                  else if(filter=="Me"){
                                    if( project?.createdBy!=null){
                                      if(project?.createdBy==loggedInName){
                                        return Column(
                                          children: [
                                            Project_item(id: myProjects?.projects[index],project:project),
                                            // Text('User name: ${project?.isDone}')
                                          ],
                                        );
                                      }
                                    }
                                  }
                                  //Text('User name: ${project?.title}');

                                }
                                  return Container();

                              }
                          );
                        }),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Text('Error retrieving user data.');
          } else {
            return Text('Loading...');
          }
        },
      );

    }
    else{
      return Center(child: CircularProgressIndicator(),);
    }



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
  Widget _buildDropdown() {
    return DropdownButtonFormField(
      items: _options.map((option) {
        return DropdownMenuItem(
          child: Row(
            children: [
              Radio(
                value: option,
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                  Navigator.pop(context); // Close the dropdown
                },
              ),
              SizedBox(width: 10),
              Text(option),
            ],
          ),
          value: option,
        );
      }).toList(),
      hint: Text('Select option'),
      onChanged: (_) {},
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }

}
