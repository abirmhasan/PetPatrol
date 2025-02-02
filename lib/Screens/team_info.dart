import 'package:flutter/material.dart';

class TeamSaatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team SAAT'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Members',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTeamMemberCard(
                    imagePath: 'images/emon.jpg',
                    name: 'Abdullah Al Arman Emon',
                    contact: '+8801521703065',
                    hall: 'Dr. Muhammad Shahidullah Hall',
                  ),
                  _buildTeamMemberCard(
                    imagePath: 'images/jamal.jpg',
                    name: 'Md. Shah Jamal Islam',
                    contact: '+8801516523490',
                    hall: 'Fazlul Huq Muslim Hall',
                  ),
                  _buildTeamMemberCard(
                    imagePath: 'images/abir.jpg',
                    name: 'Abir Hasan',
                    contact: '+8801521565024',
                    hall: 'Dr. Muhammad Shahidullah Hall',
                  ),
                  _buildTeamMemberCard(
                    imagePath: 'images/tonmoy.jpg',
                    name: 'Tonmoy Das',
                    contact: '+8801309800463',
                    hall: 'Jagannath Hall',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required String imagePath,
    required String name,
    required String contact,
    required String hall,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(imagePath),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green),
                      SizedBox(width: 8),
                      Text(contact),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hall: $hall',
                    style: TextStyle(color: Colors.grey),
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
