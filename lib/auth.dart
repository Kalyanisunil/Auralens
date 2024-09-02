import 'package:firebase_auth/firebase_auth.dart';

Future<String> login(username, password) async {
  String status = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: username, password: password)
      .then((value) {
        print("login success");
    return 'Success';
  }).catchError((onError) {
    return onError.toString();
  });
  return status; // Add a return statement here
}
//sign up
Future<String> signUp(username, password, name) async {
  await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: username, password: password)
      .then((value) {
    return 'Success';
  }).catchError((onError) {
    return onError.toString();
  });
  return "Error";
}



Future logout() async {
  await FirebaseAuth.instance.signOut();
}

 
 
