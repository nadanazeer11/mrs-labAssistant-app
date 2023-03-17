import 'package:cloud_firestore/cloud_firestore.dart';

class Notes{
  String user;
  String note;
  Timestamp time;
  bool public;

  Notes({required this.user,required this.note,required this.time,required this.public});
  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'note':note,
      'time':time,
      'public':public

    };
  }
}