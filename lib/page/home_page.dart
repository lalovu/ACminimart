import 'package:flutter/material.dart';
import 'package:dbase/page/add_product.dart';
import 'package:dbase/page/product_inventory_page.dart'; // Import the ProductsPage widget

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
                // Navigate to AddProductPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AddProductPage()),
                );
              },
              child: const Text('Add Products'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to ProductsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsPage()),
                );
              },
              child: const Text('View Products'),
            ),
            // You can add more buttons or UI elements here
          ],
        ),
      ),
    );
  }
}
