// import 'package:flutter/material.dart';
//
// import '../../config/colors.dart';
// import '../../models/Inventory.dart';
// import '../../models/InventoryItems.dart';
// import '../backend/inventContr.dart';
// import '../widgets/scrollable_widget.dart';
//
// class Loose extends StatefulWidget {
//   final List<Inventory> invent;
//   final bool isAdmin;
//   final String loggedInId;
//   final String logged
//   Loose({required this.invent});
//
//   @override
//   State<Loose> createState() => _LooseState();
// }
//
// class _LooseState extends State<Loose> {
//   var searchController = TextEditingController();
//   String? searchWord;
//   bool loadSummary = false;
//   List<InventorySummary> list = [];
//   InventContr inventoryC = InventContr();
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;
//
//     return Column(
//       children: [
//         Row(
//           children: [
//             SizedBox(
//               width: w*0.85,
//               child: TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search using id/name...',
//                   prefixIcon: searchWord == null ? IconButton(
//                     onPressed: () {
//                       setState(() {
//                         searchWord = searchController.text;
//                       });
//                     }, icon: const Icon(Icons.search),) : IconButton(
//                     onPressed: () {
//                       setState(() {
//                         searchWord = null;
//                         searchController.clear();
//                       });
//                     }, icon: const Icon(Icons.clear),),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   contentPadding: const EdgeInsets.all(8),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Align(
//                   alignment: Alignment.centerRight,
//                   child: loadSummary == true
//                       ? CircularProgressIndicator()
//                       : IconButton(onPressed: () {
//                     getSumm(context);
//                   },
//                     hoverColor: AppColorss.lightmainColor,
//                     icon: Icon(Icons.summarize_outlined),
//                     color: Colors.grey,)),
//             ),
//           ],
//         ),
//         const SizedBox(height: 15,),
//         // PaginatedDataTable(
//         //   columns:getColumns(columns),
//         //     rowsPerPage: 2,
//         //     source:
//         //     RowSource(
//         //       myData: invent?? [],
//         //       count: invent == null ? 0 : invent.length,
//         //       searchWord: searchWord,
//         //       filter: filter
//         //
//         //     )
//         //
//         // ),
//         ScrollableWidget(child: buildDataTable(widget.invent),),
//       ],
//     );
//   }
//
//   buildDataTable(invent) {}
//   Future<void> getSumm(BuildContext context) async {
//     try {
//       loadSummary = true;
//       List<InventorySummary> m = await inventoryC.getSummary();
//       setState(() {
//         list = m;
//       });
//       loadSummary = false;
//       showDialog(
//         context: context,
//         builder: (context) =>
//             buildSummaryAlert(context),
//       );
//     }
//     catch (e) {
//       loadSummary = false;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error getting summary"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//   AlertDialog buildSummaryAlert(BuildContext context) {
//     final screenWidth = MediaQuery
//         .of(context)
//         .size
//         .width;
//     final screenHeight = MediaQuery
//         .of(context)
//         .size
//         .height;
//     return AlertDialog(
//       backgroundColor: Colors.white,
//       titlePadding: EdgeInsets.zero,
//       title: Container(
//         decoration: BoxDecoration(color: AppColorss.lightmainColor),
//         child: const Center(
//           child: Padding(
//             padding: EdgeInsets.all(13.0),
//             child: Text(
//               "Inventory Summary",
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//           ),
//         ),
//       ),
//       content:
//       SizedBox(
//         width: screenWidth * 0.99,
//         child: SingleChildScrollView(
//           child: Container(
//             width: double.maxFinite,
//             child: Column(
//               children: [
//                 ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: list.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     InventorySummary x = list[index];
//                     return Column(
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.arrow_forward_ios_outlined,
//                               color: AppColorss.darkFontGrey,),
//                             const SizedBox(width: 14),
//                             Text(x.itemName, style: TextStyle(
//                                 color: AppColorss.darkFontGrey),),
//                           ],
//                         ),
//                         SizedBox(height: 12,),
//                         DataTable(
//                           headingRowHeight: 28,
//                           dataRowHeight: 28,
//                           columnSpacing: 20,
//                           border: TableBorder.all(color: Colors.black38,
//                               width: 2,
//                               borderRadius: BorderRadius.circular(2.0)),
//                           columns: const [
//                             DataColumn(label: Text('Available')),
//                             DataColumn(label: Text('Borrowed')),
//                             DataColumn(label: Text('Dead')),
//                           ],
//                           rows: [
//                             DataRow(cells: [
//                               DataCell(Text(x.availableCount.toString())),
//                               DataCell(Text(x.borrowedCount.toString())),
//                               DataCell(Text(x.deadCount.toString())),
//                             ]),
//                           ],
//                         ),
//                         SizedBox(height: 12,),
//
//                       ],
//                     );
//                   },
//                 ),
//
//               ],
//             ),
//
//           ),
//         ),
//       ),
//       actions: [
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//               backgroundColor: AppColorss.lightmainColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               minimumSize: Size(100, 30)
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: Text('OK!'),
//         )
//       ],
//     );
//   }
//
//
// }
