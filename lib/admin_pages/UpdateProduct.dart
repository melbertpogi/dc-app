import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/button.dart';
import 'Notification.dart';

class UpdateProductPage extends StatefulWidget {
  final String productId;

  const UpdateProductPage({Key? key, required this.productId}) : super(key: key);

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController itemDescriptionController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProduct(widget.productId);
  }

  Future<void> _fetchProduct(String productId) async {
    setState(() {
      _isLoading = true;
    });

    final doc = await FirebaseFirestore.instance.collection('added_products').doc(productId).get();
    if (doc.exists) {
      final data = doc.data()!;
      itemDescriptionController.text = data['description'] ?? '';
      itemPriceController.text = data['price']?.toString() ?? '0.0';
      itemQtyController.text = data['quantity']?.toString() ?? '0';
      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProduct(String productId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = FirebaseFirestore.instance.collection('added_products').doc(productId);

      String? imageUrl;
      if (_image != null) {
        final storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(_image!);
        await uploadTask.whenComplete(() => null);
        imageUrl = await storageRef.getDownloadURL();
      }

      final data = {
        'description': itemDescriptionController.text,
        'price': double.tryParse(itemPriceController.text) ?? 0.0,
        'quantity': int.tryParse(itemQtyController.text) ?? 0,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      await doc.update(data);

      itemDescriptionController.clear();
      itemPriceController.clear();
      itemQtyController.clear();
      _image = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );

      // Show confirmation dialog
      _showConfirmationDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Complete'),
        content: const Text('Are you done updating the product?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Update an Existing Product",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StyleButton(
                onTap: () async {
                  final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                },
                text: 'Upload New Image',
              ),
              const SizedBox(height: 10),
              _image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              TextFormField(
                controller: itemDescriptionController,
                decoration: const InputDecoration(labelText: 'Item Description'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: itemPriceController,
                decoration: const InputDecoration(labelText: 'Item Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: itemQtyController,
                decoration: const InputDecoration(labelText: 'Item Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : StyleButton(
                onTap: () => _updateProduct(widget.productId),
                text: 'Update Product',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
