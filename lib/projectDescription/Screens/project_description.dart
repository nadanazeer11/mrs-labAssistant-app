import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:mrs/projectDescription/Screens/x.dart';
import '../../common.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../home/backend/Home_Controller.dart';
import '../../models/FileObj.dart';
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
  ProjectDContr pdc=ProjectDContr();
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
  bool sendButton=true;
  bool stop=false;
  List<String> userss=[];
  String? searchWord;
  var searchController = TextEditingController();
  bool dontShowAlert=false;


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
      if(!stop){
        final snapshot=await task!.whenComplete((){});
        final urlDownload=await snapshot.ref.getDownloadURL();
        setState(() {
          url=urlDownload;
        });
        if(!stop){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document successfully uploaded!'),
              backgroundColor: Colors.green,
            ),
          );
          debugPrint("Download linkkkkkkkkkkkkkkkkkkkk $urlDownload");
        }

      }



    }


  debugPrint("upload file with name $fileName");
  }
  Future<void> sendNote(String text,BuildContext context,String ? title)async{
    try{
      await uploadFile(context);
      try{
        DateTime x=DateTime.now();
        bool z=isSelected[0]==true ? true : false;
        if(stop==false){
          if(url=="" || fileName=="No file Selected"){
            Notes note=Notes(note:text,user: loggedInName,time:Timestamp.fromDate(x),public:z,url:"",baseName:"No file Selected");
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
            sendPushMessage(title, text, id);

          }
          else if(url != "" && fileName!="No file Selected"){
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
            sendPushMessage(title, text, id);

          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note successfully uploaded!'),
              backgroundColor: Colors.green,
            ),
          );
        }


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
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while uploading the file'),
          backgroundColor: Colors.red,
        ),
      );

    }

  }
  void sendPushMessage(String ?title,String? text,String? id) async {
      if(userss.isEmpty){
        debugPrint("users is empty");
        List<String> m=await pdc.getUsers(id);
        setState(() {

          userss=m;
        });
        for(String z in m){
          debugPrint("eliane $z");
        }
      }

      try {
        debugPrint("enter send push message of id $id");
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=AAAAj11i4V8:APA91bHghfWBgt7-fyPnshItM_nM7CESH3tZnO5mAQ9TMA6GJSbyFg9_PTNp4-YQ56v6BIePSufVw4R_wiIW_C5AilRIIteuEV-5ZesQSwGCI1sPu2k6btlvW7a3crBDRXs1tbd4cfix',
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body': "$loggedInName: $text",
                'title':title
              },
              'priority': 'high',
              'data': <String, dynamic>{
                // 'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done',
                'notifType':"1",
                'projectId':id
              },
              // "to": tokens[0],
              'registration_ids': userss,
            },
          ),
        );
        debugPrint("exit send push notif");
      }
      catch (e) {
        debugPrint("error push notification");
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
                debugPrint("yarab x3 $id");
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
                                Text( project?.title ?? 'N/A',style:const TextStyle(fontSize: 29,fontWeight: FontWeight.w500,color: Colors.black87,fontStyle: FontStyle.normal)),
                                const SizedBox(height: 12,),
                                // SizedBox(height: 12,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          text: 'Created By: ',
                                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:project?.createdBy ?? 'N/A',
                                              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey[600]),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.add_alert_sharp,color: Colors.red,),
                                          Text(endDate,style: const TextStyle(fontSize:20),),

                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Contributors",style:TextStyle(fontSize: 20,fontWeight: FontWeight.w400)),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.people),
                              itemBuilder: (BuildContext context) {
                                debugPrint("empty");
                                if (project?.users != null) {
                                  if (project!.users.isEmpty) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: null,
                                        child: Text('No users available'),
                                      ),
                                    ];
                                  }
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
                                const Text(
                                  "Description",
                                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                    project?.description ?? 'N/A',
                                    style: TextStyle(color:AppColorss.fontGrey,fontSize: 18)
                                ),

                              ],
                            ),
                          )
                      ),
                    ),

                    // buttonArrow(context),
                    scroll(context,project?.notes,project?.title),


                  ],
                );

              }
              if (snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator(),);
              }
              if(snapshot.hasError){
                debugPrint("yarab ${snapshot.error}");
                Project? project=snapshot.data;
                Timestamp? date=project?.endDate;
                debugPrint("yarab2 $date");
                return const Center(child:Text("Error occurred while loading data,please try again"),);

              }
                return  Center(
                    child: Text(
                      'Something went wrong $id',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ));
            }
          )
      ),
    );
  }



  scroll(BuildContext context,List<String>? ids,String ? title){
    double w=MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final initialChildSize = 0.5;
    return Container(
      height: h,
      child: DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          maxChildSize: 0.7,
          minChildSize: 0.1,
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
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: [
                          const Text("Notes:",style: TextStyle(fontSize: 21,fontWeight: FontWeight.w500,color: Colors.white),),
                          allow==true?IconButton(onPressed: (){
                            setState(() {
                              addMyComment=true;
                              sendButton=true;
                              stop=false;
                              dontShowAlert=false;
                            });
                          }, icon: const Icon(Icons.add,color: Colors.white,)):Container(),
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
                                      const Text("Your note",style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 18),),
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
                                        color: Colors.white,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: TextField(
                                      controller: _notesText,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                        hintText: 'Add a comment',
                                        border: InputBorder.none,
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: Colors.white,

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
                                  }, icon: const Icon(FeatherIcons.paperclip,),color: Colors.black,),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      style: TextStyle(fontSize: 16, color: AppColorss.fontGrey),
                                    ),
                                  ),

                                  fileName!="No file Selected" ? IconButton(onPressed: (){
                                    setState(() {
                                      fileName="No file Selected";
                                      file=null;
                                      upload=false;
                                      url="";
                                    },);
                                  }, icon: const Icon(Icons.delete),color: AppColorss.redColor,):Container(),

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
                                       stop=true;
                                       dontShowAlert=true;


                                      });
                                      _notesText.clear();
                                    }, child:Text("Cancel",style: TextStyle(fontSize: 18,color: Colors.black),)),
                                    sendButton==true?TextButton(onPressed: ()async {
                                      setState(() {
                                        sendButton=false;


                                      });
                                      await sendNote(_notesText.text, context,title);
                                      setState(() {
                                        addMyComment=false;
                                        _notesText.clear();
                                      });
                                      debugPrint("boolean $sendButton");
                                    }, child:const Text("Send",style: TextStyle(fontSize: 18,color: Colors.black),)):Container(),
                                  ],
                                )


                          ]),
                        ),
                    ),
                  ):Container(),
                    const SizedBox(height: 4,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: w * 0.85,
                        child: TextField(

                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search using id/name...',
                            filled: true,
                            fillColor: Colors.white24,
                            prefixIcon: searchWord == null
                                ? IconButton(
                              onPressed: () {
                                setState(() {
                                  searchWord =
                                      searchController.text;
                                });
                              },
                              icon: const Icon(Icons.search),
                            )
                                : IconButton(
                              onPressed: () {
                                setState(() {
                                  searchWord = null;
                                  searchController.clear();
                                });
                              },
                              icon: const Icon(Icons.clear),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),

                            contentPadding: const EdgeInsets.all(8),
                          ),
                        ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
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
              String ? urll=projNotes?[index].url;
              String  user=projNotes?[index].user?? "no";
              String  text=projNotes?[index].note ?? "";
              if(public==true||allow==true){
                if(searchWord==null){
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4,0,3,27),
                    child:
                    Container(
                      margin:const EdgeInsets.fromLTRB(4, 0, 3, 0),
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
                                  Text('$time,$datee',style: TextStyle(fontSize: 14,color: AppColorss.fontGrey),),
                                ]),
                            const SizedBox(height:3),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 21,
                                  // add avatar image or tex
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: SizedBox(
                                    child: Text(
                                      projNotes?[index].note?? 'N/A',
                                      style: const TextStyle(fontSize: 16,color: Colors.black),
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
                                baseNamee!="No file Selected" ? Expanded(child:
                                Align(alignment:Alignment.bottomRight,child: TextButton(
                                    onPressed: () async {
                                      bool hasPdfExtension = baseNamee?.toLowerCase().endsWith('.pdf') ?? false;
                                      if(hasPdfExtension){
                                        final file = await pdc.loadFirebase(baseNamee!);
                                        if (file == null) return;
                                        openPDF(context, file,urll,baseNamee);
                                      }
                                      else{
                                        bool isImage = baseNamee != null &&
                                            (baseNamee.toLowerCase().endsWith('.jpg') ||
                                                baseNamee.toLowerCase().endsWith('.jpeg') ||
                                                baseNamee.toLowerCase().endsWith('.png') ||
                                                baseNamee.toLowerCase().endsWith('.gif') ||
                                                baseNamee.toLowerCase().endsWith('.bmp'));
                                        if(isImage){
                                          debugPrint("this is an image");
                                          Navigator.pushNamed(context, '/fileScreen',arguments:FileObj(baseName: baseNamee, url: urll));
                                        }
                                        else{
                                          bool isVideo = baseNamee != null &&
                                              (baseNamee.toLowerCase().endsWith('.mp4') ||
                                                  baseNamee.toLowerCase().endsWith('.mov') ||
                                                  baseNamee.toLowerCase().endsWith('.avi') ||
                                                  baseNamee.toLowerCase().endsWith('.wmv') ||
                                                  baseNamee.toLowerCase().endsWith('.mkv'));
                                          if(isVideo){

                                          }
                                        }

                                      }

                                    },
                                    child: Text("$baseNamee",style: const TextStyle(decoration: TextDecoration.underline,color: Colors.blue),)))):Container(),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );

                }
                else{
                  String sw=searchWord?? "zero";
                  debugPrint("search word $sw $user $text");

                  if(sw==user|| text.contains(sw)){
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(4,0,3,27),
                      child:
                      Container(
                        margin:const EdgeInsets.fromLTRB(4, 0, 3, 0),
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
                                    Text('$time,$datee',style: TextStyle(fontSize: 14,color: AppColorss.fontGrey),),
                                  ]),
                              const SizedBox(height:3),
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 21,
                                    // add avatar image or tex
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: SizedBox(
                                      child: Text(
                                        projNotes?[index].note?? 'N/A',
                                        style: const TextStyle(fontSize: 16,color: Colors.black),
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
                                  baseNamee!="No file Selected" ? Expanded(child: Align(alignment:Alignment.bottomRight,child: TextButton(
                                      onPressed: () async {
                                        bool hasPdfExtension = baseNamee?.toLowerCase().endsWith('.pdf') ?? false;
                                        if(hasPdfExtension){
                                          final file = await pdc.loadFirebase(baseNamee!);
                                          if (file == null) return;
                                          openPDF(context, file,urll,baseNamee);
                                        }
                                        else{
                                          bool isImage = baseNamee != null &&
                                              (baseNamee.toLowerCase().endsWith('.jpg') ||
                                                  baseNamee.toLowerCase().endsWith('.jpeg') ||
                                                  baseNamee.toLowerCase().endsWith('.png') ||
                                                  baseNamee.toLowerCase().endsWith('.gif') ||
                                                  baseNamee.toLowerCase().endsWith('.bmp'));
                                          if(isImage){
                                            debugPrint("this is an image");
                                            Navigator.pushNamed(context, '/fileScreen',arguments:FileObj(baseName: baseNamee, url: urll));
                                          }
                                          else{
                                            bool isVideo = baseNamee != null &&
                                                (baseNamee.toLowerCase().endsWith('.mp4') ||
                                                    baseNamee.toLowerCase().endsWith('.mov') ||
                                                    baseNamee.toLowerCase().endsWith('.avi') ||
                                                    baseNamee.toLowerCase().endsWith('.wmv') ||
                                                    baseNamee.toLowerCase().endsWith('.mkv'));
                                            if(isVideo){

                                            }
                                          }

                                        }

                                      },
                                      child: Text("$baseNamee",style: const TextStyle(decoration: TextDecoration.underline,color: Colors.blue),)))):Container(),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );

                  }
                }
              }
              return Container();
            },

          );
        }
        if(!snapshot.hasData){
          return Center(child:Text("No notes yet",style: TextStyle(fontSize: 16,color: Colors.black54),));
        }
        else{
          return Container();
        }
      }
    );
  }
  void openPDF(BuildContext context, File file, String? urll, String baseNamee) {
      Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => PDFViewerPage(file: file,url:urll,basenamee: baseNamee,)),
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
    //await _try();
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
