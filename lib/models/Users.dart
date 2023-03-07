import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
class User{
final String name;
final String email;
final String password;
final List<String> projects;

User({required this.name, required this.email, required this.password,required this.projects});
// factory User.fromSnapshot(DocumentSnapshot snapshot) {
//   Map<String, dynamic> data = snapshot.data() as Map<String,dynamic>;
//   name=data[]
// return User(
//   name: data[name],
// email: snapshot.data()['email'],
// projects: List<String>.from(snapshot.data()['projects'] ?? []), password: '',
// );
// }
}