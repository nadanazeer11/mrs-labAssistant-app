import 'package:cloud_firestore/cloud_firestore.dart';

class Project{
  String id;
  String title;
  String description;
  DateTime startdate;
  DateTime enddate;
  List<String> users;

  Project({required this.id, required this.title,required this.description,required this.startdate,required this.enddate,required this.users});
  factory Project.fromMap(Map<String, dynamic> data) {
    final String id=data['id'];
    final String title = data['title'];
    final String description = data['description'];
    final List<String> users = List<String>.from(data['users']);
    final DateTime enddate = data['enddate'].toDate();
    final DateTime startdate = data['startdate'].toDate();

    return Project(
      id:id,
      title: title,
      description: description,
      users: users,
      startdate: startdate,
      enddate: enddate

    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'users': users,
      'enddate': Timestamp.fromDate(enddate),
      'startdate':Timestamp.fromDate(enddate)

    };
  }
}