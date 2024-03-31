import 'package:flutter/material.dart';
import 'package:dbase/DB/inventory_database.dart';
import 'package:dbase/Model/products.dart';

class POSPage extends StatefulWidget {
  const POSPage({Key? key}) : super(key: key);

  @override
  _POSPageState createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  String _customerName = '';
  String _customerEmail = '';
  int _selectedProductId = -1; // Initialize with -1
  int _quantity = 0;
  late DateTime _selectedDate;

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerEmailController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _clearFields() {
    setState(() {
      _customerName = '';
      _customerEmail = '';
      _selectedProductId = -1; // Reset to -1
      _quantity = 0;
    });

    _customerNameController.clear();
    _customerEmailController.clear();
    _quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Point of Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(labelText: 'Customer Name'),
              onChanged: (value) {
                setState(() {
                  _customerName = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _customerEmailController,
              decoration: InputDecoration(labelText: 'Customer Email'),
              onChanged: (value) {
                setState(() {
                  _customerEmail = value;
                });
              },
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Products>>(
              future: ACDatabase.instance.getAllProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final products = snapshot.data!;
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedProductId,
                            onChanged: (int? productId) {
                              setState(() {
                                _selectedProductId = productId ?? -1;
                              });
                            },
                            items: [
                              DropdownMenuItem<int>(
                                value: -1,
                                child: Text('Select Product'),
                              ),
                              ...products.map<DropdownMenuItem<int>>((product) {
                                return DropdownMenuItem<int>(
                                  value: product.id!,
                                  child: Text(product.name),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          final selectedProductId = await showSearch(
                            context: context,
                            delegate: ProductSearchDelegate(products),
                          );
                          if (selectedProductId != null && selectedProductId != -1) {
                            setState(() {
                              _selectedProductId = selectedProductId;
                            });
                          }
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  if (int.tryParse(value) != null && int.parse(value) > 0) {
                    _quantity = int.parse(value);
                  } else {
                    _quantity = 0;
                  }
                });
              },
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () {
                _selectDate(context);
              },
              child: Row(
                children: [
                  Text('Purchase Date: '),
                  Text(
                    '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedProductId != -1) { // Check for -1
                    if (_customerName.isNotEmpty || _customerEmail.isNotEmpty) {
                      if (_quantity > 0) {
                        final newCustomer = Customers(name: _customerName, email: _customerEmail);
                        final createdCustomer = await ACDatabase.instance.createCustomers(newCustomer);
                        final customerId = createdCustomer.id ?? 0;
                        final product = await ACDatabase.instance.getProduct(_selectedProductId);

                        if (product != null && product.quantity >= _quantity) {
                          final purchase = Purchase(
                            customerId: customerId,
                            productId: _selectedProductId,
                            quantity: _quantity,
                            price: 0.0,
                            createdTime: _selectedDate,
                          );

                          final purchaseId = await ACDatabase.instance.createPurchase(purchase);
                          final totalPrice = product.price * _quantity;

                          await ACDatabase.instance.updatePurchasePrice(purchaseId, totalPrice);
                          await ACDatabase.instance.updateProductQuantity(
                              _selectedProductId, product.quantity - _quantity);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Purchase successful!'),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          _clearFields(); // Clear fields after successful purchase
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No Stock Available'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Incorrect quantity. Please enter a positive number.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please Provide Customer Details'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a product.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text('Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
}

class ProductSearchDelegate extends SearchDelegate<int> {
  final List<Products> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, -1);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Products> results = products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          onTap: () {
            // Don't close here, just return the selected product id
            Navigator.of(context).pop(results[index].id!);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Products> suggestions = products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].name),
          onTap: () {
            query = suggestions[index].name;
            showResults(context);
          },
        );
      },
    );
  }
}
