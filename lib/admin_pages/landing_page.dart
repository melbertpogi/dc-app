import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minmalecommerce/admin_pages/admin_components/admin_drawer.dart';
import 'package:minmalecommerce/components/button.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ManuallyUpdate.dart';
import 'Notification.dart';

class LandingPage extends StatefulWidget {
  LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController itemName = TextEditingController();
  final TextEditingController itemDescription = TextEditingController();
  final TextEditingController itemPrice = TextEditingController();
  final TextEditingController itemQty = TextEditingController();
  final TextEditingController itemAddress = TextEditingController();
  File? _image;
  bool _isLoading = false;
  final List<String> _selectedSizes = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static String id = '/Landing_page';

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final sellerProfileDoc = await FirebaseFirestore.instance
        .collection('seller_profiles')
        .doc(user.uid)
        .get();

    if (sellerProfileDoc.exists) {
      setState(() {
        itemAddress.text = sellerProfileDoc['homeAddress'] ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller profile not found')),
      );
    }
  }

  Future<void> _addProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Upload image to Firebase Storage
      final imageFile = _image;
      if (imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick an image first')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() => null);

      final imageUrl = await storageRef.getDownloadURL();

      // Save product data to Firestore
      final collection =
      FirebaseFirestore.instance.collection('added_products');
      final data = {
        'name': itemName.text,
        'description': itemDescription.text,
        'price': double.tryParse(itemPrice.text) ?? 0.0,
        'quantity': int.tryParse(itemQty.text) ?? 0,
        'imageUrl': imageUrl,
        'sizes': _selectedSizes,
        'sellerId': user.uid, // Add seller's UID
        'sellerEmail': user.email, // Optionally add seller's email
        'address': itemAddress.text, // Add address field
      };

      await collection.add(data);

      itemName.clear();
      itemDescription.clear();
      itemPrice.clear();
      itemQty.clear();
      itemAddress.clear();
      _image = null;
      _selectedSizes.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        actions: [
          IconButton(
            onPressed: () {
              // Handle edit action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManUpdateProductPage()),
              );
            },
            icon: const Icon(
              FontAwesomeIcons.edit,
              color: Colors.brown,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('added_products')
                .where('quantity', isEqualTo: 0)
                .snapshots(),
            builder: (context, snapshot) {
              int notificationCount = 0;
              if (snapshot.hasData) {
                notificationCount = snapshot.data!.docs.length;
              }
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationPage()),
                  );
                },
                icon: Stack(
                  children: [
                    const Icon(
                      FontAwesomeIcons.bell,
                      color: Colors.brown,
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: AdminDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Add a New Product",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StyleButton(
                onTap: () async {
                  final pickedFile =
                  await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                },
                text: 'Upload Image',
              ),
              const SizedBox(height: 10),
              // Image Preview
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
                controller: itemName,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: itemDescription,
                decoration:
                const InputDecoration(labelText: 'Item Description'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: itemPrice,
                decoration: const InputDecoration(labelText: 'Item Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: itemQty,
                decoration: const InputDecoration(labelText: 'Item Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: itemAddress,
                decoration: const InputDecoration(labelText: 'Shop Address'),
              ),
              const SizedBox(height: 10),
              MultiSelectDialogField(
                items: [
                  MultiSelectItem('Small', 'Small'),
                  MultiSelectItem('Medium', 'Medium'),
                  MultiSelectItem('Large', 'Large'),
                  MultiSelectItem('XL', 'XL'),
                ],
                title: const Text('Select Sizes'),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                buttonIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blue,
                ),
                buttonText: const Text(
                  'Select Sizes',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
                onConfirm: (values) {
                  setState(() {
                    _selectedSizes.clear();
                    _selectedSizes.addAll(values.cast<String>());
                  });
                },
                chipDisplay: MultiSelectChipDisplay(
                  onTap: (item) {
                    setState(() {
                      _selectedSizes.remove(item);
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : StyleButton(
                onTap: _addProduct,
                text: 'Add Product',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
