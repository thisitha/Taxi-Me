import 'package:shared_preferences/shared_preferences.dart';

class PassengerModel {
  String userId;
  String email;
  String passengerCode;
  String userProfilePic;
  String token;

  PassengerModel(
      {this.userId,
      this.email,
      this.passengerCode,
      this.userProfilePic,
      this.token});
}
