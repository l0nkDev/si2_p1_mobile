import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class Purchases extends StatefulWidget{
  final String? token;
  final bool isLogged;
  final Function goto;
  const Purchases({super.key, this.token, required this.isLogged, required this.goto});

  @override
  State<Purchases> createState() => _PurchasesState();
}

class _PurchasesState extends State<Purchases> {
  bool speechEnabled = false;
  late Future<List> productsFuture;
  TextEditingController search = TextEditingController();

  Future<List> getProducts() async {
    var purchases = [];
    print("started");
    final response = await http.get(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/purchases"), headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    for (var item in body) {
      var items = [];
      for (var purchase in item["items"]) {
        items.add(
          {
            "id": purchase["id"],
            "productid": purchase["productid"],
            "name": purchase["name"],
            "brand": purchase["brand"],
            "rating": purchase["rating"],
            "price": purchase["price"],
            "dprice": purchase["dprice"],
            "fprice": purchase["fprice"],
            "quantity": purchase["quantity"],
          }
        );
      }
      purchases.add(
        {
          "id": item["id"],
          "paid_on": item["paid_on"],
          "payment_method": item["payment_method"],
          "delivery_status": item["delivery_status"],
          "rating": item["rating"],
          "total_paid": item["total_paid"],
          "vip": item["vip"],
          "items": items
        }
      );
    }
    return purchases;
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
    return Scaffold(
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: 
            Column(
              children: <Widget>[
                Expanded(
                  child: FutureBuilder<List>(
                    future: productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final products = snapshot.data!;
                        return buildPurchases(products, widget.isLogged);
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

  Widget buildPurchases(List products, bool isLogged) => ListView.builder(
    itemCount: products.length,
    itemBuilder: (context, index) {
      final product = products[index];

      return PurchaseCard(product: product, rate: rateDelivery);
    }
  );

  addToCart(Purchase prod, BuildContext context) async {
    var response = await http.post(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/cart/add"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'},
      body: '{"id": "${prod.id}"}'
    );
    print(response.body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\"${prod.delivery_status}\" fue agregado al carrito.")));
  }
}

class PurchaseCard extends StatelessWidget {
  PurchaseCard({
    super.key,
    required this.product,
    required this.rate,
  });

  final dynamic product;
  final Function rate;
  final TextEditingController quantity = TextEditingController();

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    quantity.value = TextEditingValue(text: '5');
    return Card(
      child: Column(
        children: [
          ListTile(
            //leading: Image.network("http://l0nk5erver.duckdns.org:5000/products/img/${product.id}.png"),
            title: Text(product["paid_on"]),
            subtitle: Text(product["delivery_status"]),
          ),
          Row(
            children: [
              SizedBox(width: 15,),
              Text(product["vip"] != 'Y' ? "\$${product["total_paid"]}" : ''),
              Text(product["vip"] == 'Y' ? "\$${product["total_paid"]}" : '', style: TextStyle(decoration: TextDecoration.lineThrough)),
              Text(product["vip"] == 'Y' ? "     Descuento 15% VIP: \$${double.parse(product["total_paid"])*0.85}" : ''),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 15,),
              Text(product["payment_method"]),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 15,),
              Text("✰${product["rating"]}"),
            ],
          ),
          SizedBox(height: 15,),
          for (var item in product["items"]) 
            Column(
              children: [
                Row(
                  children: [
              SizedBox(width: 15,),
                    Text(item["name"]),
                  ],
                ),
                Row(
                  children: [
              SizedBox(width: 15,),
                    Text(item["brand"]),
                  ],
                ),
                Row(
                  children: [
              SizedBox(width: 15,),
                    Text("✰${item["rating"]}"),
                  ],
                ),
              SizedBox(height: 15,),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Expanded(child: TextField(controller: quantity)),
                ElevatedButton(
                  onPressed: () {rate(product["id"], double.parse(quantity.value.text));}, 
                  child: Text("Enviar Calificacion"), 
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () { _launchUrl(Uri.parse("http://l0nk5erver.duckdns.org:5000/facturas/${product["id"]}"));}, 
            child: Text("Ver factura"), 
            ), 
        ],
      )
    );
  }
}