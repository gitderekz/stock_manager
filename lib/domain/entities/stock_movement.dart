class StockMovement {
  final int id;
  final int productId;
  final String movementType; // 'in' or 'out'
  final int quantity;
  final String? reference;
  final String? notes;
  final int userId;
  final DateTime movementDate;

  StockMovement({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantity,
    this.reference,
    this.notes,
    required this.userId,
    required this.movementDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'movement_type': movementType,
      'quantity': quantity,
      'reference': reference,
      'notes': notes,
      'user_id': userId,
      'movement_date': movementDate.toIso8601String(),
    };
  }

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'],
      productId: json['product_id'],
      movementType: json['movement_type'],
      quantity: json['quantity'],
      reference: json['reference'],
      notes: json['notes'],
      userId: json['user_id'],
      movementDate: DateTime.parse(json['movement_date']),
    );
  }
}