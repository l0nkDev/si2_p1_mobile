import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'cart.dart';
import 'catalogue.dart';
import 'product.dart';
import 'purchases.dart';

void main() {
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

var selectedIndex = 0;
var product = 0;
bool isLogged = false;
String token = "";
String refreshToken = "";

  void setToken(String newToken) {
    token = newToken;
    isLogged = true;
  }

  void goto(int n, {int y = 0}) { setState(() { 
    print("y: $y | n: $n");
    product = y;
    selectedIndex = n; 
  }); }

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
                        token = ""; 
                        isLogged = false;
                        selectedIndex = 0; 
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

