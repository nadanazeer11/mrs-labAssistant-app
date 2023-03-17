import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mrs/models/Users.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/Notes.dart';
import '../../models/Project.dart';

class ProjectDContr{
  FirebaseFirestore _db=FirebaseFirestore.instance;

  Future<Notes> getNoteById(String ?id) async {
    try{
      DocumentSnapshot noteSnapshot = await FirebaseFirestore.instance
          .collection('notes')
          .doc(id)
          .get();

      if (noteSnapshot.exists) {
        return Notes(
            user: noteSnapshot.get('user'),
            note: noteSnapshot.get('note'),
            time: noteSnapshot.get('time'),
            public: noteSnapshot.get('publiv')
        );
      } else {
        return Notes(
          user:"N/A",
          note: "no note found!",
          time:Timestamp.fromDate(DateTime.now()),
          public: false
        );
      }
    }
    catch(e){
      throw Exception("ff");
    }

  }
  Future<void> addNote(Notes note,String? id)async{
    try{
      String x=note.note;
      String y=note.user;
      String? z=id;
      debugPrint("note text $x $y $z");
      DocumentReference idd=await _db.collection("notes").add(
        note.toMap()
      );
      await _db.collection('projects').doc(id).update(
        {
          'notes': FieldValue.arrayUnion([idd.id])
        }
      );
    }
    catch(e){
      throw Exception("d");
    }
  }
  Future<List<Notes>> getNotes(List<String>? noteIds) async {
    try{
      if(noteIds==null || noteIds.isEmpty){
        return [];
      }
      else{
        noteIds = List.from(noteIds.reversed);
        final List<Notes> notes = [];

        for (final n in noteIds) {
          final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('notes').doc(n).get();

          if (snapshot.exists) {
            final Map<String, dynamic> data = snapshot.data()!;
            notes.add(Notes(
              note: data['note'],
              user: data['user'],
              time: data['time'],
              public: data['public']
            ));
          }
        }

        return notes;
      }

    }
    catch(e){
      throw Exception("f");
    }

  }
  Future<bool>see (String? pid,String ?uid)async{
    try{
      DocumentSnapshot x=await _db.collection('users').doc(uid).get();
      if(x.exists){
        String name=x.get("name");
        List<String> proj=List<String>.from(x.get('projects'));
        if(proj.contains(pid)){
          debugPrint("allow ");
          return true;
        }
        else{
          debugPrint("no allow ");

          return false;
        }
      }
      else{
        debugPrint("error allow ");

        throw Exception("f");
      }
    }
    catch(e){
      throw Exception("f");
    }
  }
}