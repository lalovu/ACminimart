import 'package:flutter/material.dart';
import 'package:dbase/DB/inventory_database.dart';
import 'package:dbase/Model/products.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _selectedCategoryId;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              _buildCategoryDropdown(),
              SizedBox(height: 10),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cost'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _addProduct();
                },
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchCategories() async {
  final categories = await ACDatabase.instance.getAllCategories();
  
  // Convert the list of categories to a set to eliminate duplicates, then back to a list
  final uniqueCategories = categories.toSet().toList();
  
  setState(() {
    _categories = uniqueCategories;
  });
}


  Widget _buildCategoryDropdown() {
  return Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          onChanged: (int? newValue) {
            setState(() {
              _selectedCategoryId = newValue;
            });
          },
          items: _categories.map((category) {
            return DropdownMenuItem<int>(
              value: category.id,
              child: SizedBox(
                width: 200, // Adjust the width as needed
                child: Row(
                  children: [
                    Expanded(child: Text(category.name)),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteCategory(category.id!);
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(labelText: 'Category'),
        ),
      ),
      SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {
          _addNewCategory(context);
        },
        child: Text('Add New'),
      ),
    ],
  );
}




  void _addProduct() async {
  final String name = _nameController.text;
  final String description = _descriptionController.text;
  final int quantity = int.tryParse(_quantityController.text) ?? 0;
  final double price = double.tryParse(_priceController.text) ?? 0.0;
  final double cost = double.tryParse(_costController.text) ?? 0.0;

  if (name.isNotEmpty &&
      description.isNotEmpty &&
      _selectedCategoryId != null &&
      quantity > 0 &&
      price > 0 &&
      cost > 0) {
    final product = Products(
      name: name,
      description: description,
      category: _selectedCategoryId!,
      quantity: quantity,
      cost: cost,
      price: price,
    );

    try {
      final newProduct = await ACDatabase.instance.createProducts(product);
      print('Product added successfully with ID: ${newProduct.id}');
      _showSnackbar('Product added successfully');
      Navigator.pop(context);
    } catch (e) {
      print('Failed to add product: $e');
      _showSnackbar('Failed to add product');
    }
  } else {
    _showSnackbar('Please enter valid product details');
  }
}

void _showSnackbar(String message) {
  WidgetsBinding.instance?.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  });
}

  Future<void> _addNewCategory(BuildContext context) async {
  final TextEditingController categoryNameController = TextEditingController();

  final result = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add New Category'),
      content: TextField(
        controller: categoryNameController,
        decoration: InputDecoration(labelText: 'Category Name'),
        onChanged: (value) {
          // Automatically convert entered text to uppercase
          categoryNameController.value = TextEditingValue(
            text: value.toUpperCase(),
            selection: TextSelection.collapsed(offset: value.length),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final categoryName = categoryNameController.text.trim(); // Trim any leading or trailing whitespace
            
            if (categoryName.isNotEmpty) {
              // Check if the category already exists
              try {
                final existingCategory = _categories.firstWhere(
                  (category) => category.name.toUpperCase() == categoryName.toUpperCase(),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category already exists')),
                );
                Navigator.pop(context); // Close the dialog
                return; // Exit the method
              } catch (e) {
                // Category does not exist, proceed to add it
              }

              // If the category is unique, add it to the database
              final newCategoryId = await ACDatabase.instance.addCategory(categoryName);
              if (newCategoryId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category added successfully')),
                );
                _fetchCategories(); // Refresh categories after adding a new one
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add category')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter a category name')),
              );
            }
          },
          child: Text('Add'),
        ),
      ],
    ),
  );
}



Future<void> _deleteCategory(int categoryId) async {
  // Retrieve products associated with the category
  final products = await ACDatabase.instance.getProductsByCategory(categoryId);

  if (products.isNotEmpty) {
    // If there are products associated with the category, handle them first
    // For example, you could show a confirmation dialog to ask the user how to handle these products
    // You could either delete the associated products or update them to remove the category association
    // For simplicity, let's assume we want to delete the associated products

    bool confirmDeleteProducts = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Products Associated with Category'),
        content: Text('There are ${products.length} products associated with this category. Delete them as well?'),
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
            child: Text('Delete Products'),
          ),
        ],
      ),
    );

    if (confirmDeleteProducts) {
      // Delete associated products
      for (final product in products) {
        await ACDatabase.instance.deleteProduct(product.id!);
      }
    } else {
      // User canceled the deletion of products, abort category deletion
      return;
    }
  }

  // If there are no associated products or the user confirmed their deletion, proceed to delete the category
  try {
    await ACDatabase.instance.deleteCategory(categoryId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category deleted successfully')),
    );
    _fetchCategories(); // Refresh categories after deletion
  } catch (e) {
    print('Failed to delete category: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete category')),
    );
  }
}
}