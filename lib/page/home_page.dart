import 'package:flutter/material.dart';
import 'package:dbase/page/add_product.dart';
import 'package:dbase/page/product_inventory_page.dart';
import 'package:dbase/page/pos.dart'; 
import 'package:dbase/page/receipt_page.dart'; 
import 'package:dbase/page/sales_analytics_page.dart'; // Import the SalesAnalysisPage widget

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductPage()),
                );
              },
              child: const Text('Add Products'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsPage()),
                );
              },
              child: const Text('View Products'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => POSPage()),
                );
              },
              child: const Text('Point of Sale'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesPage()),
                );
              },
              child: const Text('Receipts'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesAnalyticsPage()),
                );
              },
              child: const Text('Sales Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}
