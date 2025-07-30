import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SingleCity extends StatefulWidget {
  final Map cityData;
  const SingleCity({Key? key, required this.cityData}) : super(key: key);

  @override
  State<SingleCity> createState() => _SingleCityState();
}

class _SingleCityState extends State<SingleCity> {
  BitmapDescriptor? pinLocationIcon;
  final Map<String, Marker> _markers = {};
  Position? _currentPosition;



  // Set custom map pin
  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/images/markericon.png',
    );
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _markers.clear();
    setState(() {
      final marker = Marker(
        markerId: MarkerId(widget.cityData['name']),
        position: LatLng(widget.cityData['lat'], widget.cityData['lng']),
        infoWindow: InfoWindow(
          title: widget.cityData['name'],
          snippet: widget.cityData['address'],
          onTap: () {
            print("${widget.cityData['lat']}, ${widget.cityData['lng']}");
          },
        ),
      );
      _markers[widget.cityData['name']] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('Show Address on Map')),
      body: Column(
        children: [
          Card(
            elevation: 5,
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        widget.cityData['Address'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 500.0,
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
                      target: LatLng(widget.cityData['lat'], widget.cityData['lng']),
                      zoom: 7,
                    ),

                    markers: _markers.values.toSet(),
                  ),
                ),
              ),
            ],

          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Direction"),
          ),
        ],
      ),
    );
  }
}
