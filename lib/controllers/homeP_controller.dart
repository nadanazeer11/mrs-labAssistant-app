import 'package:mrs/consts/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/Movies.dart';

class HomePcontroller extends GetxController{
  Future<List<String>> getProjectIdsByEmail(String email) async {
    List<String> projectsIds=[];
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: "dimanaseer@gmail.com").get();
    final DocumentSnapshot document = snapshot.docs.first;
    var returnedDocument = document.data() as Map<String, dynamic>;
    if(returnedDocument==null){
      return projectsIds;
    }
    else{
    projectsIds=returnedDocument['proj'];
    }
    return projectsIds;
  }


}
