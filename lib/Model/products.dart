final String tableInventory = 'Products';

class ProductFields {

  static final List <String> values = [
    id, name, description, category, quantity, price
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String description = 'description';
  static final String category = 'category';
  static final String quantity = 'quantity';
  static final String price = 'price';

}

class Products {
  final int? id;
  final String name;
  final String description;
  final String category;
  final int quantity;
  final double price;

  const Products ({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.quantity,
    required this.price,
  });

  Products copy({
    int? id,
    String? name,
    String? description,
    String? category,
    int? quantity,
    double? price,
  }) =>
      Products(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        category: category ?? this.category, 
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
      );
      
  static Products fromJson(Map<String, Object?> json) => Products(
    id: json[ProductFields.id] as int?,
    name: json[ProductFields.name] as String,
    description: json[ProductFields.description] as String,
    category: json[ProductFields.category] as String,
    quantity: json[ProductFields.quantity] as int,
    price: json[ProductFields.price] as double,
  );

  Map<String, Object?> toJson() => {
    ProductFields.id:id,
    ProductFields.name:name,
    ProductFields.description: description,
    ProductFields.category: category,
    ProductFields.quantity: quantity,
    ProductFields.price: price,
  };
}