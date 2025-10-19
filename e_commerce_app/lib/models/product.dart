class Product {
  final String id;
  final String name;
  final double price;
  final int availableUnits;
  final String imageAsset;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.availableUnits,
    required this.imageAsset,
    required this.description,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? availableUnits,
    String? imageAsset,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      availableUnits: availableUnits ?? this.availableUnits,
      imageAsset: imageAsset ?? this.imageAsset,
      description: description ?? this.description,
    );
  }
}
