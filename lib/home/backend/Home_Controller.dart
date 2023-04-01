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
            notes:List<String>.from(snapshot['notes']),
            creation: snapshot['creation']
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
                id:doc.id,
                creation: doc['creation']
              ),
          ).toList(),
      );
    } catch(e) {
      debugPrint("error occurred while fetching all projects: $e");
      throw Exception("");
    }
  }

  Stream<List<Project>> getProjects() {
    return _db.collection('projects').orderBy('creation', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Project(
            title: doc['title'],
            description: doc['description'],
            users: List<String>.from(doc['users']),
            createdBy: doc['createdBy'],
            startDate: doc['startDate'],
            endDate: doc['endDate'],
            isDone: doc['isDone'],
            isLate: doc['isLate'],
            notes: List<String>.from(doc['notes']),
            id:doc.id,
            creation: doc['creation']
        );
      }).toList();
    });
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
  Future<bool> isCreateP(String ? uid) async{
     try{
       DocumentSnapshot x=await _db.collection('users').doc(uid).get();
       if(x.exists){
         return x.get('createP');
       }
       else{
         return false;
       }
     }
     catch(e){
       throw Exception("");
     }
  }
  Future<bool> isCreateU(String ? uid) async{
    try{
      debugPrint("my uid $uid");
      DocumentSnapshot x=await _db.collection('users').doc(uid).get();
      if(x.exists){
        return x.get('addU');
      }
      else{
        return false;
      }
    }
    catch(e){
      throw Exception("");
    }
  }
  Future<bool> isInventoryM(String ? uid) async{
    try{
      debugPrint("my uid $uid");
      DocumentSnapshot x=await _db.collection('users').doc(uid).get();
      if(x.exists){
        return x.get('inventoryM');
      }
      else{
        return false;
      }
    }
    catch(e){
      throw Exception("");
    }
  }
  Future<List<String>> getProjUsers(String ? id)async{
    try{
      DocumentSnapshot snapshot=await _db.collection('projects').doc(id).get();
      List<String> users=List<String>.from(snapshot.get('users'));
      return users;
    }
    catch(e){
      throw Exception("d");

    }
  }
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
  Future<void> editUsers(List<String>edited,List<String>all,String? id)async{
    List<String> newList = edited.where((item) => !all.contains(item)).toList();
    List<String> missingList = all.where((item) => !edited.contains(item)).toList();
    debugPrint("hiiiiiiiiiiiiiiii$edited");
    debugPrint("byee$all");
    debugPrint("hazawdhom $newList");
    debugPrint("hashelhom $missingList");

    try{
      for(String rem in missingList){
        debugPrint(rem);
        QuerySnapshot querySnapshot=await _db.collection('users').where(
            'name',isEqualTo:rem).limit(1).get();
        DocumentSnapshot? documentSnapshot=querySnapshot.docs.first;
        final String userId=documentSnapshot.id;
        await _db.collection('users').doc(userId).update({'projects': FieldValue.arrayRemove([id])});
        await _db.collection('projects').doc(id).update({'users':FieldValue.arrayRemove([rem])});

      }
      for(String add in newList){
        QuerySnapshot querySnapshot=await _db.collection('users').where(
            'name',isEqualTo:add).limit(1).get();
        DocumentSnapshot? documentSnapshot=querySnapshot.docs.first;
        final String userId=documentSnapshot.id;
        await _db.collection('users').doc(userId).update({'projects': FieldValue.arrayUnion([id])});
        await _db.collection('projects').doc(id).update({'users':FieldValue.arrayUnion([add])});

      }
    }
    catch(e){
      debugPrint("error in editing contr");
      throw Exception("d");
    }
  }
  Future<void> deleteDocument(String ? id)async{
     try{
       DocumentSnapshot project=await _db.collection('projects').doc(id).get();
       List<String> users=List<String>.from(project.get('users'));
       List<String> notes=List<String>.from(project.get('notes'));
       try{
         for(String user in users){
           QuerySnapshot querySnapshot=await _db.collection('users').where(
               'name',isEqualTo:user).limit(1).get();
           DocumentSnapshot? documentSnapshot=querySnapshot.docs.first;
           final String userId=documentSnapshot.id;
           await _db.collection('users').doc(userId).update({'projects': FieldValue.arrayRemove([id])});
         }
         try{
           await _db.collection('projects').doc(id).delete();
           try{
             for(String note in notes){
               await _db.collection('notes').doc(note).delete();
             }
           }
           catch(e){
             throw Exception("Could not remove notes");
           }
         }
         catch(e){
           throw Exception("could not delete project itself");
         }

       }
       catch(e){
         throw Exception("Couldnt remove project from users");
       }
     }
     catch(e){
       throw Exception("couldnt get users");
     }
  }
  Future<void> updateIsLate() async{
     final now=DateTime.now();
     try {
       debugPrint("update isLate");
       // QuerySnapshot q = await _db.collection('projects')
       //     .where('endDate', isLessThanOrEqualTo: Timestamp.fromDate(now)).get();
       //     // .where('isDone', isEqualTo: false)
       //     // .get();
       QuerySnapshot q1 = await FirebaseFirestore.instance
           .collection('projects')
           .where('endDate', isLessThan: Timestamp.fromDate(now))
           .get();

       QuerySnapshot q2 = await FirebaseFirestore.instance
           .collection('projects')
           .where('isDone', isEqualTo: false)
           .get();

       List<DocumentSnapshot> docs = q1.docs.where((doc) =>
           q2.docs.any((doc2) => doc2.id == doc.id)).toList();
       debugPrint("length ${docs.length}");
       for(var x in docs){
           await _db.collection('projects').doc(x.id).update({
             'isLate': true,
           });
       }
     }
     catch(e){

     }
  }
}