// import 'package:cloud_firestore/cloud_firestore.dart';
//
// Widget steps(BuildContext context, int index, String id) {
//   return FutureBuilder<DocumentSnapshot>(
//     future: FirebaseFirestore.instance.collection('notes').doc(id).get(),
//     builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//       if (snapshot.connectionState == ConnectionState.done) {
//         if (snapshot.hasError) {
//           // If an error occurs while fetching the note, display an error message
//           return Text("Error: ${snapshot.error}");
//         } else {
//           // If the note is successfully fetched from Firestore, display it
//           Map<String, dynamic> data = snapshot.data?.data() ?? {};
//           String note = data['note'] ?? 'N/A';
//
//           return Padding(
//             padding: const EdgeInsets.fromLTRB(4,0,3,27),
//             child: Container(
//               margin:EdgeInsets.fromLTRB(4, 0, 3, 0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       // add avatar image or tex
//                     ),
//                     SizedBox(width: 15),
//                     Expanded(
//                       child: SizedBox(
//                         child: Text(
//                           '$note',
//                           style: TextStyle(fontSize: 16,color: Colors.black54),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }
//       } else {
//         // While the note is being fetched, display a loading spinner
//         return CircularProgressIndicator();
//       }
//     },
//   );
// }
