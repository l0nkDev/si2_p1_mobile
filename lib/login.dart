import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'components/labeledInput.dart';

class Login extends StatelessWidget{
  final Function setToken;
  final Function goto;
  Login(this.setToken, this.goto);



  Future<void> sendLogin(String email, String password, BuildContext context) async {
    Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
    };
    
      var response = await http.post(Uri.http("l0nk5erver.duckdns.org:5000", 'auth/login/email'), 
      headers: headers,
      body: 
      '''
        {
          "email": "$email",
          "password": "$password"
        }
    '''
    );
    print(response.body);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sesión iniciada correctamente como user ${decodedResponse["id"]}")),
    );
    setToken(decodedResponse["access_token"]);
    goto(0);
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.headlineMedium!;

    TextEditingController email = TextEditingController();
    TextEditingController passwd = TextEditingController();

    return Scaffold(
      body: Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Inicio de sesión", style: style),
              LabeledInput(label: "e-mail", controller: email,),
              LabeledInput(label: "Contraseña", controller: passwd),
              FilledButton(
                child: Text("Iniciar sesión"),
                onPressed: () {
                  sendLogin(email.value.text, passwd.value.text, context);
                })
            ],
          ),
        ),
      ),
      );
  }
}