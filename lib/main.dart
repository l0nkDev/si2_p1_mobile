import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si2_p1_mobile/firebase_api.dart';
import 'package:si2_p1_mobile/firebase_options.dart';
import 'package:si2_p1_mobile/screens/user/profile.dart';
import 'screens/auth-session/login.dart';
import 'screens/auth-session/register.dart';
import 'screens/catalog-purchase/cart.dart';
import 'screens/catalog-purchase/catalogue.dart';
import 'screens/catalog-purchase/product.dart';
import 'screens/user/purchases.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'SI2 mobile',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

var selectedIndex = 0;
var product = 0;
bool isLogged = false;
late SharedPreferences prefs;
String token = "";
String refreshToken = "";

  void setToken(String newToken) {
    token = newToken;
    isLogged = true;
    prefs.setString('token', token);
  }

  void goto(int n, {int y = 0}) { setState(() { 
    print("y: $y | n: $n");
    product = y;
    selectedIndex = n; 
  }); }

  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    if (token != '') {isLogged = true;}
    setState(() {});
  }

  logout() async {
    await http.post(Uri.http("l0nk5erver.duckdns.org:5000", 'auth/logout'), 
      headers: {HttpHeaders.authorizationHeader: "Bearer $token", HttpHeaders.contentTypeHeader: 'application/json'},
      body: 
      '''
        {
          "fcm": "${await FirebaseApi().initNotifications()}"
        }
    '''
    );
    token = ""; 
    isLogged = false;
    prefs.setString('token', '');
    selectedIndex = 0; 
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
  Widget page;
  switch (selectedIndex) {
    case 0:
      page = Catalogue(isLogged: isLogged, token: token, goto: goto,);
    case 1:
      page = Login(setToken, goto);
    case 2:
      page = CartScreen(isLogged: isLogged, token: token, goto: goto);
    case 3:
      page = Purchases(isLogged: isLogged, token: token, goto: goto);
    case 4:
      page = ProductScreen(isLogged: isLogged, token: token, goto: goto, productid: product,);
    case 5:
      page = Register(setToken, goto);
    case 6:
      page = Profile(token);
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(title: const Text('Parcial 1')),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.only(top: 40),
              children: [
              Column(
                children: [
                  InkWell(
                    onTap: () {setState(() {
                      if (isLogged) {
                        logout();
                      } else { selectedIndex = 1; }
                      Navigator.pop(context);
                      });},
                    child: Row(
                      children: [
                        SizedBox(height: 64, width: 10,),
                        Icon(isLogged ? Icons.logout : Icons.login),
                        SizedBox(height: 64, width: 10,),
                        Text(isLogged ? "Cerrar sesion" : "Iniciar Sesion"),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {setState(() {selectedIndex = 0; Navigator.pop(context);});},
                    child: Row(
                      children: [
                        SizedBox(height: 64, width: 10,),
                        Icon(Icons.shopping_bag_outlined),
                        SizedBox(height: 64, width: 10,),
                        Text("Catalogo"),
                      ],
                    ),
                  ),
                  if (isLogged)
                    InkWell(
                      onTap: () {setState(() {selectedIndex = 3; Navigator.pop(context);});},
                      child: Row(
                        children: [
                          SizedBox(height: 64, width: 10,),
                          Icon(Icons.shopping_cart_outlined),
                          SizedBox(height: 64, width: 10,),
                          Text("Historial de compras"),
                        ],
                      ),
                    ),
                  if (isLogged)
                    InkWell(
                      onTap: () {setState(() {selectedIndex = 6; Navigator.pop(context);});},
                      child: Row(
                        children: [
                          SizedBox(height: 64, width: 10,),
                          Icon(Icons.person),
                          SizedBox(height: 64, width: 10,),
                          Text("Perfil de usuario"),
                        ],
                      ),
                    ),
                ],
              )
              ],
            ),
          ),
          body: Row(
            children: [
              SafeArea(child: Text("")),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

