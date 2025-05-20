import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class Offers extends StatefulWidget {
  const Offers({super.key});

  @override
  _OffersState createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _deleteResponse(String offerId, requesterId, requestId ) async {
    try {
      await FirebaseFirestore.instance
          .collection('dealing')
          .doc(offerId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer Rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting : $e')),
      );
    }
    unhideEntityForCurrentUser(requestId,requesterId);
  }
  Future<void> unhideEntityForCurrentUser(String documentId,reqesterid) async {
    try {
      final user = reqesterid;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('Work_requests')
          .doc(documentId);

      await docRef.update({
        'hiddenFor': FieldValue.arrayRemove([user]),  // Remove user UID from array
      });

      print("Entity unhidden for user: ${user}");
    } catch (e) {
      print("Error unhiding entity: $e");
    }
  }

  Future<void> deleteRequestById(String requestId) async {
    try {
      if (requestId.isEmpty) {
        throw Exception("Request ID is missing.");
      }

      // Reference to the request document
      DocumentReference requestDocRef = FirebaseFirestore.instance
          .collection('Work_requests')
          .doc(requestId);

      // Delete the document
      await requestDocRef.delete();
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Batch for atomic operations
      WriteBatch batch = firestore.batch();
      // Query 'dealing' collection for matching documents
      QuerySnapshot dealingSnapshot = await firestore.collection('dealing')
          .where('requestid', isEqualTo: requestId)
      .where('status',isEqualTo: 'pending')
          .get();

      // Loop and delete each matching document
      for (var doc in dealingSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();
      print("Request with ID $requestId deleted successfully.");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request deleted successfully!")),
      );
    } catch (e) {
      print("Error deleting request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete request: $e")),
      );
    }
  }

  Future<void> _approvework(String productId,requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('dealing')
          .doc(productId)
          .update({
        'status': 'Approved',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer Accepted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving work: $e')),
      );
    }
    deleteRequestById(requestId);
  }
  void _launchPhoneDialer(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Couldn't launch phone dialer");
    }
  }
  void _launchWhatsapp(String phoneNumber) async {
    final Uri url = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Couldn't launch phone dialer");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade100,
        title: const Text("Response"),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("Please log in to view your medicines"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('dealing')
                  .where('requesterId',  isEqualTo: user!.uid) // Filter by logged-in user's ID
                  .where('status',  isEqualTo: "pending") // Filter by logged-in user's ID
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
                                title: Text(
                                  OffersData['spName'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Offer: ${OffersData['orderedFare'] ?? 'N/A'}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
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
                                            text: 'Your Fare: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${OffersData['actualFare'] ?? 'N/A'}',
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
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      String documentId = doc.id;
                                      String reqesterid = OffersData['spId'];
                                      String requestid = OffersData['requestId'];
                                      await _deleteResponse(documentId, reqesterid, requestid);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Response Delete successfully!")),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade300,
                                      fixedSize: const Size(110, 25),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                    String requestid = OffersData['requestId'];
                                     await   _approvework(doc.id,requestid);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade300,
                                      fixedSize: const Size(110, 25),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: (){
                                if (OffersData['phone'] != null &&
                                    OffersData['phone']!.isNotEmpty) {
                                  _launchPhoneDialer(OffersData['phone']!); // Launch phone dialer
                                } else {
                                  print(
                                      "No phone number available"); // Handle case if no phone number
                                }
                              },
                              child: Icon(
                                Icons.phone,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                          ),
                          Positioned(
                            top:55,
                            right: 7,
                            child: GestureDetector(
                              onTap: (){
                                if (OffersData['phone'] != null &&
                                    OffersData['phone']!.isNotEmpty) {
                                  _launchWhatsapp(OffersData['phone']!); // Launch phone dialer
                                } else {
                                  print(
                                      "No phone number available"); // Handle case if no phone number
                                }
                              },
                              child:  Image.asset(
                                'assets/whatsapp.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
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
