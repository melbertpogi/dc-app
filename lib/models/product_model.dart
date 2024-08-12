class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String imageUrl;
  final List<String> sizes;
  final String sellerId; // Add sellerId to the Product model

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.sizes,
    required this.sellerId,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Product(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      quantity: data['quantity']?.toInt() ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      sellerId: data['sellerId'] ?? '', // Assign sellerId
    );
  }
}
