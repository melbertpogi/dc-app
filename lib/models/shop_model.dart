import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:minmalecommerce/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Shop extends ChangeNotifier {
  // Products for sale
  List<Product> _shop = [];

  // User cart
  final List<Product> _cart = [];

  Shop() {
    fetchProducts();
  }

  // Get products list
  List<Product> get shop => _shop;

  // Get user cart
  List<Product> get cart => _cart;

  // Add item to cart or increment quantity if already in cart
  void addToCart({required Product item}) async {
    final index = _cart.indexWhere((product) => product.id == item.id);
    if (index == -1) {
      _cart.add(Product(
        id: item.id,
        name: item.name,
        price: item.price,
        description: item.description,
        quantity: 1,
        imageUrl: item.imageUrl,
        sellerId: item.sellerId,
        sizes: item.sizes,
      ));
    } else {
      _cart[index] = Product(
        id: item.id,
        name: item.name,
        price: item.price,
        description: item.description,
        quantity: _cart[index].quantity + 1,
        imageUrl: item.imageUrl,
        sellerId: item.sellerId,
        sizes: item.sizes,
      );
    }
    notifyListeners();

    // Update the quantity in Firestore
    await _updateProductQuantity(item.id, -1);
  }

  void incrementCartItem({required Product item}) async {
    final index = _cart.indexWhere((product) => product.id == item.id);
    if (index != -1) {
      final availableQuantity = await getMaxQuantity(item);
      // Update the quantity only if there's available stock in Firestore
      if (availableQuantity > 0) {
        _cart[index] = Product(
          id: item.id,
          name: item.name,
          price: item.price,
          description: item.description,
          quantity: _cart[index].quantity + 1,
          imageUrl: item.imageUrl,
          sellerId: item.sellerId,
          sizes: item.sizes,
        );
        notifyListeners();

        // Update the quantity in Firestore
        await _updateProductQuantity(item.id, -1);
      }
    }
  }

  void decrementCartItem({required Product item}) async {
    final index = _cart.indexWhere((product) => product.id == item.id);
    if (index != -1) {
      if (_cart[index].quantity > 1) {
        _cart[index] = Product(
          id: item.id,
          name: item.name,
          price: item.price,
          description: item.description,
          quantity: _cart[index].quantity - 1,
          imageUrl: item.imageUrl,
          sellerId: item.sellerId,
          sizes: item.sizes,
        );
        await _updateProductQuantity(item.id, 1);
      } else {
        _cart.removeAt(index);
        await _updateProductQuantity(item.id, 1);
      }
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Fetch products from Firestore
  Future<void> fetchProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final collection = FirebaseFirestore.instance.collection('added_products');
    final query = collection.where('sellerId', isEqualTo: user.uid);

    // Listen for realtime updates
    query.snapshots().listen((snapshot) {
      _shop = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id, // Use the document ID as the product ID
          name: data['name'] ?? '',
          price: data['price']?.toDouble() ?? 0.0,
          description: data['description'] ?? '',
          quantity: data['quantity'] ?? 0,
          imageUrl: data['imageUrl'] ?? '',
          sellerId: data['sellerId'] ?? '',
          sizes: List<String>.from(data['sizes'] ?? []), // Assuming sizes is a list of strings
        );
      }).toList();
      notifyListeners();
    });
  }

  // Update product quantity in Firestore
  Future<void> _updateProductQuantity(String productId, int change) async {
    final doc = FirebaseFirestore.instance.collection('added_products').doc(productId);
    final snapshot = await doc.get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final newQuantity = (data['quantity'] ?? 0) + change;
      if (newQuantity >= 0) {
        await doc.update({'quantity': newQuantity});
      }
    }
  }

  // Get max quantity from Firestore
  Future<int> getMaxQuantity(Product product) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('added_products')
        .doc(product.id)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['quantity'] ?? 0;
    } else {
      return 0;
    }
  }

  // Add this method in the Shop class
  Future<Product?> getProductById(String productId) async {
    final doc = await FirebaseFirestore.instance.collection('added_products').doc(productId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return Product(
        id: doc.id,
        name: data['name'] ?? '',
        description: data['description'] ?? '',
        price: data['price']?.toDouble() ?? 0.0,
        quantity: data['quantity'] ?? 0,
        imageUrl: data['imageUrl'] ?? '',
        sellerId: data['sellerId'] ?? '',
        sizes: List<String>.from(data['sizes'] ?? []),
      );
    }
    return null;
  }

  Stream<List<Product>> getAllProductsStream() {
    return FirebaseFirestore.instance
        .collection('added_products')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Product.fromFirestore(doc.data(), doc.id))
        .toList());
  }
}
