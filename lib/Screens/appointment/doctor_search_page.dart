import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../doctor/chat_screen.dart'; // Import Chat Screen
import 'appointment_booking_page.dart';

class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({super.key});

  @override
  _DoctorSearchPageState createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> doctorList = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _getRandomDoctors();
  }

  _getRandomDoctors() async {
    // First, get all doctors
    FirebaseFirestore.instance
        .collection('doctors')
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.length > 0) {
        List<QueryDocumentSnapshot> allDoctors = querySnapshot.docs;
        int numberOfDoctors = min(5, allDoctors.length);
        List<QueryDocumentSnapshot> randomDoctors = [];
        List<QueryDocumentSnapshot> tempList = List.from(allDoctors);

        for (int i = 0; i < numberOfDoctors; i++) {
          int randomIndex = Random().nextInt(tempList.length);
          randomDoctors.add(tempList[randomIndex]);
          tempList.removeAt(randomIndex);
        }

        setState(() {
          doctorList = randomDoctors;
        });
      }
    });
  }

  _searchDoctorsByLocation(String location) async {
    setState(() {
      isSearching = true;
    });

    if (location.isEmpty) {
      _getRandomDoctors();
      setState(() {
        isSearching = false;
      });
      return;
    }

    FirebaseFirestore.instance
        .collection('doctors')
        .where('location', isGreaterThanOrEqualTo: location)
        .where('location', isLessThanOrEqualTo: location + '\uf8ff')
        .get()
        .then((value) {
      setState(() {
        doctorList = value.docs;
        isSearching = false;
      });
    });
  }

  Future<bool> _isPremiumMember() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('premium_memberships')
          .doc(user.uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['membershipStatus'] == 'active';
      }
    } catch (e) {
      print('Error checking premium membership: $e');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Doctors',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          )),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors by location...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.location_on, color: Colors.orange),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _getRandomDoctors();
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.search, color: Colors.orange),
                        onPressed: () {
                          _searchDoctorsByLocation(_searchController.text);
                        },
                      ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                _searchDoctorsByLocation(value);
              },
            ),
          ),
          if (isSearching)
            Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          if (!isSearching && doctorList.isEmpty)
            Padding(
              padding: EdgeInsets.all(20),
              child: Text('No doctors found in this location',
                  style: TextStyle(color: Colors.grey)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: doctorList.length,
              itemBuilder: (context, index) {
                return DoctorCard(
                  doctor: doctorList[index],
                  isPremiumMember:
                      _isPremiumMember, // Pass the premium check function
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final QueryDocumentSnapshot doctor;
  final Future<bool> Function() isPremiumMember;

  DoctorCard({
    required this.doctor,
    required this.isPremiumMember,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                // doctor['doctorPhoto'] ??
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKlWqE6pA--N0hVkP6f-7heOuvc9Fk5p0DOQ&s',
                width: 130,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor['name'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(doctor['location'],
                      style:
                          TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                  SizedBox(height: 5),
                  Text('Payment: 1200 bdt',
                      style:
                          TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentBookingPage(
                                doctorData: doctor,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                        ),
                        child: Text('Book',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          bool isPremium = await isPremiumMember();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(doctorId: doctor.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: CircleBorder(), // Makes the button circular
                          padding: EdgeInsets.all(
                              8), // Adjust the padding to make the button smaller
                        ),
                        child: Icon(
                          Icons.chat, // Added chat icon
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 16),
                          SizedBox(width: 2),
                          Text('5.0'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
