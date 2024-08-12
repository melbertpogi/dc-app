import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPageUser extends StatelessWidget {
  const NotificationPageUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('added_products')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching notifications'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No new products uploaded'));
          } else {
            final products = snapshot.data!.docs;
            final now = DateTime.now();
            final recentProducts = products.where((product) {
              final createdAt = (product['created_at'] as Timestamp).toDate();
              return now.difference(createdAt).inHours <= 24;
            }).toList();

            if (recentProducts.isEmpty) {
              return const Center(child: Text('No new products uploaded in the last 24 hours'));
            }

            return ListView.builder(
              itemCount: recentProducts.length,
              itemBuilder: (context, index) {
                final product = recentProducts[index];
                final productName = product['name'];

                return ListTile(
                  title: Text('New Product: $productName'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
