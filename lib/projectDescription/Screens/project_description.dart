import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:file_picker/file_picker.dart';
import '../../common.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../home/backend/Home_Controller.dart';
import '../../models/Notes.dart';
import '../../models/Project.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../backend/projectDescripController.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';

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
  bool upload=false;
  TextEditingController _notesText=TextEditingController();
  File? file;
  List<String> ? notesIds=[];
  String fileName="No file Selected";
  UploadTask? task;
  bool addMyComment=false;
  bool switchPublic=false;
  String url="";
  Future<String> selectFile()async {
    final result=await FilePicker.platform.pickFiles();
    if(result==null) return "1234";
    final path=result.files.single.path!;
    setState(() {
      file=File(path);
      fileName=basename(basename(file!.path));
    });
    debugPrint("ya nada $fileName");
    return fileName;

  }
  Future<void >uploadFile(BuildContext context)async{
    if(file==null) return;
    String fileName=basename(file!.path);
    final destination='/$fileName';

   task= pdc.uploadFile(destination, file!);
   setState(() {

   });
    if (task ==null){
     return  showPlatformDialog(
          context: context,
          builder: (context) => BasicDialogAlert(
            title: Text("Uploading error"),
            content:
            Text("An Error occured while trying to upload, please try again"),
            actions: <Widget>[
              BasicDialogAction(
                title: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ));

      }
    else{
      final snapshot=await task!.whenComplete((){});
      final urlDownload=await snapshot.ref.getDownloadURL();
      setState(() {
        url=urlDownload;
      });
      debugPrint("Download linkkkkkkkkkkkkkkkkkkkk $urlDownload");
    }


  debugPrint("upload file with name $fileName");
  }
  Future<void> sendNote(String text,BuildContext context)async{
    try{
      DateTime x=DateTime.now();
      bool z=isSelected[0]==true ? true : false;
      Notes note=Notes(note:text,user: loggedInName,time:Timestamp.fromDate(x),public:z,url:url,baseName:fileName);
      await pdc.addNote(note,id);
      setState(() {
        setState(() {
          fileName="No file Selected";
          file=null;
          task=null;
          switchPublic=false;
          addMyComment=false;
          url="";
        });
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
                            setState(() {
                              addMyComment=true;
                            });
                          }, icon: Icon(Icons.add))
                        ],
                      ),
                    ),
                  addMyComment==true?
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: AppColorss.darkmainColor,
                          border: Border.all(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8,8,0,0),
                                  child: Row(
                                    children: [
                                      Text("Your note",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 18),),
                                      Expanded(
                                        child: Align(
                                          alignment:Alignment.bottomLeft,
                                          child: SwitchListTile(
                                            title: switchPublic==true ? Icon(FeatherIcons.unlock) :  Icon(FeatherIcons.lock),
                                            onChanged: (bool value){
                                              setState(() {
                                                switchPublic=value;
                                              });},
                                            value: switchPublic,
                                            activeColor: AppColorss.activeColor,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 100),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: TextField(
                                      controller: _notesText,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                        hintText: 'Add a comment',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(children: [
                                  IconButton(onPressed: ()async {
                                    String boolean=  await selectFile();
                                    debugPrint("el string aho $boolean");
                                    if (boolean!="1234"){
                                      setState(() {
                                        upload=true;
                                      });
                                    }
                                  }, icon: Icon(FeatherIcons.paperclip,),color: Colors.black,),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      style: TextStyle(fontSize: 16, color: AppColorss.fontGrey),
                                    ),
                                  ),
                                  fileName!="No file Selected"  && task==null ?      IconButton(onPressed: (){
                                    uploadFile(context);
                                  }, icon:Icon(FeatherIcons.upload)):Container(),
                                  fileName!="No file Selected" && task==null ? IconButton(onPressed: (){
                                    setState(() {
                                      fileName="No file Selected";
                                      file=null;
                                      upload=false;
                                      url="";
                                    },);
                                  }, icon: Icon(Icons.delete),color: AppColorss.redColor,):Container(),

                                ],),
                                task!=null ? Padding(
                                  padding: const EdgeInsets.only(left: 13),
                                  child: buildUploadStatus(task!),
                                ):Container(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(onPressed: (){
                                      setState(() {
                                       fileName="No file Selected";
                                       file=null;
                                       task=null;
                                       switchPublic=false;
                                       addMyComment=false;
                                       url="";
                                      });
                                    }, child:Text("Cancel",style: TextStyle(fontSize: 18,color: AppColorss.redColor),)),
                                    TextButton(onPressed: ()async {
                                      await sendNote(_notesText.text, context);
                                      setState(() {
                                        addMyComment=false;
                                      });
                                    }, child:Text("Send",style: TextStyle(fontSize: 18,color: Colors.black),)),
                                  ],
                                )


                          ]),
                        ),
                    ),
                  ):Container(),
                    SizedBox(height: 15,),


                    steps(context,ids),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
  Widget buildUploadStatus(UploadTask task)=> StreamBuilder<TaskSnapshot>(
    stream:task.snapshotEvents,
    builder: (context,snapshot){
      if(snapshot.hasData){
        final snap=snapshot.data!;
        final progress=snap.bytesTransferred/snap.totalBytes;
        final percentage=(progress*100).toStringAsFixed(2);
        debugPrint("percentage ya bro $percentage");
        return Text(
          'Uploading $percentage %',
          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.green),
        );
      }
      else{
        debugPrint("in else of stream builder");
        return Container();
      }
    }
  );
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
              String? baseNamee=projNotes?[index].baseName;
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
                               PlayPauseButton(text: projNotes?[index].note),
                                baseNamee!="" ? Expanded(child: Align(alignment:Alignment.bottomRight,child: Text("$baseNamee"))): Container()

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
    debugPrint("load data");
    await _getLoggedInId();
    await _getLoggedInName();
    await _see();
    // await saveFile();
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
      debugPrint("error in see");
    }
  }
  Future<void> saveFile() async {
    final file = File('${(await getApplicationDocumentsDirectory()).path}/example.txt');
    await file.create();
    await file.writeAsString('Hello, World!');
    debugPrint("creaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaate");
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
