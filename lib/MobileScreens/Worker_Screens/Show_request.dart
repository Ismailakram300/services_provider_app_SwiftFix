import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serviceapp/MobileScreens/Worker_Screens/show_request_details.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


import '../login.dart'; // Import for date formatting

class ShowRequest extends StatefulWidget {
  const ShowRequest({super.key});

  @override
  State<ShowRequest> createState() => _ShowRequestState();
}

class _ShowRequestState extends State<ShowRequest> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Map<String, String> usernames = {};

  @override
  void initState() {
    super.initState();
  }

  String? Servicename;
  Future<String> _getusername(String sellerId) async {
    if (usernames.containsKey(sellerId)) {
      return usernames[sellerId]!;
    }

    try {
      final sellerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(sellerId)
          .get();
      if (sellerSnapshot.exists) {
        String username = sellerSnapshot.data()?['name'] ?? 'Unknown User';
        Servicename = sellerSnapshot.data()?['businessName'] ?? 'Unknown User';
        usernames[sellerId] = username; // Cache the seller name
        return username;
      } else {
        return 'Unknown User';
      }
    } catch (e) {
      return 'Error fetching seller';
    }
  }

  Future<void> _approvework(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Work_requests')
          .doc(productId)
          .update({
        'status': 'Approved',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('work approved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving work: $e')),
      );
    }
  }

  // for reject pur[ose
  Future<void> hideEntityFromCurrentUser(String documentId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('Work_requests')
          .doc(documentId);
      await docRef.update({
        'hiddenFor': FieldValue.arrayUnion([user.uid]),
      });

      print("Entity hidden from user: ${user.uid}");
    } catch (e) {
      print("Error hiding entity: $e");
    }
  }

