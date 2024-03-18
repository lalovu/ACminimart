import 'package:flutter/material.dart';
import 'package:dbase/page/add_product.dart';
import 'package:dbase/page/saved_products.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
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
                  MaterialPageRoute(builder: (context) => AddProductPage()),
                );
              },
              child: Text('Add Product'),
            ),
            SizedBox(height: 20), // Add some spacing
            ElevatedButton(
              onPressed: () {
                // Navigate to SavedProductsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedProductsPage()),
                );
              },
              child: Text('View Saved Products'),
            ),
            // You can add more buttons or UI elements here
          ],
        ),
      ),
    );
  }
}

