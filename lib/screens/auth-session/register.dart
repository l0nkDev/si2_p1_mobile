import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:si2_p1_mobile/firebase_api.dart';
import '../../components/labeledInput.dart';

class Register extends StatelessWidget{
  final Function setToken;
  final Function goto;
  const Register(this.setToken, this.goto, {super.key});



  Future<void> sendRegistration(String email, String password, String name, String lname, String country, String state, String address, BuildContext context) async {
    Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
    };
    
      var response = await http.post(Uri.http("34.70.148.131:5000", 'auth/register'), 
      headers: headers,
      body: 
      '''
        {
          "email": "$email",
          "password": "$password",
          "name": "$name",
          "lname": "$lname",
          "country": "$country",
          "state": "$state",
          "address": "$address",
          "fcm": "${await FirebaseApi().initNotifications()}"
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
    TextEditingController name = TextEditingController();
    TextEditingController lname = TextEditingController();
    TextEditingController country = TextEditingController();
    TextEditingController state = TextEditingController();
    TextEditingController address = TextEditingController();

    return Scaffold(
      body: Card(
        child: ListView(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 32,),
                  Text("Registro de usuario", style: style),
                  LabeledInput(label: "e-mail", controller: email,),
                  LabeledInput(label: "Contraseña", controller: passwd),
                  LabeledInput(label: "Nombre", controller: name),
                  LabeledInput(label: "Apellido", controller: lname),
                  LabeledInput(label: "Pais", controller: country),
                  LabeledInput(label: "Estado/Departamento", controller: state),
                  LabeledInput(label: "Dirección", controller: address),
                  FilledButton(
                    child: Text("Registrate!"),
                    onPressed: () {
                      sendRegistration(email.value.text, passwd.value.text, name.value.text, lname.value.text, country.value.text, state.value.text, address.value.text, context);
                    }),
                  SizedBox(height: 32,),
                  Text("Ya tienes cuenta?"),
                  OutlinedButton(
                    child: Text("Inicia Sesión"),
                    onPressed: () {
                      goto(1);
                    })
                ],
              ),
            ],
          ),
        ),
      );
  }
}