// for date and time formating
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'No date available';
    }
    final DateTime date = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd-MMM-yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        automaticallyImplyLeading: false,
        title: const Text("Worker Panel"),
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (userSnapshot.hasError ||
                          !userSnapshot.hasData ||
                          !userSnapshot.data!.exists) {
                        return const Center(child: Text('Error fetching user data'));
                      }

                      final userCity = userSnapshot.data!['city'];
                      final serviceName = userSnapshot.data!['businessName'];

                      return Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Requests found in '$userCity' ",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Work_requests')
                                    .where('status', isEqualTo: 'pending')
                                    .where('name', isEqualTo: serviceName)
                                    .where('city', isEqualTo: userCity)
                                    .snapshots(),
                                // child: StreamBuilder<QuerySnapshot>(
                                //   stream: FirebaseFirestore.instance
                                //       .collection('Work_requests')
                                //       .where('status', isEqualTo: 'pending')
                                //       .where('name', isEqualTo: Servicename)
                                //       .snapshots(),

                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError) {
                                    return const Center(
                                        child: Text('Error fetching Requests'));
                                  }
                                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                        child: Text('No Work Requests available'));
                                  }
                                  final works = snapshot.data!.docs.where((doc) {
                                    final hiddenFor =
                                    List<String>.from(doc['hiddenFor'] ?? []);
                                    return !hiddenFor
                                        .contains(FirebaseAuth.instance.currentUser!.uid);
                                  }).toList();

                                  return SingleChildScrollView(
                                    child: Scrollbar(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: works.length,
                                        itemBuilder: (context, index) {
                                          final work = works[index];
                                          final workData =
                                          work.data() as Map<String, dynamic>;

                                          return FutureBuilder<String>(
                                            future: _getusername(workData['userId']),
                                            builder: (context, sellerSnapshot) {
                                              String username =
                                                  sellerSnapshot.data ?? 'Loading...';

                                              return InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ShowReqDetails(
                                                        workId: work.id,
                                                        workData: workData,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[50],
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          height: 1,
                                                          width: double.infinity,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                            BorderRadius.circular(20),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: "Service Want:  ",
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: Colors.black),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                "${workData['name'] ?? 'N/A'}",
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.normal,
                                                                    color: Colors.black),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: "Offer price :    ",
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: Colors.black),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                "${workData['fare'] ?? 'N/A'}",
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.normal,
                                                                    color: Colors.black),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: "Location :        ",
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: Colors.black),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                "${workData['location'] ?? 'N/A'}",
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    color: Colors.black),
                                                              ),
                                                            ],
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 10),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: "Work Date:    ",
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: Colors.black),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                "${workData['workDate'] ?? 'N/A'}",
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.normal,
                                                                    color: Colors.black),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: "User Name:    ",
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: Colors.black),
                                                              ),
                                                              TextSpan(
                                                                text: "${username ?? 'N/A'}",
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.normal,
                                                                    color: Colors.black),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        RichText(
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: "Request Created:    ",
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: Colors.black),
                                                              ),
                                                              TextSpan(
                                                                text: _formatTimestamp(
                                                                    workData['createdAt']
                                                                    as Timestamp?),
                                                                style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight:
                                                                    FontWeight.normal,
                                                                    color: Colors.black),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15),
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            ElevatedButton(
                                                              //onPressed: () => _deletework(work.id),
                                                              onPressed: () async {
                                                                String documentId = work.id;
                                                                await hideEntityFromCurrentUser(
                                                                    documentId);
                                                                ScaffoldMessenger.of(context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          "Item hidden successfully!")),
                                                                );
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.red,
                                                                fixedSize:
                                                                const Size(110, 40),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:  BorderRadius.circular(8),
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal: 16,
                                                                    vertical: 8),
                                                              ),
                                                              child: const Text(
                                                                'Reject',
                                                                style: TextStyle(
                                                                    color: Colors.white),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => ShowReqDetails(
                                                                      workId: work.id,
                                                                      workData: workData,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                                  // _approvework(work.id),
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.green,
                                                                fixedSize:
                                                                const Size(110, 40),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius.circular(
                                                                      8),
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal: 16,
                                                                    vertical: 8),
                                                              ),
                                                              child: const Text(
                                                                'Accept',
                                                                style: TextStyle(
                                                                    color: Colors.white),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            )

            // Expanded(
            //     child: FutureBuilder<DocumentSnapshot>(
            //   future: FirebaseFirestore.instance
            //       .collection('users')
            //       .doc(FirebaseAuth.instance.currentUser!.uid)
            //       .get(),
            //   builder: (context, userSnapshot) {
            //     if (userSnapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(child: CircularProgressIndicator());
            //     }
            //     if (userSnapshot.hasError ||
            //         !userSnapshot.hasData ||
            //         !userSnapshot.data!.exists) {
            //       return const Center(child: Text('Error fetching user data'));
            //     }
            //
            //     final userCity = userSnapshot.data!['city'];
            //     final Servicename = userSnapshot.data!['businessName'];
            //
            //     return StreamBuilder<QuerySnapshot>(
            //       stream: FirebaseFirestore.instance
            //           .collection('Work_requests')
            //           .where('status', isEqualTo: 'pending')
            //           .where('name', isEqualTo: Servicename)
            //           .where('city', isEqualTo: userCity)
            //           .snapshots(),
            //       // child: StreamBuilder<QuerySnapshot>(
            //       //   stream: FirebaseFirestore.instance
            //       //       .collection('Work_requests')
            //       //       .where('status', isEqualTo: 'pending')
            //       //       .where('name', isEqualTo: Servicename)
            //       //       .snapshots(),
            //
            //       builder: (context, snapshot) {
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return const Center(child: CircularProgressIndicator());
            //         }
            //         if (snapshot.hasError) {
            //           return const Center(
            //               child: Text('Error fetching Requests'));
            //         }
            //         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            //           return const Center(
            //               child: Text('No Work Requests available'));
            //         }
            //         final works = snapshot.data!.docs.where((doc) {
            //           final hiddenFor =
            //               List<String>.from(doc['hiddenFor'] ?? []);
            //           return !hiddenFor
            //               .contains(FirebaseAuth.instance.currentUser!.uid);
            //         }).toList();
            //
            //         return SingleChildScrollView(
            //           child: Scrollbar(
            //             child: ListView.builder(
            //               shrinkWrap: true,
            //               physics: const NeverScrollableScrollPhysics(),
            //               itemCount: works.length,
            //               itemBuilder: (context, index) {
            //                 final work = works[index];
            //                 final workData =
            //                     work.data() as Map<String, dynamic>;
            //
            //                 return FutureBuilder<String>(
            //                   future: _getusername(workData['userId']),
            //                   builder: (context, sellerSnapshot) {
            //                     String username =
            //                         sellerSnapshot.data ?? 'Loading...';
            //
            //                     return InkWell(
            //                       onTap: () {
            //                         Navigator.push(
            //                           context,
            //                           MaterialPageRoute(
            //                             builder: (context) => ShowReqDetails(
            //                               workId: work.id,
            //                               workData: workData,
            //                             ),
            //                           ),
            //                         );
            //                       },
            //                       child: Container(
            //                         margin: const EdgeInsets.all(8.0),
            //                         decoration: BoxDecoration(
            //                           color: Colors.blue[50],
            //                           borderRadius: BorderRadius.circular(10),
            //                         ),
            //                         child: Padding(
            //                           padding: const EdgeInsets.all(10.0),
            //                           child: Column(
            //                             crossAxisAlignment:
            //                                 CrossAxisAlignment.start,
            //                             children: [
            //                               SizedBox(
            //                                 height: 1,
            //                                 width: double.infinity,
            //                                 child: ClipRRect(
            //                                   borderRadius:
            //                                       BorderRadius.circular(20),
            //                                 ),
            //                               ),
            //                               const SizedBox(height: 5),
            //                               RichText(
            //                                 text: TextSpan(
            //                                   children: [
            //                                     TextSpan(
            //                                       text: "Service Want:  ",
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.bold,
            //                                           color: Colors.black),
            //                                     ),
            //                                     TextSpan(
            //                                       text:
            //                                           "${workData['name'] ?? 'N/A'}",
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.normal,
            //                                           color: Colors.black),
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ),
            //                               const SizedBox(height: 10),
            //                               RichText(
            //                                 text: TextSpan(
            //                                   children: [
            //                                     TextSpan(
            //                                       text: "Offer price :    ",
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.bold,
            //                                           color: Colors.black),
            //                                     ),
            //                                     TextSpan(
            //                                       text:
            //                                           "${workData['fare'] ?? 'N/A'}",
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.normal,
            //                                           color: Colors.black),
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ),
            //                               const SizedBox(height: 10),
            //                               Text.rich(
            //                                 TextSpan(
            //                                   children: [
            //                                     TextSpan(
            //                                       text: "Location :        ",
            //                                       style: TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.bold,
            //                                           color: Colors.black),
            //                                     ),
            //                                     TextSpan(
            //                                       text:
            //                                           "${workData['location'] ?? 'N/A'}",
            //                                       style: TextStyle(
            //                                           fontSize: 16,
            //                                           color: Colors.black),
            //                                     ),
            //                                   ],
            //                                 ),
            //                                 maxLines: 1,
            //                                 overflow: TextOverflow.ellipsis,
            //                               ),
            //                               const SizedBox(height: 10),
            //                               RichText(
            //                                 text: TextSpan(
            //                                   children: [
            //                                     TextSpan(
            //                                       text: "Work Date:    ",
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.bold,
            //                                           color: Colors.black),
            //                                     ),
            //                                     TextSpan(
            //                                       text:
            //                                           "${workData['workDate'] ?? 'N/A'}",
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.normal,
            //                                           color: Colors.black),
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ),
            //                               const SizedBox(height: 10),
            //                               RichText(
            //                                 text: TextSpan(
            //                                   children: [
            //                                     TextSpan(
            //                                       text: "User Name:    ",
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.bold,
            //                                           color: Colors.black),
            //                                     ),
            //                                     TextSpan(
            //                                       text: "${username ?? 'N/A'}",
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.normal,
            //                                           color: Colors.black),
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ),
            //                               const SizedBox(height: 10),
            //                               RichText(
            //                                 text: TextSpan(
            //                                   children: [
            //                                     TextSpan(
            //                                       text: "Request Created:    ",
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.bold,
            //                                           color: Colors.black),
            //                                     ),
            //                                     TextSpan(
            //                                       text: _formatTimestamp(
            //                                           workData['createdAt']
            //                                               as Timestamp?),
            //                                       style: const TextStyle(
            //                                           fontSize: 16,
            //                                           fontWeight:
            //                                               FontWeight.normal,
            //                                           color: Colors.black),
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ),
            //                               const SizedBox(height: 15),
            //                               Row(
            //                                 mainAxisAlignment:
            //                                     MainAxisAlignment.spaceEvenly,
            //                                 children: [
            //                                   ElevatedButton(
            //                                     //onPressed: () => _deletework(work.id),
            //                                     onPressed: () async {
            //                                       String documentId = work.id;
            //                                       await hideEntityFromCurrentUser(
            //                                           documentId);
            //                                       ScaffoldMessenger.of(context)
            //                                           .showSnackBar(
            //                                         SnackBar(
            //                                             content: Text(
            //                                                 "Item hidden successfully!")),
            //                                       );
            //                                     },
            //                                     style: ElevatedButton.styleFrom(
            //                                       backgroundColor: Colors.red,
            //                                       fixedSize:
            //                                           const Size(110, 40),
            //                                       shape: RoundedRectangleBorder(
            //                                         borderRadius:
            //                                             BorderRadius.circular(
            //                                                 8),
            //                                       ),
            //                                       padding: const EdgeInsets
            //                                           .symmetric(
            //                                           horizontal: 16,
            //                                           vertical: 8),
            //                                     ),
            //                                     child: const Text(
            //                                       'Reject',
            //                                       style: TextStyle(
            //                                           color: Colors.white),
            //                                     ),
            //                                   ),
            //                                   ElevatedButton(
            //                                     onPressed: () =>
            //                                         _approvework(work.id),
            //                                     style: ElevatedButton.styleFrom(
            //                                       backgroundColor: Colors.green,
            //                                       fixedSize:
            //                                           const Size(110, 40),
            //                                       shape: RoundedRectangleBorder(
            //                                         borderRadius:
            //                                             BorderRadius.circular(
            //                                                 8),
            //                                       ),
            //                                       padding: const EdgeInsets
            //                                           .symmetric(
            //                                           horizontal: 16,
            //                                           vertical: 8),
            //                                     ),
            //                                     child: const Text(
            //                                       'Accept',
            //                                       style: TextStyle(
            //                                           color: Colors.white),
            //                                     ),
            //                                   ),
            //                                 ],
            //                               )
            //                             ],
            //                           ),
            //                         ),
            //                       ),
            //                     );
            //                   },
            //                 );
            //               },
            //             ),
            //           ),
            //         );
            //       },
            //     );
            //   },
            // )),
          ],
        ),
      ),
    );
  }
}
