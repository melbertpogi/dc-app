import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minmalecommerce/components/my_button.dart';
import 'package:minmalecommerce/models/product_model.dart';
import 'package:minmalecommerce/models/shop_model.dart';
import 'package:minmalecommerce/pages/OrderList.dart';
import 'package:minmalecommerce/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);
  static String id = "/cart_page";

  void payButtonPressed(BuildContext context) {
    List<Product> cartItems = context.read<Shop>().cart;
    if (cartItems.isEmpty) {
      // Show Snackbar if cart is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot proceed because the cart is empty'),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderListScreen(
            cartItems: cartItems,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Shop>().cart;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.cartArrowDown,
                  size: Utils.getScreenWidth(context) * 0.17 >= 120
                      ? 120
                      : Utils.getScreenWidth(context) * 0.17,
                ),
                SizedBox(
                  height: Utils.getScreenHeight(context) * 0.02,
                ),
                Center(
                  child: Text(
                    "Your Cart is Empty",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: (UniversalPlatform.isDesktop ||
                          UniversalPlatform.isWeb)
                          ? Utils.getScreenWidth(context) * 0.027
                          : Utils.getScreenWidth(context) * 0.04,
                    ),
                  ),
                ),
              ],
            )
                : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                final itemCount = item.quantity;

                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(item.imageUrl), // Corrected from imagePath to imageUrl
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text('P${item.price.toStringAsFixed(2)}'),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<Shop>().decrementCartItem(item: item);
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$itemCount',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        FutureBuilder<int>(
                          future: context.read<Shop>().getMaxQuantity(item),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('Error');
                            } else {
                              final availableQuantity = snapshot.data ?? 0;

                              return IconButton(
                                onPressed: availableQuantity > 0
                                    ? () {
                                  context.read<Shop>().incrementCartItem(item: item);
                                }
                                    : null, // Disable button if quantity in Firestore is 0
                                icon: const Icon(Icons.add),
                                disabledColor: Colors.grey,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: MyButton(
              onTap: cart.isNotEmpty
                  ? () {
                payButtonPressed(context);
              }
                  : null,
              child: const Text("CHECK OUT NOW"),
            ),
          )
        ],
      ),
    );
  }
}
