// lib/utils/api_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stock_manager/config/env.dart';
import 'auth_helper.dart';

class ApiService {

  static Future<http.Response> get(String endpoint, {Map<String, String>? params}) async {
    final token = await AuthHelper.getToken();

    // Append query parameters if provided
    final uri = Uri.parse('${Env.baseUrl}/$endpoint').replace(queryParameters: params);

    return await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }


  static Future<http.Response> post(String endpoint, dynamic body) async {
    final token = await AuthHelper.getToken();
    return await http.post(
      Uri.parse('${Env.baseUrl}/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );
  }

  static Future<http.Response> multipartRequest(
      String endpoint,
      Map<String, String> fields,
      List<http.MultipartFile> files,
      ) async {
    final token = await AuthHelper.getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Env.baseUrl}/$endpoint'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    request.files.addAll(files);

    return await http.Response.fromStream(await request.send());
  }
}



// // utils/api_service.dart
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../models/product.dart';
//
// class ApiService {
//   static const String baseUrl = 'http://192.168.8.101/api';
//
//   static Future<List<Product>> getProducts() async {
//     final response = await http.get(Uri.parse('$baseUrl/products'));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => Product.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load products');
//     }
//   }
//
//   static Future<Product> addProduct(Product product) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/products'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(product.toJson()),
//     );
//     if (response.statusCode == 201) {
//       return Product.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to add product');
//     }
//   }
// }