import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/purchase.dart';

class ProductScreen extends StatefulWidget{
  final String? token;
  final bool isLogged;
  final int productid;
  final Function goto;
  ProductScreen({Key? key, this.token, required this.isLogged, required this.goto, required this.productid}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}




class _ProductScreenState extends State<ProductScreen> {
  bool speechEnabled = false;
  late Future<Map> productsFuture;
  TextEditingController search = TextEditingController();

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
    return Scaffold(
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: 
            Column(
              children: <Widget>[
                Expanded(
                  child: FutureBuilder<Map>(
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

  Widget buildPurchases(Map products, bool isLogged) => ListView.builder(
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

  @override
  Widget build(BuildContext context) {
    quantity.value = TextEditingValue(text: '5');
    return Card(
      child: Column(
        children: [
          ListTile(
            //leading: Image.network("http://l0nk5erver.duckdns.org:5000/products/img/${product.id}.png"),
            title: Text(product["name"]),
            subtitle: Text(product["brand"]),
          ),
        ],
      )
    );
  }
}