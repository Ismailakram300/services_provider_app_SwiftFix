import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/location_service.dart';
import '../Model/service_model.dart';
import '../utils/custom_text.dart';
import '../utils/custome_form.dart';
import 'offers.dart';

class AddWorkRequest extends StatefulWidget {
  const AddWorkRequest({super.key});

  @override
  State<AddWorkRequest> createState() => _AddWorkRequestState();
}

class _AddWorkRequestState extends State<AddWorkRequest> {
  String? _address;
  String? _citySelected;
  final LocationService _locationService = LocationService();
  int _currentWordCount = 0;
  bool getcurrentloc = false;
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != today) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 0, minute: 0),
      );


      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _workDateController.text =
          "${combinedDateTime.year}-${combinedDateTime.month.toString().padLeft(2, '0')}-${combinedDateTime.day.toString().padLeft(2, '0')} ${pickedTime.format(context)}";
        });
      }
    }
  }

  List<String> services = ['Plumber', 'Painting', 'Electrical Work', 'Carpentry', 'House Cleaning','Babysitting', 'Cooking/Cheif'];

  final _formKey = GlobalKey<FormState>();
  String? _requestNameController ;
  final _fareController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _workDateController =   TextEditingController();
  String? _selectedCity;
  Iterable<dynamic> emptyIterable = Iterable.empty();



  Future<void> _saveRequests() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save request')),
      );
      return;
    }
    final userName = currentUser.displayName?.isNotEmpty ?? false ? currentUser.displayName : 'Unknown User';
    if (!_formKey.currentState!.validate()) return;


    setState(() => isLoading = true);

    try {
         final docRef = FirebaseFirestore.instance.collection('Work_requests').doc();

      final request = ServiceModel(
        name: _requestNameController,
        fare:  _fareController.text,
        description: _descriptionController.text,
        phoneNumber: _phoneController.text,
        city: _citySelected,
        location: getcurrentloc ? _address: _locationController.text,
        requestId: docRef.id,
        userId: currentUser.uid,
        workDate: _workDateController.text,
        createdAt: Timestamp.now(),
        status: "pending",
        requesterName:userName,
          hiddenFor:List.empty(),
      );

      await docRef.set(request.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Added successfully!')),
      );
         // Future.delayed(const Duration(minutes: 1), () async {
         //   final docSnapshot = await docRef.get();
         //   if (docSnapshot.exists) {
         //     await docRef.delete();
         //     print("Document deleted after 5 minutes.");
         //   }
         // });
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Offers(),
      ),
    );
  }

  void _clearForm() {
    _requestNameController;
    _fareController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _workDateController.clear();
    _phoneController.clear();
    setState(() {

      _citySelected = null;
      _requestNameController = null;
    });
  }

  Future<void> _initializeLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      final locationData = await _locationService.getAddressFromLatLng(
          position.latitude, position.longitude);
      setState(() {
        _address = locationData["address"];
        _citySelected = locationData["city"];
        //_currentLocatioN='Lat: ${position.latitude}, Long: ${position.longitude}';
      });
    }



  }
  void initState() {
    super.initState();
    _initializeLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,

        title: const MyTextt(
            text: "Add Work Request",
            fontSize: 20,
            color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select your Service',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                  value: _requestNameController,
                  items: services.map((service) {
                    return DropdownMenuItem<String>(
                      value: service,
                      child: Text(service),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _requestNameController = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'What Service You want';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _fareController,
                  hintText: "fare",
                  prefixIcon: Icon(Icons.currency_ruble),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (!getcurrentloc && (value?.isEmpty ?? true)) {
                      return 'Please enter fare';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    CustomTextFormField(
                      controller: _locationController,
                      prefixIcon: Icon(Icons.location_on),
                      hintText: "Address (e.g: House:8347 / Landmark)",
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a specific address';
                        }
                        return null;
                      },
                      enabled: !getcurrentloc,
                                          ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Get my Current Location"),
                        Switch(
                          value: getcurrentloc,
                          onChanged: (value) {
                            setState(() {
                              _initializeLocation();
                              getcurrentloc = value;
                              if (getcurrentloc) {

                                _locationController.text = _address.toString();
                              } else {

                                _locationController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),




                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _phoneController,
                  prefixIcon: Icon(Icons.phone),
                  hintText: "Phone Number",
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _workDateController,
                  readOnly:
                      true,
                    decoration: const InputDecoration(
                    hintText: "Work Date (e.g., 2024-12-31)",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () =>
                      _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter work date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  maxLines: 5,
                  controller: _descriptionController,
                  onChanged: (value) {
                    setState(() {
                      _currentWordCount =
                          value.trim().split(RegExp(r'\s+')).length;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Description",
                    border: OutlineInputBorder(),
                  ),

                ),

                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: isLoading ? null : _saveRequests,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Add Request",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
