import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dbase/DB/inventory_database.dart';
import 'package:dbase/Model/products.dart';

class SalesAnalyticsPage extends StatefulWidget {
  const SalesAnalyticsPage({Key? key}) : super(key: key);

  @override
  _SalesAnalyticsPageState createState() => _SalesAnalyticsPageState();
}

class _SalesAnalyticsPageState extends State<SalesAnalyticsPage> {
  List<Products> _products = [];
  List<Category> _categories = [];
  Map<int, double> _salesPerProduct = {};
  Map<int, double> _salesPerCategory = {};
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TextEditingController _searchController = TextEditingController();
  int _selectedCategoryId = -1; // Initialize with -1
  bool _showCategorySales = false;
  bool _showOverallSales = false; // Variable to control overall sales section visibility

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await _fetchProductsAndCategories();
      await _calculateSales();
    } catch (e) {
      print("Error fetching data: $e");
      // Handle error, show error message, etc.
    }
  }

  Future<void> _fetchProductsAndCategories() async {
    _products = (await ACDatabase.instance.getAllProducts()) ?? [];
    _categories = (await ACDatabase.instance.getAllCategories()) ?? [];
    await _calculateSalesPerProduct();
    await _calculateSalesPerCategory(_selectedCategoryId);
    setState(() {});
  }

  Future<void> _calculateSales() async {
    await _calculateSalesPerProduct();
    await _calculateSalesPerCategory(_selectedCategoryId);
  }

  Future<void> _calculateSalesPerProduct() async {
    final purchases = (await ACDatabase.instance.getAllPurchases()) ?? [];

    _salesPerProduct.clear();

    for (var product in _products) {
      double productSales = 0.0;

      for (var purchase in purchases) {
        if (product.id == purchase.productId &&
            purchase.createdTime.isAfter(_startDate.subtract(Duration(days: 1))) &&
            purchase.createdTime.isBefore(_endDate.add(Duration(days: 1)))) {
          productSales += purchase.price;
        }
      }

      _salesPerProduct[product.id ?? -1] = productSales;
    }

    setState(() {});
  }

  Future<void> _calculateSalesPerCategory(int categoryId) async {
    final purchases = (await ACDatabase.instance.getAllPurchases()) ?? [];

    _salesPerCategory.clear();

    for (var category in _categories) {
      double categorySales = 0.0;

      for (var product in _products) {
        if (product.category == category.id) {
          for (var purchase in purchases) {
            if (purchase.productId == product.id &&
                purchase.createdTime.isAfter(_startDate.subtract(Duration(days: 1))) &&
                purchase.createdTime.isBefore(_endDate.add(Duration(days: 1)))) {
              categorySales += purchase.price;
            }
          }
        }
      }

      _salesPerCategory[category.id ?? -1] = categorySales;
    }

    setState(() {});
  }

  Widget _buildDateSelectionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime(2000),
              lastDate: _endDate, // Set the last date as the selected end date
            );

            if (date != null) {
              setState(() {
                _startDate = date;
              });
              await _calculateSalesPerProduct();
              await _calculateSalesPerCategory(_selectedCategoryId);
            }
          },
          child: Text('Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}'),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _endDate,
              firstDate: _startDate,
              lastDate: DateTime.now(),
            );

            if (date != null) {
              setState(() {
                _endDate = date;
              });
              await _calculateSalesPerProduct();
              await _calculateSalesPerCategory(_selectedCategoryId);
            }
          },
          child: Text('End Date: ${DateFormat('yyyy-MM-dd').format(_endDate)}'),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Center(
      child: DropdownButton<int>(
        value: _selectedCategoryId,
        onChanged: (value) async {
          setState(() {
            _selectedCategoryId = value!;
          });
          await _calculateSalesPerCategory(value!);
        },
        items: [
          DropdownMenuItem<int>(
            value: -1,
            child: Text('All Categories'),
          ),
          if (_categories.isNotEmpty)
            for (var category in _categories)
              if (_products.any((product) => product.category == category.id))
                DropdownMenuItem<int>(
                  value: category.id!,
                  child: Text(category.name ?? ''),
                ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) async {
                await _searchProducts(value);
              },
              decoration: InputDecoration(
                hintText: 'Search for a product',
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              await _searchProducts(_searchController.text);
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      await _fetchProductsAndCategories();
    } else {
      final searchedProducts = _products.where((product) => product.name?.toLowerCase().contains(query.toLowerCase()) ?? false).toList();
      setState(() {
        _products = searchedProducts;
      });
      await _calculateSalesPerProduct();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Analytics'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateSelectionButtons(context),
          _buildCategoryDropdown(),
          _buildSearchBar(context),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final productSales = _salesPerProduct[product.id ?? -1] ?? 0.0;
                final grossProfit = _calculateGrossProfit(product.id ?? -1, productSales);
                final categoryName = _categories.firstWhere((category) => category.id == product.category, orElse: () => Category(id: 0, name: ''));

                final isProductInSelectedCategory = (_selectedCategoryId == -1 || product.category == _selectedCategoryId);

                return isProductInSelectedCategory ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(product.name ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sales: ₱${productSales.toStringAsFixed(2)}'),
                          Text('Category: ${categoryName.name}'),
                          Text('Gross Profit: ₱${grossProfit.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                ) : SizedBox.shrink();
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showCategorySales = !_showCategorySales;
                    _showOverallSales = false; // Ensure only one section is visible
                  });
                },
                child: Text(_showCategorySales ? 'Hide Category Sales' : 'Show Category Sales'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showOverallSales = !_showOverallSales;
                    _showCategorySales = false; // Ensure only one section is visible
                  });
                },
                child: Text(_showOverallSales ? 'Hide Overall Sales' : 'Show Overall Sales'),
              ),
            ],
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: _showCategorySales ? MediaQuery.of(context).size.height * 0.5 : 0,
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final categorySales = _salesPerCategory[category.id ?? -1] ?? 0.0;
                final categoryProducts = _products.where((product) => product.category == category.id).toList();
                final totalCostPerCategory = categoryProducts.fold<double>(0, (previous, current) => previous + (current.cost ?? 0));

                final grossProfit = categorySales - totalCostPerCategory;

                return ListTile(
                  title: Text(category.name ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Sales: ₱${categorySales.toStringAsFixed(2)}'),
                      Text('Gross Profit: ₱${grossProfit.toStringAsFixed(2)}'),
                    ],
                  ),
                );
              },
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: _showOverallSales ? MediaQuery.of(context).size.height * 0.5 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Sales',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Total Sales: ₱${_calculateOverallSales().toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateGrossProfit(int productId, double sales) {
    final product = _products.firstWhere((product) => product.id == productId, orElse: () => Products(id: 0, name: '', description: '', category: 0, quantity: 0, price: 0.0, cost: 0.0));
    return sales - (product.cost ?? 0.0);
  }

  double _calculateOverallSales() {
    double overallSales = 0.0;
    _salesPerCategory.values.forEach((sales) {
      overallSales += sales;
    });
    return overallSales;
  }
}
