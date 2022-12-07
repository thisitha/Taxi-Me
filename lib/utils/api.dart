import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
class Network{
  final String _url = 'http://173.82.95.250:8095';
  final String _webURL = 'http://173.82.95.250:8095/';


  var token;

  // _getToken() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   token = jsonDecode(localStorage.getString('token'))['token'];
  // }

  getData(data, apiUrl) async{
    var fullUrl = _url + apiUrl;
    return await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }
  postData(data, apiUrl) async{
    var fullUrl = _url + apiUrl;
    return await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }

  // getData(data,apiUrl) async {
  //   var fullUrl = _url + apiUrl;
  //   return await http.post(
  //       fullUrl,
  //       body: jsonEncode(data),
  //       headers: _setHeadersPayment()
  //   );
  // }

  getDataAPI(apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(
        fullUrl,
        headers: _setHeaders()
    );
  }
  getURL(){
    return _webURL;
  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
    'Authorization' : 'Bearer $token',
    'Connection':'keep-alive',
  };


}