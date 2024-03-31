import 'package:flutter/material.dart';
import 'package:dbase/DB/inventory_database.dart';
import 'package:dbase/Model/products.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late List<Products> _products = [];
  late List<Category> _categories = [];
  int _selectedCategoryId = 0; // 0 represents "All" option

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch products based on the selected category
    if (_selectedCategoryId == 0) {
      _products = await ACDatabase.instance.getAllProducts();
    } else {
      _products = await ACDatabase.instance.getProductsByCategory(_selectedCategoryId);
    }

    // Fetch all categories
    final categories = await ACDatabase.instance.getAllCategories();
    setState(() {
      _categories = categories;
    });
  }

  List<Products> _getFilteredProducts() {
    if (_selectedCategoryId == 0) {
      // Show all products
      return _products;
    } else {
      // Show products for the selected category
      return _products.where((product) => product.category == _selectedCategoryId).toList();
    }
  }

  Future<void> _showUpdateDialog(Products product) async {
    double newPrice = product.price;
    int newQuantity = product.quantity;
    double newCost = product.cost;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Price: ${product.price}'),
              TextField(
                decoration: InputDecoration(labelText: 'New Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newPrice = double.tryParse(value) ?? product.price;
                },
              ),
              SizedBox(height: 8),
              Text('Current Quantity: ${product.quantity}'),
              TextField(
                decoration: InputDecoration(labelText: 'New Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newQuantity = int.tryParse(value) ?? product.quantity;
                }, 
              ),
              Text('Current Cost: ${product.cost}'),
              TextField(
                decoration: InputDecoration(labelText: 'New Cost'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newCost = double.tryParse(value) ?? product.cost;
                },
              ),
              
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Update product in the database
                  await ACDatabase.instance.updateProductPrice(product.id!, newPrice);
                  await ACDatabase.instance.updateProductQuantity(product.id!, newQuantity);
                  await ACDatabase.instance.updateProductCost(product.id!, newCost);

                  // Refresh the UI
                  _fetchData();

                  Navigator.pop(context); // Close the bottom sheet
                },
                child: Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: DropdownButton<int>(
              value: _selectedCategoryId,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedCategoryId = newValue ?? 0;
                  _fetchData(); // Update products based on the selected category
                });
              },
              items: [
                DropdownMenuItem<int>(
                  value: 0,
                  child: Text('All'),
                ),
                if (_categories != null) // Add null check here
                  for (var category in _categories)
                    DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getFilteredProducts().length,
              itemBuilder: (context, index) {
                final product = _getFilteredProducts()[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.description),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteProduct(product.id!);
                    },
                  ),
                  onTap: () {
                    _showUpdateDialog(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(int productId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // Return false to indicate cancellation
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true); // Return true to indicate deletion confirmation
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        // Delete the product from the database
        await ACDatabase.instance.deleteProduct(productId);
        // Refresh the UI
        _fetchData();
        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product deleted successfully')),
        );
      } catch (e) {
        // Show an error message if deletion fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product')),
        );
      }
    }
  }
}
