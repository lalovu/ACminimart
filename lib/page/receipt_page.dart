import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import DateFormat
import 'package:dbase/DB/inventory_database.dart';
import 'package:dbase/Model/products.dart';


class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late Future<List<Purchase>> _purchases;

  @override
  void initState() {
    super.initState();
    _fetchPurchases(); // Fetch purchases when the widget initializes
  }

  Future<void> _fetchPurchases() async {
    setState(() {
      _purchases = ACDatabase.instance.getAllPurchases(); // Retrieve all purchases from the database
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipts'),
      ),
      body: FutureBuilder<List<Purchase>>(
        future: _purchases,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final purchases = snapshot.data!;
            return ListView.builder(
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final purchase = purchases[index];
                return ListTile(
                  title: FutureBuilder<String>(
                    future: _getProductName(purchase.productId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final productName = snapshot.data!;
                        return Text(productName);
                      }
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${purchase.quantity}'),
                      Text('Total Price: ₱${purchase.price}'),
                      Text('Date Purchased: ${DateFormat.yMd().format(purchase.createdTime)}'), // Display purchase date
                      ElevatedButton(
                        onPressed: () => _confirmDeletePurchase(context, purchase.id!), // Call delete method
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<String> _getProductName(int productId) async {
    final product = await ACDatabase.instance.getProduct(productId);
    return product?.name ?? 'Unknown'; // Return product name or 'Unknown' if not found
  }

  Future<void> _confirmDeletePurchase(BuildContext context, int purchaseId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this purchase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deletePurchase(purchaseId);
    }
  }

  Future<void> _deletePurchase(int purchaseId) async {
    // Get the purchase to know the product and quantity
    final purchase = await ACDatabase.instance.getPurchase(purchaseId);
    if (purchase != null) {
      // Delete the purchase
      await ACDatabase.instance.deletePurchase(purchaseId);
      // Update product quantity
      final product = await ACDatabase.instance.getProduct(purchase.productId);
      if (product != null) {
        final newQuantity = product.quantity + purchase.quantity;
        await ACDatabase.instance.updateProductQuantity(purchase.productId, newQuantity);
      }
      // Re-fetch purchases
      _fetchPurchases();
    }
  }
}
