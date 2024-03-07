final String tableInventory = 'Products';

class ProductFields {
  static final String id = '_id';
  static final String name = 'name';
  static final String description = 'description';
  static final String category = 'category';
  static final String quantity = 'quantity';
  static final String price = 'price';

}

class Products {
  final int? id;
  final String? name;
  final String? description;
  final String? category;
  final int? quantity;
  final double? price;

  const Products ({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.quantity,
    required this.price,
  });
}