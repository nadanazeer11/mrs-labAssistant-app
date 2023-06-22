import 'dart:convert';

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
import '../../models/CompactInventory.dart';
import '../../models/InventoryItems.dart';
import '../backend/inventContr.dart';
import '../widgets/scrollable_widget.dart';
import 'package:http/http.dart' as http;

class Inventory5 extends StatefulWidget {
  const Inventory5({Key? key}) : super(key: key);

  @override
  State<Inventory5> createState() => _Inventory5State();
}

class _Inventory5State extends State<Inventory5> {
  int x = 0;
  String? filter;
  String loggedInName = "";
  String? loggedInId;
  final columns = ['Id', 'Name', 'Status', "Creation Date", "Created By"];
  String? searchWord;
  var searchController = TextEditingController();
  bool isAdmin = false;
  List<String>? allAdmins;
  bool isTrue = false;
  bool isHovered = false;
  List<InventorySummary> list = [];
  bool loadSummary = false;
  final _formU2 = GlobalKey<FormState>();
  final _formReturnBack = GlobalKey<FormState>();
  final _formdead = GlobalKey<FormState>();
  var borrowUserController = TextEditingController();
  var returnUserController = TextEditingController();
  var deadReasonController = TextEditingController();
  InventContr inventoryC = InventContr();
  bool giveAccessloading = false;
  bool returnBackLoading = false;
  bool deadLoading = false;
  bool isChecked = false;
  bool isLoading = true;
  bool deleteLoading = false;


