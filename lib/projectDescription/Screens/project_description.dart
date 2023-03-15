import 'package:flutter/material.dart';

//import './fillHome.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../home/backend/Home_Controller.dart';
import '../../models/Notes.dart';
import '../../models/Project.dart';
import 'package:intl/intl.dart';

import '../backend/projectDescripController.dart';

class ProjDescrip extends StatefulWidget {
  const ProjDescrip({Key? key}) : super(key: key);

  @override
  State<ProjDescrip> createState() => _ProjDescripState();
}

class _ProjDescripState extends State<ProjDescrip> {

  HomeContr homeC=HomeContr();
  ProjectDContr pdc=new ProjectDContr();
  DateTime Start= DateTime.now();
  String loggedInName="";
  String? loggedInId;
  String getId="";
  String ?id;
  List<Notes> n=[];
  List<String> ?myNotesId;
  TextEditingController _notesText=TextEditingController();
  void sendNote(String text)async{
    try{
      Notes note=Notes(note:text,user: loggedInName);
      await pdc.addNote(note,id);
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.Please try again!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<String> ? notesIds=[];
  @override
  void initState() {
    super.initState();
    _getLoggedInName();
    _getLoggedInId();
  }
  void _getLoggedInName()async{
    try {
      String x=await getLoggedInName();
      setState(() {
        loggedInName=x;

      });

    }
    catch(e){
      setState(() {

      });
    }
  }
  void _getLoggedInId() async{
    try {
      String x=await getIdofUser();
      setState(() {
        loggedInId=x;

      });

    }
    catch(e){
      setState(() {
      });
    }
  }
  void getTheNotes(List<String> ?nn)async{
    try{
      List<Notes> x=await pdc.getNotes(nn);
      setState(() {
        n=x;
      });
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.Please try again!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments ;
     id = (args as Map<String, dynamic>)['id'];

    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
          appBar:AppBar(
            backgroundColor:AppColorss.lightmainColor ,
            elevation: 0,
            title:Text("MRS",style:subHeadingStyle) ,
            actions: [
              IconButton(onPressed: (){}, icon:Icon(Icons.filter_list_outlined))
            ],
            leading: IconButton(onPressed: (){
              Navigator.pop(context);
            },icon: Icon(Icons.arrow_back_ios),),
          ),
          body:StreamBuilder<Project>(
              stream: homeC.getProjectDetails(id),
              builder: (context, snapshot) {
              if(snapshot.hasData){
                Project? project=snapshot.data;
                Timestamp? date=project?.endDate;
                DateTime? x=date?.toDate();
                String endDate=DateFormat.yMd().format(x!);
                myNotesId=project?.notes;
                debugPrint("e ${myNotesId?.length}");
                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: SizedBox(
                          width: double.infinity,
                          child:Padding(
                            padding: const EdgeInsets.fromLTRB(10,16,0,0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text( '${project?.title ?? 'N/A'}',style:TextStyle(fontSize: 29,fontWeight: FontWeight.w500,color: Colors.black87,fontStyle: FontStyle.normal)),
                                SizedBox(height: 12,),
                                SizedBox(height: 12,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'Created By: ',
                                          style: TextStyle(fontSize: 18, color: Colors.grey),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:'${project?.createdBy ?? 'N/A'}',
                                              style: TextStyle(fontWeight: FontWeight.w400, color: AppColorss.darkmainColor),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.add_alert_sharp,color: Colors.red,),
                                          Text('$endDate',style: TextStyle(fontSize:20),),

                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Contributers",style:TextStyle(fontSize: 20,fontWeight: FontWeight.w400)),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.people),
                              itemBuilder: (BuildContext context) {
                                if (project?.users != null) {
                                  return project!.users.map((String option) {
                                    return PopupMenuItem<String>(
                                      value: option,
                                      child: Text(option),
                                    );
                                  }).toList();
                                }
                                return <PopupMenuEntry<String>>[];
                              },

                            ),

                            ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Divider(
                                    height: 4,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  "Description",
                                  style: TextStyle(fontWeight: FontWeight.w400,fontSize: 22,color: Color(0xFF36454F)),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                    '${project?.description ?? 'N/A'}',
                                    style: TextStyle(color:Color(0xFF647E68),fontSize: 18)
                                ),

                              ],
                            ),
                          )
                      ),
                    ),

                    // buttonArrow(context),
                    scroll(context,project?.notes),


                  ],
                );

              }
              return Text("f");
            }
          )
      ),
    );
  }



  scroll(BuildContext context,List<String>? ids){
    double w=MediaQuery.of(context).size.width;

    final h = MediaQuery.of(context).size.height;
    final initialChildSize = 0.5;
    return Container(
      height: h,
      child: DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          maxChildSize: 0.7,
          minChildSize: 0,
          builder: (context, scrollController){
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration:  BoxDecoration(
                color: AppColorss.darkmainColor,
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text("Notes:",style: TextStyle(fontSize: 21,fontWeight: FontWeight.w500,color: Colors.white),),
                          IconButton(onPressed: (){
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text(
                                  "Add Note",
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
                                ),
                                content: TextFormField(
                                  controller: _notesText,
                                  minLines: 3,
                                  maxLines: 10,
                                  decoration: InputDecoration(
                                    hintText: "Enter your note here",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                    )
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel',style:TextStyle( color:Color(0xFF005466),fontSize: 19),),
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      sendNote(_notesText.text);
                                      Navigator.pop(context, 'Yes');
                                    },
                                    child: const Text('Submit',style:TextStyle( color:Color.fromRGBO(230, 46, 4, 1),fontSize: 19),),
                                  ),
                                ],
                              ),
                            );
                          }, icon: Icon(Icons.add))
                        ],
                      ),
                    ),
                    // ListView.builder(
                    //   physics: NeverScrollableScrollPhysics(),
                    //   shrinkWrap: true,
                    //   itemCount: ids?.length??0,
                    //   itemBuilder: (context, index) => steps(context, index,ids![index]),
                    // ),
                    steps(context,ids),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
  steps(BuildContext context,List<String>? ids)  {
    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(4,0,3,27),
    //   child:
    //   Container(
    //     margin:EdgeInsets.fromLTRB(4, 0, 3, 0),
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(10.0),
    //       color: Colors.white,
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.grey.withOpacity(0.5),
    //           spreadRadius: 2,
    //           blurRadius: 5,
    //           offset: Offset(0, 3),
    //         ),
    //       ],
    //     ),
    //     child: Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Row(
    //         children: [
    //           CircleAvatar(
    //             radius: 30,
    //             // add avatar image or tex
    //           ),
    //           SizedBox(width: 15),
    //           Expanded(
    //             child: SizedBox(
    //               child: Text(
    //                 'ff',
    //                 style: TextStyle(fontSize: 16,color: Colors.black54),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    //
    // );
    return FutureBuilder<List<Notes>>(
      future:pdc.getNotes(ids),
      builder: (context,snapshot){
        if(snapshot.hasData){
          List<Notes>? projNotes=snapshot.data;
          debugPrint("gggg ${projNotes?.length}");
          return ListView.builder(
            itemCount: projNotes?.length??0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context,index){
              return Padding(
                padding: const EdgeInsets.fromLTRB(4,0,3,27),
                child:
                Container(
                  margin:EdgeInsets.fromLTRB(4, 0, 3, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          // add avatar image or tex
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: SizedBox(
                            child: Text(
                              '${projNotes?[index].note?? 'N/A'}',
                              style: TextStyle(fontSize: 16,color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              );

            },

          );
        }
        else{
          return Container();
        }
      }
    );
  }


}

