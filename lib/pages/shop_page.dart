import 'package:flutter/material.dart';
// import 'dart:io';
import 'package:universal_platform/universal_platform.dart';
import 'package:minmalecommerce/components/my_drawer.dart';
import 'package:minmalecommerce/components/my_product_tile.dart';
import 'package:minmalecommerce/models/shop_model.dart';
import 'package:minmalecommerce/pages/cart_page.dart';
import 'package:minmalecommerce/utils/scroller.dart';
import 'package:minmalecommerce/utils/utils.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';

class ShopPage extends StatelessWidget {
  static String id = '/shop_page';
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<Shop>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, CartPage.id);
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: MyDrawer(),
      body: ListView(
        children: [
          SizedBox(
            height: Utils.getScreenHeight(context) * 0.025,
          ),
          Padding(
            padding:
                EdgeInsets.only(bottom: Utils.getScreenHeight(context) * 0.015),
            child: Center(
              child: Text(
                "Pick from a Selected list of premium products ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ),
          StreamBuilder<List<Product>>(
            stream: shop.getAllProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final products = snapshot.data ?? [];
                return ScrollConfiguration(
                  behavior: MyCustomScrollBehavior(),
                  child: SizedBox(
                    height:
                        UniversalPlatform.isDesktop || UniversalPlatform.isWeb
                            ? Utils.getScreenHeight(context) > 500
                                ? Utils.getScreenHeight(context) * 0.80
                                : Utils.getScreenHeight(context) * 0.70
                            : Utils.getScreenHeight(context) * 0.68,
                    child: ListView.builder(
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: Utils.getScreenWidth(context) * 0.03,
                        vertical: Utils.getScreenWidth(context) * 0.005,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return MyProductTile(product: product);
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
