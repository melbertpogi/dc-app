import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minmalecommerce/pages/shop_page.dart';
import '../models/product_model.dart';

class ReceiptScreen extends StatefulWidget {
  final List<Product> cartItems;
  final double totalPrice;

  const ReceiptScreen({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  User? _currentUser;
  Map<String, dynamic>? _customerInfo;
  Map<String, dynamic>? _sellerInfo;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchCustomerInfo();
    _fetchSellerInfo();
  }

  Future<void> _fetchCustomerInfo() async {
    if (_currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(_currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _customerInfo = userDoc.data();
      });
    }
  }

  Future<void> _fetchSellerInfo() async {
    if (widget.cartItems.isEmpty) return;

    final productDoc = await FirebaseFirestore.instance
        .collection('added_products')
        .doc(widget.cartItems.first.id)
        .get();

    if (productDoc.exists) {
      setState(() {
        _sellerInfo = productDoc.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with user information
              const Text(
                'Customer Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('User Email: ${FirebaseAuth.instance.currentUser?.email ?? 'Unknown'}'),
              Text('User Name: ${FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown'}'),
              Text('Home Address: ${_customerInfo?['homeAddress'] ?? 'Loading...'}'),
              const Divider(),
              // Seller information
              const Text(
                'Seller Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Seller Email: ${_sellerInfo?['sellerEmail'] ?? 'Loading...'}'),
              Text('Seller Address: ${_sellerInfo?['address'] ?? 'Loading...'}'),
              const Divider(),
              // Product details section
              const Text(
                'Product Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  final totalItemPrice = item.price * item.quantity;
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qty: ${item.quantity}'),
                        Text('Unit Price: P${item.price.toStringAsFixed(2)}'),
                        Text('Total Price: P${totalItemPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),
              // Total price section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'P${widget.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Add some space between the total price and the button
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShopPage()),
              );
            },
            child: const Text('Go Home'),
          ),
        ),
      ),
    );
  }
}
