import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/models/auth/auth_model.dart';
import 'package:sansom/service/token/token_storage.dart';

class AuthService{
  

  Future<Map<String, dynamic>> login(Login request) async{
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/login'),
      headers : {
          'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

     if (response.statusCode == 200) {

    
      return jsonDecode(response.body);
     
    }

    throw Exception('Login failed');
  }

  Future<Map<String, dynamic>> register(User request) async{
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/register'),
      headers : {
          'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(request.toJson()),

    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception('Register Failed');
  }
 
}

