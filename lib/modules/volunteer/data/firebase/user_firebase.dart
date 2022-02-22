import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:object_detection/models/Request.dart';
import 'package:object_detection/models/User.dart';
import 'package:object_detection/shared/constants.dart';
import 'package:object_detection/strings/strings.dart';

class UserFirebase {
  static final _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _fireStore = myFireStore;
  static final FirebaseStorage _storage = myStorage;

  static Future<UserCredential> createCredentialAndSignIn(
      String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return await signInWithCredential(credential);
  }

  static Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  static Future<void> signIn(
      {required String phone,
      required onVerificationFailed(FirebaseAuthException e),
      required onCodeSent(String verificationId, int? resendToken)}) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await signInWithCredential(credential);
      },
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      timeout: const Duration(seconds: 120),
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  static resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showToast('Reset password email is send to you',
          duration: Toast.LENGTH_LONG);
    } on FirebaseAuthException catch (err) {
      handleError(err.code);
    }
  }

  static Future<void> storeUserData(
      {required UserModel user, required String uId}) async {
    await _fireStore.collection(USERS_COLLECTION).doc(uId).set(user.toMap());
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUser() async {
    return await _fireStore.collection(USERS_COLLECTION).doc(getUid()).get();
  }

  static String getUid() {
    return _auth.currentUser!.uid;
  }

  static bool isUserLogin() {
    return _auth.currentUser != null;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getAnotherUser(
      String userId) async {
    return await _fireStore.collection(USERS_COLLECTION).doc(userId).get();
  }

  static clearUnSeenNotificationsNumber() async {
    await _fireStore
        .collection(USERS_COLLECTION)
        .doc(getUid())
        .update({'unseenNotifications': 0});
  }

  static updateUserField(
    String key,
    dynamic value,
  ) async {
    await _fireStore
        .collection(USERS_COLLECTION)
        .doc(getUid())
        .update({key: value});
  }

  static updateAnotherUserField(String key, dynamic value, String uId) async {
    await _fireStore.collection(USERS_COLLECTION).doc(uId).update({key: value});
  }

  static Future<void> setRequestForAllVolunteers(Request request) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapShot =
          await _fireStore.collection(VOLUNTEERS_COLLECTION).get();
      showToast('1');
      querySnapShot.docs.forEach((doc) async {
        try {
          await doc.reference
              .collection(REQUESTS_COLLECTION)
              .doc(getUid())
              .set(request.toMap());
        } catch (e) {
          showToast(e.toString());
          showToast('3');
        }
      });
    } on FirebaseException catch (e) {
      showToast(e.message.toString());
    }
  }
}
