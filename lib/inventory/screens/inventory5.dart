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
  InventContr inventoryC = InventContr();
  bool giveAccessloading=false;
  bool returnBackLoading=false;
  bool deadLoading=false;
  bool isChecked = false;
  bool isLoading=true;
  bool deleteLoading=false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    debugPrint("load data");
    setState(() {
      isLoading=true;
    });
    try {
      //get logged in id

      String x = await getIdofUser();
      setState(() {
        loggedInId = x;
      });
      try {
        //get loggedInName
        setState(() {
          isLoading=true;
        });
        String x = await getLoggedInName();
        setState(() {
          loggedInName = x;
        });
        //get isAdmin
        try {
          setState(() {
            isLoading=true;
          });
          bool x = await inventoryC.isAdmin(loggedInId);
          setState(() {
            isAdmin = x;
          });
          //get all admins
          try {
            setState(() {
              isLoading=true;
            });
            List<String> admins = await inventoryC.allAdmins();
            setState(() {
              allAdmins = admins;
            });
            setState(() {
              isTrue=true;
              isLoading=false;
            });
          }
          catch (e) {
            setState(() {
              isLoading=false;
            });

          }
        }
        catch (e) {
          setState(() {
            isLoading=false;
          });

        }
      }
      catch (e) {
        debugPrint("Fff");
        setState(() {
          isLoading=false;
        });
      }
      debugPrint("iddddddddddddddddd$loggedInId");
    }
    catch (e) {
      setState(() {
        isLoading=false;
      });
    }


    // await saveFile();
  }




  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    if (isTrue && !isLoading) {
      debugPrint("inside if true $isTrue");

      return StreamBuilder<List<Inventory>>(
          stream: inventoryC.getInventoryLoose(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
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
                      ],),

                      CircularProgressIndicator()
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: w*0.12,
                      height: h * 0.12,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/warning.png"),
                          // fit:BoxFit.fill
                        ),
                      ),
                    ),
                    Text("An unexpected error occured", style: TextStyle(fontSize: 20)),
                    Text("in getting inventory.",style: TextStyle(fontSize: 20),),
                    Text(   "please try loading the page again!",
                      style: TextStyle(fontSize: 20),)
                  ],
                ),
              );

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: w*0.12,
                    height: h * 0.12,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/warning.png"),
                        // fit:BoxFit.fill
                      ),
                    ),
                  ),
                  Text("An unexpected error occured", style: TextStyle(fontSize: 20)),
                  Text("in getting inventory.",style: TextStyle(fontSize: 20),),
                  Text(   "please try loading the page again!",
                    style: TextStyle(fontSize: 20),)
                ],
              ),
            );

          });
    }
    else if(isLoading) {
      debugPrint("i am loading hahahah");
      return Center(child: CircularProgressIndicator(),);
    }
    else if(!isTrue){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: w*0.12,
              height: h * 0.12,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/warning.png"),
                  // fit:BoxFit.fill
                ),
              ),
            ),
            Text("An unexpected error occured", style: TextStyle(fontSize: 20)),
            Text("in getting user data.",style: TextStyle(fontSize: 20),),
            Text(   "please try logging out!",
              style: TextStyle(fontSize: 20),)
          ],
        ),
      );
    }
    else{
      debugPrint("hey ya nado");
      return Center(child:CircularProgressIndicator());
    }
  }

  Widget buildDataTable(List<Inventory>? inventory) {
    return DataTable(
      headingRowColor: MaterialStateProperty.resolveWith(
              (states) =>Color(0xFFBACDDB)),
      headingRowHeight: 30,
      columns: getColumns(columns),
      rows: getInventoryRows(inventory),
      border: TableBorder.all(color: Colors.black38,
          width: 2, borderRadius: BorderRadius.circular(16.0)),);
  }
  List<DataColumn> getColumns(List<String> columns) =>
      columns
          .map((String column) =>
          DataColumn(
            label: Text(column, style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500),),
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
            type=="Borrowed" && isAdmin==true?
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
                PopupMenuItem(
                  child: Text('Delete'),
                  value: "delete",
                ),
              ],
              // color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (value)async {
                  if(value=="av"){
                    Navigator.pop(context);
                    returnBackdeadAlert(itemName,itemId,"Return");
                  }
                  else if(value=="dead"){
                    Navigator.pop(context);
                    returnBackdeadAlert(itemName,itemId,"Dead");
                  }
                  else if(value=="delete"){
                    Navigator.pop(context);
                    deleteItem(itemId,itemName);
                  }

              },
            ):type=="Dead" && isAdmin==true ?
            PopupMenuButton(
              icon: Icon(Icons.settings, color: Colors.white,),
              itemBuilder: (BuildContext context) =>
              [
                PopupMenuItem(
                  child: Text('Delete'),
                  value: "delete",
                ),
              ],
              // color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (value)async {
                if(value=="delete"){
                  Navigator.pop(context);
                  deleteItem(itemId,itemName);
                }

              },
            ) :Container(),
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


  deleteItem(String itemId,String itemName){

  String itemName2 = "$itemName #$itemId";


  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Delete $itemName2"),
            content: Text("Are you sure you want to delete?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel",style: TextStyle(color: Colors.black),),
              ),
              deleteLoading==true?CircularProgressIndicator():TextButton(
                onPressed: ()async {
                  try{
                    setState((){
                      deleteLoading=true;
                    });
                    await inventoryC.deleteItem(itemId);
                    setState((){
                      deleteLoading=false;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                        content: Text("Successfully deleted $itemName2"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  catch(e){
                    setState((){
                      deleteLoading=false;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error in deleting $itemName2"),
                        backgroundColor: Colors.red,
                      ),
                    );

                  }
                },
                child: Text("Delete",style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      );
    },
  );
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
        isAdmin!=true ? Container():PopupMenuButton(
              icon: Icon(Icons.settings, color: Colors.white,),
              itemBuilder: (BuildContext context) =>
              [
                const PopupMenuItem(
                  value: "av",
                  child: Text('Give Access'),
                ),
                const PopupMenuItem(
                  value: "dead",
                  child: Text('Mark as dead'),
                ),
                const PopupMenuItem(
                  value: "delete",
                  child: Text('Delete'),
                ),
              ],
              // color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (value) async{
                Navigator.pop(context);
                if(value=="av") {
                  giveAccessAlert(itemName,itemId);
                }
                else if(value=="dead"){
                  returnBackdeadAlert(itemName, itemId, "Dead");
                }
                else if(value=="delete"){

                  deleteItem(itemId,itemName);
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
  returnBackdeadAlert( String itemName,String itemId,String status){
    showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setState) {
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
                                returnBackLoading==true? CircularProgressIndicator():ElevatedButton(onPressed: () async{
                                  final isValid = _formReturnBack.currentState!.validate();
                                  if(isValid){
                                    setState(() {
                                      returnBackLoading=true;
                                    });
                                    String username=returnUserController.text.trim().toLowerCase();
                                    // returnBackMethod(context,
                                    //     itemId,returnUserController.text.trim().toLowerCase());
                                    try{
                                      bool exists=await inventoryC.userNameCheck(username);
                                      if(exists){
                                        try{
                                          bool correctPerson=await inventoryC.checkReturnee(username, itemId);
                                          if(correctPerson){
                                            changeStatus(context, itemId, "", "","Available","");
                                          }
                                          else{
                                              setState(() {
                                          returnBackLoading=false;
                                        });
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
                                        setState(() {
                                          returnBackLoading=false;
                                        });
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
                                }, child:Text("Return back",),   style: ElevatedButton.styleFrom(
                                    backgroundColor:AppColorss.lightmainColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minimumSize: Size(100, 30)
                                ),):
                               deadLoading==true?CircularProgressIndicator(): ElevatedButton(onPressed: (){
                                 final isValid=_formdead.currentState!.validate();
                                 if(isValid){
                                   setState(() {
                                     deadLoading=true;
                                   });
                                   DateTime now = DateTime.now();
                                   String formattedDate = DateFormat('dd/MM/yy HH:mm a').format(now);
                                   changeStatus(context, itemId, formattedDate, "", "Dead",deadReasonController.text);
                                 }
                                }, child:Text("Submit Reason",),   style: ElevatedButton.styleFrom(
                                    backgroundColor:AppColorss.lightmainColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minimumSize: Size(100, 30)
                                ),)

                              ],)
                          ),


                        ],
                      ),
                    ))
            );
          },
        );
      },
    );
  }

  giveAccessAlert( String itemName,String itemId) {
    String itemName2 = "$itemName #$itemId";
    showDialog(
      context: context,
      builder: (context) {
        String contentText = "Content of Dialog";
        return StatefulBuilder(
          builder: (context, setState)
        {
          return AlertDialog(
              backgroundColor: Colors.white,
              titlePadding: EdgeInsets.zero,
              title: Container(
                decoration: BoxDecoration(color: AppColorss.lightmainColor),
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
                            key: _formU2,
                            child: Column(children: [
                              SizedBox(height: 10,),
                              FractionallySizedBox(
                                widthFactor: 0.8,
                                child: TextFormField(
                                    controller: borrowUserController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          new RegExp(r"\s"))
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                      hintText: "Give access to",
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF005466))
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.trim().isEmpty) {
                                        return "Please enter an id";
                                      }
                                      return null;
                                    }
                                ),

                              ),
                              SizedBox(height: 10,),
                              giveAccessloading == true
                                  ? CircularProgressIndicator()
                                  : ElevatedButton(onPressed: () async {
                                final isValid = _formU2.currentState!
                                    .validate();
                                if (isValid) {
                                  setState(() {
                                    giveAccessloading = true;
                                  });
                                  // borrowTo(context,
                                  //     itemId, borrowUserController.text.trim()
                                  //         .toLowerCase());
                                  // String itemId=itemId;
                                  String username=borrowUserController.text.trim()
                                      .toLowerCase();

                                  try{
                                    bool exists=await inventoryC.userNameCheck(username);
                                    if(exists){
                                      DateTime now = DateTime.now();
                                      String formattedDate = DateFormat('dd/MM/yy HH:mm a').format(now);
                                      changeStatus(context, itemId, formattedDate, username,"Borrowed","");
                                    }
                                    else{
                                      setState(() {
                                        giveAccessloading=false;
                                      });
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
                              },
                                child: Text("Give Access",),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColorss.lightmainColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minimumSize: Size(100, 30)
                                ),)
                            ],)
                        ),
                      ],
                    ),
                  ))
          );
        }
        );
      },
    );
  }

  Future<void> changeStatus(BuildContext context, String itemId, String date,
      String username, String status,String deathReason) async {
    try {
      await inventoryC.changeStatus(itemId, status, loggedInName, date, username, deathReason);
      if(status=="Borrowed"){
        borrowUserController.clear();setState(() {
        giveAccessloading=false;
      }); }
      else if(status=="Available"){
        setState(() {
          returnBackLoading=false;
        });
        returnUserController.clear();}
      else if(status=="Dead"){
        setState(() {
          deadLoading=false;
        });
        deadReasonController.clear();}
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
      setState(() {
        giveAccessloading=false;
        deadLoading=false;
        returnBackLoading=false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating status,try again!"),
          backgroundColor: Colors.red,
        ),
      );
    }
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

}
