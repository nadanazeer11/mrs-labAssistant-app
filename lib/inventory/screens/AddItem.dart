import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:mrs/models/Inventory.dart';
import 'package:intl/intl.dart';
import '../../common.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../backend/inventContr.dart';
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
            Text("Add Item",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.black87),),
            Container(
            height: screenHeight*0.009,
            width: screenWidth*0.4,
            color: AppColorss.darkmainColor,
          ),
            SizedBox(height: screenHeight*0.02,),
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
                          ElevatedButton(onPressed: (){
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
    return allItems?.where((data) => data.contains(x)).map((data) =>
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
            builder: (context) =>
                buildAvailableAlert(
                    context, data),
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
        bool x=await invC.idUnique(id.toLowerCase().trim());
        if(x){
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
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('dd/MM/yy HH:mm a').format(now);

            Inventory inv=Inventory(
              itemId:id.toLowerCase().trim(),
              itemName: name.toLowerCase().trim(),
              status:"Available",
              createdBy:loggedInName?? "Omar",
              creationDate: Timestamp.fromDate(DateTime.now()),
              administeredBy: "",
              borrowedUser: "",
              borrowDeathDate: formattedDate,
              deathReason: "",
            );
            await invC.addItem(inv);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Item successfully created!'),
                backgroundColor: Colors.green,
              ),
            );
            _idController.clear();
            _nameController.clear();
            await _getData();
          }
          catch(e){
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
  Future<void> _addItem2(String id, String name)async {
   final isValid=_formU2.currentState!.validate();
   debugPrint("pop up $isValid");
   if(isValid){
     try{
       bool x=await invC.idUnique(id.toLowerCase().trim());
       if(x){
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
             itemId:id.toLowerCase().trim(),
             itemName: name.toLowerCase().trim(),
             status:"Available", createdBy:loggedInName?? "Omar",
             creationDate: Timestamp.fromDate(DateTime.now()),
             administeredBy: "",
             borrowedUser: "",
             borrowDeathDate: "",
             deathReason: "",);

           await invC.addItem(inv);
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
  AlertDialog buildAvailableAlert(BuildContext context, String itemName){
    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(color:AppColorss.lightmainColor),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Text(
              itemName,
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
                ElevatedButton(onPressed: (){
                  popUpLoading=true;
                  _addItem2(_idController2.text.toLowerCase().trim(),itemName.toLowerCase().trim());

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
 }
}
