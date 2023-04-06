

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
  HomeContr homeC=HomeContr();
  String ? filter;
  bool late=false;

  bool isLoading=true;
  bool isTrue = false;
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    if (isTrue && !isLoading) {
      return StreamBuilder <List<Project>>(
        stream: homeC.getProjects(),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: w*0.12,
                    height: h * 0.12,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/warning.png"),
                        // fit:BoxFit.fill
                      ),
                    ),
                  ),
                  Text("An unexpected error occured,please try again!",
                    style: TextStyle(fontSize: 20),)
                ],
              ),
            );
            // Show error message
          }

          else if (snapshot.connectionState == ConnectionState.active){
            if(snapshot.hasData){
              List<Project> ?allProjects=snapshot.data;
              debugPrint("F${allProjects?.length}");
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
                                else{
                                  return Container();
                                }
                              }
                              else{
                                return Container();
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
                                else{
                                  return Container();
                                }
                              }
                              else{
                                return Container();
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
                                else{
                                  return Container();
                                }
                              }
                              else{
                                return Container();
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
                                else{
                                  return Container();
                                }
                              }
                              else{
                                return Container();
                              }
                            }
                            else{
                              return Container();
                            }

                          }),
                    ),
                  ],
                ),
              );

            }
            else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: w*0.12,
                      height: h * 0.12,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/warning.png"),
                          // fit:BoxFit.fill
                        ),
                      ),
                    ),
                    Text("An unexpected error occured,please try again!",
                      style: TextStyle(fontSize: 20),)
                  ],
                ),
              );
              // Show error message
            }
            else{
              return Center(child: Text("No Projects yet!"),);
            }
          }
          return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ));
        },
      );
    }
    else if(isLoading) {
      debugPrint("i am loading hahahah");
      return Center(child: CircularProgressIndicator(),);
    }
    else if(!isTrue){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: w*0.12,
              height: h * 0.12,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/warning.png"),
                  // fit:BoxFit.fill
                ),
              ),
            ),
            Text("An unexpected error occured,please try again!",
              style: TextStyle(fontSize: 20),)
          ],
        ),
      );
    }
    else{
      debugPrint("hey ya nado");
      return Center(child:CircularProgressIndicator());
    }

  }



  @override
  void initState() {
    _loadData();
    // homeC.updateIsLate();
  }
  void _loadData()async{
    setState(() {
      isLoading=true;
    });
    try {
      String x=await getLoggedInName();

      setState(() {
        loggedInName=x;
      });
      setState(() {
        isLoading=true;
      });
      try {
        setState(() {
          isLoading=true;
        });
        String x=await getIdofUser();
        setState(() {
          loggedInId=x;
          isTrue=true;
          isLoading=false;

        });

      }
      catch(e){
        setState(() {
          isLoading=false;

        });

      }

    }
    catch(e){
      setState(() {
        isLoading=false;

      });

    }

  }


}
