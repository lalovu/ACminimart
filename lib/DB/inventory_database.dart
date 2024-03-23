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

 Future<Products> checkProduct(String category) async {
   final db = await instance.database;


   List<Map<String, dynamic>> maps;


   if (category.toUpperCase() == 'ALL') {
     maps = await db.query(
       tableInventory,
       columns: ProductFields.values,
     );
   } else {
     maps = await db.query(
       tableInventory,
       columns: ProductFields.values,
       where: '${ProductFields.category} = ?',
       whereArgs: [category],
     );
   }


   if (maps.isNotEmpty) {
     return Products.fromJson(maps.first);
   } else {
     throw Exception('No products found for category: $category');
   }
 }

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


// Create Purchase (POS)

 Future<Purchase> createPurchases(Purchase purchase) async {
   final db = await instance.database;


   final id = await db.insert(tablePurchases, purchase.toJson());
   return purchase.copy(id: id);
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





 Future close() async {
   final db = await instance.database;


   db.close();


 }
 
}