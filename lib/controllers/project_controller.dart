import 'package:mrs/consts/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ProjectController extends GetxController{
  final CollectionReference projects =
  FirebaseFirestore.instance.collection('projects');
  Future<bool> createProject({title,description,enddate,startdate,users}) async {
    bool isUnique = false;
    String id;
    DocumentReference id2;
    try {
      debugPrint('fff,${enddate}');
       id= await projects.add({
        "title": title,
        "description": description,
        "enddate": enddate,
        "startdate": startdate,
        "users": users
      }).then((doc) => doc.id);

      for (String user in users){
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('name', isEqualTo: user)
            .get();

        final DocumentSnapshot userDoc = snapshot.docs.first;
        final String userId = userDoc.id;

        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'projects': FieldValue.arrayUnion([id])
        });
      }
      isUnique = true;
    }
    catch (e) {
      isUnique = false;
    }
    return isUnique;
  }



  Future<List<String>> getUserNames() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    final List<String> userNames = [];

    for (final DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
      final Map<String, dynamic>? data = documentSnapshot.data();
      if (data != null && data.containsKey('name')) {
        userNames.add(data['name'] as String);
      }
    }
    for (String username in userNames) {
      debugPrint(username);
    }
    return userNames;
  }




}