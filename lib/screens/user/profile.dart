import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:si2_p1_mobile/models/user.dart';
import '../../components/labeledInput.dart';

// ignore: must_be_immutable
class Profile extends StatelessWidget{
  final String token;
  Profile(this.token, {super.key});

    TextEditingController email = TextEditingController();
    TextEditingController passwd = TextEditingController();
    TextEditingController role = TextEditingController();
    TextEditingController name = TextEditingController();
    TextEditingController lname = TextEditingController();
    TextEditingController country = TextEditingController();
    TextEditingController state = TextEditingController();
    TextEditingController address = TextEditingController();

  Future<User> getUser() async {
    final response = await http.get(Uri.parse("http://34.70.148.131:5000/users/self"),headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    final body = json.decode(response.body);
    final user = User.fromJson(body);
    print(user.name);
    return user;
  }

  Future<void> updateProfile(String email, String password, String name, String lname, String country, String state, String address, BuildContext context) async {
      await http.patch(Uri.http("34.70.148.131:5000", 'users/self'), 
      headers: {HttpHeaders.authorizationHeader: "Bearer $token", HttpHeaders.contentTypeHeader: 'application/json'},
      body: 
      '''
        {
          "email": "$email",
          "password": "$password",
          "name": "$name",
          "lname": "$lname",
          "country": "$country",
          "state": "$state",
          "address": "$address"
        }
    '''
    );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.headlineMedium!;

    getUser().then((value) => {
      name.value = TextEditingValue(text: value.name),
      lname.value = TextEditingValue(text: value.lname),
      email.value = TextEditingValue(text: value.email),
      passwd.value = TextEditingValue(text: value.password),
      role.value = TextEditingValue(text: value.role),
      country.value = TextEditingValue(text: value.country),
      state.value = TextEditingValue(text: value.state),
      address.value = TextEditingValue(text: value.address),
      });

    return Scaffold(
      body: Card(
        child: ListView(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 32,),
                  Text("Perfil de usuario", style: style),
                  LabeledInput(label: "Nombre", controller: name),
                  LabeledInput(label: "Apellido", controller: lname),
                  LabeledInput(label: "e-mail", controller: email,),
                  LabeledInput(label: "Contraseña", controller: passwd),
                  LabeledInput(label: "Rol", controller: role, enabled: false),
                  LabeledInput(label: "Pais", controller: country),
                  LabeledInput(label: "Estado/Departamento", controller: state),
                  LabeledInput(label: "Dirección", controller: address),
                  FilledButton(
                    child: Text("Actualizar datos"),
                    onPressed: () {
                      updateProfile(email.value.text, passwd.value.text, name.value.text, lname.value.text, country.value.text, state.value.text, address.value.text, context);
                    }),
                ],
              ),
            ],
          ),
        ),
      );
  }
}