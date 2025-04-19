import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/product.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class Catalogue extends StatefulWidget{
  final String? token;
  final bool isLogged;
  final Function goto;
  Catalogue({Key? key, this.token, required this.isLogged, required this.goto}) : super(key: key);

  @override
  State<Catalogue> createState() => _CatalogueState();
}




class _CatalogueState extends State<Catalogue> {
  bool speechEnabled = false;
  stt.SpeechToText _speechToText = stt.SpeechToText();
  Future<List<Product>> productsFuture = getProducts();
  TextEditingController search = TextEditingController();
  String _lastWords = '';

  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse("http://l0nk5erver.duckdns.org:5000/products"));
    final body = json.decode(response.body);
    return body.map<Product>(Product.fromJson).toList();
  }

  static Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(Uri.parse("http://l0nk5erver.duckdns.org:5000/products/search?q=$query"));
    final body = json.decode(response.body);
    return body.map<Product>(Product.fromJson).toList();
  }

    @override
  initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

    void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult, partialResults: false, localeId: "es_ES");
    setState(() {});
  }

    void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

    void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {_lastWords = result.recognizedWords;}); 
    search.value = TextEditingValue(text: _lastWords);
    productsFuture = searchProducts(search.text);
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
                Row(
                  children: [
                    Expanded(child: TextField(
                      controller: search,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    )),
                    ElevatedButton(onPressed: () {
                      if (search.text != '') {productsFuture = searchProducts(search.text);} 
                      else { productsFuture = getProducts();}
                      setState(() {});
                      }, child: Text("Search")),
                    ElevatedButton(onPressed: widget.isLogged ? () {widget.goto(2);} : null, child: Text("Carrito")),
                  ],
                ),
                Expanded(
                  child: FutureBuilder<List<Product>>(
                    future: productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final products = snapshot.data!;
                        return buildProducts(products, widget.isLogged);
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
      floatingActionButton: FloatingActionButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      )
    );
  }

  Widget buildProducts(List<Product> products, bool isLogged) => ListView.builder(
    itemCount: products.length,
    itemBuilder: (context, index) {
      final product = products[index];

      return Card(
        child: Column(
          children: [
            ListTile(
              //leading: Image.network("http://l0nk5erver.duckdns.org:5000/products/img/${product.id}.png"),
              title: Text(product.name),
              subtitle: Text(product.brand),
            ),
            ElevatedButton(
              onPressed: isLogged ? () { addToCart(product, context); } : null, 
              child: Text("Al carrito"), 
              ) 
          ],
        )
      );
    }
  );

  addToCart(Product prod, BuildContext context) async {
    var response = await http.post(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/cart/add"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'},
      body: '{"id": "${prod.id}"}'
    );
    print(response.body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\"${prod.name}\" fue agregado al carrito.")));
  }
}