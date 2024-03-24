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
  int? _selectedProductId; // Change type to int? (nullable)
  int _quantity = 0;
  late DateTime _selectedDate; // Track the selected date

  @override
  void initState() {
    super.initState();
    // Set the default selected date to today's date
    _selectedDate = DateTime.now();
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
              decoration: InputDecoration(labelText: 'Customer Name'),
              onChanged: (value) {
                setState(() {
                  _customerName = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
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
                  return DropdownButton<int>(
                    value: _selectedProductId,
                    onChanged: (int? productId) {
                      setState(() {
                        _selectedProductId = productId;
                      });
                    },
                    items: [
                      // Add a null item as the first item
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Select Product'),
                      ),
                      // Map products to DropdownMenuItem
                      ...products.map<DropdownMenuItem<int>>((product) {
                        return DropdownMenuItem<int>(
                          value: product.id!,
                          child: Text(product.name),
                        );
                      }),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _quantity = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16),
            // Date picker widget
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
                  // Check if a product is selected
                  if (_selectedProductId != null) {
                    // Check if customer details are provided
                    if (_customerName.isNotEmpty || _customerEmail.isNotEmpty) {
                      // Create a new customer
                      final newCustomer = Customers(name: _customerName, email: _customerEmail);
                      final createdCustomer = await ACDatabase.instance.createCustomers(newCustomer);

                      // Get the generated customer ID
                      final customerId = createdCustomer.id ?? 0;

                      final product = await ACDatabase.instance.getProduct(_selectedProductId!);

                      // Create a purchase record in the Purchase table
                      if (product != null && product.quantity >= _quantity) {
                        final purchase = Purchase(
                          customerId: customerId,
                          productId: _selectedProductId!,
                          quantity: _quantity,
                          price: 0.0,
                          createdTime: _selectedDate, // Use the selected date
                        );

                        final purchaseId = await ACDatabase.instance.createPurchase(purchase);

                        final totalPrice = product.price * _quantity;

                        await ACDatabase.instance.updatePurchasePrice(purchaseId, totalPrice);
                        await ACDatabase.instance.updateProductQuantity(
                            _selectedProductId!, product!.quantity - _quantity);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Purchase successful!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        // Show error message if insufficient stock
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No Stock Available'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                                            // Show error message if customer details are not provided
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please Provide Customer Details'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    // Show error message if no product is selected
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

  // Function to display date picker
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

