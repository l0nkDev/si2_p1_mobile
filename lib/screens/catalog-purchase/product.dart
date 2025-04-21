import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ProductScreen extends StatefulWidget{
  final String? token;
  final bool isLogged;
  int productid;
  final Function goto;
  ProductScreen({super.key, this.token, required this.isLogged, required this.goto, required this.productid});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}


class _ProductScreenState extends State<ProductScreen> {
  bool speechEnabled = false;
  late Future<Map> productsFuture;
  TextEditingController rating = TextEditingController();

  goto(int n) {
    widget.productid = n;
    productsFuture = getProducts();
    setState(() {});
  }

  rate(int id, double rating) async {
    await http.post(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/products/rate"),
    headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: "application/json"},
    body: '''{"id": "$id", "rating": "$rating"}'''
    );
    productsFuture = getProducts();
    setState(() {});
  }

  Future<Map> getProducts() async {
    var data = {};
    print("started");
    final response = await http.get(Uri.parse("http://l0nk5erver.duckdns.org:5000/products/get?id=${widget.productid}"));
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var items = [];
    for (var item in body["recommendations"]) {
      items.add(
        {      
          "brand": item["brand"],
          "date_added": item["date_added"],
          "description": item["description"],
          "discount": item["discount"],
          "discount_type": item["discount_type"],
          "id": item["id"],
          "name": item["name"],
          "price": item["price"],
          "rating": item["rating"],
          "stock": item["stock"]
        }
      );
    }
    data = {
      "brand": body["brand"],
      "date_added": body["date_added"],
      "description": body["description"],
      "discount": body["discount"],
      "discount_type": body["discount_type"],
      "id": body["id"],
      "name": body["name"],
      "price": body["price"],
      "rating": body["rating"],
      "recommendations": items
    };
    return data;
  }

  @override
  void initState() {
    super.initState();
    productsFuture = getProducts();
  }

  rateDelivery(int id, double rating) async {
    final response = await http.post(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/purchases/rate"),
    headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: "application/json"},
    body: '''{"id": "$id", "rating": "$rating"}'''
    );
    print(response.body);
    productsFuture = getProducts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    rating.value = TextEditingValue(text: "5");
    return Scaffold(
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: 
            Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () { widget.goto(0); }, 
                  child: Text("Volver a catalogo"), 
                  ),
                Expanded(
                  child: FutureBuilder<Map>(
                    future: productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final products = snapshot.data!;
                        return Column(
                          children: [
                            Card(
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Image.network("http://l0nk5erver.duckdns.org:5000/products/img/${products["id"]}.png",
                                        loadingBuilder: (BuildContext context, Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          final totalBytes = loadingProgress?.expectedTotalBytes;
                                          final bytesLoaded =
                                              loadingProgress?.cumulativeBytesLoaded;
                                          if (totalBytes != null && bytesLoaded != null) {
                                            return CircularProgressIndicator(
                                              backgroundColor: Colors.white70,
                                              value: bytesLoaded / totalBytes,
                                              color: Colors.blue[900],
                                              strokeWidth: 5.0,
                                            );
                                          } else {
                                            return child;
                                          }
                                        },
                                        frameBuilder: (BuildContext context, Widget child,
                                            int? frame, bool wasSynchronouslyLoaded) {
                                          if (wasSynchronouslyLoaded) {
                                            return child;
                                          }
                                          return AnimatedOpacity(
                                            opacity: frame == null ? 0 : 1,
                                            duration: const Duration(seconds: 1),
                                            curve: Curves.easeOut,
                                            child: child,
                                          );
                                        },
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              
                                        return const Text('😢');
                                        },
                                      ),
                                    title: Text(products["name"]),
                                    subtitle: Text(products["brand"]),
                                  ),
                                  Row(
                                    children: [SizedBox(width: 15,),
                                      Text(products["description"]),
                                    ],
                                  ),
                                  Row(
                                    children: [SizedBox(width: 15,),
                                      Text("✰${products["rating"]}"),
                                    ],
                                  ),
                                  Row(
                                    children: [SizedBox(width: 15,),
                                      Text(products["discount"] == 0 ? "\$${double.parse(products["price"]).toStringAsFixed(2)}" : ""),
                                      Text(products["discount"] != 0 ? "\$${double.parse(products["price"]).toStringAsFixed(2)}   " : "", style: TextStyle(decoration: TextDecoration.lineThrough),),
                                      Text(products["discount"] != 0 ? "\$${products["discount_type"] == 'P' ? (double.parse(products["price"]) * (1-(double.parse(products["discount"])*0.01))).toStringAsFixed(2) : (double.parse(products["price"]) - double.parse(products["discount"])).toStringAsFixed(2)}" : ""),
                                    ],
                                  ),
                                  Row( mainAxisSize: MainAxisSize.min,
                                    children: [SizedBox(width: 15,),
                                    Expanded(child: TextField(controller: rating)),
                                    ElevatedButton(
                                      onPressed: widget.isLogged ? () { rate(products["id"], double.parse(rating.value.text)); } : null, 
                                      child: Text("Calificar"), 
                                      ), 
                                    ElevatedButton(
                                      onPressed: widget.isLogged ? () { addToCart(products, context); } : null, 
                                      child: Text("Al carrito"), 
                                      ) 
                                    ],
                                  ),
                                ],
                              )
                            ),
                            Expanded(child: buildPurchases(products, widget.isLogged)),
                          ],
                        );
                      } else {
                        return const Text("No data");
                      }
                    }
                  ),
                )
              ]
            )
          );
        }
      ),
    );
  }

  Widget buildPurchases(Map products, bool isLogged) => ListView.builder(
    itemCount: products["recommendations"].length,
    itemBuilder: (context, index) {
      final product = products["recommendations"][index];

      return PurchaseCard(product: product, rate: rateDelivery, isLogged: isLogged, goto: goto, token: widget.token);
    }
  );

  addToCart(Map prod, BuildContext context) async {
    var response = await http.post(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/cart/add"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'},
      body: '{"id": "${prod["id"]}"}'
    );
    print(response.body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\"${prod["name"]}\" fue agregado al carrito.")));
  }
}

