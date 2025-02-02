import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:petpal/admin%20side/adminScreens/Usermanagement.dart';
import 'package:petpal/admin%20side/admin_login.dart';
import 'package:petpal/firebase_options.dart';
import 'package:petpal/user%20registration/homeScreen.dart';
import 'package:petpal/user%20registration/login.dart';

void insertSampleDoctors() {
  _insertDoctor(
    name: "Dr. Ayesha Rahman",
    location: "Dhaka",
    specialization: "Pediatrician",
    experience: 8,
    contactNumber: "+880 1700 123456",
  );

  _insertDoctor(
    name: "Dr. Tanvir Hasan",
    location: "Dhaka",
    specialization: "Cardiologist",
    experience: 12,
    contactNumber: "+880 1711 654321",
  );

  _insertDoctor(
    name: "Dr. Meherun Nessa",
    location: "Dhaka",
    specialization: "Dermatologist",
    experience: 5,
    contactNumber: "+880 1722 987654",
  );

  _insertDoctor(
    name: "Dr. Faridul Alam",
    location: "Dhaka",
    specialization: "Orthopedic Surgeon",
    experience: 15,
    contactNumber: "+880 1733 112233",
  );

  _insertDoctor(
    name: "Dr. Nusrat Jahan",
    location: "Dhaka",
    specialization: "General Physician",
    experience: 6,
    contactNumber: "+880 1744 445566",
  );
}

_insertDoctor({
  required String name,
  required String location,
  required String specialization,
  required int experience,
  required String contactNumber,
}) async {
  try {
    // Create a map for the doctor's data
    Map<String, dynamic> doctorData = {
      'name': name,
      'location': location,
      'specialization': specialization,
      'experience': experience,
      'contactNumber': contactNumber,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Add the data to the 'doctors' collection
    await FirebaseFirestore.instance.collection('doctors').add(doctorData);

    print("Doctor added successfully!");
  } catch (e) {
    print("Error adding doctor: $e");
  }
}

_updateDoctor({
  required String doctorId,
  String? photoUrl,
  int? payment,
}) async {
  try {
    Map<String, dynamic> updatedData = {};
    if (photoUrl != null) updatedData['photoUrl'] = photoUrl;
    if (payment != null) updatedData['payment'] = payment;

    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .update(updatedData);

    print("Doctor updated successfully!");
  } catch (e) {
    print("Error updating doctor: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } else {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
    // insertSampleDoctors();
    runApp(const MyApp());
  } catch (e) {
    // Handle initialization errors here
    print('Firebase initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (kIsWeb) {
          // Web: Check if the user is an admin or not
          if (snapshot.hasData) {
            User? user = snapshot.data;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
                        body: Center(child: CircularProgressIndicator())),
                  );
                }

                if (userSnapshot.hasData) {
                  bool isAdmin = userSnapshot.data!['isAdmin'] ?? false;
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: isAdmin ? const Usermanagement() : const Login(),
                  );
                } else {
                  return const MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: AdminLogin(),
                  );
                }
              },
            );
          } else {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: AdminLogin(),
            );
          }
        } else {
          // Mobile: Redirect to the user login screen
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: snapshot.hasData ? const HomeScreen() : const Login(),
          );
        }
      },
    );
  }
}
