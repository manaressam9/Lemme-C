import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:object_detection/models/Request.dart';
import 'package:object_detection/models/User.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_request/cubit/cubit.dart';
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
      required onAutoVerification(PhoneAuthCredential phoneAuthCredential),
      required onCodeSent(String verificationId, int? resendToken),
      required onAutoVerificationTimeOut(String verificationId)}) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '$phone',
      verificationCompleted: onAutoVerification,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      timeout: const Duration(seconds: 60),
      codeAutoRetrievalTimeout: onAutoVerificationTimeOut,
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

  static isPhoneNumberExist(String phone) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapShot = await _fireStore
          .collection(USERS_COLLECTION)
          .where('phone', isEqualTo: phone)
          .get();
      if (snapShot.docs.isNotEmpty) return true;
    } catch (e) {
      return false;
    }
    return false;
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

  static Future<void> setRequestForAllVolunteers(Request request,VolunteerRequestCubit cubit) async {
    await _fireStore
        .collection(REQUESTS_COLLECTION)
        .doc(getUid())
        .set(request.toMap());
    final preference = await getPreference();
    preference.setBool(REQUEST_SENT_FLAG, true);
    cubit.onRequestSuccess();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> listenOnMyRequest() {
    return _fireStore.collection(REQUESTS_COLLECTION).doc(getUid()).snapshots();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> listenOnMyResponse(
      String responseId) {
    return _fireStore
        .collection(RESPONSES_COLLECTION)
        .doc(responseId)
        .snapshots();
  }
}
