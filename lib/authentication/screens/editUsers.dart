import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:mrs/authentication/backend/authenticate.dart';

import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../inventory/widgets/scrollable_widget.dart';
import '../../models/Users.dart';

class editUsers extends StatefulWidget {
  const editUsers({Key? key}) : super(key: key);

  @override
  State<editUsers> createState() => _editUsersState();
}

class _editUsersState extends State<editUsers> {
  Authenticate authh=Authenticate();
  String? searchWord;
  List<Userr> allUsers=[];
  var searchController=TextEditingController();
  bool popUpLoading=false;
  bool popUpLoading2=false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar:
      AppBar(
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
                    Text("Edit Users",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.black87),),
                  ],
                ),
                Container(
                  height: screenHeight*0.009,
                  width: screenWidth*0.4,
                  color: AppColorss.darkmainColor,
                ),
                SizedBox(height: screenHeight*0.02,),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        child:    Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width:screenWidth*0.9,
                                  child: TextField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search using name/email...',
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

                  ],)



              ]),


        ),
      ),

    );
  }

  Widget buildTable(){
    List<String> columns=["Action","Username","Email"];
    return DataTable(
      headingRowColor: MaterialStateProperty.resolveWith(
              (states) => AppColorss.lightmainColor),
      headingRowHeight: 30,
      columns: getColumns(columns),
      rows: getRows(allUsers),
      border: TableBorder.all(color: AppColorss.mainblackColor,
          width: 2,borderRadius: BorderRadius.circular(16.0)),);
  }
  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
    label: Text(column,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 20),),
  ))
      .toList();
  List<DataRow> getRows(List<Userr> users) {
    List<Userr> filteredUsers = users;
    bool searchNotEmpty = searchWord?.isNotEmpty ?? false;
    String x = searchWord ?? "a";

    if (searchWord != null && searchNotEmpty) {
      filteredUsers = users.where((user) {
        final nameLower = user.name.toLowerCase();
        final emailLower = user.email.toLowerCase();
        final searchLower = x.toLowerCase();
        return nameLower.contains(searchLower) || emailLower.contains(searchLower);
      }).toList();
    }

    return filteredUsers.map((user) {
      return
        DataRow(
        cells: [
          DataCell(
              // IconButton(onPressed: (){
              //   showDialog(
              //     context: context,
              //     builder: (context) {
              //       bool createP=user.createP;
              //       bool createU=user.addU;
              //       bool inventoryM=user.inventoryM;
              //       return StatefulBuilder(
              //         builder: (context, setState) {
              //           return AlertDialog(
              //               backgroundColor: Colors.white,
              //               titlePadding: EdgeInsets.zero,
              //               title:
              //               Container(
              //                 decoration: BoxDecoration(color:AppColorss.lightmainColor),
              //                 child: Center(
              //                   child: Padding(
              //                     padding: const EdgeInsets.all(13.0),
              //                     child: Text(
              //                       user.name,
              //                       style: TextStyle(color: Colors.white, fontSize: 24),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //               content: SingleChildScrollView(
              //                   child: Container(
              //                     width: double.maxFinite,
              //                     child: Column(
              //                       children: [
              //                         SwitchListTile(
              //                           title:const Text("Create Projects",style: TextStyle(fontSize: 20,color: Color.fromRGBO(62, 68, 71, 1)),),
              //                           onChanged: (bool value){
              //                             setState(() {
              //                               createP=value;
              //                             });},
              //                           value: createP,
              //                           activeColor: AppColorss.darkmainColor,
              //                         ),
              //                         const SizedBox(height: 10,),
              //                         SwitchListTile(
              //                           title:const Text("Create Users",style: TextStyle(fontSize: 20,color: Color.fromRGBO(62, 68, 71, 1)),),
              //                           onChanged: (bool value){
              //                             setState(() {
              //                               createU=value;
              //                             });},
              //                           value: createU,
              //                           activeColor: AppColorss.darkmainColor,
              //                         ),
              //                         SwitchListTile(
              //                           title:const Text("Manage Inventory",style: TextStyle(fontSize: 20,color: Color.fromRGBO(62, 68, 71, 1)),),
              //                           onChanged: (bool value){
              //                             setState(() {
              //                               inventoryM=value;
              //                             });},
              //                           value: inventoryM,
              //                           activeColor: AppColorss.darkmainColor,
              //                         ),
              //                       ],
              //                     ),
              //                   ))
              //           );
              //         },
              //       );
              //     },
              //   );
              // }, icon: Icon(Icons.settings))
              PopupMenuButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    child: Text('Edit User'),
                    value: "av",
                  ),
                  PopupMenuItem(
                    child: Text('Delete'),
                    value: "dead",
                  ),
                ],
                // color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (value) async {
                  if (value == "av") {

                      showDialog(
                        context: context,
                        builder: (context) {
                          bool createP=user.createP;
                          bool createU=user.addU;
                          bool inventoryM=user.inventoryM;
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
                                          user.name,
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
                                            SwitchListTile(
                                              title:const Text("Create Projects",style: TextStyle(fontSize: 20,color: Color.fromRGBO(62, 68, 71, 1)),),
                                              onChanged: (bool value){
                                                setState(() {
                                                  createP=value;
                                                });},
                                              value: createP,
                                              activeColor: AppColorss.darkmainColor,
                                            ),
                                            const SizedBox(height: 10,),
                                            SwitchListTile(
                                              title:const Text("Create Users",style: TextStyle(fontSize: 20,color: Color.fromRGBO(62, 68, 71, 1)),),
                                              onChanged: (bool value){
                                                setState(() {
                                                  createU=value;
                                                });},
                                              value: createU,
                                              activeColor: AppColorss.darkmainColor,
                                            ),
                                            const SizedBox(height: 10,),
                                            SwitchListTile(
                                              title:const Text("Manage Inventory",style: TextStyle(fontSize: 20,color: Color.fromRGBO(62, 68, 71, 1)),),
                                              onChanged: (bool value){
                                                setState(() {
                                                  inventoryM=value;
                                                });},
                                              value: inventoryM,
                                              activeColor: AppColorss.darkmainColor,
                                            ),
                                            const SizedBox(height: 10,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                        ElevatedButton(onPressed: () async {
                                                  setState(() {
                                                    popUpLoading=false;
                                                  });
                                                  Navigator.pop(context);

                                                }, child:Text("Cancel",),   style: ElevatedButton.styleFrom(
                                                    backgroundColor:AppColorss.lightmainColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    minimumSize: Size(100, 30)
                                                ),),
                                                popUpLoading==true?CircularProgressIndicator():ElevatedButton(onPressed: () async {
                                                  // setState(() {
                                                  //   popUpLoading=true;
                                                  // });
                                                  try{
                                                     showPlatformDialog(
                                                context: context,
                                                builder: (context) => BasicDialogAlert(
                                                  title: Text("Editing user privelages"),
                                                  content:
                                                  Text("Are you sure you want to edit?"),
                                                  actions: <Widget>[
                                                    BasicDialogAction(
                                                      title: Text("Yes"),
                                                      onPressed: () async{
                                                        Navigator.pop(context);
                                                        try{
                                                          setState(() {
                                                            popUpLoading=true;
                                                          });
                                                 await authh.updateUser(user.name,createU , createP, inventoryM);
                                                 setState(() {
                                                   popUpLoading=false;
                                                 });
                                                 _getData();

                                                        }
                                                        catch(e){

                                                        }
                                                      },
                                                    ),
                                                    BasicDialogAction(
                                                      title: Text("No"),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                         setState(() {
                                                   popUpLoading=false;
                                                 });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );

                                                  }
                                                  catch(e){

                                                  }

                                                }, child:Text("Save",),   style: ElevatedButton.styleFrom(
                                                    backgroundColor:AppColorss.lightmainColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    minimumSize: Size(100, 30)
                                                ),)
                                              ],
                                            ),

                                          ],
                                        ),
                                      ))
                              );
                            },
                          );
                        },
                      );
                  } else if (value == "dead") {
                    showPlatformDialog(
                      context: context,
                      builder: (context) => BasicDialogAlert(
                        title: Text("Delete user"),
                        content:
                        Text("Are you sure you want to delete ${user.name}?"),
                        actions: <Widget>[
                          BasicDialogAction(
                            title: Text("Yes"),
                            onPressed: () async{

                              Navigator.pop(context);
                              try{
                                setState(() {
                                  popUpLoading2=true;
                                });
                                await authh.deleteUser(user.email,user.password);
                                setState(() {
                                  popUpLoading2=false;
                                });
                                _getData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('User ${user.name} successfully deleted!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );


                              }
                              catch(e){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting ${user.name}, please try again!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                          BasicDialogAction(
                            title: Text("No"),
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                popUpLoading2=false;
                              });
                            },
                          ),
                        ],
                      ),
                    );

                  }
                },
              )

          ),
          DataCell(Text(user.name)),
          DataCell(Text(user.email)),
        ],
      );
    }).toList();
  }
  // DataRow _buildDataRow(String data){
  //   return DataRow(
  //       cells: <DataCell>[
  //         DataCell(Text(data,style: TextStyle(fontSize: 18),)),
  //         DataCell(SizedBox(
  //           height: 30,
  //           child: IconButton(onPressed: (){
  //             showDialog(
  //               context: context,
  //               builder: (context) {
  //                 String contentText = "Content of Dialog";
  //                 return StatefulBuilder(
  //                   builder: (context, setState) {
  //                     return AlertDialog(
  //                         backgroundColor: Colors.white,
  //                         titlePadding: EdgeInsets.zero,
  //                         title:
  //                         Container(
  //                           decoration: BoxDecoration(color:AppColorss.lightmainColor),
  //                           child: Center(
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(13.0),
  //                               child: Text(
  //                                 data,
  //                                 style: TextStyle(color: Colors.white, fontSize: 24),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         content: SingleChildScrollView(
  //                             child: Container(
  //                               width: double.maxFinite,
  //                               child: Column(
  //                                 children: [
  //                                   Form(
  //                                       key:_formU2,
  //                                       child:Column(children: [
  //                                         SizedBox(height: 10,),
  //                                         FractionallySizedBox(
  //                                           widthFactor: 0.8,
  //                                           child: TextFormField(
  //                                               controller: _idController2,
  //                                               inputFormatters: [
  //                                                 FilteringTextInputFormatter.deny(new RegExp(r"\s"))
  //                                               ],
  //                                               decoration: const InputDecoration(
  //                                                 labelText: 'Id',
  //                                                 hintText: "Enter item's id",
  //                                                 border: OutlineInputBorder(),
  //                                                 focusedBorder: OutlineInputBorder(
  //                                                     borderSide: BorderSide(color:Color(0xFF005466))
  //                                                 ),
  //                                               ),
  //                                               validator:(value) {
  //                                                 if (value!.trim().isEmpty) {
  //                                                   return "Please enter an id";
  //                                                 }
  //                                                 return null;
  //                                               }
  //                                           ),
  //
  //                                         ),
  //                                         SizedBox(height:10,),
  //                                         popUpLoading==true?CircularProgressIndicator():ElevatedButton(onPressed: () async {
  //
  //                                           final isValid=_formU2.currentState!.validate();
  //                                           debugPrint("pop up $isValid");
  //                                           if(isValid){
  //                                             setState(() {
  //                                               popUpLoading=true;
  //                                             });
  //                                             try{
  //                                               bool x=await invC.idUnique(_idController2.text.toLowerCase().trim());
  //                                               if(x){
  //                                                 setState(() {
  //                                                   popUpLoading=false;
  //                                                 });
  //                                                 showPlatformDialog(
  //                                                   context: context,
  //                                                   builder: (context) => BasicDialogAlert(
  //                                                     title: Text("Authentication Error"),
  //                                                     content:
  //                                                     Text("Id already exists"),
  //                                                     actions: <Widget>[
  //                                                       BasicDialogAction(
  //                                                         title: Text("OK"),
  //                                                         onPressed: () {
  //                                                           Navigator.pop(context);
  //                                                         },
  //                                                       ),
  //                                                     ],
  //                                                   ),
  //                                                 );
  //                                               }
  //                                               else{
  //                                                 try{
  //                                                   Inventory inv=Inventory(
  //                                                     itemId:_idController2.text.toLowerCase().trim(),
  //                                                     itemName: data.toLowerCase().trim(),
  //                                                     status:"Available", createdBy:loggedInName?? "Omar",
  //                                                     creationDate: Timestamp.fromDate(DateTime.now()),
  //                                                     administeredBy: "",
  //                                                     borrowedUser: "",
  //                                                     borrowDeathDate: "",
  //                                                     deathReason: "",);
  //
  //                                                   await invC.addItem(inv);
  //                                                   setState(() {
  //                                                     popUpLoading=false;
  //                                                   });
  //
  //                                                   sendPushMessage("Loose",data.toLowerCase().trim());
  //                                                   ScaffoldMessenger.of(context).showSnackBar(
  //                                                     SnackBar(
  //                                                       content: Text('Item successfully created!'),
  //                                                       backgroundColor: Colors.green,
  //                                                     ),
  //                                                   );
  //                                                   _idController2.clear();
  //                                                   _nameController2.clear();
  //                                                   await _getData();
  //                                                 }
  //                                                 catch(e){
  //                                                   setState(() {
  //                                                     popUpLoading=false;
  //                                                   });
  //                                                   ScaffoldMessenger.of(context).showSnackBar(
  //                                                     SnackBar(
  //                                                       content: Text('Error adding item,try again!'),
  //                                                       backgroundColor: Colors.red,
  //                                                     ),
  //                                                   );
  //                                                 }
  //                                               }
  //                                             }
  //                                             catch(e){
  //                                               setState(() {
  //                                                 popUpLoading=false;
  //                                               });
  //                                               showPlatformDialog(
  //                                                 context: context,
  //                                                 builder: (context) => BasicDialogAlert(
  //                                                   title: Text("Error Occured"),
  //                                                   content:
  //                                                   Text(e.toString()),
  //                                                   actions: <Widget>[
  //                                                     BasicDialogAction(
  //                                                       title: Text("OK"),
  //                                                       onPressed: () {
  //                                                         Navigator.pop(context);
  //                                                       },
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               );
  //                                             }
  //
  //                                           }
  //                                         }, child:Text("Add",),   style: ElevatedButton.styleFrom(
  //                                             backgroundColor:AppColorss.lightmainColor,
  //                                             shape: RoundedRectangleBorder(
  //                                               borderRadius: BorderRadius.circular(15),
  //                                             ),
  //                                             minimumSize: Size(100, 30)
  //                                         ),)
  //                                       ],)
  //                                   )
  //
  //                                 ],
  //                               ),
  //                             ))
  //                     );
  //                   },
  //                 );
  //               },
  //             );
  //
  //           },icon: Icon(Icons.add)),
  //         ))
  //       ]
  //   );
  // }

  void initState() {
    super.initState();
    _loadData();
    // _loadData2();
  }
  void _loadData()async{
    _getData();

  }

  Future<void> _getData()async{
    try{
      List<Userr> x=await authh.getAllUsers();
      setState(() {
        allUsers=x;
      });
      debugPrint("all the items in stock $allUsers");
    }
    catch(e){
      debugPrint("sorry error in additem widget");
    }
  }

  // DataRow _buildDataRow(String data){
  //   return DataRow(
  //       cells: <DataCell>[
  //         DataCell(Text(data,style: TextStyle(fontSize: 18),)),
  //         DataCell(SizedBox(
  //           height: 30,
  //           child: IconButton(onPressed: (){
  //             showDialog(
  //               context: context,
  //               builder: (context) {
  //                 String contentText = "Content of Dialog";
  //                 return StatefulBuilder(
  //                   builder: (context, setState) {
  //                     return AlertDialog(
  //                         backgroundColor: Colors.white,
  //                         titlePadding: EdgeInsets.zero,
  //                         title:
  //                         Container(
  //                           decoration: BoxDecoration(color:AppColorss.lightmainColor),
  //                           child: Center(
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(13.0),
  //                               child: Text(
  //                                 data,
  //                                 style: TextStyle(color: Colors.white, fontSize: 24),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         content: SingleChildScrollView(
  //                             child: Container(
  //                               width: double.maxFinite,
  //                               child: Column(
  //                                 children: [
  //                                   Form(
  //                                       key:_formU2,
  //                                       child:Column(children: [
  //                                         SizedBox(height: 10,),
  //                                         FractionallySizedBox(
  //                                           widthFactor: 0.8,
  //                                           child: TextFormField(
  //                                               controller: _idController2,
  //                                               inputFormatters: [
  //                                                 FilteringTextInputFormatter.deny(new RegExp(r"\s"))
  //                                               ],
  //                                               decoration: const InputDecoration(
  //                                                 labelText: 'Id',
  //                                                 hintText: "Enter item's id",
  //                                                 border: OutlineInputBorder(),
  //                                                 focusedBorder: OutlineInputBorder(
  //                                                     borderSide: BorderSide(color:Color(0xFF005466))
  //                                                 ),
  //                                               ),
  //                                               validator:(value) {
  //                                                 if (value!.trim().isEmpty) {
  //                                                   return "Please enter an id";
  //                                                 }
  //                                                 return null;
  //                                               }
  //                                           ),
  //
  //                                         ),
  //                                         SizedBox(height:10,),
  //                                         popUpLoading==true?CircularProgressIndicator():ElevatedButton(onPressed: () async {
  //
  //                                           final isValid=_formU2.currentState!.validate();
  //                                           debugPrint("pop up $isValid");
  //                                           if(isValid){
  //                                             setState(() {
  //                                               popUpLoading=true;
  //                                             });
  //                                             try{
  //                                               bool x=await invC.idUnique(_idController2.text.toLowerCase().trim());
  //                                               if(x){
  //                                                 setState(() {
  //                                                   popUpLoading=false;
  //                                                 });
  //                                                 showPlatformDialog(
  //                                                   context: context,
  //                                                   builder: (context) => BasicDialogAlert(
  //                                                     title: Text("Authentication Error"),
  //                                                     content:
  //                                                     Text("Id already exists"),
  //                                                     actions: <Widget>[
  //                                                       BasicDialogAction(
  //                                                         title: Text("OK"),
  //                                                         onPressed: () {
  //                                                           Navigator.pop(context);
  //                                                         },
  //                                                       ),
  //                                                     ],
  //                                                   ),
  //                                                 );
  //                                               }
  //                                               else{
  //                                                 try{
  //                                                   Inventory inv=Inventory(
  //                                                     itemId:_idController2.text.toLowerCase().trim(),
  //                                                     itemName: data.toLowerCase().trim(),
  //                                                     status:"Available", createdBy:loggedInName?? "Omar",
  //                                                     creationDate: Timestamp.fromDate(DateTime.now()),
  //                                                     administeredBy: "",
  //                                                     borrowedUser: "",
  //                                                     borrowDeathDate: "",
  //                                                     deathReason: "",);
  //
  //                                                   await invC.addItem(inv);
  //                                                   setState(() {
  //                                                     popUpLoading=false;
  //                                                   });
  //
  //                                                   sendPushMessage("Loose",data.toLowerCase().trim());
  //                                                   ScaffoldMessenger.of(context).showSnackBar(
  //                                                     SnackBar(
  //                                                       content: Text('Item successfully created!'),
  //                                                       backgroundColor: Colors.green,
  //                                                     ),
  //                                                   );
  //                                                   _idController2.clear();
  //                                                   _nameController2.clear();
  //                                                   await _getData();
  //                                                 }
  //                                                 catch(e){
  //                                                   setState(() {
  //                                                     popUpLoading=false;
  //                                                   });
  //                                                   ScaffoldMessenger.of(context).showSnackBar(
  //                                                     SnackBar(
  //                                                       content: Text('Error adding item,try again!'),
  //                                                       backgroundColor: Colors.red,
  //                                                     ),
  //                                                   );
  //                                                 }
  //                                               }
  //                                             }
  //                                             catch(e){
  //                                               setState(() {
  //                                                 popUpLoading=false;
  //                                               });
  //                                               showPlatformDialog(
  //                                                 context: context,
  //                                                 builder: (context) => BasicDialogAlert(
  //                                                   title: Text("Error Occured"),
  //                                                   content:
  //                                                   Text(e.toString()),
  //                                                   actions: <Widget>[
  //                                                     BasicDialogAction(
  //                                                       title: Text("OK"),
  //                                                       onPressed: () {
  //                                                         Navigator.pop(context);
  //                                                       },
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               );
  //                                             }
  //
  //                                           }
  //                                         }, child:Text("Add",),   style: ElevatedButton.styleFrom(
  //                                             backgroundColor:AppColorss.lightmainColor,
  //                                             shape: RoundedRectangleBorder(
  //                                               borderRadius: BorderRadius.circular(15),
  //                                             ),
  //                                             minimumSize: Size(100, 30)
  //                                         ),)
  //                                       ],)
  //                                   )
  //
  //                                 ],
  //                               ),
  //                             ))
  //                     );
  //                   },
  //                 );
  //               },
  //             );
  //
  //           },icon: Icon(Icons.add)),
  //         ))
  //       ]
  //   );
  // }
}
