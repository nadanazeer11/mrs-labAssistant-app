import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mrs/models/Project.dart';

import '../../common.dart';
import '../../config/colors.dart';
import '../../config/n.dart';
import '../../config/text_styles.dart';
import '../backend/CreateP.dart';

import 'package:http/http.dart' as http;
// import 'package:firebase_admin/firebase_admin.dart';

class Create_Project extends StatefulWidget {
  const Create_Project({Key? key}) : super(key: key);

  @override
  State<Create_Project> createState() => _Create_ProjectState();
}

class _Create_ProjectState extends State<Create_Project> {
  final _projectNameController=TextEditingController();
  final _projectDescripController=TextEditingController();
  CreatePController contr=CreatePController();
  bool _allFieldsEntered = false;
  String? _error;
  bool loading=false;
  List<String> _selectedItems=[];
  String loggedInName="";
  void _checkFieldsEntered() {
    bool x=_projectDescripController.text.isNotEmpty;
    bool y=_projectNameController.text.isNotEmpty;
    bool m=        _selectedItems.isNotEmpty;
    debugPrint("Hello, my name is $x and I am $y $m years old.");
    if (_projectDescripController.text.isNotEmpty &&
        _projectNameController.text.isNotEmpty
        //&& _selectedItems.isNotEmpty

    ) {
      setState(() {
        _allFieldsEntered = true;
      });
      setState(() {_error = "";});
    } else {
      setState(() {
        _allFieldsEntered = false;
      });
    }
  }
  void initState()  {
    super.initState();
   getToke();
    _projectNameController.addListener(_checkFieldsEntered);
    _projectDescripController.addListener(_checkFieldsEntered);
     _getUserNames();
    _getLoggedInName();
  }
  void getToke() async{
    debugPrint("getToke");
    await FirebaseMessaging.instance.getToken().then(
            (token) async {
          debugPrint("my token in authenticate is $token");

        }
    );
  }
  void _getLoggedInName()async{
    try {
      String x=await getLoggedInName();
      setState(() {
        loggedInName=x;
        _error="";
      });
      debugPrint(x);

    }
    catch(e){
      setState(() {
        _error="Failed to get logged in user";
      });
    }
  }
  void _getUserNames()async {
    try{
      debugPrint("fdd");
      List<String>x=await contr.getUserNames();
      setState(()  {
        items=x;
        _error="";
      });

    }
    catch(e){
      debugPrint("f");
      setState(() {
        _error="Please reload!";
      });
    }


  }
  void dispose() {
    _projectDescripController.dispose();
    _projectNameController.dispose();
    super.dispose();
  }
  DateTimeRange dateTimeRange=DateTimeRange(
      start: DateTime.now(),
      end: DateTime(DateTime.now().year,12,30)
  );
  List<String> items=[];
  void _showMultiSelect  ()async{
    List<String> res=await showDialog(context: context, builder:
        (BuildContext){
      return MultiSelect(items: items, preSelectedItems: _selectedItems);
    });

      setState(() {
        _selectedItems=res;
      });


  }
  void submitProject()async{
    Project project=new Project(title: _projectNameController.text,
        description: _projectDescripController.text,
        users: _selectedItems,
        createdBy:loggedInName,
        startDate: Timestamp.fromDate(dateTimeRange.start),
        endDate: Timestamp.fromDate(dateTimeRange.end),
        notes: [],
        creation: Timestamp.fromDate(DateTime.now()));
    try{
      setState(() {
        loading=true;
      });
      String idd=await contr.createProject(project);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project successfully created!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _error="";

        loading=false;
      });
      String title= _projectNameController.text;
      String text="You are assigned project $title by $loggedInName";
      _projectNameController.clear();
      _projectDescripController.clear();
    try{
      List<String> tokens=await contr.getTokens(_selectedItems);
      setState(() {
        _selectedItems=[];
      });
      sendPushMessage(title, text, tokens,idd);


    }
    catch(e){
      // setState(() {
      //   _selectedItems=[];
      // });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error sending notification to users'),
          backgroundColor: Colors.red,
        ),
      );
    }


    }
    catch(e){
      setState(() {
        _error="Cant create project,please try again";
        loading=false;
      });
    }
  }
  void sendPushMessage(String title,String text,List<String> tokens,String id) async {
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
              'body': text,
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
            'registration_ids': tokens,
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
    final Start=dateTimeRange.start;
    final end=dateTimeRange.end;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:AppColorss.lightmainColor ,
        elevation: 0,
        title:Text("MRS",style:subHeadingStyle) ,
        actions: [
          IconButton(onPressed: ()async{
            debugPrint("getting token");
            await FirebaseMessaging.instance.getToken().then(
                    (token) async {
                  debugPrint("my token in authenticate is $token");

                }
            );
          }, icon:Icon(Icons.filter_list_outlined))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20,20,20,20),
        child:SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Project",style: headingStyle,),
              InputwithHeader(label: "Title",hint: "Enter title",maxlines: 1,height:62,contr: _projectNameController),
              SizedBox(height: 8,),
              InputwithHeader(label: "Description",hint: "Enter Description",maxlines: 5,height: 102,contr: _projectDescripController),
              SizedBox(height: 8,),
              DatePicks(label:"Duration",hint:'${Start.day}/${Start.month}/${Start.year}  -> ${end.day}/${end.month}/${end.year}' ),
              SizedBox(height: 16,),
              Column(children: [
                Row(
                  children: [
                    Text("Choose Contributers",style: TextStyle(color: AppColorss.mainblackColor,fontSize: 20,fontWeight: FontWeight.w400),),
                    IconButton(onPressed: _showMultiSelect, icon: Icon(Icons.people)),
                  ],
                ),
                const SizedBox(width:3,),
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: _selectedItems.map((e) => Chip(label: Text(e))).toList(),
                ),
                const SizedBox(height: 18,),
                Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text("${_error ?? ''}", style: TextStyle(color: Colors.redAccent)),
                    ),
                ElevatedButton(onPressed:
                    _allFieldsEntered? (){
                        submitProject();
                    }:(){
                  setState(() {_error = "Please fill out all fields!";});
                    },   style: ElevatedButton.styleFrom(
                        backgroundColor:_allFieldsEntered? AppColorss.darkmainColor:Colors.grey,// Set the background color
                      ), child:loading==true?const CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ):
               Text("Create",style: subHeadingStyle,),)
              ],),
            ],
          ),
        )
      ),
    );
  }
  Widget InputwithHeader({required String label,required String hint,required int maxlines,required double height, required TextEditingController contr}){
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,style: titleStyle,),
          Container(
            height: height,
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.only(left: 14),
            decoration:BoxDecoration(
                border: Border.all(
                    color: Colors.grey,
                    width: 1.0
                ),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              children: [
                Expanded(
                    child:TextFormField(
                      controller: contr,
                      maxLines: maxlines,
                      autofocus:false,
                      cursorColor: AppColorss.darkmainColor,
                      style:subtitleStyle,
                      decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: subtitleStyle,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0
                              )
                          ),
                          enabledBorder:  UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0
                              )
                          )
                      ),
                    )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget DatePicks({required String label,required String hint}){
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,style: titleStyle,),
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.only(left: 14),
            decoration:BoxDecoration(
                border: Border.all(
                    color: Colors.grey,
                    width: 1.0
                ),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              children: [
                Expanded(
                    child:TextFormField(
                      readOnly: true,
                      maxLines: 1,
                      autofocus:false,
                      cursorColor: AppColorss.darkmainColor,
                      style:subtitleStyle,
                      decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: subtitleStyle,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0
                              )
                          ),
                          enabledBorder:  UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0
                              )
                          )
                      ),
                    ),
                ),
                Container(
                  child: IconButton(icon:Icon(Icons.calendar_month_outlined),onPressed:pickDateRange,),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  Future pickDateRange() async {
    DateTimeRange ? newTime=await showDateRangePicker(context: context, firstDate: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day),initialDateRange: dateTimeRange, lastDate: DateTime(2100));
    if(newTime==null) return ;
    setState(() {
      dateTimeRange=newTime;
    });

  }

}
class MultiSelect extends StatefulWidget {
  final List<String> items;
  final List<String> preSelectedItems;
  const MultiSelect({Key? key, required this.items, required this.preSelectedItems}) : super(key: key);

