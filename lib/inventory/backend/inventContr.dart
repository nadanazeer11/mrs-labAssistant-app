import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:mrs/models/Users.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/Inventory.dart';
import '../../models/Project.dart';

class InventContr{
  FirebaseFirestore _db=FirebaseFirestore.instance;
  Stream<List<Inventory>> getInventoryLoose() {
    debugPrint("getInventoryLoose");
    return _db.collection('inventory').orderBy('creationDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        debugPrint("el id ya basha beta3 el inventory${doc['borrowedDate']}");
        return Inventory(
            itemId: doc['itemId'],
            itemName: doc['itemName'],
            status: doc['status'],
            createdBy: doc['createdBy'],
            borrowedUser: doc['borrowedUser'],
            creationDate: doc['creationDate'],
            borrowedFrom: doc['borrowedFrom'],
            borrowedDate: doc['borrowedDate']
        );
      }).toList();
    });
  }
  Future<bool> isAdmin(String ?id)async{
    try{
      DocumentSnapshot user=await _db.collection('users').doc(id).get();
      bool isAdm=user.get("inventoryM");
      return isAdm;
    }
    catch(e){
      throw Exception();
    }
  }
  Future<List<String>> allAdmins() async {
    try{
      List<String> admins=[];
      QuerySnapshot x=await _db.collection('users').where('inventoryM',isEqualTo: true).get();
      for (var doc in x.docs) {
        String username = doc.get('name');
        admins.add(username);
      }
      return admins;
    }
    catch(e){
      throw Exception();
    }
  }
  Future<List<String>> getInventoryItems() async{
    List<String> list=[];
    try{
      QuerySnapshot inventory=await _db.collection('inventory').get();
      for(var doc in inventory.docs){
        String name=doc.get('itemName');
        String toLower=name.toLowerCase().trim();
        if(!list.contains(toLower)){
          list.add(toLower);
        }
      }

      return list;
    }
    catch(e){
      throw Exception("error");
    }
  }
  Future<void> addItem(Inventory inv)async{

    try{
      await _db.collection('inventory').add(inv.toMap());
    }
    catch(e){
      throw Exception("rrr");
    }
  }


}