import 'package:flutter/material.dart';
import 'package:dbase/DB/inventory_database.dart';
import 'package:dbase/Model/products.dart';


class SalesPage extends StatelessWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales'),
      ),
      body: FutureBuilder<List<Purchase>>(
        future: ACDatabase.instance.getAllPurchases(),
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
}
