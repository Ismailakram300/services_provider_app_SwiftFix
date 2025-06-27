import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String? name;
  String? fare;
  String? description;
  String? city;
  String? location;
  String? requestId;
  String? userId;
  Timestamp? createdAt;

  String? workDate;
  String? status;
  String? phoneNumber;
  String? requesterName;
  List<dynamic>? hiddenFor = [];
  ServiceModel({
    this.name,
    this.fare,
    this.description,
    this.city,
    this.location,
    this.requestId,
    this.userId,
    this.workDate,
    this.phoneNumber,
    this.createdAt,
    this.status,
    this.requesterName,
    this.hiddenFor
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      name: json['name'],
      fare: json['fare'],
      description: json['description'],
      city: json['city'],
      location: json['location'],
      requestId: json['requestId'],
      userId: json['userId'],
      workDate: json['workDate'],
      phoneNumber: json['phoneNumber'],
      status: json['status'],
      createdAt: json['createdAt'] is Timestamp ? json['createdAt'] : null,
      requesterName: json['requesterName'],
        hiddenFor:json['hiddenFor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fare': fare,
      'description': description,
      'city': city,
      'location': location,
      'requestId': requestId,
      'userId': userId,
      'workDate': workDate,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'status':status,
      'requesterName':requesterName,
      'hiddenFor':hiddenFor,
    };
  }
}
