import 'package:flutter/material.dart';
import 'package:dbase/DB/inventory_database.dart';
import 'package:dbase/Model/products.dart'; 
import 'package:intl/intl.dart';

class SalesAnalyticsPage extends StatefulWidget {
  const SalesAnalyticsPage({Key? key}) : super(key: key);

  @override
  _SalesAnalyticsPageState createState() => _SalesAnalyticsPageState();
}

class _SalesAnalyticsPageState extends State<SalesAnalyticsPage> {
  late List<Products> _products;
  late Map<int, Map<String, double>> _dailySalesMap = {};
  late Map<int, Map<String, double>> _weeklySalesMap = {};

  @override
  void initState() {
    super.initState();
    _fetchProductsAndSales();
  }

  Future<void> _fetchProductsAndSales() async {
    _products = await ACDatabase.instance.getAllProducts();
    await _computeDailySales();
    await _computeWeeklySales();
  }

Future<void> _computeDailySales() async {
  final DateTime now = DateTime.now();
  final DateTime startOfDay = DateTime(now.year, now.month, now.day);
  final DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final DateTime yesterdayStart = startOfDay.subtract(const Duration(days: 1));
  final DateTime yesterdayEnd = endOfDay.subtract(const Duration(days: 1));

  _dailySalesMap = {};

  final List<Purchase> purchases = await ACDatabase.instance.getAllPurchases();
  final List<Purchase> purchasesToday = purchases.where((purchase) =>
      purchase.createdTime.isAfter(startOfDay) && purchase.createdTime.isBefore(endOfDay)).toList();
  final List<Purchase> purchasesYesterday = purchases.where((purchase) =>
    purchase.createdTime.year == yesterdayStart.year &&
    purchase.createdTime.month == yesterdayStart.month &&
    purchase.createdTime.day == yesterdayStart.day).toList();


  // Compute sales for yesterday
  // Compute sales for yesterday only if not already computed
for (var product in _products) {
  final dailySales = _dailySalesMap[product.id];
  if (dailySales == null || dailySales['yesterday'] == null) {
    _dailySalesMap[product.id!] = {
      'yesterday': _aggregateSales(purchasesYesterday, product),
      'today': 0.0, // Set today's sales to 0 initially
    };
  }
}


  // Update today's sales for products purchased today
  for (var purchase in purchasesToday) {
  final product = _products.firstWhere((product) => product.id == purchase.productId);
  final dailySales = _dailySalesMap[purchase.productId];
  if (dailySales != null) {
    dailySales['today'] = (dailySales['today'] ?? 0.0) + purchase.price;
  }
}


  setState(() {});
}


  Future<void> _computeWeeklySales() async {
    final DateTime now = DateTime.now();
    final DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    final DateTime lastWeekStart = startOfWeek.subtract(Duration(days: 7));
    final DateTime lastWeekEnd = endOfWeek.subtract(Duration(days: 7));

    _weeklySalesMap = {};

    final List<Purchase> purchases = await ACDatabase.instance.getAllPurchases();
    final List<Purchase> purchasesThisWeek = purchases.where((purchase) =>
        purchase.createdTime.isAfter(startOfWeek) && purchase.createdTime.isBefore(endOfWeek)).toList();
    final List<Purchase> purchasesLastWeek = purchases.where((purchase) =>
        purchase.createdTime.isAfter(lastWeekStart) && purchase.createdTime.isBefore(lastWeekEnd)).toList();

    _weeklySalesMap = {
      for (var product in _products)
        product.id!: {
          'lastWeek': _aggregateSales(purchasesLastWeek, product),
          'thisWeek': _aggregateSales(purchasesThisWeek, product),
        }
    };

    setState(() {});
  }

  double _aggregateSales(List<Purchase> purchases, Products product) {
    double totalSales = 0.0;
    for (var purchase in purchases) {
      if (product.id == purchase.productId) {
        totalSales += purchase.price;
      }
    }
    return totalSales;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Analytics'),
      ),
      body: _dailySalesMap.isEmpty || _weeklySalesMap.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final dailySales = _dailySalesMap[product.id]!;
                final weeklySales = _weeklySalesMap[product.id]!;

                final todayDateFormatted = DateFormat.yMd().format(DateTime.now());
                final yesterdayDateFormatted = DateFormat.yMd().format(DateTime.now().subtract(Duration(days: 1)));
                final startOfWeekFormatted = DateFormat.yMd().format(
                    DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));
                final endOfWeekFormatted = DateFormat.yMd().format(DateTime.now()
                    .subtract(Duration(days: DateTime.now().weekday - 1))
                    .add(Duration(days: 6)));
                final lastWeekStartFormatted =
                    DateFormat.yMd().format(DateTime.now().subtract(Duration(days: DateTime.now().weekday + 6)));
                final lastWeekEndFormatted =
                    DateFormat.yMd().format(DateTime.now().subtract(Duration(days: DateTime.now().weekday + 1)));

                return ListTile(
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yesterday Sales ($yesterdayDateFormatted): \₱${dailySales['yesterday']!.toStringAsFixed(2)}'),
                      Text('Last Week Sales ($lastWeekStartFormatted - $lastWeekEndFormatted): \₱${weeklySales['lastWeek']!.toStringAsFixed(2)}'),
                      Text('Today Sales ($todayDateFormatted): \₱${dailySales['today']!.toStringAsFixed(2)}'),
                      Text('This Week Sales ($startOfWeekFormatted - $endOfWeekFormatted): \₱${weeklySales['thisWeek']!.toStringAsFixed(2)}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
