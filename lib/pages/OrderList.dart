import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minmalecommerce/models/product_model.dart';
import 'package:minmalecommerce/pages/shop_page.dart';
import 'package:provider/provider.dart';

import '../models/shop_model.dart';
import 'Receipt.dart';

class OrderListScreen extends StatefulWidget {
  final List<Product> cartItems;

  const OrderListScreen({
    Key? key,
    required this.cartItems,
  }) : super(key: key);

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  User? _currentUser;
  Map<String, dynamic>? _customerInfo;
  Map<String, Map<String, dynamic>> _sellerInfo = {};

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

    for (var product in widget.cartItems) {
      final productDoc = await FirebaseFirestore.instance
          .collection('added_products')
          .doc(product.id)
          .get();

      if (productDoc.exists) {
        final sellerInfo = productDoc.data();
        final sellerEmail = sellerInfo?['sellerEmail'] ?? 'Unknown';
        if (!_sellerInfo.containsKey(sellerEmail)) {
          _sellerInfo[sellerEmail] = sellerInfo!;
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedFile;
    });
  }

  Future<void> uploadTransaction(BuildContext context, double totalPrice) async {
    try {
      List<Map<String, dynamic>> items = [];
      for (var item in widget.cartItems) {
        final productDoc = await FirebaseFirestore.instance
            .collection('added_products')
            .doc(item.id)
            .get();

        String sellerEmail = 'Unknown';
        if (productDoc.exists) {
          final sellerInfo = productDoc.data();
          sellerEmail = sellerInfo?['sellerEmail'] ?? 'Unknown';
        }

        items.add({
          'itemName': item.name,
          'itemPrice': item.price,
          'itemQuantity': item.quantity,
          'totalItemPrice': item.price * item.quantity,
          'sellerEmail': sellerEmail,
        });
      }

      await FirebaseFirestore.instance.collection('transaction_list').add({
        'items': items,
        'totalPrice': totalPrice,
        'timestamp': Timestamp.now(),
        'userEmail': _currentUser?.email ?? 'Unknown',
      });

      print('Transaction uploaded successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction uploaded successfully')),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Transaction uploaded successfully'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ShopPage()),
                );
                context.read<Shop>().clearCart();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      print('Error uploading transaction: $error');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Error uploading transaction'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cartItems.fold(
        0, (sum, item) => sum + item.price * item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text("Customer Information", style: TextStyle(fontWeight: FontWeight.bold),),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            _customerInfo != null
                                ? _customerInfo!['name'] ?? 'No user name'
                                : 'Loading...',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.home, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        _customerInfo != null
                            ? _customerInfo!['homeAddress'] ?? 'No address'
                            : 'Loading...',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text("Seller Information", style: TextStyle(fontWeight: FontWeight.bold),),
                      for (var sellerEmail in _sellerInfo.keys)
                        Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.email, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  sellerEmail,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.store, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  _sellerInfo[sellerEmail] != null
                                      ? _sellerInfo[sellerEmail]!['address'] ?? 'No seller address'
                                      : 'Loading...',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.black),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  final totalItemPrice = item.price * item.quantity;
                  return ListTile(
                    leading: GestureDetector(
                      onTap: _pickImage,
                      child: _pickedImage == null
                          ? Image.network(
                        item.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : Image.file(
                        File(_pickedImage!.path),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontSize: 18)),
                        Text('Qty: ${item.quantity}',
                            style: const TextStyle(fontSize: 16)),
                        Text('P${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    trailing: Text(
                      'P${totalItemPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.black),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Total Price: P${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await uploadTransaction(context, totalPrice);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptScreen(
                      cartItems: widget.cartItems,
                      totalPrice: totalPrice,
                    ),
                  ),
                );
              },
              child: const Text('Order Now'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
