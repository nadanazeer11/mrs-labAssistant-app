// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/services.dart';
// import 'config/colors.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   HomePageState createState() => HomePageState();
// }
//
// class HomePageState extends State<HomePage> {
//   var currentIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     double displayWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       bottomNavigationBar: Container(
//         margin: EdgeInsets.all(displayWidth * .05),
//         height: displayWidth * .155,
//         decoration: BoxDecoration(
//           color: AppColorss.darkmainColor,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(.1),
//               blurRadius: 30,
//               offset: Offset(0, 10),
//             ),
//           ],
//           borderRadius: BorderRadius.circular(50),
//         ),
//         child: ListView.builder(
//           itemCount: 2,
//           scrollDirection: Axis.horizontal,
//           padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
//           itemBuilder: (context, index) => InkWell(
//             onTap: () {
//               setState(() {
//                 currentIndex = index;
//                 HapticFeedback.lightImpact();
//               });
//             },
//             splashColor: Colors.transparent,
//             highlightColor: Colors.transparent,
//             child: Stack(
//               children: [
//                 AnimatedContainer(
//                   duration: Duration(seconds: 1),
//                   curve: Curves.fastLinearToSlowEaseIn,
//                   width: index == currentIndex
//                       ? displayWidth * .32
//                       : displayWidth * .18,
//                   alignment: Alignment.center,
//                   child: AnimatedContainer(
//                     duration: Duration(seconds: 1),
//                     curve: Curves.fastLinearToSlowEaseIn,
//                     height: index == currentIndex ? displayWidth * .12 : 0,
//                     width: index == currentIndex ? displayWidth * .32 : 0,
//                     decoration: BoxDecoration(
//                       color: index == currentIndex
//                           ? Colors.blueAccent.withOpacity(.2)
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                   ),
//                 ),
//                 AnimatedContainer(
//                   duration: Duration(seconds: 1),
//                   curve: Curves.fastLinearToSlowEaseIn,
//                   width: index == currentIndex
//                       ? displayWidth * .5
//                       : displayWidth * .20,
//                   alignment: Alignment.center,
//                   child: Stack(
//                     children: [
//                       Row(
//                         children: [
//                           AnimatedContainer(
//                             duration: Duration(seconds: 1),
//                             curve: Curves.fastLinearToSlowEaseIn,
//                             width:
//                             index == currentIndex ? displayWidth * .13 : 0,
//                           ),
//                           AnimatedOpacity(
//                             opacity: index == currentIndex ? 1 : 0,
//                             duration: Duration(seconds: 1),
//                             curve: Curves.fastLinearToSlowEaseIn,
//                             child: Text(
//                               index == currentIndex
//                                   ? '${listOfStrings[index]}'
//                                   : '',
//                               style: TextStyle(
//                                 color: Colors.blueAccent,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Center(
//                         child: Row(
//                           children: [
//                             AnimatedContainer(
//                               duration: Duration(seconds: 1),
//                               curve: Curves.fastLinearToSlowEaseIn,
//                               width:
//                               index == currentIndex ? displayWidth * .03 : 20,
//                             ),
//                             Icon(
//                               listOfIcons[index],
//                               size: displayWidth * .076,
//                               color: index == currentIndex
//                                   ? Colors.white
//                                   : Colors.black,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<IconData> listOfIcons = [
//     Icons.home_rounded,
//     Icons.pan_tool,
//
//   ];
//
//   List<String> listOfStrings = [
//     'Home',
//     'Inventory'
//   ];
// }
//
//
