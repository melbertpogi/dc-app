import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rounded_expansion_tile/rounded_expansion_tile.dart'; // Import rounded_expansion_tile package

class TransactionListPage extends StatelessWidget {
  static const String id = '/transaction_list';

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('transaction_list')
            .where('userEmail', isEqualTo: currentUser?.email)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No transactions found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var transaction = snapshot.data!.docs[index];
              var timestamp = transaction['timestamp'];

              // Convert timestamp to Philippine 12-hour format
              var date = (timestamp as Timestamp).toDate();
              var formattedDate = DateFormat.yMd().add_jm().format(date);

              // Check if 'totalPrice' field exists
              var totalPrice = transaction['totalPrice'] != null
                  ? transaction['totalPrice'].toStringAsFixed(2)
                  : 'N/A';

              // Extract the items array from the transaction document
              var items = transaction['items'] as List<dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundedExpansionTile( // Wrap ListTile with RoundedExpansionTile
                    title: Text('Transaction on $formattedDate'),
                    children: [
                      ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User Email: ${transaction['userEmail']}'),
                            SizedBox(height: 4),
                            Text('Total Price: P$totalPrice'), // Assuming totalPrice is in PHP currency
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          var item = items[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Item Name: ${item['itemName']}'),
                              Text('Item Price: ${item['itemPrice']}'),
                              Text('Item Quantity: ${item['itemQuantity']}'),
                              Text('Total Item Price: ${item['totalItemPrice']}'),
                              Text('Seller Email: ${item['sellerEmail']}'), // Display sellerEmail
                              Divider(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
