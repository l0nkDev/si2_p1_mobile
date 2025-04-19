import 'product.dart';

class Cart {
  final int id;
  final int cartid;
  final int productid;
  final int quantity;
  final Product product;

  const Cart({
    required this.id,
    required this.cartid,
    required this.productid,
    required this.quantity,
    required this.product,
  });

  static Cart fromJson(json) => Cart(
    id: json["id"], 
    cartid: json["cartid"], 
    productid: json["productid"], 
    quantity: json["quantity"], 
    product: Product.fromJson(json["product"])
    );
}