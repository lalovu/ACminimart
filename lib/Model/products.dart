
final String tableInventory = 'Products';
final String tableCustomer = 'Customers';
final String tablePurchases = 'Purchase';
final String tableCategory = 'Categories';

class ProductFields {
 static final List <String> values = [
   id, name, description, category, quantity, price, cost
 ];


 static final String id = '_id';
 static final String name = 'name';
 static final String description = 'description';
 static final String category = 'category';
 static final String quantity = 'quantity';
 static final String price = 'price';
 static final String cost = 'cost';

}

class CustomerFields {
 static final List<String> values = [
   id, name, email
 ];

 static final String id = '_id';
 static final String name = 'name';
 static final String email = 'email';
 
}

class PurchaseFields {
 static final List<String> values = [
  id, customerId, productId, quantity, price, time
 ];

 static final String id = '_id';
 static final String customerId = 'customer_id';
 static final String productId = 'product_id';
 static final String quantity = 'quantity';
 static final String price = 'price';
 static final String time = 'time';
}

class CategoryFields {
  static final List<String> values = [
  id, name
 ];
  static final String id = '_id';
  static final String name = 'name';
}


class Products {
 final int? id;
 final String name;
 final String description;
 final int category;
 final int quantity;
 final double price;
 final double cost;


 const Products ({
   this.id,
   required this.name,
   required this.description,
   required this.category,
   required this.quantity,
   required this.price,
   required this.cost,
 });


 Products copy({
   int? id,
   String? name,
   String? description,
   int? category,
   int? quantity,
   double? price,
   double? cost,
 }) =>
     Products(
       id: id ?? this.id,
       name: name ?? this.name,
       description: description ?? this.description,
       category: category ?? this.category, 
       quantity: quantity ?? this.quantity,
       price: price ?? this.price,
       cost: cost ?? this.cost,
     );
     
 static Products fromJson(Map<String, Object?> json) => Products(
   id: json[ProductFields.id] as int?,
   name: json[ProductFields.name] as String,
   description: json[ProductFields.description] as String,
   category: json[ProductFields.category] as int,
   quantity: json[ProductFields.quantity] as int,
   price: json[ProductFields.price] as double,
   cost: json[ProductFields.cost] as double,
 );


 Map<String, Object?> toJson() => {
   ProductFields.id:id,
   ProductFields.name:name,
   ProductFields.description: description,
   ProductFields.category: category,
   ProductFields.quantity: quantity,
   ProductFields.price: price,
   ProductFields.cost: cost,
 };
}


class Customers {
 final int? id;
 final String name;
 final String email;


 const Customers({
   this.id,
   required this.name,
   required this.email,
 });


 Customers copy({
   int? id,
   String? name,
   String? email,
 }) =>
     Customers(
       id: id ?? this.id,
       name: name ?? this.name,
       email: email ?? this.email,
     );


 static Customers fromJson(Map<String, Object?> json) => Customers(
   id: json[CustomerFields.id] as int?,
   name: json[CustomerFields.name] as String,
   email: json[CustomerFields.email] as String,
 );


 Map<String, Object?> toJson() => {
   CustomerFields.id: id,
   CustomerFields.name: name,
   CustomerFields.email: email,
 };
}


class Purchase {
 final int? id;
 final int customerId;
 final int productId;
 final int quantity;
 final double price;
 final DateTime createdTime;



 const Purchase({
   this.id,
   required this.customerId,
   required this.productId,
   required this.quantity,
   required this.price,
   required this.createdTime,
 });


 Purchase copy({
   int? id,
   int? customerId,
   int? productId,
   int? quantity,
   double? price,
   DateTime? createdTime,
 }) =>
     Purchase(
       id: id ?? this.id,
       customerId: customerId ?? this.customerId,
       productId: productId ?? this.productId,
       quantity: quantity ?? this.quantity,
       price: price ?? this.price,  
       createdTime: createdTime ?? this.createdTime, 
     );

 static Purchase fromJson(Map<String, Object?> json) => Purchase(
       id: json[PurchaseFields.id] as int?,
       customerId: json[PurchaseFields.customerId] as int,
       productId: json[PurchaseFields.productId] as int,
       quantity: json[PurchaseFields.quantity] as int,
       price: json[PurchaseFields.price] as double,
       createdTime: DateTime.parse(json[PurchaseFields.time] as String),
     );


 Map<String, Object?> toJson() => {
       PurchaseFields.id: id,
       PurchaseFields.customerId: customerId,
       PurchaseFields.productId: productId,
       PurchaseFields.quantity: quantity,
       PurchaseFields.price: price,
       PurchaseFields.time: createdTime.toIso8601String(),
     };

}

class Category {
  final int? id;
  final String name;

  Category({this.id, required this.name});

  Category copy({int? id, String? name}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  static Category fromJson(Map<String, Object?> json) => Category(
        id: json[CategoryFields.id] as int?,
        name: json[CategoryFields.name] as String,
      );

  Map<String, Object?> toJson() => {
        CategoryFields.id: id,
        CategoryFields.name: name,
      };
}