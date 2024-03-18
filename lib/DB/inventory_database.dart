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
 ${ProductFields.category} $textType,
 ${ProductFields.quantity} $integerType,
 ${ProductFields.price} $doubleType
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


 Future<Products> createProducts(Products product) async {
   final db = await instance.database;

   final id = await db.insert(tableInventory, product.toJson());
   return product.copy(id:id);
 }


 Future<Customers> createCustomers(Customers customer) async {
   final db = await instance.database;


   final id = await db.insert(tableCustomer, customer.toJson());
   return customer.copy(id: id);
 }


 Future<Purchase> createPurchases(Purchase purchase) async {
   final db = await instance.database;


   final id = await db.insert(tablePurchases, purchase.toJson());
   return purchase.copy(id: id);
 }

 Future<List<Products>> getAllProducts() async {
    final db = await instance.database;
    final products = await db.query(tableInventory);
    return products.map((json) => Products.fromJson(json)).toList();
  }


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






 Future <int> update(Products product) async {
   final db = await instance.database;


   return db.update(
     tableInventory,
     product.toJson(),
     where: '${ProductFields.id} = ?',
     whereArgs: [product.id],
   ); 
 }


 Future<int> delete (int id) async {
   final db = await instance.database;


   return await db.delete(
     tableInventory,
     where: '${ProductFields.id} = ?',
     whereArgs: [id],
   );
 }




 Future close() async {
   final db = await instance.database;


   db.close();


 }
 
}