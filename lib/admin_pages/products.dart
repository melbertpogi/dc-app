import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minmalecommerce/admin_pages/admin_components/admin_drawer.dart';
import 'package:minmalecommerce/admin_pages/admin_components/admin_product_tile.dart';
import 'package:minmalecommerce/models/product_model.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:minmalecommerce/utils/scroller.dart';
import 'package:minmalecommerce/utils/utils.dart';

class Products extends StatelessWidget {
  Products({super.key});

  static String id = '/Products';

  Future<List<Product>> _fetchUserProducts() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('added_products')
        .where('sellerId', isEqualTo: user.uid)
        .get();

    return querySnapshot.docs.map((doc) {
      return Product.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: AdminDrawer(),
      body: FutureBuilder<List<Product>>(
        future: _fetchUserProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          } else {
            final products = snapshot.data!;
            return ListView(
              children: [
                SizedBox(
                  height: Utils.getScreenHeight(context) * 0.025,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      bottom: Utils.getScreenHeight(context) * 0.015),
                  child: Center(
                    child: Text(
                      " ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ),
                ),
                ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: SizedBox(
                    height:
                    UniversalPlatform.isDesktop || UniversalPlatform.isWeb
                        ? Utils.getScreenHeight(context) > 500
                        ? Utils.getScreenHeight(context) * 0.80
                        : Utils.getScreenHeight(context) * 0.70
                        : Utils.getScreenHeight(context) * 0.68,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                          horizontal: Utils.getScreenWidth(context) * 0.03,
                          vertical: Utils.getScreenWidth(context) * 0.005),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return AdminProductTile(product: product);
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
