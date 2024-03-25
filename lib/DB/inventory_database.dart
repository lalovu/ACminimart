import 'package:dbase/Model/products.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';




class ACDatabase {
 static final ACDatabase instance = ACDatabase._init();


 static Database? _database;


 ACDatabase._init();


 Future<Database> get database async{
   if(_database != null) return _database!;


   _database = await _initDB('ACminimart.db');
   return _database!;


 }


 Future<Database> _initDB(String filePath) async {
   final dbPath = await getDatabasesPath();
   final path = join(dbPath, filePath);


   return await openDatabase(path, version: 1, onCreate: _createDB);
   
 }


 Future _createDB(Database db, int version) async{
   final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
   final textType = 'TEXT NOT NULL';
   final integerType = 'INTEGER NOT NULL';
   final doubleType = 'DOUBLE NOT NULL';


   await db.execute('''
 CREATE TABLE $tableInventory (
 ${ProductFields.id} $idType,
 ${ProductFields.name} $textType,
 ${ProductFields.description} $textType,
 ${ProductFields.category} $integerType,
 ${ProductFields.quantity} $integerType,
 ${ProductFields.price} $doubleType,
 FOREIGN KEY (${ProductFields.category}) REFERENCES $tableCategory(${CategoryFields.id})

)
''');

   await db.execute('''
CREATE TABLE $tableCustomer (
${CustomerFields.id} $idType,
${CustomerFields.name} $textType,
${CustomerFields.email} $textType
)

''');

  await db.execute('''
CREATE TABLE $tableCategory (
  ${CategoryFields.id} $idType,
  ${CategoryFields.name} $textType
)
''');

   await db.execute('''
CREATE TABLE $tablePurchases (
${PurchaseFields.id} $idType,
${PurchaseFields.customerId} $integerType,
${PurchaseFields.productId} $integerType,
${PurchaseFields.quantity} $integerType,
${PurchaseFields.price} $doubleType,
${PurchaseFields.time} $textType,
FOREIGN KEY (${PurchaseFields.customerId}) REFERENCES $tableCustomer(${CustomerFields.id}),
FOREIGN KEY (${PurchaseFields.productId}) REFERENCES $tableInventory(${ProductFields.id})
)
''');

 }



// Create Products

 Future<Products> createProducts(Products product) async {
   final db = await instance.database;

   final id = await db.insert(tableInventory, product.toJson());
   return product.copy(id:id);
 }

// Query of All Products

 Future<List<Products>> getAllProducts() async {
    final db = await instance.database;
    final products = await db.query(tableInventory);
    return products.map((json) => Products.fromJson(json)).toList();
  }


// Inside your ACDatabase class:

Future<Products?> getProduct(int productId) async {
  final db = await instance.database;
  final products = await db.query(
    tableInventory,
    where: '${ProductFields.id} = ?',
    whereArgs: [productId],
  );
  if (products.isNotEmpty) {
    return Products.fromJson(products.first);
  } else {
    return null;
  }
}



Future<int> updateProduct(Products product) async {
  final db = await instance.database;
  return await db.update(
    tableInventory,
    product.toJson(),
    where: '${ProductFields.id} = ?',
    whereArgs: [product.id],
  );
}


Future<void> deleteProduct(int productId) async {
  final db = await instance.database;
  await db.delete(
    tableInventory,
    where: '${ProductFields.id} = ?',
    whereArgs: [productId],
  );
}
 

// Checking of Product


 Future<void> updateProductPrice(int productId, double newPrice) async {
  final db = await instance.database;
  await db.update(
    tableInventory,
    {ProductFields.price: newPrice},
    where: '${ProductFields.id} = ?',
    whereArgs: [productId],
  );
}

Future<void> updateProductQuantity(int productId, int newQuantity) async {
  final db = await instance.database;
  await db.update(
    tableInventory,
    {ProductFields.quantity: newQuantity},
    where: '${ProductFields.id} = ?',
    whereArgs: [productId],
  );
}

 Future<Products?> getProductById(int productId) async {
  final db = await instance.database;
  final List<Map<String, dynamic>> maps = await db.query(
    tableInventory,
    where: '${ProductFields.id} = ?',
    whereArgs: [productId],
  );
  
  if (maps.isNotEmpty) {
    return Products.fromJson(maps.first);
  } else {
    return null; // Return null if product with given ID is not found
  }
}


// Category 

    Future<int> addCategory(String categoryName) async {
  final db = await instance.database;
  return await db.insert(
    tableCategory,
    {CategoryFields.name: categoryName},
  );
}
 
Future<List<Products>> getProductsByCategory(int categoryId) async {
  final db = await instance.database;
  final List<Map<String, dynamic>> result = await db.query(
    tableInventory,
    where: '${ProductFields.category} = ?',
    whereArgs: [categoryId],
  );

  return result.map((json) => Products.fromJson(json)).toList();
}



Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final categories = await db.query(tableCategory);

    return categories.map((json) => Category.fromJson(json)).toList();
  }
  
