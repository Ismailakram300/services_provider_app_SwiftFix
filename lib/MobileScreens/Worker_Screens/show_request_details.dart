import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Show_request.dart';
class ShowReqDetails extends StatefulWidget {
  final Map<String, dynamic> workData;
  final String workId;


  const ShowReqDetails({super.key, required this.workData,required this.workId});
  @override
  State<ShowReqDetails> createState() => _ShowReqDetailsState();
}
class _ShowReqDetailsState extends State<ShowReqDetails> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _currentImageUrl;
  bool _sendorder = true;


  Set<Marker> _markers = {};


  void _launchPhoneDialer(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Couldn't launch phone dialer");
    }
  }

  // map fetching function
  Future<void> _onMapCreated(GoogleMapController controller) async {
    _markers.clear();
    String address = widget.workData['location'] ?? 'Unknown address';
   try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        final marker = Marker(
          markerId: MarkerId(widget.workData['name'] ?? 'Unknown'),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: widget.workData['name'] ?? 'Unknown',
            snippet: address,
            onTap: () {
              print("Tapped on marker: ${location.latitude}, ${location.longitude}");
            },
          ),);
        setState(() {
          _markers.add(marker);
        });
        controller.animateCamera(CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)));
      } else {
        print('No locations found for the address');
      }
    } catch (e) {
      print('Error occurred while geocoding: $e');
    }
  }
  @override

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
  Future<void> _submitfare(int price, String documentId) async {
    String? phone;
    String? city;

    final user = FirebaseAuth.instance.currentUser ;
    if (user == null) {
      return;
    }else {
      await user.reload();
      final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          phone = data['phoneNumber'] ?? '';
          _currentImageUrl = data['profileImage'];
           city =data['city'];
        });
      }
    }
    final userName = user.displayName?.isNotEmpty ?? false ? user.displayName : 'Unknown User';
    //String userName;

    final offerData = {
      'requestId': widget.workId,
      'requester':widget.workData['requesterName'],
      'requesterId':widget.workData['userId'],
      'spId': user.uid,
      'spName':userName,
      'serviceName': widget.workData['name'],
       'address': widget.workData['location'],
      'workDate':widget.workData['workDate'],
       'city': city,
      'profileImage':_currentImageUrl,
       'phone': phone,
      'actualFare':widget.workData['fare'],
      'orderedFare':price,
      'type':'sp_order',
      'status':'pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('dealing').add(offerData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offer Send successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
      print(e);
    }
    hideEntityFromCurrentUser(documentId);
  }
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        backgroundColor: Colors.green.shade200,
        title: const Text('User Request Detail'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
                if (widget.workData['phoneNumber'] != null &&
                    widget.workData['phoneNumber']!.isNotEmpty) {
                  _launchPhoneDialer(widget.workData['phoneNumber']!); // Launch phone dialer
                } else {
                  print(
                      "No phone number available"); // Handle case if no phone number
                }
              },
              child: const Icon(Icons.phone),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Google Map Container
              const SizedBox(height: 20),
              Text(
                " ${widget.workData['name'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity, // Full width
                height: 300.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(0.0, 0.0),
                      zoom: 13,
                    ),
                    markers: _markers,
                  ),
                ),
              ),



              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "order price :    ",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: "${widget.workData['fare'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Work Date :    ",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: "${widget.workData['workDate'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Phone Number :    ",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: "${widget.workData['phoneNumber'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "City :    ",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: "${widget.workData['city'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 10),
              const Text(
                "Description",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.workData['description'] ?? "No description available.",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),



              const SizedBox(height: 30),
if(_sendorder) ...[
  Text(
    " order Your Fare",
    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 10),
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment:MainAxisAlignment.center,
      children: <Widget>[

        const SizedBox(width: 3),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade200,
            foregroundColor: Colors.black,
            minimumSize: const Size(30, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () {
            String documentId =widget.workId ;
            _sendorder = false;
            int baseFare = int.parse(widget.workData['fare'] ?? '0');
            int price = baseFare + 100;
            _submitfare(price,documentId);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 3),
              Text('Rs: ${int.parse(widget.workData['fare'] ?? '0') + 100}',
                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(width: 3),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade200,
            foregroundColor: Colors.black,
            minimumSize: const Size(30, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () {
            String documentId =widget.workId ;
            _sendorder = false;
            int baseFare = int.parse(widget.workData['fare'] ?? '0');
            int price = baseFare + 250;
            _submitfare(price,documentId);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 3),
              Text('Rs: ${int.parse(widget.workData['fare'] ?? '0') + 250}',
                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15)), // Button text
            ],
          ),
        ),
        const SizedBox(width: 3),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade200,
            foregroundColor: Colors.black,
            minimumSize: const Size(20, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () {
            String documentId =widget.workId ;
            _sendorder = false;
            int baseFare = int.parse(widget.workData['fare'] ?? '0');
            int price = baseFare + 400;
            _submitfare(price,documentId);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 3),
              Text('Rs: ${int.parse(widget.workData['fare'] ?? '0') + 400}',
                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 15)), // Button text
            ],
          ),
        ),
      ],
    ),),

], Column(
                children: [

                  const SizedBox(height: 20),
                  SizedBox(
                      width: double.infinity, // Make buttons full-width on mobile
                      child:ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,


                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowRequest(),
                            ),
                          );
                        },
                        child: const Text("Cancel Now",style:TextStyle(color: Colors.white)),

                      )
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
