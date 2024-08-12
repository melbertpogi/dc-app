import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:rounded_expansion_tile/rounded_expansion_tile.dart'; // Import rounded_expansion_tile package

class TransactionListPageAdmin extends StatefulWidget {
  static const String id = '/transaction_list';

  @override
  _TransactionListPageAdminState createState() => _TransactionListPageAdminState();
}

class _TransactionListPageAdminState extends State<TransactionListPageAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Transaction List'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('transaction_list')
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

          // Sort the transactions by timestamp in descending order
          var transactions = snapshot.data!.docs;
          transactions.sort((a, b) {
            var aTimestamp = a['timestamp'] as Timestamp;
            var bTimestamp = b['timestamp'] as Timestamp;
            return bTimestamp.compareTo(aTimestamp);
          });

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];
              var userEmail = transaction['userEmail']; // Get user email

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

              return Card(
                child: RoundedExpansionTile(
                  leading: Icon(Icons.receipt),
                  title: Text(userEmail),
                  children: [
                    ListTile(
                      title: Text('Transaction on $formattedDate'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Price"),
                              Text('P$totalPrice', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8.0), // Add some spacing
                          Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, itemIndex) {
                              var item = items[itemIndex];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Item Name"),
                                        Text('${item['itemName']}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Item Price"),
                                        Text('${item['itemPrice']}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Item Quantity"),
                                        Text('${item['itemQuantity']}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Total Item Price"),
                                        Text('${item['totalItemPrice']}'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Seller Email"),
                                        Text('${item['sellerEmail']}'), // Display sellerEmail
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
