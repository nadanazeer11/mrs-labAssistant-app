import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:mrs/models/Inventory.dart';
import 'package:mrs/models/Project.dart';
import 'package:intl/intl.dart';
import '../../common.dart';
import '../../config/colors.dart';
import '../../models/InventoryItems.dart';
import '../backend/inventContr.dart';
import '../widgets/scrollable_widget.dart';

class Inventory5 extends StatefulWidget {
  const Inventory5({Key? key}) : super(key: key);

  @override
  State<Inventory5> createState() => _Inventory5State();
}

class _Inventory5State extends State<Inventory5> {
  int x = 0;
  String ? filter;
  String loggedInName = "";
  String? loggedInId;
  final columns = ['Id', 'Name', 'Status', "Creation Date", "Created By"];
  String? searchWord;
  var searchController = TextEditingController();
  bool isAdmin = false;
  List<String> ? allAdmins;
  bool isTrue = false;
  bool isHovered = false;
  List<InventorySummary> list = [];
  bool loadSummary = false;
  final _formU2=GlobalKey<FormState>();
  final _formReturnBack=GlobalKey<FormState>();
  final _formdead=GlobalKey<FormState>();
  var borrowUserController=TextEditingController();
  var returnUserController=TextEditingController();
  var deadReasonController=TextEditingController();

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
      isTrue = true;
    });
    // await saveFile();
  }

  Future<void> _getLoggedInName() async {
    try {
      String x = await getLoggedInName();
      setState(() {
        loggedInName = x;
      });
    }
    catch (e) {
      setState(() {

      });
    }
  }

  Future<void> _getLoggedInId() async {
    try {
      String x = await getIdofUser();
      setState(() {
        loggedInId = x;
      });
      debugPrint("iddddddddddddddddd$loggedInId");
    }
    catch (e) {
      setState(() {});
    }
  }

  Future<void> _isAdmin() async {
    try {
      bool x = await inventoryC.isAdmin(loggedInId);
      setState(() {
        isAdmin = x;
      });
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error checking if inventory manager"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getAdmins() async {
    try {
      List<String> admins = await inventoryC.allAdmins();
      setState(() {
        allAdmins = admins;
      });
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error getting admins"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InventContr inventoryC = InventContr();

  @override
  Widget build(BuildContext context) {
    if (isTrue) {
      return StreamBuilder<List<Inventory>>(
          stream: inventoryC.getInventoryLoose(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              //return Center(child: CircularProgressIndicator());
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(children: [
                        Text("Inventory", style: TextStyle(fontSize: 28,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),),
                        PopupMenuButton(
                          icon: Icon(Icons.filter_alt_rounded, color: AppColorss
                              .darkmainColor,),
                          itemBuilder: (BuildContext context) =>
                          [
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
                        filter != null ? Row(children: [
                          Text("$filter", style: TextStyle(
                              color: AppColorss.fontGrey,
                              fontSize: 19,
                              fontWeight: FontWeight.w400),),
                          IconButton(onPressed: () {
                            setState(() {
                              filter = null;
                            });
                          }, icon: Icon(Icons.clear))
                        ]) : Container()
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
            if (snapshot.hasData) {
              debugPrint("i have dataaaaaaaaa");
              List<Inventory> ?invent = snapshot.data;
              debugPrint("${snapshot.data}");
              return Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(children: [
                        const Text("Inventory", style: TextStyle(fontSize: 28,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),),
                        PopupMenuButton(
                          icon: Icon(Icons.filter_alt_rounded, color: AppColorss
                              .darkmainColor,),
                          itemBuilder: (BuildContext context) =>
                          [
                            const PopupMenuItem(
                              value: "Available",
                              child: Text('Available'),
                            ),
                            const PopupMenuItem(
                              value: "Borrowed",
                              child: Text("Borrowed"),
                            ),
                            const PopupMenuItem(
                              value: "Dead",
                              child: Text('Dead'),
                            ),

                          ],
                          // color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onSelected: (value) {
                            debugPrint('your p$value');
                            setState(() {
                              filter = value;
                            });
                          },
                        ),
                        filter != null ? Row(children: [
                          Text("$filter", style: TextStyle(
                              color: AppColorss.fontGrey,
                              fontSize: 19,
                              fontWeight: FontWeight.w400),),
                          IconButton(onPressed: () {
                            setState(() {
                              filter = null;
                            });
                          }, icon: const Icon(Icons.clear))
                        ]) : Container(),
                        Spacer(),
                        Expanded(
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: loadSummary == true
                                  ? CircularProgressIndicator()
                                  : IconButton(onPressed: () {
                                getSumm(context);
                              },
                                hoverColor: AppColorss.lightmainColor,
                                icon: Icon(Icons.summarize_outlined),
                                color: Colors.grey,)),
                        ),
                      ],),
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search using id/name...',
                          prefixIcon: searchWord == null ? IconButton(
                            onPressed: () {
                              setState(() {
                                searchWord = searchController.text;
                              });
                            }, icon: const Icon(Icons.search),) : IconButton(
                            onPressed: () {
                              setState(() {
                                searchWord = null;
                                searchController.clear();
                              });
                            }, icon: const Icon(Icons.clear),),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          contentPadding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(height: 15,),
                      // PaginatedDataTable(
                      //   columns:getColumns(columns),
                      //     rowsPerPage: 2,
                      //     source:
                      //     RowSource(
                      //       myData: invent?? [],
                      //       count: invent == null ? 0 : invent.length,
                      //       searchWord: searchWord,
                      //       filter: filter
                      //
                      //     )
                      //
                      // ),
                      ScrollableWidget(child: buildDataTable(invent),),
                    ],
                  ),
                ),
              );
            }
            return const Center(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ));
          });
    }
    else {
      return const Center(child: CircularProgressIndicator(),);
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
          width: 2, borderRadius: BorderRadius.circular(16.0)),);
  }

  List<DataColumn> getColumns(List<String> columns) =>
      columns
          .map((String column) =>
          DataColumn(
            label: Text(column, style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),),
          ))
          .toList();


  List<DataRow> getInventoryRows(List<Inventory>? inventory) {
    String x = searchWord ?? "a";
    String filters = filter ?? "all";
    bool searchNotEmpty = searchWord?.isNotEmpty ?? false;
    bool filterNotEmpty = filter?.isNotEmpty ?? false;
    return inventory?.where((data) {
      if (searchWord != null && searchNotEmpty) {
        if (data.itemName.toLowerCase().contains(x.trim().toLowerCase()) ||
            data.itemId.trim().startsWith(x)) {
          if (filter != null && filterNotEmpty) {
            if (data.status == filter) {
              return true;
            } else {
              return false;
            }
          } else {
            return true;
          }
        } else {
          return false;
        }
      }
      if (filter != null && filterNotEmpty) {
        if (data.status == filter) {
          if (searchWord != null && searchNotEmpty) {
            if (data.itemName.toLowerCase().contains(x.trim().toLowerCase())) {
              return true;
            }
            else {
              return false;
            }
          }
          else {
            return true;
          }
        }
        else {
          return false;
        }
      }

      return true;
    }).map((data) => buildDataRow(data)).toList() ?? [];
  }

  DataRow buildDataRow(Inventory data) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Row(
          children: [
            Text(data.itemId),
          ],
        )),
        DataCell(Text(data.itemName)),
        DataCell(GestureDetector(
          onTap: () {
            debugPrint("${data.status} pressed on status");
            if (data.status == "Borrowed" || data.status == "Dead") {
              String type = data.status == "Borrowed" ? "Borrowed" : "Dead";
              String borrowedBy = data.borrowedUser;
              String administeredBy = data.administeredBy;
              String borrowDeathDate =data.borrowDeathDate;
              String deathReason=data.deathReason;
              String itemName = "${data.itemName} #${data.itemId}";
              String itemName2=data.itemName;
              String itemId=data.itemId;
              showDialog(
                context: context,
                builder: (context) =>
                    buildAlertDialog(
                        context, borrowedBy, administeredBy, type,itemId, itemName2,
                        borrowDeathDate,deathReason),
              );
            }
            else if (data.status == "Available") {
              String itemName = "${data.itemName} #${data.itemId}";
              String itemName2=data.itemName;
              String itemId=data.itemId;

              showDialog(
                context: context,
                builder: (context) =>
                    buildAvailableAlert(
                        context, itemName2,itemId),
              );
            }
          },
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,

            children: [
              Chip(
                padding: data.status == "Dead" ? EdgeInsets.symmetric(
                    horizontal: 16) : null,
                label: Text(data.status),
                backgroundColor: data.status == "Available" ? const Color(
                    0xFFB2E672) : data.status == "Dead"
                    ? Color(0xFFFF4646)
                    : Color(0xFFFEFF86),),
            ],
          ),
        ),
        ),
        DataCell(Text(DateFormat.yMd().format(data.creationDate.toDate()))),
        DataCell(Text(data.createdBy)),
      ],
    );
  }

  AlertDialog buildAlertDialog(BuildContext context, String borrowedBy,
      String administeredBy, String type,String itemId, String itemName, String userDate,String deathReason) {
    String itemName2 = "$itemName #$itemId";

    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(color: AppColorss.lightmainColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            type=="Borrowed"?
            PopupMenuButton(
              icon: Icon(Icons.settings, color: Colors.white,),
              itemBuilder: (BuildContext context) =>
              [
                PopupMenuItem(
                  child: Text('Return item'),
                  value: "av",
                ),
                PopupMenuItem(
                  child: Text('Mark as dead'),
                  value: "dead",
                ),
              ],
              // color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (value) {
                  if(value=="av"){
                    String status="Return";
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) =>
                          returnBackDeadAlert(context,itemName,itemId,"Return"),
                    );
                  }
                  if(value=="dead"){
                    showDialog(
                      context: context,
                      builder: (context) =>
                          returnBackDeadAlert(
                              context, itemName,itemId,"Dead"),
                    );
                  }

              },
            ):Container(),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text(
                  itemName2, style: TextStyle(color: Colors.white, fontSize: 24),),
              ),
            ),
          ],
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(children: [
            type == "Borrowed" ? Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Borrowed By:',
                    style: TextStyle(fontWeight: FontWeight.w400,
                        fontSize: 24,
                        color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: " "),
                      TextSpan(text: borrowedBy,
                          style: TextStyle(fontWeight: FontWeight.w400,
                              color: AppColorss.darkFontGrey)),
                    ],
                  ),
                )
              ],
            ) :
            Row(
              children: [
                Text("Death Reason:", style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                    color: Colors.black),
                ),
                Expanded(
                  child: Text(deathReason, style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 22,
                      color: AppColorss.darkFontGrey),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15,),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Authorized by: ',
                      style: TextStyle(fontWeight: FontWeight.w400,
                          fontSize: 24,
                          color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(text: administeredBy, style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: AppColorss.darkFontGrey)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: Colors.black,
                    size: 24),
                SizedBox(width: 14,),
                Expanded(
                  child:Text(userDate, style: TextStyle(
                    fontSize: 22,

                      fontWeight: FontWeight.w400,
                      color: AppColorss.darkFontGrey))
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
              backgroundColor: AppColorss.lightmainColor,
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

  AlertDialog statusAlert(BuildContext context, String itemName,String itemId){
    String itemName2 = "$itemName #$itemId";
    return AlertDialog(
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(color:AppColorss.lightmainColor),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Text(
                itemName2,
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
                              controller: borrowUserController,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(new RegExp(r"\s"))
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: "Give access to",
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
                          final isValid = _formU2.currentState!.validate();
                          if(isValid){
                            borrowTo(context,
                                itemId,borrowUserController.text.trim().toLowerCase());

                          }
                        }, child:Text("Give Access",),   style: ElevatedButton.styleFrom(
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


  AlertDialog buildSummaryAlert(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(color: AppColorss.lightmainColor),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(13.0),
            child: Text(
              "Inventory Summary",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
      content:
      SizedBox(
        width: screenWidth * 0.99,
        child: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    InventorySummary x = list[index];
                    return Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.arrow_forward_ios_outlined,
                              color: AppColorss.darkFontGrey,),
                            const SizedBox(width: 14),
                            Text(x.itemName, style: TextStyle(
                                color: AppColorss.darkFontGrey),),
                          ],
                        ),
                        SizedBox(height: 12,),
                        DataTable(
                          headingRowHeight: 28,
                          dataRowHeight: 28,
                          columnSpacing: 20,
                          border: TableBorder.all(color: Colors.black38,
                              width: 2,
                              borderRadius: BorderRadius.circular(2.0)),
                          columns: const [
                            DataColumn(label: Text('Available')),
                            DataColumn(label: Text('Borrowed')),
                            DataColumn(label: Text('Dead')),
                          ],
                          rows: [
                            DataRow(cells: [
                              DataCell(Text(x.availableCount.toString())),
                              DataCell(Text(x.borrowedCount.toString())),
                              DataCell(Text(x.deadCount.toString())),
                            ]),
                          ],
                        ),
                        SizedBox(height: 12,),

                      ],
                    );
                  },
                ),

              ],
            ),

          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColorss.lightmainColor,
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
  Future<void> getSumm(BuildContext context) async {
    try {
      loadSummary = true;
      List<InventorySummary> m = await inventoryC.getSummary();
      setState(() {
        list = m;
      });
      loadSummary = false;
      showDialog(
        context: context,
        builder: (context) =>
            buildSummaryAlert(context),
      );
    }
    catch (e) {
      loadSummary = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error getting summary"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> borrowTo(BuildContext context,String itemId,String username)async{
    try{
      bool exists=await inventoryC.userNameCheck(username);
      if(exists){
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('dd/MM/yy HH:mm a').format(now);
        changeStatus(context, itemId, formattedDate, username,"Borrowed","");
      }
      else{
        showPlatformDialog(
          context: context,
          builder: (context) => BasicDialogAlert(
            title: Text("Authentication Error"),
            content:
            Text("Username doesnt exist"),
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
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error checking if username exists,try again!"),
          backgroundColor: Colors.red,
        ),
      );

    }
  }

  AlertDialog buildAvailableAlert(BuildContext context, String itemName,String itemId) {
    debugPrint("pressed on available alert with itemname $itemName with id $itemId");

    String itemName2 = "$itemName #$itemId";
    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(color: AppColorss.lightmainColor),
        child: Row(
          children: [
            PopupMenuButton(
              icon: Icon(Icons.settings, color: Colors.white,),
              itemBuilder: (BuildContext context) =>
              [
                PopupMenuItem(
                  child: Text('Give Access'),
                  value: "av",
                ),
                PopupMenuItem(
                  child: Text('Mark as dead'),
                  value: "dead",
                ),
              ],
              // color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (value) {
                Navigator.pop(context);
                if(value=="av"){
                  showDialog(
                    context: context,
                    builder: (context) =>
                        statusAlert(
                            context, itemName,itemId),
                  );
                }
                if(value=="dead"){
                  showDialog(
                    context: context,
                    builder: (context) =>
                        returnBackDeadAlert(
                            context, itemName,itemId,"Dead"),
                  );

                }


              },
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text(
                  itemName2,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ],
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
                itemCount: allAdmins?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Icon(Icons.arrow_forward_ios_outlined,
                        color: AppColorss.darkFontGrey,),
                      const SizedBox(width: 14),
                      Text("${allAdmins?[index]}",
                        style: TextStyle(color: AppColorss.darkFontGrey),),
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
              backgroundColor: AppColorss.lightmainColor,
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
  AlertDialog returnBackDeadAlert(BuildContext context, String itemName,String itemId,String status){
    String itemName2 = "$itemName #$itemId";
    return AlertDialog(
        backgroundColor: Colors.white,
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(color:AppColorss.lightmainColor),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Text(
                itemName2,
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
                      key:status=="Return"?_formReturnBack:_formdead,
                      child:Column(children: [
                        SizedBox(height: 10,),
                        FractionallySizedBox(
                          widthFactor: 0.8,
                          child:status=="Return"?
                          TextFormField(
                              controller:returnUserController,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(new RegExp(r"\s"))
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: "Returnee Username",
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xFF005466))
                                ),
                              ),
                              validator:(value) {
                                if (value!.trim().isEmpty) {
                                  return "Please enter a username";
                                }
                                return null;
                              }
                          ):
                          TextFormField(
                              controller:deadReasonController,
                              decoration: const InputDecoration(
                                labelText: 'Death Reason',
                                hintText: "Reason of death",
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color:Color(0xFF005466))
                                ),
                              ),
                              validator:(value) {
                                if (value!.trim().isEmpty) {
                                  return "Please enter a reason";
                                }
                                return null;
                              }
                          )

                        ),
                        SizedBox(height:10,),
                        status=="Return"?
                        ElevatedButton(onPressed: (){
                              formReturnBack(itemId,"Available");
                        }, child:Text("Return back",),   style: ElevatedButton.styleFrom(
                            backgroundColor:AppColorss.lightmainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: Size(100, 30)
                        ),):
                        ElevatedButton(onPressed: (){
                          formReturnBack(itemId,"Dead");
                        }, child:Text("Submit Reason",),   style: ElevatedButton.styleFrom(
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
  Future<void> formReturnBack(String itemId,String status)async {
    if (status=="Available"){
      final isValid = _formReturnBack.currentState!.validate();
      if(isValid){
        returnBackMethod(context,
            itemId,returnUserController.text.trim().toLowerCase());
      }
    }
    else if (status=="Dead"){
      final isValid=_formdead.currentState!.validate();
      if(isValid){
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('dd/MM/yy HH:mm a').format(now);
        changeStatus(context, itemId, formattedDate, "", "Dead",deadReasonController.text);
      }
    }


  }
  Future<void> returnBackMethod(BuildContext context,String itemId,String username)async{
    try{
      bool exists=await inventoryC.userNameCheck(username);
      if(exists){
        try{
          bool correctPerson=await inventoryC.checkReturnee(username, itemId);
          if(correctPerson){
            changeStatus(context, itemId, "", "","Available","");
          }
          else{
            showPlatformDialog(
              context: context,
              builder: (context) => BasicDialogAlert(
                title: Text("Authentication Error"),
                content:
                Text("Item was not borrowed by this user"),
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
        catch(e){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error checking if correct user,try again!"),
              backgroundColor: Colors.red,
            ),
          );
        }

        DateTime now = DateTime.now();
        String formattedDate = DateFormat('dd/MM/yy HH:mm a').format(now);

      }
      else{
        showPlatformDialog(
          context: context,
          builder: (context) => BasicDialogAlert(
            title: Text("Authentication Error"),
            content:
            Text("Username doesnt exist"),
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
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error checking if username exists,try again!"),
          backgroundColor: Colors.red,
        ),
      );

    }
  }


  Future<void> changeStatus(BuildContext context, String itemId, String date,
      String username, String status,String deathReason) async {
    try {
      await inventoryC.changeStatus(itemId, status, loggedInName, date, username, deathReason);
      if(status=="Borrowed"){borrowUserController.clear();}
      else if(status=="Available"){returnUserController.clear();}
      else if(status=="Dead"){deadReasonController.clear();}
      Navigator.pop(context);
       status=="Borrowed" ?ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text("Access given to ${username}"),
          backgroundColor: Colors.green,
        ),
      ):status=="Available"?ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text("item successfully returned"),
           backgroundColor: Colors.green,
         ),
       ):ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text("item successfully marked as Dead"),
             backgroundColor: Colors.green,
           )
       );
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating status,try again!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
class RowSource extends DataTableSource {
  Inventory5 inn=Inventory5();
  List<Inventory> myData;
  final count;
  String ? filter;
  String ? searchWord;
  RowSource({
    required this.myData,
    required this.count,
    required this.filter,
    required this.searchWord
  });

  @override
  DataRow? getRow(int index) {
    if (index < rowCount) {
      String x = searchWord ?? "a";
      String filters = filter ?? "all";
      bool searchNotEmpty = searchWord?.isNotEmpty ?? false;
      bool filterNotEmpty = filter?.isNotEmpty ?? false;
      Inventory data=myData[index];
      if (searchWord != null && searchNotEmpty) {

        if (data.itemName.toLowerCase().contains(x.trim().toLowerCase()) ||
            data.itemId.trim().startsWith(x)) {
          if (filter != null && filterNotEmpty) {
            if (data.status == filter) {
              return recentFileDataRow(myData![index]);
            } else {
              return null;
            }
          } else {
            return recentFileDataRow(myData![index]);
          }
        } else {
          return null;
        }
      }
      if (filter != null && filterNotEmpty) {
        if (data.status == filter) {
          if (searchWord != null && searchNotEmpty) {
            if (data.itemName.toLowerCase().contains(x.trim().toLowerCase())) {
              return recentFileDataRow(myData![index]);
            }
            else {
              return null;
            }
          }
          else {
            return recentFileDataRow(myData![index]);
          }
        }
        else {
          return null;
        }
      }
      return recentFileDataRow(myData![index]);
    } else {
      return null;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => count;

  @override
  int get selectedRowCount => 0;
}

DataRow recentFileDataRow(Inventory data) {

  return DataRow(
    cells: [
      DataCell(Text(data.status ?? "Name")),
      DataCell(Text(data.status.toString())),
      DataCell(Text(data.status.toString())),
      DataCell(Text(data.status.toString())),
      DataCell(Text(data.status.toString())),
    ],
  );

}