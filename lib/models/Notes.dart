import 'package:cloud_firestore/cloud_firestore.dart';

class Notes{
  String user;
  String note;
  Timestamp time;
  bool public;
  String url;
  String baseName;

  Notes({required this.user,required this.note,required this.time,required this.public,required this.url,required this.baseName});
  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'note':note,
      'time':time,
      'public':public,
      'url':url,
      'baseName':baseName

    };
  }
}