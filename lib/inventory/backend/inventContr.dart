import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mrs/models/InventoryItems.dart';

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
  Future<List<InventorySummary>> getSummary()async{
    try{
      QuerySnapshot all=await _db.collection("inventory").get();
      List<String> names=[];
      List<InventorySummary> invList=[];

      for(var doc in all.docs){
        String itemName=doc.get("itemName");
        String status=doc.get("status");
        if(names.contains(itemName)){
          invList.firstWhere((element) => element.itemName==itemName).quantity+=1;
          if(status=="Available"){
            invList.firstWhere((element) => element.itemName==itemName).availableCount+=1;
          }
          else if(status=="Dead"){
            invList.firstWhere((element) => element.itemName==itemName).deadCount+=1;

          }
          else if(status=="Borrowed"){
            invList.firstWhere((element) => element.itemName==itemName).borrowedCount+=1;
          }

        }
        else{
          names.add(itemName);
          InventorySummary inv=InventorySummary(itemName: itemName,
              borrowedCount:status=="Borrowed"?1:0, availableCount: status=="Available"?1:0, deadCount: status=="Dead"?1:0, quantity:1);
          invList.add(inv);
        }

      }
      return invList;
    }
    catch(e){
      throw Exception("f");
    }
  }
  Future<void> changeStatus(String id,String status,String admin,Timestamp date,String user)async{
    try{
      final QuerySnapshot snapshot = await _db.collection('inventory')
          .where('itemId', isEqualTo: id)
          .get();
      final DocumentSnapshot userDoc = snapshot.docs.first;
      final String userId = userDoc.id;
      await FirebaseFirestore.instance.collection('inventory').doc(userId).update(
          {
            'status':status,
            'borrowedDate':status=="Available"? "": date,
            'borrowedUser':status=="Borrowed"? user:"",


          });
    }
    catch(e){

    }
  }


}