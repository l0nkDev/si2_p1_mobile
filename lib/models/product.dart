class Product {
  final int id;
  final String name;
  final String brand;
  final String description;
  final double rating;
  final double price;
  final double discount;
  final String discount_type;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.rating,
    required this.price,
    required this.discount,
    required this.discount_type,
    required this.stock
  });

  static Product fromJson(json) => Product(
    id: json['id'],
    name: json['name'],
    brand: json['brand'],
    description: json['description'],
    rating: double.parse(json['rating']),
    price: double.parse(json['price']),
    discount: double.parse(json['discount']),
    discount_type: json['discount_type'],
    stock: json['stock']
  );
}