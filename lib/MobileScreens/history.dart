import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';
class MyHistory extends StatefulWidget {
  const MyHistory({super.key});

  @override
  State<MyHistory> createState() => _MyHistoryState();
}
final User? user = FirebaseAuth.instance.currentUser;

class _MyHistoryState extends State<MyHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.green.shade300,
        automaticallyImplyLeading: false,
        title: const Text("History"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color:Colors.indigo),
            iconSize: 30, // Small size for the logout icon
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginM()),);


            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("Please log in to view your medicines"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dealing')
            .where('requesterId',  isEqualTo: user!.uid) // Filter by logged-in user's ID
            .where('status',  isEqualTo: "Approved") // Filter by logged-in user's ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Response added yet."));
          }

          final mDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: mDocs.length,
            itemBuilder: (context, index) {
              final doc = mDocs[index];
              final OffersData = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 80,
                              height: 90,
                              child: CircleAvatar(
                                radius: 90,
                                backgroundImage: NetworkImage(OffersData['profileImage']),
                                onBackgroundImageError: (_, __) => const Icon(Icons.error),
                              ),
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Offer: ${OffersData['orderedFare'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                OffersData['spName'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Service: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${OffersData['serviceName'] ?? 'N/A'}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),

                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Status: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${OffersData['status'] ?? 'N/A'}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Work Date: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${OffersData['workDate'] ?? 'N/A'}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                        const SizedBox(height: 15),


                      ],
                    ),

                  ],
                ),
              );

            },
          );
        },
      ),


    );
  }
}
