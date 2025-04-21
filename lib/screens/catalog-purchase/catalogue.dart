import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/product.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class Catalogue extends StatefulWidget{
  final String? token;
  final bool isLogged;
  final Function goto;
  const Catalogue({super.key, this.token, required this.isLogged, required this.goto});

  @override
  State<Catalogue> createState() => _CatalogueState();
}




class _CatalogueState extends State<Catalogue> {
  bool speechEnabled = false;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  TextEditingController search = TextEditingController();
  String _lastWords = '';
  
  List<Product> products  = [];
  int nextPage = 0;
  
  ValueNotifier<int> itemCount = ValueNotifier<int>(0);

  void loadNextPage() {
    getProducts(nextPage++, search.text).then((newProducts){
      products.addAll(newProducts);
      itemCount.value = products.length;
    });
  }

  static Future<List<Product>> getProducts(int page, String query) async {
    late dynamic response;
    if (query == '') {response = await http.get(Uri.parse("http://l0nk5erver.duckdns.org:5000/products?page=$page"));}
    else {response = await http.get(Uri.parse("http://l0nk5erver.duckdns.org:5000/products/search?q=$query&page=$page"));}
    final body = json.decode(response.body);
    return body.map<Product>(Product.fromJson).toList();
  }

    @override
  initState() {
    super.initState();
    _initSpeech();
    loadNextPage();
  }

  Product getProductAtIndex(int index) {
    if (index > products.length - 5) {
      loadNextPage();
    }
    return products[index];
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
    products = [];
    nextPage = 0;
    itemCount.value = 0;
    loadNextPage();
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
                    Expanded(child: 
                      TextField(
                        controller: search,
                        decoration: InputDecoration(border: OutlineInputBorder()),
                      )
                    ),
                    ElevatedButton(onPressed: () {
                      products = [];
                      nextPage = 0;
                      itemCount.value = 0;
                      loadNextPage();
                      }, child: Text("Search")),
                    ElevatedButton(onPressed: widget.isLogged ? () {widget.goto(2);} : null, child: Text("Carrito")),
                  ],
                ),
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: itemCount,
                    builder: (BuildContext context, int value, Widget? child) {
                      return buildProducts(products, widget.isLogged, widget.goto);
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

  Widget buildProducts(List<Product> products, bool isLogged, Function goto) => ListView.builder(
      itemCount: itemCount.value,
      itemBuilder: (context, index) {
      final product = getProductAtIndex(index);

      return Card(
        child: Column(
          children: [
            ListTile(
              leading: Image.network("http://l0nk5erver.duckdns.org:5000/products/img/${product.id}.png",
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
              title: Text(product.name),
              subtitle: Text(product.brand),
            ),
            Row(
              children: [SizedBox(width: 15,),
                Text(product.description),
              ],
            ),
            Row(
              children: [SizedBox(width: 15,),
                Text("✰${product.rating}"),
              ],
            ),
            Row(
              children: [SizedBox(width: 15,),
                Text(product.discount == 0 ? "\$${product.price.toStringAsFixed(2)}" : ""),
                Text(product.discount != 0 ? "\$${product.price.toStringAsFixed(2)}   " : "", style: TextStyle(decoration: TextDecoration.lineThrough),),
                Text(product.discount != 0 ? "\$${product.discount_type == 'P' ? (product.price * (1-(product.discount*0.01))).toStringAsFixed(2) : (product.price - product.discount).toStringAsFixed(2)}" : ""),
              ],
            ),
            Row( mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () { goto(4, y: product.id); }, 
                  child: Text("Ver mas..."), 
                  ),
            ElevatedButton(
              onPressed: isLogged ? () { addToCart(product, context); } : null, 
              child: Text("Al carrito"), 
              ) 
              ],
            ),
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