  String initialValue = "loose";
  String ?filter2;
  var searchController2 = TextEditingController();
  String? searchWord2;
  bool deleteLoading2 = false;
  final _formdead2 = GlobalKey<FormState>();
  var deadReasonController2 = TextEditingController();
  bool deadLoading2 = false;
  void sendPushMessage(String status,String itemName,String type) async {
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
              'body': "$itemName marked as $status by $loggedInName",
              'title':"$type inventory update"
            },
            'priority': 'high',
            'data': <String, dynamic>{
              // 'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'notifType':"2",

            },
            "to":"/topics/Inventory"
          },
        ),
      );
      debugPrint("exit send push notif");
    }
    catch (e) {
      debugPrint("error push notification");
    }
  }
  Future<void> changeStatus(BuildContext context, String itemId, String date,
      String username, String status, String deathReason,String itemName) async {
    try {
      await inventoryC.changeStatus(
          itemId, status, loggedInName, date, username, deathReason);
      sendPushMessage(status, itemName,"Loose");
      if (status == "Borrowed") {
        borrowUserController.clear();
        setState(() {
          giveAccessloading = false;
        });
      } else if (status == "Available") {
        setState(() {
          returnBackLoading = false;
        });
        returnUserController.clear();
      } else if (status == "Dead") {
        setState(() {
          deadLoading = false;
        });
        deadReasonController.clear();
      }
      Navigator.pop(context);
      status == "Borrowed"
          ? ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Access given to ${username}"),
          backgroundColor: Colors.green,
        ),
      )
          : status == "Available"
          ? ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("item successfully returned"),
          backgroundColor: Colors.green,
        ),
      )
          : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("item successfully marked as Dead"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      setState(() {
        giveAccessloading = false;
        deadLoading = false;
        returnBackLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating status,try again!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    debugPrint("load data");
    setState(() {
      isLoading = true;
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
          isLoading = true;
        });
        String x = await getLoggedInName();
        setState(() {
          loggedInName = x;
        });
        //get isAdmin
        try {
          setState(() {
            isLoading = true;
          });
          bool x = await inventoryC.isAdmin(loggedInId);
          setState(() {
            isAdmin = x;
          });
          //get all admins
          try {
            setState(() {
              isLoading = true;
            });
            List<String> admins = await inventoryC.allAdmins();
            setState(() {
              allAdmins = admins;
            });
            setState(() {
              isTrue = true;
              isLoading = false;
            });
          } catch (e) {
            setState(() {
              isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Fff");
        setState(() {
          isLoading = false;
        });
      }
      debugPrint("iddddddddddddddddd$loggedInId");
    } catch (e) {
      setState(() {
        isLoading = false;
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
      return Column(children: [
        Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Inventory",
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                 initialValue=="loose"? PopupMenuButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: AppColorss.fontGrey,
                    ),
                    itemBuilder: (BuildContext context) => [
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
                  ):
                 PopupMenuButton(
                   icon: Icon(
                     Icons.filter_list,
                     color: AppColorss.fontGrey,
                   ),
                   itemBuilder: (BuildContext context) => [
                     const PopupMenuItem(
                       value: "Available",
                       child: Text('Available'),
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
                       filter2 = value;
                     });
                   },
                 ),
                 initialValue=="loose"? filter != null
                      ? Row(children: [
                    Text(
                      "$filter",
                      style: TextStyle(
                          color: AppColorss.fontGrey,
                          fontSize: 19,
                          fontWeight: FontWeight.w400),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            filter = null;
                          });
                        },
                        icon: const Icon(Icons.clear))
                  ])
                      : Container() : filter2!=null ?
                 Row(children: [
                   Text(
                     "$filter2",
                     style: TextStyle(
                         color: AppColorss.fontGrey,
                         fontSize: 19,
                         fontWeight: FontWeight.w400),
                   ),
                   IconButton(
                       onPressed: () {
                         setState(() {
                           filter2 = null;
                         });
                       },
                       icon: const Icon(Icons.clear))
                 ])
                   :Container(),
                  Spacer(),
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

              Row(
                children: [
                  initialValue=="loose"?
                  SizedBox(
                    width: w * 0.85,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search using id/name...',
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
                        filled: true,
                        contentPadding: const EdgeInsets.all(8),
                      ),
                    ),
                  ):
                  SizedBox(
                    width: w * 0.85,
                    child: TextField(
                      controller: searchController2,
                      decoration: InputDecoration(
                        hintText: 'Search using id/name...',
                        prefixIcon: searchWord2 == null
                            ? IconButton(
                          onPressed: () {
                            setState(() {
                              searchWord2 =
                                  searchController2.text;
                            });
                          },
                          icon: const Icon(Icons.search),
                        )
                            : IconButton(
                          onPressed: () {
                            setState(() {
                              searchWord2 = null;
                              searchController2.clear();
                            });
                          },
                          icon: const Icon(Icons.clear),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: loadSummary == true
                            ? CircularProgressIndicator()
                            : IconButton(
                          onPressed: () {
                            getSumm(context);
                          },
                          hoverColor: AppColorss.lightmainColor,
                          icon: Icon(Icons.summarize_outlined),
                          color: Colors.grey,
                        )),
                  ),
                ],
              ),
              // const SizedBox(
              //   height: 15,
              // ),

            ],
          ),
        ),
      ),
        initialValue=="loose"?
        StreamBuilder<List<Inventory>>(
            stream: inventoryC.getInventoryLoose(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
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
                        width: w * 0.12,
                        height: h * 0.12,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/warning.png"),
                            // fit:BoxFit.fill
                          ),
                        ),
                      ),
                      Text("An unexpected error occured",
                          style: TextStyle(fontSize: 20)),
                      Text(
                        "in getting inventory.",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        "please try loading the page again!",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                );
              }
              if (snapshot.hasData) {
                debugPrint("i have dataaaaaaaaa");
                List<Inventory>? invent = snapshot.data;
                debugPrint("${snapshot.data}");
                return Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18,2,18,18),
                    child: Column(
                      children: [
                        // Row(
                        //   children: [
                        //     const Text(
                        //       "Inventory",
                        //       style: TextStyle(
                        //           fontSize: 28,
                        //           color: Colors.black,
                        //           fontWeight: FontWeight.bold),
                        //     ),
                        //     PopupMenuButton(
                        //       icon: Icon(
                        //         Icons.filter_list,
                        //         color: AppColorss.fontGrey,
                        //       ),
                        //       itemBuilder: (BuildContext context) => [
                        //         const PopupMenuItem(
                        //           value: "Available",
                        //           child: Text('Available'),
                        //         ),
                        //         const PopupMenuItem(
                        //           value: "Borrowed",
                        //           child: Text("Borrowed"),
                        //         ),
                        //         const PopupMenuItem(
                        //           value: "Dead",
                        //           child: Text('Dead'),
                        //         ),
                        //       ],
                        //       // color: Colors.black,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       onSelected: (value) {
                        //         debugPrint('your p$value');
                        //         setState(() {
                        //           filter = value;
                        //         });
                        //       },
                        //     ),
                        //     filter != null
                        //         ? Row(children: [
                        //             Text(
                        //               "$filter",
                        //               style: TextStyle(
                        //                   color: AppColorss.fontGrey,
                        //                   fontSize: 19,
                        //                   fontWeight: FontWeight.w400),
                        //             ),
                        //             IconButton(
                        //                 onPressed: () {
                        //                   setState(() {
                        //                     filter = null;
                        //                   });
                        //                 },
                        //                 icon: const Icon(Icons.clear))
                        //           ])
                        //         : Container(),
                        //     Spacer(),
                        //     Expanded(
                        //       child: Align(
                        //         alignment: Alignment.centerRight,
                        //         child: PopupMenuButton(
                        //           initialValue: initialValue,
                        //           icon: Icon(
                        //             Icons.arrow_drop_down_circle_outlined,
                        //             color: AppColorss.fontGrey,
                        //           ),
                        //           itemBuilder: (BuildContext context) => [
                        //             const PopupMenuItem(
                        //               value: "Loose",
                        //               child: Text('Loose'),
                        //             ),
                        //             const PopupMenuItem(
                        //               value: "Compact",
                        //               child: Text("Compact"),
                        //             ),
                        //           ],
                        //           // color: Colors.black,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(10),
                        //           ),
                        //           onSelected: (value) {
                        //             debugPrint('your p$value');
                        //             setState(() {
                        //               initialValue = value;
                        //             });
                        //           },
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        //
                        // Row(
                        //   children: [
                        //     SizedBox(
                        //       width: w * 0.85,
                        //       child: TextField(
                        //         controller: searchController,
                        //         decoration: InputDecoration(
                        //           hintText: 'Search using id/name...',
                        //           prefixIcon: searchWord == null
                        //               ? IconButton(
                        //                   onPressed: () {
                        //                     setState(() {
                        //                       searchWord =
                        //                           searchController.text;
                        //                     });
                        //                   },
                        //                   icon: const Icon(Icons.search),
                        //                 )
                        //               : IconButton(
                        //                   onPressed: () {
                        //                     setState(() {
                        //                       searchWord = null;
                        //                       searchController.clear();
                        //                     });
                        //                   },
                        //                   icon: const Icon(Icons.clear),
                        //                 ),
                        //           border: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(20),
                        //             borderSide: BorderSide.none,
                        //           ),
                        //           filled: true,
                        //           contentPadding: const EdgeInsets.all(8),
                        //         ),
                        //       ),
                        //     ),
                        //     Expanded(
                        //       child: Align(
                        //           alignment: Alignment.centerRight,
                        //           child: loadSummary == true
                        //               ? CircularProgressIndicator()
                        //               : IconButton(
                        //                   onPressed: () {
                        //                     getSumm(context);
                        //                   },
                        //                   hoverColor: AppColorss.lightmainColor,
                        //                   icon: Icon(Icons.summarize_outlined),
                        //                   color: Colors.grey,
                        //                 )),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 15,
                        // ),
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
                        ScrollableWidget(
                          child: buildDataTable(invent),
                        ),
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
                      width: w * 0.12,
                      height: h * 0.12,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/warning.png"),
                          // fit:BoxFit.fill
                        ),
                      ),
                    ),
                    Text("An unexpected error occured",
                        style: TextStyle(fontSize: 20)),
                    Text(
                      "in getting inventory.",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "please try loading the page again!",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              );
            }):
        StreamBuilder<List<CompactInventory>>(
            stream: inventoryC.getInventoryCompact(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator()
                      ],
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                debugPrint("Error: ${snapshot.error}");                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: w * 0.12,
                        height: h * 0.12,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/warning.png"),
                            // fit:BoxFit.fill
                          ),
                        ),
                      ),
                      Text("An unexpected error occured",
                          style: TextStyle(fontSize: 20)),
                      Text(
                        "in getting inventory.",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        "please try loading the page again!",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                );
              }
              if (snapshot.hasData) {
                debugPrint("i have dataaaaaaaaa");
                List<CompactInventory>? invent = snapshot.data;
                debugPrint("${snapshot.data}");
                return Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18,2,18,18),
                    child: Column(
                      children: [
                        // Row(
                        //   children: [
                        //     const Text(
                        //       "Inventory",
                        //       style: TextStyle(
                        //           fontSize: 28,
                        //           color: Colors.black,
                        //           fontWeight: FontWeight.bold),
                        //     ),
                        //     PopupMenuButton(
                        //       icon: Icon(
                        //         Icons.filter_list,
                        //         color: AppColorss.fontGrey,
                        //       ),
                        //       itemBuilder: (BuildContext context) => [
                        //         const PopupMenuItem(
                        //           value: "Available",
                        //           child: Text('Available'),
                        //         ),
                        //         const PopupMenuItem(
                        //           value: "Borrowed",
                        //           child: Text("Borrowed"),
                        //         ),
                        //         const PopupMenuItem(
                        //           value: "Dead",
                        //           child: Text('Dead'),
                        //         ),
                        //       ],
                        //       // color: Colors.black,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       onSelected: (value) {
                        //         debugPrint('your p$value');
                        //         setState(() {
                        //           filter = value;
                        //         });
                        //       },
                        //     ),
                        //     filter != null
                        //         ? Row(children: [
                        //             Text(
                        //               "$filter",
                        //               style: TextStyle(
                        //                   color: AppColorss.fontGrey,
                        //                   fontSize: 19,
                        //                   fontWeight: FontWeight.w400),
                        //             ),
                        //             IconButton(
                        //                 onPressed: () {
                        //                   setState(() {
                        //                     filter = null;
                        //                   });
                        //                 },
                        //                 icon: const Icon(Icons.clear))
                        //           ])
                        //         : Container(),
                        //     Spacer(),
                        //     Expanded(
                        //       child: Align(
                        //         alignment: Alignment.centerRight,
                        //         child: PopupMenuButton(
                        //           initialValue: initialValue,
                        //           icon: Icon(
                        //             Icons.arrow_drop_down_circle_outlined,
                        //             color: AppColorss.fontGrey,
                        //           ),
                        //           itemBuilder: (BuildContext context) => [
                        //             const PopupMenuItem(
                        //               value: "Loose",
                        //               child: Text('Loose'),
                        //             ),
                        //             const PopupMenuItem(
                        //               value: "Compact",
                        //               child: Text("Compact"),
                        //             ),
                        //           ],
                        //           // color: Colors.black,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(10),
                        //           ),
                        //           onSelected: (value) {
                        //             debugPrint('your p$value');
                        //             setState(() {
                        //               initialValue = value;
                        //             });
                        //           },
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        //
                        // Row(
                        //   children: [
                        //     SizedBox(
                        //       width: w * 0.85,
                        //       child: TextField(
                        //         controller: searchController,
                        //         decoration: InputDecoration(
                        //           hintText: 'Search using id/name...',
                        //           prefixIcon: searchWord == null
                        //               ? IconButton(
                        //                   onPressed: () {
                        //                     setState(() {
                        //                       searchWord =
                        //                           searchController.text;
                        //                     });
                        //                   },
                        //                   icon: const Icon(Icons.search),
                        //                 )
                        //               : IconButton(
                        //                   onPressed: () {
                        //                     setState(() {
                        //                       searchWord = null;
                        //                       searchController.clear();
                        //                     });
                        //                   },
                        //                   icon: const Icon(Icons.clear),
                        //                 ),
                        //           border: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(20),
                        //             borderSide: BorderSide.none,
                        //           ),
                        //           filled: true,
                        //           contentPadding: const EdgeInsets.all(8),
                        //         ),
                        //       ),
                        //     ),
                        //     Expanded(
                        //       child: Align(
                        //           alignment: Alignment.centerRight,
                        //           child: loadSummary == true
                        //               ? CircularProgressIndicator()
                        //               : IconButton(
                        //                   onPressed: () {
                        //                     getSumm(context);
                        //                   },
                        //                   hoverColor: AppColorss.lightmainColor,
                        //                   icon: Icon(Icons.summarize_outlined),
                        //                   color: Colors.grey,
                        //                 )),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(
                        //   height: 15,
                        // ),
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
                        ScrollableWidget(
                          child: buildDataTable2(invent),
                        ),

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
                      width: w * 0.12,
                      height: h * 0.12,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/warning.png"),
                          // fit:BoxFit.fill
                        ),
                      ),
                    ),
                    Text("An unexpected error occured",
                        style: TextStyle(fontSize: 20)),
                    Text(
                      "in getting inventory.",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "please try loading the page again!",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              );
            })
      ]);
      //return
    }
    else if (isLoading) {
      debugPrint("i am loading hahahah");
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (!isTrue) {
      return
        Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: w * 0.12,
              height: h * 0.12,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/warning.png"),
                  // fit:BoxFit.fill
                ),
              ),
            ),
            Text("An unexpected error occured", style: TextStyle(fontSize: 20)),
            Text(
              "in getting user data.",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "please try logging out!",
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      );
    } else {
      debugPrint("hey ya nado");
      return Center(child: CircularProgressIndicator());
    }
  }

  Widget buildDataTable(List<Inventory>? inventory) {
    return DataTable(
      headingRowColor:
          MaterialStateProperty.resolveWith((states) => Color(0xFFBACDDB)),
      headingRowHeight: 30,
      columns: getColumns(columns),
      rows: getInventoryRows(inventory),
      border: TableBorder.all(
          color: Colors.black38,
          width: 2,
          borderRadius: BorderRadius.circular(16.0)),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
            label: Text(
              column,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ))
      .toList();

  List<DataRow> getInventoryRows(List<Inventory>? inventory) {
    String x = searchWord ?? "a";
    String filters = filter ?? "all";
    bool searchNotEmpty = searchWord?.isNotEmpty ?? false;
    bool filterNotEmpty = filter?.isNotEmpty ?? false;
    return inventory
            ?.where((data) {
              if (searchWord != null && searchNotEmpty) {
                if (data.itemName
                        .toLowerCase()
                        .contains(x.trim().toLowerCase()) ||
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
                    if (data.itemName
                        .toLowerCase()
                        .contains(x.trim().toLowerCase())) {
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

              return true;
            })
            .map((data) => buildDataRow(data))
            .toList() ??
        [];
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
        DataCell(
          GestureDetector(
            onTap: () {
              debugPrint("${data.status} pressed on status");
              if (data.status == "Borrowed" || data.status == "Dead") {
                String type = data.status == "Borrowed" ? "Borrowed" : "Dead";
                String borrowedBy = data.borrowedUser;
                String administeredBy = data.administeredBy;
                String borrowDeathDate = data.borrowDeathDate;
                String deathReason = data.deathReason;
                String itemName = "${data.itemName} #${data.itemId}";
                String itemName2 = data.itemName;
                String itemId = data.itemId;
                showDialog(
                  context: context,
                  builder: (context) => buildAlertDialog(
                      context,
                      borrowedBy,
                      administeredBy,
                      type,
                      itemId,
                      itemName2,
                      borrowDeathDate,
                      deathReason),
                );
              } else if (data.status == "Available") {
                String itemName = "${data.itemName} #${data.itemId}";
                String itemName2 = data.itemName;
                String itemId = data.itemId;

                showDialog(
                  context: context,
                  builder: (context) =>
                      buildAvailableAlert(context, itemName2, itemId),
                );
              }
            },
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Chip(
                  padding: data.status == "Dead"
                      ? EdgeInsets.symmetric(horizontal: 16)
                      : null,
                  label: Text(data.status),
                  backgroundColor: data.status == "Available"
                      ? const Color(0xFFB2E672)
                      : data.status == "Dead"
                          ? Color(0xFFFF4646)
                          : Color(0xFFFEFF86),
                ),
              ],
            ),
          ),
        ),
        DataCell(Text(DateFormat(
            'dd/MM/yy')
            .format(data.creationDate.toDate()))),
        DataCell(Text(data.createdBy)),
      ],
    );
  }

  AlertDialog buildAlertDialog(
      BuildContext context,
      String borrowedBy,
      String administeredBy,
      String type,
      String itemId,
      String itemName,
      String userDate,
      String deathReason) {
    String itemName2 = "$itemName #$itemId";

    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(color: AppColorss.lightmainColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            type == "Borrowed" && isAdmin == true
                ?
            PopupMenuButton(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    itemBuilder: (BuildContext context) => [
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
                    onSelected: (value) async {
                      if (value == "av") {
                        Navigator.pop(context);
                        returnBackdeadAlert(itemName, itemId, "Return");
                      } else if (value == "dead") {
                        Navigator.pop(context);
                        returnBackdeadAlert(itemName, itemId, "Dead");
                      } else if (value == "delete") {
                        Navigator.pop(context);
                        deleteItem(itemId, itemName);
                      }
                    },
                  )
                : type == "Dead" && isAdmin == true
                    ? PopupMenuButton(
                        icon: Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            child: Text('Delete'),
                            value: "delete",
                          ),
                        ],
                        // color: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: (value) async {
                          if (value == "delete") {
                            Navigator.pop(context);
                            deleteItem(itemId, itemName);
                          }
                        },
                      )
                    : Container(),
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Padding(
            //     padding: const EdgeInsets.all(13.0),
            //     child: Text(
            //       itemName2,
            //       style: TextStyle(color: Colors.white, fontSize: 24),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  " $itemName2",
                  textAlign: TextAlign.center,
                  style:  TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),

          ],
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(children: [
            type == "Borrowed"
                ? Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Borrowed By:',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 24,
                                color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(text: " "),
                              TextSpan(
                                  text: borrowedBy,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: AppColorss.darkFontGrey)),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                : Row(
                    children: [
                      Text(
                        "Death Reason:",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                            color: Colors.black),
                      ),
                      Expanded(
                        child: Text(
                          deathReason,
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 22,
                              color: AppColorss.darkFontGrey),
                        ),
                      )
                    ],
                  ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Authorized by: ',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: administeredBy,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: AppColorss.darkFontGrey)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    color: Colors.black, size: 24),
                SizedBox(
                  width: 14,
                ),
                Expanded(
                    child: Text(userDate,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: AppColorss.darkFontGrey)))
              ],
            ),
          ]),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColorss.lightmainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: Size(100, 30)),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK!'),
        )
      ],
    );
  }

  deleteItem(String itemId, String itemName) {
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
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                deleteLoading == true
                    ? CircularProgressIndicator()
                    : TextButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              deleteLoading = true;
                            });
                            await inventoryC.deleteItem(itemId);
                            setState(() {
                              deleteLoading = false;
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Successfully deleted $itemName2"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              deleteLoading = false;
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
                        child: Text("Delete",
                            style: TextStyle(color: Colors.black)),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  AlertDialog buildAvailableAlert(
      BuildContext context, String itemName, String itemId) {
    debugPrint(
        "pressed on available alert with itemname $itemName with id $itemId");

    String itemName2 = "$itemName #$itemId";
    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(color: AppColorss.lightmainColor),
        child: Row(
          children: [
            isAdmin != true
                ? Container()
                : PopupMenuButton(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    itemBuilder: (BuildContext context) => [
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
                    onSelected: (value) async {
                      Navigator.pop(context);
                      if (value == "av") {
                        giveAccessAlert(itemName, itemId);
                      } else if (value == "dead") {
                        returnBackdeadAlert(itemName, itemId, "Dead");
                      } else if (value == "delete") {
                        deleteItem(itemId, itemName);
                      }
                    },
                  ),
            // Center(
            //   child: Padding(
            //     padding: const EdgeInsets.all(13.0),
            //     child: Text(
            //       itemName2,
            //       style: TextStyle(color: Colors.white, fontSize: 24),
            //       overflow: TextOverflow.ellipsis,
            //     ),
            //   ),
            // ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  itemName2,
                  textAlign: TextAlign.center,
                  style:  TextStyle(color: Colors.white, fontSize: 24),
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
                "Item is available  for borrowing from:",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 13),
              ListView.builder(
                shrinkWrap: true,
                itemCount: allAdmins?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColorss.darkFontGrey,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        "${allAdmins?[index]}",
                        style: TextStyle(color: AppColorss.darkFontGrey),
                      ),
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
              minimumSize: Size(100, 30)),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK!'),
        )
      ],
    );
  }

  returnBackdeadAlert(String itemName, String itemId, String status) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String itemName2 = "$itemName #$itemId";
            return AlertDialog(
                backgroundColor: Colors.white,
                titlePadding: EdgeInsets.zero,
                //title:
                // Container(
                //   decoration: BoxDecoration(color: AppColorss.lightmainColor),
                //   child:
                //   // Expanded(
                //   //   child: Text(
                //   //     itemName2,
                //   //     textAlign: TextAlign.center,
                //   //     style:  TextStyle(color: Colors.white, fontSize: 24),
                //   //   ),
                //   // ),
                //   Expanded(
                //   child: Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Text(
                //   itemName2,
                //   textAlign: TextAlign.center,
                //   style:  TextStyle(color: Colors.white, fontSize: 24),
                //   ),
                //   ),
                // ),
                // ),
                title: Container(
                  decoration: BoxDecoration(color: AppColorss.lightmainColor),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            itemName2,
                            textAlign: TextAlign.center,
                            style:  TextStyle(color: Colors.white, fontSize: 24),
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
                      Form(
                          key: status == "Return" ? _formReturnBack : _formdead,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              FractionallySizedBox(
                                  widthFactor: 0.8,
                                  child: status == "Return"
                                      ? TextFormField(
                                          controller: returnUserController,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.deny(
                                                new RegExp(r"\s"))
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Username',
                                            hintText: "Returnee Username",
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFF005466))),
                                          ),
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "Please enter a username";
                                            }
                                            return null;
                                          })
                                      : TextFormField(
                                          controller: deadReasonController,
                                          decoration: const InputDecoration(
                                            labelText: 'Death Reason',
                                            hintText: "Reason of death",
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFF005466))),
                                          ),
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "Please enter a reason";
                                            }
                                            return null;
                                          })),
                              SizedBox(
                                height: 10,
                              ),
                              status == "Return"
                                  ? returnBackLoading == true
                                      ? CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: () async {
                                            final isValid = _formReturnBack
                                                .currentState!
                                                .validate();
                                            if (isValid) {
                                              setState(() {
                                                returnBackLoading = true;
                                              });
                                              String username =
                                                  returnUserController.text
                                                      .trim()
                                                      .toLowerCase();
                                              // returnBackMethod(context,
                                              //     itemId,returnUserController.text.trim().toLowerCase());
                                              try {
                                                bool exists = await inventoryC
                                                    .userNameCheck(username);
                                                if (exists) {
                                                  try {
                                                    bool correctPerson =
                                                        await inventoryC
                                                            .checkReturnee(
                                                                username,
                                                                itemId);
                                                    if (correctPerson) {
                                                      changeStatus(
                                                          context,
                                                          itemId,
                                                          "",
                                                          "",
                                                          "Available",
                                                          "",
                                                      itemName);
                                                    } else {
                                                      setState(() {
                                                        returnBackLoading =
                                                            false;
                                                      });
                                                      showPlatformDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            BasicDialogAlert(
                                                          title: Text(
                                                              "Authentication Error"),
                                                          content: Text(
                                                              "Item was not borrowed by this user"),
                                                          actions: <Widget>[
                                                            BasicDialogAction(
                                                              title: Text("OK"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "Error checking if correct user,try again!"),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }

                                                  DateTime now = DateTime.now();
                                                  String formattedDate =
                                                      DateFormat(
                                                              'dd/MM/yy HH:mm a')
                                                          .format(now);
                                                } else {
                                                  setState(() {
                                                    returnBackLoading = false;
                                                  });
                                                  showPlatformDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        BasicDialogAlert(
                                                      title: Text(
                                                          "Authentication Error"),
                                                      content: Text(
                                                          "Username doesnt exist"),
                                                      actions: <Widget>[
                                                        BasicDialogAction(
                                                          title: Text("OK"),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Error checking if username exists,try again!"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Text(
                                            "Return back",
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColorss.lightmainColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              minimumSize: Size(100, 30)),
                                        )
                                  : deadLoading == true
                                      ? CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: () {
                                            final isValid = _formdead
                                                .currentState!
                                                .validate();
                                            if (isValid) {
                                              setState(() {
                                                deadLoading = true;
                                              });
                                              DateTime now = DateTime.now();
                                              String formattedDate =
                                                  DateFormat('dd/MM/yy HH:mm a')
                                                      .format(now);
                                              changeStatus(
                                                  context,
                                                  itemId,
                                                  formattedDate,
                                                  "",
                                                  "Dead",
                                                  deadReasonController.text,
                                              itemName);
                                            }
                                          },
                                          child: Text(
                                            "Submit Reason",
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColorss.lightmainColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              minimumSize: Size(100, 30)),
                                        )
                            ],
                          )),
                    ],
                  ),
                )));
          },
        );
      },
    );
  }

  giveAccessAlert(String itemName, String itemId) {
    String itemName2 = "$itemName #$itemId";
    showDialog(
      context: context,
      builder: (context) {
        String contentText = "Content of Dialog";
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              backgroundColor: Colors.white,
              titlePadding: EdgeInsets.zero,
              // title: Container(
              //   decoration: BoxDecoration(color: AppColorss.lightmainColor),
              //   child:
              //   // Center(
              //   //   child: Padding(
              //   //     padding: const EdgeInsets.all(13.0),
              //   //     child:
              //   //     Text(
              //   //       itemName2,
              //   //       style: TextStyle(color: Colors.white, fontSize: 24),
              //   //     ),
              //   //   ),
              //   // ),
              //   Expanded(
              //   child: Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Text(
              //   itemName2,
              //   textAlign: TextAlign.center,
              //   style:  TextStyle(color: Colors.white, fontSize: 24),
              //   ),
              //   ),
              // ),),
              title: Container(
                decoration: BoxDecoration(color: AppColorss.lightmainColor),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          itemName2,
                          textAlign: TextAlign.center,
                          style:  TextStyle(color: Colors.white, fontSize: 24),
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
                    Form(
                        key: _formU2,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
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
                                            color: Color(0xFF005466))),
                                  ),
                                  validator: (value) {
                                    if (value!.trim().isEmpty) {
                                      return "Please enter an id";
                                    }
                                    return null;
                                  }),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            giveAccessloading == true
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () async {
                                      final isValid =
                                          _formU2.currentState!.validate();
                                      if (isValid) {
                                        setState(() {
                                          giveAccessloading = true;
                                        });
                                        // borrowTo(context,
                                        //     itemId, borrowUserController.text.trim()
                                        //         .toLowerCase());
                                        // String itemId=itemId;
                                        String username = borrowUserController
                                            .text
                                            .trim()
                                            .toLowerCase();

                                        try {
                                          bool exists = await inventoryC
                                              .userNameCheck(username);
                                          if (exists) {
                                            DateTime now = DateTime.now();
                                            String formattedDate =
                                                DateFormat('dd/MM/yy HH:mm a')
                                                    .format(now);
                                            changeStatus(
                                                context,
                                                itemId,
                                                formattedDate,
                                                username,
                                                "Borrowed",
                                                "",
                                            itemName);
                                          } else {
                                            setState(() {
                                              giveAccessloading = false;
                                            });
                                            showPlatformDialog(
                                              context: context,
                                              builder: (context) =>
                                                  BasicDialogAlert(
                                                title: Text(
                                                    "Authentication Error"),
                                                content: Text(
                                                    "Username doesnt exist"),
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
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Error checking if username exists,try again!"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Give Access",
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColorss.lightmainColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        minimumSize: Size(100, 30)),
                                  )
                          ],
                        )),
                  ],
                ),
              )));
        });
      },
    );
  }



  AlertDialog buildSummaryAlert(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child:
          SingleChildScrollView(
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
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: AppColorss.darkFontGrey,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              x.itemName,
                              style: TextStyle(color: AppColorss.darkFontGrey),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        DataTable(
                          headingRowHeight: 28,
                          dataRowHeight: 28,
                          columnSpacing: 20,
                          border: TableBorder.all(
                              color: Colors.black38,
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
                        SizedBox(
                          height: 12,
                        ),
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
              minimumSize: Size(100, 30)),
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
        builder: (context) => buildSummaryAlert(context),
      );
    } catch (e) {
      loadSummary = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error getting summary"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //compact inventoryyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
  Widget buildDataTable2(List<CompactInventory>? inventory) {
    List<String> columns2=["id","Name","Status","Description","Creation Date","Created By"];
    return DataTable(
      headingRowColor:
          MaterialStateProperty.resolveWith((states) => Color(0xFFBACDDB)),
      headingRowHeight: 30,
      columns: getColumns(columns2),
      rows: getInventoryRows2(inventory),
      border: TableBorder.all(
          color: Colors.black38,
          width: 2,
          borderRadius: BorderRadius.circular(16.0)),
    );
  }
  List<DataRow> getInventoryRows2(List<CompactInventory>? inventory) {
    String x = searchWord2 ?? "a";
    String filters = filter2 ?? "all";
    bool searchNotEmpty = searchWord2?.isNotEmpty ?? false;
    bool filterNotEmpty = filter2?.isNotEmpty ?? false;
    return inventory
        ?.where((data) {
      if (searchWord2 != null && searchNotEmpty) {
        if (data.itemName
            .toLowerCase()
            .contains(x.trim().toLowerCase()) ||
            data.itemId.trim().startsWith(x)) {
          if (filter2 != null && filterNotEmpty) {
            if (data.status == filter2) {
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
      if (filter2 != null && filterNotEmpty) {
        if (data.status == filter2) {
          if (searchWord2 != null && searchNotEmpty) {
            if (data.itemName
                .toLowerCase()
                .contains(x.trim().toLowerCase())) {
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

      return true;
    })
        .map((data) => buildDataRow2(data))
        .toList() ??
        [];
  }
  DataRow buildDataRow2(CompactInventory data) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Row(
          children: [
            Text(data.itemId),
          ],
        )),
        DataCell(Text(data.itemName)),

        DataCell(
          GestureDetector(
            onTap: () {
              debugPrint("${data.status} pressed on status");
              if (data.status == "Dead") {
                String type ="Dead" ;
                String administeredBy = data.administeredBy;
                String borrowDeathDate = data.deathDate;
                String deathReason = data.deathReason;
                String itemName = "${data.itemName} #${data.itemId}";
                String itemName2 = data.itemName;
                String itemId = data.itemId;
                showDialog(
                  context: context,
                  builder: (context) => buildDeaddAlert(
                      context,
                      administeredBy,
                      type,
                      itemId,
                      itemName2,
                      borrowDeathDate,
                      deathReason),
                );
              } else if (data.status == "Available") {
                String itemName = "${data.itemName} #${data.itemId}";
                String itemName2 = data.itemName;
                String itemId = data.itemId;

                showDialog(
                  context: context,
                  builder: (context) =>
                      buildAvailableAlert2(context, itemName2, itemId),
                );
              }
            },
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Chip(
                  padding: data.status == "Dead"
                      ? EdgeInsets.symmetric(horizontal: 16)
                      : null,
                  label: Text(data.status),
                  backgroundColor: data.status == "Available"
                      ? const Color(0xFFB2E672):
                    Color(0xFFFF4646)

                ),
              ],
            ),
          ),
        ),
        DataCell(SizedBox(
            width:80
            ,child: GestureDetector(
          onTap:(){
            descriptioncaller(context,data.itemName,data.itemId,data.description);
          },
            child: Text(data.description,maxLines: 1,overflow:TextOverflow.ellipsis,)))),
        DataCell(Text(DateFormat.yMd().format(data.creationDate.toDate()))),
        DataCell(Text(data.createdBy)),
      ],
    );
  }
  AlertDialog buildAvailableAlert2(
      BuildContext context, String itemName, String itemId) {
    debugPrint(
        "pressed on available alert with itemname $itemName with id $itemId");

    String itemName2 = "$itemName #$itemId";
    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(color: AppColorss.lightmainColor),
        child: Row(
          children: [
            isAdmin != true
                ? Container()
                : PopupMenuButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              itemBuilder: (BuildContext context) => [
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
              onSelected: (value) async {
                Navigator.pop(context);
                 if (value == "dead") {
                  returnBackdeadAlert2(itemName, itemId, "Dead");
                } else if (value == "delete") {
                  deleteItem2(itemId, itemName);
                }
              },
            ),
            // Flexible(
            //   child: Text(
            //     "itemName2",
            //
            //
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 24,
            //     ),
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
            Expanded(
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
            itemName2,
            textAlign: TextAlign.center,
            style:  TextStyle(color: Colors.white, fontSize: 24),
            ),
            ),),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child:

              const Text(
                "Item Successfully working",
                style: TextStyle(fontWeight: FontWeight.w500),
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
              minimumSize: Size(100, 30)),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK!'),
        )
      ],
    );
  }

  void descriptioncaller(BuildContext context,String itemName,String itemId,String description){
    showDialog(
      context: context,
      builder: (context) =>
          buildDescriptionAlert(context, itemName, itemId,description),
    );
  }
  AlertDialog buildDescriptionAlert(BuildContext context,String itemName,String itemId,String description){
    String itemName2 = "$itemName #$itemId";
    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(color: AppColorss.lightmainColor),
        child: Row(
          children: [
        Expanded(
        child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          itemName2,
          textAlign: TextAlign.center,
          style:  TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
        ),
            // Center(
            //   child: Padding(
            //     padding: const EdgeInsets.all(13.0),
            //     child: Text(
            //       itemName2,
            //       style: TextStyle(color: Colors.white, fontSize: 24),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child:

           Text(
            description,
            style: TextStyle(fontWeight: FontWeight.w500),
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
              minimumSize: Size(100, 30)),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK!'),
        )
      ],
    );

  }
  deleteItem2(String itemId, String itemName) {
    String itemName2 = "$itemName #$itemId";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title:
              Expanded(
                child: Padding(
                padding: const EdgeInsets.all(8.0),
            child: Text(
              "Delete $itemName2",
            textAlign: TextAlign.center,
            style:  TextStyle(color: Colors.white, fontSize: 24),
            ),
            ),
              ),
              // Text("Delete $itemName2"),
              content: Text("Are you sure you want to delete?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                deleteLoading2 == true
                    ? CircularProgressIndicator()
                    : TextButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        deleteLoading2 = true;
                      });
                      await inventoryC.deleteItem2(itemId);
                      setState(() {
                        deleteLoading2 = false;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text("Successfully deleted $itemName2"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      setState(() {
                        deleteLoading2 = false;
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
                  child: Text("Delete",
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }
  returnBackdeadAlert2(String itemName, String itemId, String status) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String itemName2 = "$itemName #$itemId";
            return AlertDialog(
                backgroundColor: Colors.white,
                titlePadding: EdgeInsets.zero,
                title:
                Container(
                  decoration: BoxDecoration(color: AppColorss.lightmainColor),
                  child:
                  // Center(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(13.0),
                  //     child: Text(
                  //       itemName2,
                  //       style: TextStyle(color: Colors.white, fontSize: 24),
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Delete $itemName2",
                        textAlign: TextAlign.center,
                        style:  TextStyle(color: Colors.white, fontSize: 24),
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
                              key: _formdead2,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  FractionallySizedBox(
                                      widthFactor: 0.8,
                                      child: TextFormField(
                                          controller: deadReasonController2,
                                          maxLines:null,
                                          decoration: const InputDecoration(
                                            labelText: 'Death Reason',
                                            hintText: "Reason of death",
                                            border: OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFF005466))),
                                          ),
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "Please enter a reason";
                                            }
                                            return null;
                                          })),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  deadLoading2 == true
                                      ? CircularProgressIndicator()
                                      : ElevatedButton(
                                    onPressed: () {
                                      final isValid = _formdead2
                                          .currentState!
                                          .validate();
                                      if (isValid) {
                                        setState(() {
                                          deadLoading2 = true;
                                        });
                                        DateTime now = DateTime.now();
                                        String formattedDate =
                                        DateFormat('dd/MM/yy HH:mm a')
                                            .format(now);
                                        changeStatus2(
                                            context,
                                            itemId,
                                            formattedDate,
                                            "",
                                            "Dead",
                                            deadReasonController2.text,
                                        itemName);
                                      }
                                    },
                                    child: Text(
                                      "Submit Reason",
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        AppColorss.lightmainColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                        minimumSize: Size(100, 30)),
                                  )
                                ],
                              )),
                        ],
                      ),
                    )));
          },
        );
      },
    );
  }
  Future<void> changeStatus2(BuildContext context, String itemId, String date,
      String username, String status, String deathReason,String itemName) async {
    try {
      await inventoryC.changeStatus2(
          itemId, status, loggedInName, date, username, deathReason);
      sendPushMessage(status, itemName,"Compact");
      if (status == "Borrowed") {
        borrowUserController.clear();
        setState(() {
          giveAccessloading = false;
        });
      }
      else if (status == "Available") {
        setState(() {
          returnBackLoading = false;
        });
        returnUserController.clear();
      }
      else if (status == "Dead") {
        debugPrint("fff");
        setState(() {
          deadLoading2 = false;
        });
        deadReasonController2.clear();
      }
      Navigator.pop(context);
      status == "Borrowed"
          ?
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Access given to ${username}"),
          backgroundColor: Colors.green,
        ),
      )
          : status == "Available"
          ?
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("item successfully returned"),
          backgroundColor: Colors.green,
        ),
      )
          :
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("item successfully marked as Dead"),
        backgroundColor: Colors.green,
      ));
    }
    catch (e) {
      setState(() {
        giveAccessloading = false;
        deadLoading2 = false;
        returnBackLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error updating status,try again!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  AlertDialog buildDeaddAlert(
      BuildContext context,
      String administeredBy,
      String type,
      String itemId,
      String itemName,
      String userDate,
      String deathReason) {
    String itemName2 = "$itemName #$itemId";

    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        decoration: BoxDecoration(color: AppColorss.lightmainColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              isAdmin == true
                ? PopupMenuButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              itemBuilder: (BuildContext context) => [

                PopupMenuItem(
                  child: Text('Delete'),
                  value: "delete",
                ),
              ],
              // color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onSelected: (value) async {
                if (value == "delete") {
                  Navigator.pop(context);
                  deleteItem2(itemId, itemName);
                }
              },
            )

                : Container(),
            // Align(
            //   alignment: Alignment.topRight,
            //   child:Expanded(
            //     child: Container(
            //       child: Text(
            //         "ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd",
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 24,
            //           overflow: TextOverflow.ellipsis,
            //         ),
            //       ),
            //     ),
            //   ),
            //
            //   // child: Padding(
            //   //   padding: const EdgeInsets.all(13.0),
            //   //   child: Expanded(
            //   //
            //   //       child: Text(
            //   //         itemName2,
            //   //         style: TextStyle(color: Colors.white, fontSize: 24,overflow: TextOverflow.ellipsis),
            //   //       ),
            //   //
            //   //   ),
            //   // ),
            // ),
            // Flexible(
            //   child: Text(
            //     itemName2,
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 24,
            //     ),
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Delete $itemName2",
                  textAlign: TextAlign.center,
                  style:  TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),

          ],
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(children: [
             Row(
              children: [
                Text(
                  "Death Reason:",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      color: Colors.black),
                ),
                Expanded(
                  child: Text(
                    deathReason,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 22,
                        color: AppColorss.darkFontGrey),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Authorized by: ',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                          color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: administeredBy,
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: AppColorss.darkFontGrey)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    color: Colors.black, size: 24),
                SizedBox(
                  width: 14,
                ),
                Expanded(
                    child: Text(userDate,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: AppColorss.darkFontGrey)))
              ],
            ),
          ]),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColorss.lightmainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: Size(100, 30)),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('OK!'),
        )
      ],
    );
  }
}
