import 'package:flutter/material.dart';

//import './fillHome.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

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
  FlutterTts flutterTts = FlutterTts();
  List<String>? languages;
  String langCode = "en-US";
  HomeContr homeC=HomeContr();
  ProjectDContr pdc=new ProjectDContr();
  DateTime Start= DateTime.now();
  String loggedInName="";
  String? loggedInId;
  String ?id;
  List<String> ?myNotesId;
  List<bool>isSelected=[true,false]; //public,not pub;lic
  bool allow=true;
  TextEditingController _notesText=TextEditingController();
  void sendNote(String text)async{
    try{
      DateTime x=DateTime.now();
      bool z=isSelected[0]==true ? true : false;
      Notes note=Notes(note:text,user: loggedInName,time:Timestamp.fromDate(x),public:z);
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
                                content: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: _notesText,
                                            minLines: 3,
                                            maxLines: 4,
                                            decoration: InputDecoration(
                                                hintText: "Enter your note here",
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                                )
                                            ),
                                          ),
                                          SizedBox(height: 10,),
                                          ToggleButtons(
                                            isSelected: isSelected,
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                            onPressed: (int index) {
                                              setState(() {
                                                for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                                                  if (buttonIndex == index) {
                                                    isSelected[buttonIndex] = true;
                                                  } else {
                                                    isSelected[buttonIndex] = false;
                                                  }
                                                }
                                              });
                                            },
                                            children:  <Widget>[
                                            Icon(
                                            Icons.public_outlined,
                                            color: isSelected[0] == true ? Color(0xFF09126C) : Color.fromRGBO(62, 68, 71, 1),
                                          ),
                                            Icon(
                                        Icons.public_off_outlined,
                                        color: isSelected[1] == true ? Color(0xFF09126C) : Color.fromRGBO(62, 68, 71, 1),
                                      ),

                                      ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {_notesText.clear();Navigator.pop(context, 'Cancel');
                                    setState(() {
                                      isSelected=[true,false];
                                    });},
                                    child: const Text('Cancel',style:TextStyle( color:Color(0xFF005466),fontSize: 19),),

                                  ),
                                  TextButton(
                                    onPressed: (){
                                      sendNote(_notesText.text);
                                      Navigator.pop(context, 'Yes');
                                      _notesText.clear();

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
              Timestamp? date=projNotes?[index].time;
              DateTime? x=date?.toDate();
              String datee=DateFormat('dd/MM/yy').format(x!).toString();
              String time=DateFormat('HH:mm').format(x!).toString();
              bool? public =projNotes?[index].public;
              if(public==true||allow==true){
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
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children:[
                                  Icon(Icons.access_time_sharp,size: 15,color: AppColorss.darkFontGrey,),
                                  Text('${ time},${datee}',style: TextStyle(fontSize: 14,color: AppColorss.fontGrey),),
                                ]),
                            SizedBox(height:3),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 21,
                                  // add avatar image or tex
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: SizedBox(
                                    child: Text(
                                      '${projNotes?[index].note?? 'N/A'}',
                                      style: TextStyle(fontSize: 16,color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                public == true
                                    ? Align(alignment: Alignment.bottomLeft, child: Icon(FeatherIcons.unlock, size: 16))
                                    : Align(alignment: Alignment.bottomLeft, child: Icon(FeatherIcons.lock, size: 16)),
                                // speak==true? IconButton(onPressed: (){
                                //   debugPrint("play");
                                //   setState(() {
                                //     speakStates[index]=false;
                                //   });
                                // }, icon: Icon(FeatherIcons.play,size: 16,))
                                //     :
                                // IconButton(onPressed: (){
                                //   debugPrint("pause");
                                //   setState(() {
                                //     speakStates[index]=true;
                                //   });
                                // }, icon: Icon(FeatherIcons.pause,size:16))
                               PlayPauseButton(text: projNotes?[index].note)
                              ],
                            )
                          ],
                        ),
                      ),
                     ),
                );

              }
              else{
                return Container();
              }

            },

          );
        }
        else{
          return Container();
        }
      }
    );
  }
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  void _loadData() async {
    await _getLoggedInId();
    await _getLoggedInName();
    await _see();
  }
  Future<void> _getLoggedInName()async{
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
  Future<void> _getLoggedInId() async{
    try {
      String x=await getIdofUser();
      setState(() {
        loggedInId=x;

      });
      debugPrint("iddddddddddddddddd$loggedInId");

    }
    catch(e){
      setState(() {
      });
    }
  }
  Future<void> _see()async{
    try{
      // debugPrint("d$loggedInId");
      bool see=await pdc.see(id, loggedInId);
      setState(() {
        allow=see;
      });
      debugPrint("allow $allow");
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

class PlayPauseButton extends StatefulWidget {
  String ?text;
  PlayPauseButton({required this.text});

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  bool _isPlaying = false;
  FlutterTts flutterTts = FlutterTts();
  List<String>? languages;
  String langCode = "en-US";
  double volume = 1.0;
  void _togglePlayPause() {
    setState(() {
      if(_isPlaying){
        _stop();
      }
      else{
        _speak();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _togglePlayPause,
      icon: Icon(
        _isPlaying ? Icons.pause : Icons.play_arrow,
      ),
    );
  }
  void initSetting() async {
    await flutterTts.setVolume(volume);

    await flutterTts.setLanguage(langCode);
  }

  void _speak() async {
    initSetting();


    String x=widget.text ?? 'N/A';
    await flutterTts.speak(x);


  }

  void _stop() async {
    await flutterTts.stop();
  }
}
