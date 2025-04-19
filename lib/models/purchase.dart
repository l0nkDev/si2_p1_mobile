import 'purchaseitem.dart';

class Purchase {
  final int id;
  final String delivery_status;
  final String paid_on;
  final String payment_method;
  final String vip;
  final double rating;
  final double total_paid;
  List<PurchaseItem>? items;

  Purchase({
    required this.id,
    required this.delivery_status,
    required this.paid_on,
    required this.payment_method,
    required this.vip,
    required this.rating,
    required this.total_paid,
  });

  static Purchase fromJson(json) => Purchase(
    id: json["id"], 
    delivery_status: json["delivery_status"], 
    paid_on: json["paid_on"], 
    payment_method: json["payment_method"], 
    vip: json["vip"], 
    rating: double.parse(json["rating"]), 
    total_paid: double.parse(json["total_paid"]), 
    //items: json["items"].map<PurchaseItem>(PurchaseItem.fromJson).toList()
    );
}