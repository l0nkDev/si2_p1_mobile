import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:si2_p1_mobile/firebase_api.dart';
import '../../components/labeledInput.dart';

class Login extends StatelessWidget{
  final Function setToken;
  final Function goto;
  const Login(this.setToken, this.goto, {super.key});



  Future<void> sendLogin(String email, String password, BuildContext context) async {
    Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
    };
    
      var response = await http.post(Uri.http("34.70.148.131:5000", 'auth/login/email'), 
      headers: headers,
      body: 
      '''
        {
          "email": "$email",
          "password": "$password",
          "fcm": "${await FirebaseApi().initNotifications()}"
        }
    '''
    );
    print(response.body);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sesión iniciada correctamente.")),
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
                }),
              SizedBox(height: 32,),
              Text("No tienes cuenta?"),
              OutlinedButton(
                child: Text("Registrate"),
                onPressed: () {
                  goto(5);
                })
            ],
          ),
        ),
      ),
      );
  }
}