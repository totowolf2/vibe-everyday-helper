class Product {
  final String id;
  final String name;
  final double price;
  final double quantity;
  final String unit;
  final int packSize;
  final double individualQuantity;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    this.packSize = 1,
    double? individualQuantity,
  }) : individualQuantity = individualQuantity ?? quantity;

  double get pricePerUnit {
    if (quantity <= 0) return 0.0;
    return price / quantity;
  }

  double get pricePerPiece {
    if (packSize <= 0) return 0.0;
    return price / packSize;
  }

  double get totalQuantity {
    return packSize * individualQuantity;
  }

  double get pricePerUnitFromPack {
    final total = totalQuantity;
    if (total <= 0) return 0.0;
    return price / total;
  }

  bool get isPack {
    return packSize > 1;
  }

  String get formattedPricePerUnit {
    if (quantity <= 0) return '0.00';
    return pricePerUnit.toStringAsFixed(2);
  }

  String get displayName {
    return name.isEmpty ? 'Product ${id.substring(0, 8)}' : name;
  }

  bool get isValid {
    return name.isNotEmpty &&
        price > 0 &&
        quantity > 0 &&
        unit.isNotEmpty &&
        packSize > 0 &&
        individualQuantity > 0;
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? quantity,
    String? unit,
    int? packSize,
    double? individualQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      packSize: packSize ?? this.packSize,
      individualQuantity: individualQuantity ?? this.individualQuantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'packSize': packSize,
      'individualQuantity': individualQuantity,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      packSize: map['packSize'] ?? 1,
      individualQuantity: map['individualQuantity']?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, quantity: $quantity, unit: $unit, packSize: $packSize, individualQuantity: $individualQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.packSize == packSize &&
        other.individualQuantity == individualQuantity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        packSize.hashCode ^
        individualQuantity.hashCode;
  }
}
