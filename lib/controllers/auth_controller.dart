//login method
import 'package:mrs/consts/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserCredential?> loginMethod({email, password, context}) async {
    UserCredential? userCredential;

    try {
      userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
    }
    on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
    }
    return userCredential;
  }

  Future<UserCredential?> signupMethod({email, password, context}) async {
    UserCredential? userCredential;
    try {
      userCredential =
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    }
    on FirebaseAuthException catch (e) {
      VxToast.show(context, msg: e.toString());
      debugPrint('ee');
    }
    return userCredential;
  }

  signoutMethod(context) async {
    try {
      await auth.signOut();
    }
    catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }
  Future<bool> isUsernameUnique(String username) async {
    bool isUnique = true;
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection(usersCollection).where('name', isEqualTo: username).get();
      if (snapshot.docs.isNotEmpty) {
        isUnique = false;
      }
    } catch (e) {
      print('Error checking username uniqueness: $e');
    }
    return isUnique;
  }
  // Future<bool> signUpmethod(User user){
  //
  //   return true;
  // }

  storeUserData({name, password, email}) async {
    // DocumentReference store = firestore.collection(usersCollection).doc(
    //     currentUser!.uid);
    // store.set(
    //     {'name': name, 'password': password, 'email': email, 'imageurl': ''});
    final CollectionReference user =
    FirebaseFirestore.instance.collection('users');
    await user.add({"name": name, "password": password,"email":email});
  }
}