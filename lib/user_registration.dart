import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserRegistration extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.headlineMedium!;

    TextEditingController email = TextEditingController();
    TextEditingController passwd = TextEditingController();
    TextEditingController fname = TextEditingController();
    TextEditingController lname = TextEditingController();

    return Scaffold(
      body: Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Registar nuevo usuario", style: style),
              LabeledInput(label: "e-mail", controller: email,),
              LabeledInput(label: "Contraseña", controller: passwd),
              LabeledInput(label: "Nombre", controller: fname),
              LabeledInput(label: "Apellido", controller: lname),
              FilledButton(
                child: Text("Ingresar"),
                onPressed: () {
                  sendRegistration(email.value.text, passwd.value.text, fname.value.text, lname.value.text, context);
                  
                })
            ],
          ),
        ),
      ),
      );
  }
}

Future<void> sendRegistration(String email, String password, String name, String lastname, BuildContext context) async {

      Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
    };
    
      var response = await http.post(Uri.https("dismac-backend.up.railway.app", 'auth/register'), 
      headers: headers,
      body: 
      '''
        {
          "email": "$email",
          "password": "$password",
          "first_name": "$name",
          "last_name": "$lastname",
          "role": "customer"
        }
    '''
    );
    print(response.body);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("user ${decodedResponse["id"]} registrado correctamente")),
    );
}

class LabeledInput extends StatelessWidget {
    const LabeledInput({
    super.key,
    required this.label,
    required this.controller
    });

    final String label;
    final TextEditingController controller;

  @override
  Widget build(BuildContext context) {

    return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: 
                  InputDecoration(
                    label: Text(label),
                    border: OutlineInputBorder()
                    ),
                )
              ],
            ),
          );
  }
}