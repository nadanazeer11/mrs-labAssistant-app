import 'package:mrs/consts/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/Movies.dart';

class HomePcontroller extends GetxController{
  Future<List<String>> getProjectIdsByEmail(String email) async {
    List<String> projectsIds=[];
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: "dimanaseer@gmail.com").get();
    final DocumentSnapshot document = snapshot.docs.first;
    var returnedDocument = document.data() as Map<String, dynamic>;
    if(returnedDocument==null){
      return projectsIds;
    }
    else{
    projectsIds=returnedDocument['proj'];
    }
    return projectsIds;
  }


}
// Future<List<Project>> getProjectsByIds(List<String> ids) async {
//   final querySnapshot = await FirebaseFirestore.instance
//       .collection('projects')
//       .where(FieldPath.documentId, whereIn: ids)
//       .get();
//
//   final projects = querySnapshot.docs.map((doc) => Project.fromSnapshot(doc)).toList();
//
//   return projects;
// }
final moviesRef = FirebaseFirestore.instance.collection('movies').withConverter<Movie>(
  fromFirestore: (snapshot, _) => Movie.fromJson(snapshot.data()!),
  toFirestore: (movie, _) => movie.toJson(),
);
Future<void> s({title,genre}) async {
  // Obtain science-fiction movies
  // List<QueryDocumentSnapshot<Movie>> movies = await moviesRef
  //     .where('genre', isEqualTo: 'Sci-fi')
  //     .get()
  //     .then((snapshot) => snapshot.docs);

  // Add a movie
  await moviesRef.add(
    Movie(
        title: 'Star Wars: A New Hope (Episode IV)',
        genre: 'Sci-fi'
    ),
  );

  // Get a movie with the id 42
}