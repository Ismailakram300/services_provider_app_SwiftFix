import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:image_picker/image_picker.dart';
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
Future<UserCredential> signUpWithEmailAndPassword({
  required String email,
  required String password,  


  
}) async {
  try {

    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;


    if (user != null) {
      UserData.email = user.email!;
      print("Signed up user email: ${UserData.email}");
    } else {
      print("User creation failed or email is null");
    }

    return userCredential;
  } catch (e) {
    // If any error occurs during signup
    throw Exception('Failed to create account: $e');
  }
}


  // Upload profile image for mobile
  Future<String> _uploadProfileImageToStorage(File file) async {
    try {
      final storageRef = _storage.ref().child('profileImages/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<String> _uploadProfileImageToStorageWeb(Uint8List fileBytes, String fileName) async {
    try {
      final storageRef = _storage.ref().child('profileImages/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putData(fileBytes);

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  // Create user document in Firestore
  Future<void> createUserDocument({
    required String userId,
    required String name,
    required String email,
    required String role,
   // required String phone,
    required String imageUrl, String? city,
     String? businessName,
     String? businessDetails,
    required String phoneNumber,
   // required PhoneAuthCredential phoneCredential,
  }) async {
    try {
      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'profileImage': imageUrl,
        'userId': userId,
        'city': city,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add  for service provider
      if (role == 'service_provider') {
        userData.addAll({
          'businessName': businessName ?? '',
          'businessDetails': businessDetails ?? '',
        });
      }

      await _firestore.collection('users').doc(userId).set(userData);
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }

}


  // Complete the sign-up process
  Future<void> completeSignUpProcess({

    required String email,
    required String password,
    required String name,
    XFile? profileImage,
    required String role,
    required String? city,
    required String? businessName,
    required String? businessDetails,
    required String phoneNumber,


  }) async {
    try {
      final userCredential = await signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      String imageUrl = '';
      if (profileImage != null) {

        if (kIsWeb) {
          final fileBytes = await profileImage.readAsBytes();
          imageUrl = await _uploadProfileImageToStorageWeb(fileBytes, profileImage.name);
        } else {
          final File mobileFile = File(profileImage.path);
          imageUrl = await _uploadProfileImageToStorage(mobileFile);
        }
      }


      await userCredential.user?.updateDisplayName(name);
      await createUserDocument(
        userId: userCredential.user!.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        imageUrl: imageUrl,
        city:city,
        role: role,
        businessName: role == 'service_provider' ? businessName : null,
        businessDetails: role == 'service_provider' ? businessDetails : null,

      );

    } catch (e) {
      throw Exception('Sign up process failed: $e');
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class UserData {
  static String email = '';
}
