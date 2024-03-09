import 'package:dbase/Model/products.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dbase/widget/main.dart';

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
${ProductFields.id},$idType,
${ProductFields.name},$textType,
${ProductFields.description},$textType,
${ProductFields.category},$textType,
${ProductFields.quantity},$integerType,
${ProductFields.price},$doubleType,
)

''');

  }
  Future<Products> create(Products product) async {
    final db = await instance.database;

    final id = await db.insert(tableInventory, product.toJson());
    return product.copy(id:id);
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




