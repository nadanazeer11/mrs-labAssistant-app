import 'package:mrs/controllers/project_controller.dart';
import 'package:mrs/widgets/big_text.dart';
import 'package:mrs/widgets/small_text.dart';
import 'package:flutter/material.dart';
import './../colors.dart';
//import './fillHome.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrs/colors.dart';
import 'package:mrs/consts/consts.dart';
import 'package:mrs/main.dart';
import 'package:mrs/screens/home_page.dart';
import 'package:mrs/widgets/big_text.dart';
import 'package:mrs/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:mrs/controllers/auth_controller.dart';

class Createproject extends StatefulWidget {
  const Createproject({Key? key}) : super(key: key);

  @override
  State<Createproject> createState() => _CreateprojectState();
}

class _CreateprojectState extends State<Createproject> {
  String? _error;
  final _formKey=GlobalKey<FormState>();
  final _projectNameController=TextEditingController();
  final _projectDescripController=TextEditingController();
  var controller=Get.put(ProjectController());
  List<String> items=[];
  bool _allFieldsEntered = false;
  DateTime date =DateTime.now();
  DateTime enddate=DateTime.now();
  List<String> _selectedItems=[];
  DateTimeRange dateTimeRange=DateTimeRange(
      start: DateTime.now(),
      end: DateTime(DateTime.now().year,12,30)
  );
  void _checkFieldsEntered() {
    if (_projectDescripController.text.isNotEmpty &&
        _projectNameController.text.isNotEmpty &&
        _selectedItems.isNotEmpty
    ) {
      setState(() {
        _allFieldsEntered = true;
      });
    } else {
      setState(() {
        _allFieldsEntered = false;
      });
    }
  }
  void initState()  {
    super.initState();
    _projectNameController.addListener(_checkFieldsEntered);
    _projectDescripController.addListener(_checkFieldsEntered);
    _getUserNames();
  }
  void _getUserNames()async {
    try{
      setState(() async {
        items=await controller.getUserNames();
      });
    }
    catch(e){
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

  void _showMultiSelect  ()async{

    List<String> res=await showDialog(context: context, builder:
    (BuildContext){
      // return MultiSelect(items:items,);
      return MultiSelect(items: items, preSelectedItems: _selectedItems);
    });
    if(items!=null){
      setState(() {
        _selectedItems=res;
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    final Start=dateTimeRange.start;
    final end=dateTimeRange.end;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(2),
        child: Container(
          margin: EdgeInsets.fromLTRB(24, 16, 10, 0),
          child: ListView(
            children: [
             Text("Create Project",style:TextStyle(color:AppColorss.darkmainColor,fontWeight: FontWeight.bold,fontSize: 27)),
                SizedBox(height: 13,),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextField(
                        controller:_projectNameController,
                        decoration: InputDecoration(
                          labelText: "Project Name",
                          prefixIcon: Icon(Icons.title),
                          border:OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:AppColorss.lightmainColor,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color:AppColorss.darkmainColor),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    SizedBox(height: 30,),
                      TextField(
                          controller:_projectDescripController,
                          decoration: InputDecoration(
                              labelText: "Project Description",
                              prefixIcon: Icon(Icons.description),
                             border:OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color:AppColorss.darkmainColor,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color:AppColorss.darkmainColor),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            ),
                              maxLines: 4,
                      ),
                      SizedBox(height: 20,),
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
                        )
                      ],),
                      Row(children: [
                        Text("Choose Duration",style: TextStyle(color: AppColorss.mainblackColor,fontSize: 20,fontWeight:FontWeight.w400),),
                        IconButton(onPressed:pickDateRange, icon: Icon(Icons.calendar_month_sharp))
                      ],),
                  Text('${Start.day}/${Start.month}/${Start.year}  -> ${end.day}/${end.month}/${end.year}',
                  style:TextStyle(
                    fontSize: 21,
                    color:Colors.blueGrey,
                    fontWeight: FontWeight.w500
                  )),


                  SizedBox(height: 30,),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text("${_error ?? ''}", style: TextStyle(color: Colors.redAccent)),
                      ),
                  ElevatedButton(onPressed: _allFieldsEntered? ()async{
                    try{
                   bool x=   await controller.createProject(title:_projectNameController.text,description:
                      _projectDescripController.text,startdate:'${Start.day}/${Start.month}/${Start.year}',
                        enddate: '${end.day}/${end.month}/${end.year}',users:_selectedItems
                      );
                      setState(() {
                        _error = "";
                      });
                      if(x){
                        //Go to project Page
                      }
                      else{
                        setState(() {
                          _error="Please Try again";
                        });
                      }
                    }
                    catch(e){
                      setState(() {
                        _error="Please Try again";
                      });
                    }
                  }:(){
                    setState(() {
                      _error = "Please fill out all fields!";
                    });
                  }, child:Text("Create Project"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:_allFieldsEntered? AppColorss.darkmainColor:Colors.grey,// Set the background color
                    ),)
                  ,
                    ],
                  ),
                )
            ],
          ),
        ),
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