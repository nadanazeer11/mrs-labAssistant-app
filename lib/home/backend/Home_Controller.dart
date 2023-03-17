import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../common.dart';
import '../../models/Project.dart';
import '../models/all.dart';

class HomeContr{
  FirebaseFirestore _db=FirebaseFirestore.instance;
   Stream<MyProjects> getMyProjectsStream(String ? id)  {
    debugPrint("here in getmy projectstream");
    try{
      return _db.collection('users').doc(id).snapshots().map((snapshot) =>
      MyProjects(name: snapshot['name'], projects:List<String>.from(
        snapshot['projects']
      )));
    }
    catch(e){
      throw Exception("");
    }
  }
  Stream<Project> getProjectDetails(String? id){
    debugPrint("here in getmy proj det");
     try{
       return _db.collection('projects').doc(id).snapshots().map((snapshot) =>
        Project(title: snapshot['title'],
            description: snapshot['description'],
            users: List<String>.from(snapshot['users']),
            createdBy:snapshot['createdBy'],
            startDate: snapshot['startDate'],
            endDate:snapshot['endDate'],
            isDone:snapshot['isDone'],
            isLate: snapshot['isLate'],
            notes:List<String>.from(snapshot['notes'])
        ));

     }
     catch(e){
       debugPrint("here hc");
       throw Exception("");
     }
  }

  Stream <List<Project>> getPD(){
    debugPrint("home controllor getPD");
    try {
      return _db.collection('projects').get().asStream().map((querySnapshot) =>
          querySnapshot.docs.map((doc) =>
              Project(
                title: doc['title'],
                description: doc['description'],
                users: List<String>.from(doc['users']),
                createdBy: doc['createdBy'],
                startDate: doc['startDate'],
                endDate: doc['endDate'],
                isDone: doc['isDone'],
                isLate: doc['isLate'],
                notes: List<String>.from(doc['notes']),
                id:doc.id
              ),
          ).toList(),
      );
    } catch(e) {
      debugPrint("error occurred while fetching all projects: $e");
      throw Exception("");
    }
  }
  void get(String ?docId)async {
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(docId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Project name: ${documentSnapshot.get('notes')}');
        print('Project description: ${documentSnapshot.get('description')}');
        // add more print statements for other fields as needed
      } else {
        print('Document does not exist');
      }
    })
        .catchError((error) => print('Error getting document: $error'));
  }
   Future<void> updateProjectIsDone(String? projectId, bool isDone) async {
    try {
      await _db.collection('projects').doc(projectId).update({'isDone': isDone});

    } catch (e) {
     throw Exception("Ff");
    }
  }

}