  @override
  State<MultiSelect> createState() => _MultiSelectState();
}
class _MultiSelectState extends State<MultiSelect> {
  List<String> _selectedItems=[];

  void initState() {
    super.initState();
    _selectedItems = widget.preSelectedItems;
  }

  void _itemChange(String itemValue,bool isSelected){
    setState(() {
      if(isSelected){
        _selectedItems.add(itemValue);
      }
      else{
        _selectedItems.remove(itemValue);
      }

    });
  }
  void _cancel(){
    Navigator.pop(context);
  }
  void _submit(){
    Navigator.pop(context,_selectedItems);
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Contributors'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Colors.grey[300],
        ),
        child: SizedBox(
          height: 300.0, // Set the desired height of the dialog
          width: 300.0, // Set the desired width of the dialog
          child: Scrollbar(
            child: SingleChildScrollView(
              child: ListBody(
                children: widget.items.map((item) => CheckboxListTile(
                  value: _selectedItems.contains(item),
                  title: Text(item),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) => _itemChange(item, isChecked!),
                )).toList(),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _cancel,
            child: Text("Cancel",style: TextStyle(
                color: AppColorss.darkmainColor
            ),)
        ),
        TextButton(
            onPressed: _submit,
            child:Text("Submit",style: TextStyle(
                color: AppColorss.darkmainColor
            ),)
        )
      ],
    );


  }
}


