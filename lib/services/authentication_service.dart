import 'package:firebase_auth/firebase_auth.dart';
import 'package:sketch_to_real/Database/database.dart';
import 'package:sketch_to_real/config/collection_names.dart';
import 'package:sketch_to_real/models/user_model.dart';
import 'package:sketch_to_real/tools/custom_toast.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> logIn({
    String? email,
    final String? password,
  }) async {
    try {
      final UserCredential result = await _firebaseAuth
          .signInWithEmailAndPassword(email: email!, password: password!);
      return result.user!.uid;
    } on FirebaseAuthException catch (e) {
      // errorToast(message: e.message!);
      return null;
    }
  }

  Future deleteUser({required String email, required String password}) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      User user = _firebaseAuth.currentUser!;
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);
      print(user);
      UserCredential result =
          await user.reauthenticateWithCredential(credentials);
      userRef.doc(user.uid).delete();

      await result.user!.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> signUp({
    final String? password,
    final String? userName,
    final timestamp,
    final String? email,
    final bool? isAdmin,
  }) async {
    print("1st stop");
    try {
      final UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email!, password: password!)
          .catchError((Object obj) {
        // errorToast(message: obj.toString());
      });
      final User user = result.user!;
      assert(user != null);
      assert(await user.getIdToken() != null);
      if (user != null) {
        final AppUserModel currentUser = AppUserModel(
            userId: user.uid,
            userName: userName,
            email: email.trim(),
            password: password,
            timestamp: timestamp,
            isAdmin: false,
            photoUrl: "");
        await DatabaseMethods().addUserInfoToFirebase(
            userModel: currentUser, userId: user.uid, email: email);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // errorToast(message: e.message!);
      return null;
    }
  }
}
