class PassengerRideModel {
  final String passengerId;
  final String address;
  final double latitude;
  final double longitude;
  final String operationRadius;
  final String dropLocations;
  final String distance;
  final String bidValue;
  final String vehicleCategory;
  final String vehicleSubCategory;
  final String hireCost;
  final String type;
  final String validTime;
  final String payMethod;

  PassengerRideModel({
    this.passengerId,
    this.address,
    this.latitude,
    this.longitude,
    this.operationRadius,
    this.dropLocations,
    this.distance,
    this.bidValue,
    this.vehicleCategory,
    this.vehicleSubCategory,
    this.hireCost,
    this.type,
    this.validTime,
    this.payMethod,
  });

  factory PassengerRideModel.fromJson(Map<dynamic, dynamic> json) {
    return PassengerRideModel(
      passengerId: json['passengerId'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      operationRadius: json['operationRadius'],
      dropLocations: json['dropLocations'],
      distance: json['distance'],
      bidValue: json['bidValue'],
      vehicleCategory: json['vehicleCategory'],
      vehicleSubCategory: json['vehicleSubCategory'],
      hireCost: json['hireCost'],
      type: json['type'],
      validTime: json['validTime'],
      payMethod: json['payMethod'],
    );
  }
}