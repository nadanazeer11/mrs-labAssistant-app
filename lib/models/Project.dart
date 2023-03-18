import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  String title;
  String description;
  bool isDone;
  bool isLate;
  List<String> users;
  String createdBy;
  Timestamp startDate;
  Timestamp endDate;
  List<String> notes;
  String id;
  Timestamp creation;


  Project(
      {
        required this.title,
        required this.description,
        required this.users,
        required this.createdBy,
        required this.startDate,
        required this.endDate,
        this.isDone=false,
        this.isLate=false,
        this.id="",
        required this.notes,
        required this.creation
      });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'isLate': isLate,
      'users': users,
      'createdBy': createdBy,
      'startDate': startDate,
      'endDate': endDate,
      'notes':notes,
      'id':id,
      'creation':creation
    };
  }
  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Project(
      title: data['title'],
      description: data['description'],
      users: List<String>.from(data['users']),
      createdBy: data['createdBy'],
      startDate: data['startDate'],
      endDate: data['endDate'],
      isDone: data['isDone'] ?? false,
      isLate: data['isLate'] ?? false,
      notes:data['notes'],
      id:data['id'],
      creation:data['creation']
    );
  }


}