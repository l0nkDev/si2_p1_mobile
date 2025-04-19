class PurchaseItem {
  final int id;
  final String name;
  final String brand;
  final double rating;
  final double price;
  final double dprice;
  final double fprice;
  final int productid;
  final int quantity;

  const PurchaseItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.rating,
    required this.price,
    required this.dprice,
    required this.fprice,
    required this.productid,
    required this.quantity,
  });

  static PurchaseItem fromJson(json) => PurchaseItem(
    id: json['id'],
    name: json['name'],
    brand: json['brand'],
    rating: double.parse(json['rating']),
    price: double.parse(json['price']),
    dprice: double.parse(json['dprice']),
    fprice: double.parse(json['fprice']),
    productid: json['productid'],
    quantity: json['quantity'],
  );
}