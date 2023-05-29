import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:mrs/models/CompactInventory.dart';
import 'package:mrs/models/Inventory.dart';
import 'package:intl/intl.dart';
import '../../common.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../backend/inventContr.dart';
import 'package:http/http.dart' as http;
import '../widgets/scrollable_widget.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
 bool error=false;
 List<String>allItems=[];
 InventContr invC=InventContr();
 String? searchWord;
 var searchController=TextEditingController();
 final _formU=GlobalKey<FormState>();
 final _formU2=GlobalKey<FormState>();
 var _nameController=TextEditingController();
 var _idController=TextEditingController();
 String ? loggedInName;
 var _nameController2=TextEditingController();
 var _idController2=TextEditingController();
 bool popUpLoading=false;
 bool textLoading=false;
 String initialValue="loose";

 final _formU3=GlobalKey<FormState>();
 var _nameController3=TextEditingController();
 var _idController3=TextEditingController();
 var _descriptionController=TextEditingController();
 bool compactLoading=false;

 @override
  Widget build(BuildContext context) {
   final screenWidth = MediaQuery.of(context).size.width;
   final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar:  AppBar(
        backgroundColor:AppColorss.lightmainColor ,
        elevation: 0,
        title:Text("MRS",style:subHeadingStyle) ,
        actions: [
          IconButton(onPressed: (){

          }, icon:Icon(Icons.filter_list_outlined))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                Text("Add Item",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.black87),),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child:
                    PopupMenuButton(
                      initialValue: initialValue,
                      icon: Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: AppColorss.fontGrey,
                      ),
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: "loose",
                          child: Text('Loose'),
                        ),
                        const PopupMenuItem(
                          value: "compact",
                          child: Text("Compact"),
                        ),
                      ],
                      // color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (value) {
                        debugPrint('your p$value');
                        setState(() {
                          initialValue = value;
                        });
                      },
                    ),
                  ),
                ),

              ],
            ),
            Container(
            height: screenHeight*0.009,
            width: screenWidth*0.4,
            color: AppColorss.darkmainColor,
          ),
            SizedBox(height: screenHeight*0.02,),
            initialValue=="loose"?
                Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text("Choose from Existing Items :",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color:AppColorss.darkFontGrey),),
              SizedBox(height: screenHeight*0.02,),
              Center(
                child: Container(
                  child:    Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width:screenWidth*0.6,
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: 'Search using name...',
                                prefixIcon:searchWord==null? IconButton(onPressed: (){
                                  setState(() {
                                    searchWord=searchController.text;
                                  });
                                },icon: Icon(Icons.search),): IconButton(onPressed: (){
                                  setState(() {
                                    searchWord=null;
                                    searchController.clear();
                                  });
                                },icon: Icon(Icons. clear),),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight*0.02,),
                      ScrollableWidget(child: buildTable()),
                    ],
                  ),
                ),
              ),
              SizedBox(height:screenHeight*0.02,),
              Center(
                  child:Text("OR",style:TextStyle(fontSize: 22,fontWeight: FontWeight.bold,decoration: TextDecoration.underline ))
              ),
              SizedBox(height:screenHeight*0.02,),
              Text("Enter new Item:",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color:AppColorss.darkFontGrey),),
              SizedBox(height:screenHeight*0.02,),
              Form(
                  key:_formU,
                  child:Center(
                    child: Column(children: [
                      FractionallySizedBox(
                        widthFactor: 0.8,
                        child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              hintText: 'Enter items name',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:Color(0xFF005466))
                              ),
                            ),
                            validator:(value) {
                              if (value!.trim().isEmpty) {
                                return "Please enter a name";
                              }
                              return null;
                            }
                        ),

                      ),
                      SizedBox(height: screenHeight*0.02,),
                      FractionallySizedBox(
                        widthFactor: 0.8,
                        child: TextFormField(
                            controller: _idController,
                            decoration: const InputDecoration(
                              labelText: 'Id',
                              hintText: "Enter item's id",
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:Color(0xFF005466))
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(new RegExp(r"\s"))
                            ],
                            validator:(value) {
                              if (value!.trim().isEmpty) {
                                return "Please enter an id";
                              }
                              return null;
                            }
                        ),

                      ),
                      SizedBox(height: screenHeight*0.02,),
                      textLoading==true? CircularProgressIndicator() : ElevatedButton(onPressed: (){
                        _addItem(_idController.text.trim(),_nameController.text.trim());

                      }, child:Text("Add",),   style: ElevatedButton.styleFrom(
                          backgroundColor:AppColorss.lightmainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          minimumSize: Size(100, 30)
                      ),)
                    ]),
                  )
              ),
            ],):
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                  Text("Create new compact item :",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color:AppColorss.darkFontGrey),),
                    SizedBox(height: screenHeight*0.02,),
                    Form(
                      key:_formU3,
                      child:Center(
                        child: Column(children: [
                          FractionallySizedBox(
                            widthFactor: 0.8,
                            child: TextFormField(
                                controller: _nameController3,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  hintText: 'Enter items name',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:Color(0xFF005466))
                                  ),
                                ),
                                validator:(value) {
                                  if (value!.trim().isEmpty) {
                                    return "Please enter a name";
                                  }
                                  return null;
                                }
                            ),

                          ),
                          SizedBox(height: screenHeight*0.02,),
                          FractionallySizedBox(
                            widthFactor: 0.8,
                            child: TextFormField(
                                controller: _idController3,
                                decoration: const InputDecoration(
                                  labelText: 'Id',
                                  hintText: "Enter item's id",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:Color(0xFF005466))
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(new RegExp(r"\s"))
                                ],
                                validator:(value) {
                                  if (value!.trim().isEmpty) {
                                    return "Please enter an id";
                                  }
                                  return null;
                                }
                            ),

                          ),
                          SizedBox(height: screenHeight*0.02,),
                          FractionallySizedBox(
                            widthFactor: 0.8,
                            child: TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  hintText: "Enter item's description",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color:Color(0xFF005466))
                                  ),
                                ),
                                validator:(value) {
                                  if (value!.trim().isEmpty) {
                                    return "Please enter a description";
                                  }
                                  return null;
                                }
                            ),

                          ),
                          SizedBox(height: screenHeight*0.02,),
                          compactLoading==true? CircularProgressIndicator() : ElevatedButton(onPressed: (){

                            _addCompactItem(_idController3.text.trim(),_nameController3.text.trim(),_descriptionController.text.trim());

                          }, child:Text("Add",),   style: ElevatedButton.styleFrom(
                              backgroundColor:AppColorss.lightmainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: Size(100, 30)
                          ),)
                        ]),
                      )
                  ),

                ],)


              ]),


        ),
      ),

    );
  }
  Widget buildTable(){
    List<String> columns=["ItemName","Action"];
    return DataTable(
      headingRowColor: MaterialStateProperty.resolveWith(
              (states) => AppColorss.lightmainColor),
      headingRowHeight: 30,
      columns: getColumns(columns),
      rows: getRows(),
      border: TableBorder.all(color: AppColorss.mainblackColor,
          width: 2,borderRadius: BorderRadius.circular(16.0)),);
  }
  List<DataColumn> getColumns(List<String> columns) => columns
     .map((String column) => DataColumn(
   label: Text(column,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 20),),
 ))
     .toList();
  List<DataRow> getRows(){
  if(searchWord!=null){
    String x=searchWord??"a";
    return allItems?.where((data) => data.contains(x.toLowerCase().trim())).map((data) =>
        _buildDataRow(data)).toList() ?? [];
  }
  else{
    return allItems.map((data) =>_buildDataRow(data)).toList() ?? [];
  }

}
  DataRow _buildDataRow(String data){
  return DataRow(
    cells: <DataCell>[
      DataCell(Text(data,style: TextStyle(fontSize: 18),)),
      DataCell(SizedBox(
        height: 30,
        child: IconButton(onPressed: (){
          showDialog(
            context: context,
            builder: (context) {
              String contentText = "Content of Dialog";
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                      backgroundColor: Colors.white,
                      titlePadding: EdgeInsets.zero,
                      title:
                      Container(
                        decoration: BoxDecoration(color:AppColorss.lightmainColor),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(13.0),
                            child: Text(
                              data,
                              style: TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ),
                        ),
                      ),
                      content: SingleChildScrollView(
                          child: Container(
                            width: double.maxFinite,
                            child: Column(
                              children: [
                                Form(
                                    key:_formU2,
                                    child:Column(children: [
                                      SizedBox(height: 10,),
                                      FractionallySizedBox(
                                        widthFactor: 0.8,
                                        child: TextFormField(
                                            controller: _idController2,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.deny(new RegExp(r"\s"))
                                            ],
                                            decoration: const InputDecoration(
                                              labelText: 'Id',
                                              hintText: "Enter item's id",
                                              border: OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color:Color(0xFF005466))
                                              ),
                                            ),
                                            validator:(value) {
                                              if (value!.trim().isEmpty) {
                                                return "Please enter an id";
                                              }
                                              return null;
                                            }
                                        ),

                                      ),
                                      SizedBox(height:10,),
                                      popUpLoading==true?CircularProgressIndicator():ElevatedButton(onPressed: () async {

                                        final isValid=_formU2.currentState!.validate();
                                        debugPrint("pop up $isValid");
                                        if(isValid){
                                          setState(() {
                                            popUpLoading=true;
                                          });
                                          try{
                                            bool x=await invC.idUnique(_idController2.text.toLowerCase().trim());
                                            if(x){
                                              setState(() {
                                                popUpLoading=false;
                                              });
                                              showPlatformDialog(
                                                context: context,
                                                builder: (context) => BasicDialogAlert(
                                                  title: Text("Authentication Error"),
                                                  content:
                                                  Text("Id already exists"),
                                                  actions: <Widget>[
                                                    BasicDialogAction(
                                                      title: Text("OK"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            else{
                                              try{
                                                Inventory inv=Inventory(
                                                  itemId:_idController2.text.toLowerCase().trim(),
                                                  itemName: data.toLowerCase().trim(),
                                                  status:"Available", createdBy:loggedInName?? "Omar",
                                                  creationDate: Timestamp.fromDate(DateTime.now()),
                                                  administeredBy: "",
                                                  borrowedUser: "",
                                                  borrowDeathDate: "",
                                                  deathReason: "",);

                                                await invC.addItem(inv);
                                                setState(() {
                                                  popUpLoading=false;
                                                });

                                                sendPushMessage("Loose",data.toLowerCase().trim());
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Item successfully created!'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                                _idController2.clear();
                                                _nameController2.clear();
                                                await _getData();
                                              }
                                              catch(e){
                                                setState(() {
                                                  popUpLoading=false;
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error adding item,try again!'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                          catch(e){
                                            setState(() {
                                              popUpLoading=false;
                                            });
                                            showPlatformDialog(
                                              context: context,
                                              builder: (context) => BasicDialogAlert(
                                                title: Text("Error Occured"),
                                                content:
                                                Text(e.toString()),
                                                actions: <Widget>[
                                                  BasicDialogAction(
                                                    title: Text("OK"),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                        }
                                      }, child:Text("Add",),   style: ElevatedButton.styleFrom(
                                          backgroundColor:AppColorss.lightmainColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          minimumSize: Size(100, 30)
                                      ),)
                                    ],)
                                )

                              ],
                            ),
                          ))
                  );
                },
              );
            },
          );

        },icon: Icon(Icons.add)),
      ))
    ]
  );
}
  Future<void> _addItem(String id, String name)async {
    final isValid=_formU.currentState!.validate();
    if(isValid){
      try{
        setState(() {
          textLoading=true;
        });
        bool x=await invC.idUnique(id.toLowerCase().trim());
        if(x){
          setState(() {
            textLoading=false;
          });
          showPlatformDialog(
            context: context,
            builder: (context) => BasicDialogAlert(
              title: const Text("Authentication Error"),
              content:
              Text("Id already exists"),
              actions: <Widget>[
                BasicDialogAction(
                  title: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }
        else{
          try{
            // DateTime now = DateTime.now();
            // String formattedDate = DateFormat('dd/MM/yy HH:mm a').format(now);

            Inventory inv=Inventory(
              itemId:id.toLowerCase().trim(),
              itemName: name.toLowerCase().trim(),
              status:"Available",
              createdBy:loggedInName?? "Omar",
              creationDate: Timestamp.fromDate(DateTime.now()),
              administeredBy: "",
              borrowedUser: "",
              borrowDeathDate: "",
              deathReason: "",
            );
            await invC.addItem(inv);
            setState(() {
              textLoading=false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Item successfully created!'),
                backgroundColor: Colors.green,
              ),
            );
            _idController.clear();
            _nameController.clear();
            await _getData();
            sendPushMessage("Loose",name);
          }
          catch(e){
            setState(() {
              textLoading=false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error Creating item,try again!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      catch(e){
        setState(() {
          textLoading=false;
        });
        showPlatformDialog(
          context: context,
          builder: (context) => BasicDialogAlert(
            title: Text("Error Occured"),
            content:
            Text(e.toString()),
            actions: <Widget>[
              BasicDialogAction(
                title: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }

    }

  }
  Future<void> _addCompactItem(String id,String name,String description) async{
    final isValid=_formU3.currentState!.validate();
    if(isValid){
      try{
        setState(() {
          compactLoading=true;
        });
        bool x=await invC.idUnique2(id.toLowerCase().trim());
        if(x){
          setState(() {
            compactLoading=false;
          });
          showPlatformDialog(
            context: context,
            builder: (context) => BasicDialogAlert(
              title: Text("Authentication Error"),
              content:
              Text("Id already exists"),
              actions: <Widget>[
                BasicDialogAction(
                  title: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }
        else{
          try{
            CompactInventory inv=CompactInventory(
              itemId:id.toLowerCase().trim(),
              itemName: name.toLowerCase().trim(),
              status:"Available",
              createdBy:loggedInName?? "Omar",
              creationDate: Timestamp.fromDate(DateTime.now()),
              administeredBy: "",
              deathDate: "",
              deathReason: "",
              description: description,
            );
            await invC.addItem2(inv);
            setState(() {
              compactLoading=false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Item successfully created!'),
                backgroundColor: Colors.green,
              ),
            );
            _idController3.clear();
            _nameController3.clear();
            _descriptionController.clear();
            sendPushMessage("Compact",name);
          }
          catch(e){
            setState(() {
              compactLoading=false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error Creating item,try again!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      catch(e){
        setState(() {
          compactLoading=false;
        });
        showPlatformDialog(
          context: context,
          builder: (context) => BasicDialogAlert(
            title: Text("Error Occured"),
            content:
            Text(e.toString()),
            actions: <Widget>[
              BasicDialogAction(
                title: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }

    }
  }
  void sendPushMessage(String type,String name) async {
   try {
     debugPrint("enter send push message of inventory change status");
     await http.post(
       Uri.parse('https://fcm.googleapis.com/fcm/send'),
       headers: <String, String>{
         'Content-Type': 'application/json',
         'Authorization': 'key=AAAAj11i4V8:APA91bHghfWBgt7-fyPnshItM_nM7CESH3tZnO5mAQ9TMA6GJSbyFg9_PTNp4-YQ56v6BIePSufVw4R_wiIW_C5AilRIIteuEV-5ZesQSwGCI1sPu2k6btlvW7a3crBDRXs1tbd4cfix',
       },
       body: jsonEncode(
         <String, dynamic>{
           'notification': <String, dynamic>{
             'body': "$name newly created by $loggedInName",
             'title':"$type inventory update"
           },
           'priority': 'high',
           'data': <String, dynamic>{
             // 'click_action': 'FLUTTER_NOTIFICATION_CLICK',
             'id': '1',
             'status': 'done',
             'notifType':"2",

           },
           "to":"/topics/InventoryBroadCast"
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
  void initState() {
    super.initState();
    _loadData();
    // _loadData2();
  }
  void _loadData()async{
    _getData();
    _getLoggedInName();
  }

  Future<void> _getData()async{
    try{
      List<String> x=await invC.getInventoryItems();
      setState(() {
        allItems=x;
      });
      debugPrint("all the items in stock $allItems");
    }
    catch(e){
      debugPrint("sorry error in additem widget");
    }
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
}
