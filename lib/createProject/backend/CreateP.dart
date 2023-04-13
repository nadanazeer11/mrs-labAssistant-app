import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mrs/models/Users.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/Project.dart';

class CreatePController{
  FirebaseFirestore _db=FirebaseFirestore.instance;
  Future<List<String>> getUserNames() async {
    final List<String> userNames = [];
    try{
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      for (final DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
        final Map<String, dynamic>? data = documentSnapshot.data();
        if (data != null && data.containsKey('name')) {
          userNames.add(data['name'] as String);
        }
      }
      for (String username in userNames) {
        debugPrint(username);
      }
    }
    catch(e){
      throw Exception("w");
    }

    return userNames;
  }
  Future<String>createProject(Project project)async{
    DocumentReference id;
    try{
      debugPrint("in create P cont");
     id=await  _db.collection("projects").add(project.toMap());
     for (String user in project.users){
       final QuerySnapshot snapshot = await _db.collection('users')
           .where('name', isEqualTo: user)
           .get();
       final DocumentSnapshot userDoc = snapshot.docs.first;
       final String userId = userDoc.id;
       await FirebaseFirestore.instance.collection('users').doc(userId).update({
         'projects': FieldValue.arrayUnion([id.id])
       });
     }
     return id.id;
    }
    catch(e){
      throw Exception("f");
    }
  }
  Future<List<String>> getTokens(List<String>names) async{
    try{

      List<String> result=[];
      QuerySnapshot querySnapshot = await _db.collection('users')
          .where('name', whereIn: names)
          .get();

      for (var doc in querySnapshot.docs) {
        int count=1;
        debugPrint("tokennnnnnnn ${doc["token"]}");
        count+=1;
        result.add(doc['token']);
      }
      // debugPrint("uaraaaaaaaaaaaaah${result[0]}");
      // debugPrint("uaraaaaaaaaaaaaah${result[1]}");
      return result;
    }
    catch(e){
      throw Exception("F");
    }

  }

}