import 'product.dart';

class User {
  final int id;
  final String email;
  final String password;
  final String name;
  final String lname;
  final String role;
  final String country;
  final String state;
  final String address;
  final String token;
  final String vip;

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.lname,
    required this.role,
    required this.country,
    required this.state,
    required this.address,
    required this.token,
    required this.vip,
  });

  static User fromJson(json) => User(
    id: json["id"], 
    email: json["email"], 
    password: json["password"], 
    name: json["name"], 
    lname: json["lname"], 
    role: json["role"], 
    country: json["country"], 
    state: json["state"], 
    address: json["address"], 
    token: json["token"], 
    vip: json["vip"], 
    );
}