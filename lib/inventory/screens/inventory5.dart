import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:mrs/models/Inventory.dart';
import 'package:mrs/models/Project.dart';
import 'package:intl/intl.dart';
import '../../common.dart';
import '../../config/colors.dart';
import '../backend/inventContr.dart';
import '../widgets/scrollable_widget.dart';

class Inventory5 extends StatefulWidget {
  const Inventory5({Key? key}) : super(key: key);

  @override
  State<Inventory5> createState() => _Inventory5State();
}

class _Inventory5State extends State<Inventory5>{
  int x=0;
  String ? filter;
  String loggedInName="";
  String? loggedInId;
  final columns = ['Id', 'Name', 'Status',"Creation Date","Created By"];
  String? searchWord;
  var searchController=TextEditingController();
  bool isAdmin=false;
  List<String> ? allAdmins;
  bool isTrue=false;

  @override
  void initState() {
    super.initState();
    _loadData();

  }

  void _loadData() async {
    debugPrint("load data");
    await _getLoggedInId();
    await _getLoggedInName();
    await _isAdmin();
    await _getAdmins();
    setState(() {
      isTrue=true;
    });
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
  Future<void> _isAdmin() async{
    try{
      bool x=await inventoryC.isAdmin(loggedInId);
      setState(() {
        isAdmin=x;
      });
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error checking if inventory manager"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _getAdmins() async{
    try{
      List<String> admins=await inventoryC.allAdmins();
      setState(() {
        allAdmins=admins;
      });
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error getting admins"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  InventContr inventoryC=InventContr();

  @override
  Widget build(BuildContext context) {
    if(isTrue){
      return StreamBuilder<List<Inventory>>(
          stream: inventoryC.getInventoryLoose(),
          builder: (context,snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              //return Center(child: CircularProgressIndicator());
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(children: [
                        Text("Inventory",style: TextStyle(fontSize: 28,color: Colors.black,fontWeight: FontWeight.bold),),
                        PopupMenuButton(
                          icon: Icon(Icons.filter_alt_rounded,color: AppColorss.darkmainColor,),
                          itemBuilder: (BuildContext context)=>[
                            PopupMenuItem(
                              child: Text('Loading'),
                              value: "Me",
                            ),
                          ],
                          // color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onSelected: (value) {
                            debugPrint('your p${value}');

                          },
                        ),
                        filter!=null ? Row(children: [
                          Text("$filter",style: TextStyle(color: AppColorss.fontGrey,fontSize: 19,fontWeight: FontWeight.w400),),
                          IconButton(onPressed: (){
                            setState(() {
                              filter=null;
                            });
                          }, icon: Icon(Icons.clear))
                        ]):Container()
                      ],),

                       CircularProgressIndicator()
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              // Show error message
            }
            if(snapshot.hasData){
              debugPrint("i have dataaaaaaaaa");
              List<Inventory> ?invent=snapshot.data;
              return  Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(children: [
                        Text("Inventory",style: TextStyle(fontSize: 28,color: Colors.black,fontWeight: FontWeight.bold),),
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
                        filter!=null ? Row(children: [
                          Text("$filter",style: TextStyle(color: AppColorss.fontGrey,fontSize: 19,fontWeight: FontWeight.w400),),
                          IconButton(onPressed: (){
                            setState(() {
                              filter=null;
                            });
                          }, icon: Icon(Icons.clear))
                        ]):Container()
                      ],),
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search using id...',
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
                      SizedBox(height: 15,),
                      ScrollableWidget(child: buildDataTable(invent)),


                    ],
                  ),
                ),
              );
            }
            return Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ));
          });

    }
    else{
      return Center(child: CircularProgressIndicator(),);
    }

  }
  Widget buildDataTable(List<Inventory>? inventory) {
    // final columns = ['Id', 'Name', 'Status',"Creation Date"];

    return DataTable(
      headingRowColor: MaterialStateProperty.resolveWith(
              (states) => AppColorss.lightmainColor),
      headingRowHeight: 30,
      columns: getColumns(columns),
      rows: getInventoryRows(inventory),
      border: TableBorder.all(color: AppColorss.mainblackColor,
          width: 2,borderRadius: BorderRadius.circular(16.0)),);


  }
  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
    label: Text(column,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
  ))
      .toList();


  List<DataRow> getInventoryRows(List<Inventory>? inventory) {
    if(filter==null && searchWord==null){
      return inventory?.map((data) =>_buildDataRow(data)).toList() ?? [];
    }
    if(searchWord!=null){
      String x=searchWord??"a";
      return inventory?.where((data) => data.itemId.startsWith(x)).map((data) =>
          _buildDataRow(data)).toList() ?? [];
    }
    return inventory?.map((data) =>_buildDataRow(data)).toList() ?? [];

  }
  DataRow _buildDataRow(Inventory data) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(data.itemId)),
        DataCell(Text(data.itemName)),
        DataCell(GestureDetector(
          onTap: () {
            debugPrint("${data.status} pressed on status");
            if(data.status=="Borrowed"|| data.status=="Dead") {
              String type = data.status == "Borrowed" ? "Borrowed" : "Dead";
              String borrowedBy = data.borrowedUser;
              String borrowedFrom = data.borrowedFrom;
              String borrowedDate = DateFormat.yMd().format(
                  data.creationDate.toDate());
              String itemName = data.itemName + " " + "#" + data.itemId;
              showDialog(
                context: context,
                builder: (context) =>
                    buildAlertDialog(
                        context, borrowedBy, borrowedFrom, type, itemName,
                        borrowedDate),
              );
            }
            else if (data.status=="Available"){
              String itemName = data.itemName + " " + "#" + data.itemId;
              showDialog(
                context: context,
                builder: (context) =>
                    buildAvailableAlert(
                        context,itemName),
              );
            }
          },
          child:Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,

            children: [
              Chip(
                padding: data.status=="Dead"?EdgeInsets.symmetric(horizontal: 16):null,
                label: Text(data.status),backgroundColor: data.status=="Available"?const Color(0xFFB2E672):data.status=="Dead"?Color(0xFFFF4646):Color(0xFFFEFF86),),
              ] ,
          ),
        ),
        ),
        DataCell(Text(DateFormat.yMd().format(data.creationDate.toDate()))),
        DataCell(Text(data.createdBy)),
      ],
    );
  }

  AlertDialog buildAlertDialog(BuildContext context, String actionuser, String actionAdmin,String type,String itemName,String userDate) {
    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title:  Container(
        decoration: BoxDecoration(color:AppColorss.lightmainColor),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Text(itemName,style: TextStyle(color: Colors.white,fontSize: 24),),
          ),
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(children: [
            type=="Borrowed"?Row(
              children: [
                RichText(
                  text: TextSpan(
                    text:'Borrowed By:' ,
                    style: TextStyle(fontWeight:FontWeight.w400,fontSize: 24,color: Colors.black),
                    children:  <TextSpan>[
                      TextSpan(text:" "),
                      TextSpan(text:actionuser, style: TextStyle(fontWeight: FontWeight.w400,color:AppColorss.darkFontGrey)),
                    ],
                  ),
                )
              ],
            ):
            Row(
              children: [
                Text("Death Reason:",style: TextStyle(fontWeight:FontWeight.w400,fontSize: 24,color: Colors.black),
                    ),
                Expanded(
                  child: Text(actionuser, style: TextStyle(fontWeight: FontWeight.w400,fontSize:22,color:AppColorss.darkFontGrey),
                  ),
                )
              ],
            ) ,
            const SizedBox(height: 15,),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Administered By: ',
                      style: TextStyle(fontWeight:FontWeight.w400,fontSize: 24,color: Colors.black),
                      children:  <TextSpan>[
                        TextSpan(text:actionAdmin, style: TextStyle(fontWeight: FontWeight.w400,color:AppColorss.darkFontGrey)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.black, size: 24),
                SizedBox(width: 14,),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: '',
                      style: TextStyle(fontWeight:FontWeight.w400,fontSize: 24,color: Colors.black),
                      children:  <TextSpan>[
                        TextSpan(text:userDate, style: TextStyle(fontWeight: FontWeight.w400,color:AppColorss.darkFontGrey)),
                      ],
                    ),
                  ),
                )
              ],
            ),


          ]),
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      actions: [
        ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor:AppColorss.lightmainColor,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    ),
    minimumSize: Size(100, 30)
    ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK!'),
        )
      ],
    );
  }



  AlertDialog buildAvailableAlert(BuildContext context, String itemName) {
    List<String> myList = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
    debugPrint("${allAdmins?.length}");
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
              const Text(
                "Item is available for for borrowing from:",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 13),
              ListView.builder(
                shrinkWrap: true,
                itemCount:allAdmins?.length??0,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Icon(Icons.arrow_forward_ios_outlined,color: AppColorss.darkFontGrey,),
                      const SizedBox(width: 14),
                      Text("${allAdmins?[index]}",style:TextStyle( color: AppColorss.darkFontGrey),),
                    ],
                  );
                },
              ),

            ],
          ),
          
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
             backgroundColor:AppColorss.lightmainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: Size(100, 30)
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK!'),
        )
      ],
    );
  }


}
