import 'package:flutter/material.dart';
import 'package:dbase/DB/inventory_database.dart';
import 'package:dbase/Model/products.dart';
import 'package:intl/intl.dart'; // Import DateFormat

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
    _purchases = ACDatabase.instance.getAllPurchases();
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
                      FutureBuilder<String>(
                        future: _getCustomerName(purchase.customerId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final customerName = snapshot.data!;
                            return Text('Customer: $customerName');
                          }
                        },
                      ),
                      Text('Quantity: ${purchase.quantity}'),
                      Text('Total Price: ₱${purchase.price}'),
                      Text('Date Purchased: ${DateFormat.yMd().format(purchase.createdTime)}'), // Display purchase date
                      ElevatedButton(
                        onPressed: () => _deletePurchase(purchase.id!), // Call delete method
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                  // You can display more information about the purchase if needed
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

  Future<String> _getCustomerName(int customerId) async {
    final customer = await ACDatabase.instance.getCustomer(customerId);
    return customer?.name ?? 'Unknown'; // Return customer name or 'Unknown' if not found
  }

  Future<void> _deletePurchase(int purchaseId) async {
    await ACDatabase.instance.deletePurchase(purchaseId);
    setState(() {
      _purchases = ACDatabase.instance.getAllPurchases(); // Refresh UI after deletion
    });
  }
}
