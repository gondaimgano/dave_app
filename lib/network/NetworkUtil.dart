import 'package:dave_app/db.dart';
import 'package:dave_app/models/Person.dart';
import 'package:dave_app/network/DaveUtils.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class NetworkUtil {
  NetworkUtil._();

  static Future<List<dynamic>> getAllUsers({String path = "users"}) async {
    http.Response response = await http.get(DaveUtils.baseURL + path,
        headers: {"Content-Type": 'application/json'});
    var data = json.decode(response.body);
    print(DaveUtils.baseURL + path);
    //print(json.decode(response.body));
    if(response.statusCode!=200)
      {
       var pp= await DatabaseCreator.getAllPersons();
       return pp;
      }

  data.map((item) async {
      await DatabaseCreator.savePerson(Person.fromJson(item));
      return Person.fromJson(item);
    }).toList();
    return DatabaseCreator.getAllPersons();
  }

}