Future<void> deleteCategory(int categoryId) async {
  final db = await instance.database;
  await db.delete(
    tableCategory,
    where: '${CategoryFields.id} = ?',
    whereArgs: [categoryId],
  );
}



// Create Customer

 Future<Customers> createCustomers(Customers customer) async {
   final db = await instance.database;

   final id = await db.insert(tableCustomer, customer.toJson());
   return customer.copy(id: id);
 }

Future<Customers?> getCustomerByNameAndEmail(String name, String email) async {
  final db = await instance.database;
  final List<Map<String, dynamic>> maps = await db.query(
    tableCustomer,
    where: '${CustomerFields.name} = ? AND ${CustomerFields.email} = ?',
    whereArgs: [name, email],
  );
  
  if (maps.isNotEmpty) {
    return Customers.fromJson(maps.first);
  } else {
    return null; // Return null if customer with given name and email is not found
  }
}

Future<Customers?> getCustomer(int customerId) async {
  final db = await instance.database;
  
  final List<Map<String, dynamic>> maps = await db.query(
    tableCustomer,
    where: '${CustomerFields.id} = ?',
    whereArgs: [customerId],
  );

  if (maps.isNotEmpty) {
    return Customers.fromJson(maps.first);
  } else {
    return null; // Return null if customer with specified ID is not found
  }
}



// Create Purchase (POS)

 Future<int> createPurchase(Purchase purchase) async {
  final db = await instance.database;
  final id = await db.insert(tablePurchases, purchase.toJson());
  return id;
}


Future<void> updatePurchasePrice(int purchaseId, double price) async {
  final db = await instance.database;

  await db.update(
    tablePurchases,
    {PurchaseFields.price: price},
    where: '${PurchaseFields.id} = ?',
    whereArgs: [purchaseId],
  );
}




// Total Sales

 Future<double> getTotalSalesForProduct(int productId) async {
   final db = await instance.database;


   final result = await db.query(
     tablePurchases,
     columns: [
       'SUM(${PurchaseFields.quantity} * ${ProductFields.price}) AS total_sales'
     ],
     where: '${tablePurchases}.${PurchaseFields.productId} = ${tableInventory}.${ProductFields.id}',
     whereArgs: [],
   );


   final totalSales = result.isNotEmpty ? result.first['total_sales'] as double : 0.0;


   return totalSales;
 }

// After Purchase it will deduct 

 Future<void> purchaseProduct(int productId, int quantity) async {
   final db = await instance.database;


   // Get the current quantity of the product
   final product = await db.query(
     tableInventory,
     columns: [ProductFields.quantity],
     where: '${ProductFields.id} = ?',
     whereArgs: [productId],
   );


   if (product.isNotEmpty) {
     final int currentQuantity = product.first[ProductFields.quantity] as int;


     if (currentQuantity >= quantity) {
       // Sufficient stock available, update the quantity
       final updatedQuantity = currentQuantity - quantity;
       await db.update(
         tableInventory,
         {ProductFields.quantity: updatedQuantity},
         where: '${ProductFields.id} = ?',
         whereArgs: [productId],
       );
     } else {
       // Insufficient stock available
       throw Exception('No more stock available for this product.');
     }
   } else {
     // Product not found
     throw Exception('Product not found.');
   }
 }

   Future<List<Purchase>> getAllPurchases() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tablePurchases);

    // Convert the List<Map<String, dynamic>> to a List<Purchase>
    return List.generate(maps.length, (i) {
      return Purchase.fromJson(maps[i]);
    });
  }

Future<Map<int, double>> calculateOverallSalesPerCategory() async {
  final Database db = await database;
  final Map<int, double> overallSalesPerCategory = {};

  // Query purchases table to get total sales for each product and its category
  final List<Map<String, dynamic>> purchases = await db.query(
    tablePurchases,
    columns: [
      '${PurchaseFields.productId}',
      'SUM(${PurchaseFields.price}) AS totalSales',
    ],
    groupBy: '${PurchaseFields.productId}',
  );

  // Iterate through purchases to populate overall sales per category map
  for (final purchase in purchases) {
    final int productId = purchase[PurchaseFields.productId] as int;
    final double totalSales = purchase['totalSales'] as double;

    // Query products table to get category for the product
    final List<Map<String, dynamic>> productData = await db.query(
      tableInventory,
      columns: [ProductFields.category],
      where: '${ProductFields.id} = ?',
      whereArgs: [productId],
    );

    // Extract category ID and update overall sales per category
    if (productData.isNotEmpty) {
      final int categoryId = productData.first[ProductFields.category] as int;
      overallSalesPerCategory[categoryId] = (overallSalesPerCategory[categoryId] ?? 0) + totalSales;
    }
  }

  return overallSalesPerCategory;
}

Future<void> deletePurchase(int purchaseId) async {
  final db = await database;
  await db.delete(
    tablePurchases,
    where: '${PurchaseFields.id} = ?',
    whereArgs: [purchaseId],
  );
}





 Future close() async {
   final db = await instance.database;


   db.close();


 }
 
}