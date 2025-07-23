import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviceapp/MobileScreens/add_request.dart';
import 'package:serviceapp/data/notification_settings.dart';
import '../Model/location_service.dart';
import '../screens/single_city.dart';
import '../utils/my_list_tile.dart';
import 'login.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String? _currentLocation;
  String? _address;
  String? _city;
  final LocationService _locationService = LocationService();
  BitmapDescriptor? pinLocationIcon;
  void getDetails(Map singleCityData, BuildContext context) {
    print(singleCityData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SingleCity(
          cityData: singleCityData,
        ),
      ),
    );
  }
  @override
  // NotificationServices notificationServices = NotificationServices();
  void initState() {
    super.initState();
    _initializeLocation();
    // notificationServices.requestNotificationPrtmission();

  }
  List<Map<String, dynamic>> cityList = [];
  Future<void> _initializeLocation() async {
    final position = await _locationService.getCurrentLocation();
    // Get the current position
    if (position != null) {
      final locationData = await _locationService.getAddressFromLatLng(position.latitude, position.longitude); // Get address from lat/long
      setState(() {
        _address = locationData["address"];
        _city = locationData["city"];
        _currentLocation = 'Lat: ${position.latitude}, Long: ${position.longitude}';
        cityList.insert(0, {
          "address": _address,
          "id": "current_location",
          "lat": position.latitude,
          "lng": position.longitude,
          "name": "$_city (Current Location)",
          "phone": "N/A",
          "region": "Current Location"
        });
      });
    }
  }
  // Future<void> _onMapCreated(GoogleMapController controller) async {
  //   _markers.clear();
  //   setState(() {
  //     for (var city in cityList) {
  //       final marker = Marker(
  //
  //         markerId: MarkerId(city['name']),
  //         position: LatLng(city['lat'], city['lng']),
  //         infoWindow: InfoWindow(
  //           title: city['name'],
  //           snippet: city['address'],
  //           onTap: () {
  //             print("${city['lat']}, ${city['lng']}");
  //           },
  //         ),
  //       );
  //       _markers[city['name']] = marker;
  //     }});
  // }
  String _getCategoryName(int index) {
    switch (index) {
      case 0:
        return 'Cleaning';
      case 1:
        return 'Plumbing';
      case 2:
        return 'Electrician';
      case 3:
        return 'Painting';
      case 4:
        return 'Carpentry';
      case 5:
        return 'Baby Sitting';
      case 6:
        return 'Cooking';
        default:
        return 'Cooking';
    }
  }
  // IconData _getCategoryIcon(int index) {
  //   switch (index) {
  //     case 0:
  //       return Icons.cleaning_services;
  //     case 1:
  //       return Icons.plumbing;
  //     case 2:
  //       return Icons.electrical_services;
  //     case 3:
  //       return Icons.format_paint;
  //     case 4:
  //       return Icons.handyman;
  //     case 5:
  //       return Icons.grass;
  //     case 6:
  //       return Icons.build;
  //     case 7:
  //       return Icons.computer;
  //     default:
  //       return Icons.help_outline;
  //   }
  // }

  String _getCategoryImage(int index) {

    switch (index) {
      case 0:
        return 'assets/cleaner.png';
      case 1:
        return 'assets/plumber.png';
      case 2:
        return 'assets/electrician.png';
      case 3:
        return 'assets/painter.png';
      case 4:
        return 'assets/carpenter.png';
      case 5:
        return 'assets/babysitting.png';
      case 6:
        return 'assets/chef.png';
      default:
        return 'assets/chef.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text("SwiftFix"),
        centerTitle: true,

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: cityList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(cityList[index]['name']),
                    subtitle: Text(cityList[index]['address']),
                    trailing: IconButton(
                      icon: const Icon(Icons.navigation),
                      onPressed: () {
                        Navigator.pop(context); // Close the list modal
                        getDetails(cityList[index], context);// Show details modal
                      },
                    ),
                  );
                },
              );
            },
          );
        },
        backgroundColor: Colors.green.shade300,
        child: const Icon(Icons.navigation),
      ),
  drawer:     Expanded(
        child: Drawer(
          child: Column(
            children: [

              const SizedBox(height: 20),
              MyListTile(

                title: "LogOut",
                imageIcon: "assets/check-out.png",
                onTap: () {
                  //firhalo
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginM()),
                  );
                },
              ),
            ],
          ),
        ),

      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 13,top: 20.0,right: 5.0),
            child: Row(
              children: [

                Icon(
                  size: 30,
                  Icons.location_on,
                  color: Colors.black,
                ),
                const SizedBox(width: 10),
                Text(
                  _address ?? 'Getting address...',
                  //"F345+HCH,Abbottabad,Pakistan",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),

              ],
            ),

          ),
          const SizedBox(width: 10),

          SizedBox(
            height: 205,
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                viewportFraction: 1.0,
              ),
              items: [
                'assets/s1.jfif',
                'assets/s2.jfif',
                'assets/s3.jfif',
                'assets/s4.jfif',
                'assets/s5.jfif',
                'assets/s6.jfif',


              ].map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                        border: Border.all(
                          color: Colors.green.shade300,  // Border color
                          width: 1,  // Border width
                        ),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Categories
         // const SizedBox(height: 11),
          Expanded(

            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),itemCount: 7,
              itemBuilder: (context, index) {
                return Card(

                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWorkRequest(

                          ),
                        ),
                      );
                    },
                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(

                          _getCategoryImage(index),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,

                        ),
                        const SizedBox(height: 11),
                        Text(
                          _getCategoryName(index),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Card(
          //   elevation: 5,
          //   child: Column(
          //     children: [
          //
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.only(left: 10),
          //             child: Text(
          //               'Curren: $_address',
          //               //"F345+HCH,Abbottabad,Pakistan",
          //               style: const TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //           ElevatedButton(
          //             onPressed: () {},
          //             child: const Text("Direction"),
          //           )
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          // Column(
          //   children: [
          //     Container(
          //       width: double.infinity, // Full width
          //       height: 300.0, // Set specific height for the map box
          //       decoration: BoxDecoration(
          //         color: Colors.grey[200], // Optional: background color for the map box
          //         borderRadius: BorderRadius.circular(12.0), // Optional: rounded corners
          //         border: Border.all(
          //           color: Colors.blue, // Optional: border color for the map box
          //           width: 2.0, // Optional: border width
          //         ),
          //       ),
          //       child: ClipRRect(
          //         borderRadius: BorderRadius.circular(12.0), // Ensure the map also has rounded corners
          //         child: GoogleMap(
          //           onMapCreated: _onMapCreated,
          //           initialCameraPosition: CameraPosition(
          //             target: LatLng(cityList.isNotEmpty ? cityList[0]['lat'] : 0.0, cityList.isNotEmpty ? cityList[0]['lng'] : 0.0), zoom: 7,
          //           ),
          //           markers: _markers.values.toSet(),
          //         ),
          //       ),
          //     ),
          //
          //   ],
          // ),


        ],
      ),
    );
  }
}
