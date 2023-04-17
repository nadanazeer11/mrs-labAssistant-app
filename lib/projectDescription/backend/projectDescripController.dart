import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mrs/models/Users.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/Notes.dart';
import '../../models/Project.dart';
import 'package:path/path.dart';
import 'dart:io';
class ProjectDContr{
  FirebaseFirestore _db=FirebaseFirestore.instance;

  Future<Notes> getNoteById(String ?id) async {
    debugPrint("immmmmmmmmmm heeeeeeeeeeeeeeeeeeere");
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
            public: noteSnapshot.get('publiv'),
            url: noteSnapshot.get('url'),
            baseName: noteSnapshot.get('baseName'),
        );
      } else {
        return Notes(
          user:"N/A",
          note: "no note found!",
          time:Timestamp.fromDate(DateTime.now()),
          public: false,
          url: "",
          baseName: ""
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
              public: data['public'],
              url: data['url'],
              baseName: data['baseName']
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
  UploadTask? uploadFile(String destination,File file){
    try{
      final ref=FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    }
    on FirebaseAuthException catch (e){
      return null;
    }

  }
  Future<String> downloadFile(String? ref) async{
    try{
      // final dir=await DownloadsPathProvider.downloadsDirectory;
      final dir=await getApplicationDocumentsDirectory();
      final FirebaseStorage storage=FirebaseStorage.instance;
      String x= ref ?? "sorry.png";
      Reference ref2=storage.ref().child(x);
      final file=File('${dir.path}/${x}');
      String link=await ref2.getDownloadURL();
      debugPrint("hey ${link}");
      debugPrint("dir ${dir}");
      try{
        await ref2.writeToFile(file);
        return "done";
      }
      catch(e){
        return "was not able to download";
      }


    }
    catch(e){
      return "was not able to get reference";
    }
  }
  Future<File> loadFirebase(String url) async {
    try {
      final refPDF = FirebaseStorage.instance.ref().child(url);
      final bytes = await refPDF.getData();
      return _storeFile(url, bytes as List<int>);
    } catch (e) {
      throw Exception("");
    }
  }
  Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
  Future<List<String>> getUsers(String? id) async{
    try{
      debugPrint("id el note $id");
      List<String> tokens=[];
      final docSnapshot =await _db.collection('projects').doc(id).get();
      if (!docSnapshot.exists) {
        throw Exception('Project with ID $id does not exist');
      }

      final data = docSnapshot.data();
      if (data == null) {
        throw Exception('Project data is null');
      }

      final users = data['users'];
      if (users == null || !(users is List<dynamic>)) {
        throw Exception('Invalid users field in project data');
      }
      List<String> x=List<String>.from(users);
      for (String  m in x){
        final querySnapshot=await _db.collection('users').where('name',isEqualTo: m).get();
        String id=querySnapshot.docs.first.get('token');
        debugPrint("token el notes $id");
        tokens.add(id);

      }
      return tokens;

    }
    catch(e){
      throw Exception();

    }
  }
}