class PurchaseCard extends StatelessWidget {
  PurchaseCard({
    super.key,
    required this.product,
    required this.rate,
    required this.isLogged,
    required this.goto,
    required this.token,
  });

  final dynamic product;
  final Function rate;
  final bool isLogged;
  final Function goto;
  final String? token;
  final TextEditingController quantity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    quantity.value = TextEditingValue(text: '5');
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Image.network("http://l0nk5erver.duckdns.org:5000/products/img/${product["id"]}.png",
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  final totalBytes = loadingProgress?.expectedTotalBytes;
                  final bytesLoaded =
                      loadingProgress?.cumulativeBytesLoaded;
                  if (totalBytes != null && bytesLoaded != null) {
                    return CircularProgressIndicator(
                      backgroundColor: Colors.white70,
                      value: bytesLoaded / totalBytes,
                      color: Colors.blue[900],
                      strokeWidth: 5.0,
                    );
                  } else {
                    return child;
                  }
                },
                frameBuilder: (BuildContext context, Widget child,
                    int? frame, bool wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) {
                    return child;
                  }
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
        
                  return const Text('😢');
                },
              ),
            title: Text(product["name"]),
            subtitle: Text(product["brand"]),
          ),
          Row(
            children: [SizedBox(width: 15,),
              Text(product["description"]),
            ],
          ),
          Row(
            children: [SizedBox(width: 15,),
              Text("✰${product["rating"]}"),
            ],
          ),
          Row(
            children: [SizedBox(width: 15,),
              Text(product["discount"] == 0 ? "\$${double.parse(product["price"]).toStringAsFixed(2)}" : ""),
              Text(product["discount"] != 0 ? "\$${double.parse(product["price"]).toStringAsFixed(2)}   " : "", style: TextStyle(decoration: TextDecoration.lineThrough),),
              Text(product["discount"] != 0 ? "\$${product["discount_type"] == 'P' ? (double.parse(product["price"]) * (1-(double.parse(product["discount"])*0.01))).toStringAsFixed(2) : (double.parse(product["price"]) - double.parse(product["discount"])).toStringAsFixed(2)}" : ""),
            ],
          ),
          Row( mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () { goto(product["id"]); }, 
                child: Text("Ver mas..."), 
                ),
          ElevatedButton(
            onPressed: isLogged ? () { addToCart(product, context, token); } : null, 
            child: Text("Al carrito"), 
            ) 
            ],
          ),
        ],
      )
    );
  }

  addToCart(Map prod, BuildContext context, String? token) async {
    var response = await http.post(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/cart/add"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer $token", HttpHeaders.contentTypeHeader: 'application/json'},
      body: '{"id": "${prod["id"]}"}'
    );
    print(response.body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\"${prod["name"]}\" fue agregado al carrito.")));
  }
}