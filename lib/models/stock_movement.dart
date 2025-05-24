// models/stock_movement.dart
class StockMovement {
  final int id;
  final int productId;
  final String movementType; // 'in', 'out', 'adjustment'
  final int quantity;
  final String? reference;
  final String? notes;
  final int userId;
  final DateTime movementDate;
  final bool isSynced;
  String productName; // Add product name for display
  String? date; // Formatted date for display

  StockMovement({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantity,
    this.reference,
    this.notes,
    required this.userId,
    required this.movementDate,
    this.isSynced = false,
    required this.productName,
  }) {
    // Format date for display
    date = '${movementDate.day}/${movementDate.month}/${movementDate.year}';
  }

  // Add type getter for display
  String get type {
    switch (movementType) {
      case 'in':
        return 'Stock In';
      case 'out':
        return 'Stock Out';
      case 'adjustment':
        return 'Adjustment';
      default:
        return movementType;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'movement_type': movementType,
      'quantity': quantity,
      'reference': reference,
      'notes': notes,
      'user_id': userId,
      'movement_date': movementDate.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'],
      productName: map['product_name'],
      productId: map['product_id'],
      movementType: map['movement_type'],
      quantity: map['quantity'],
      reference: map['reference'],
      notes: map['notes'],
      userId: map['user_id'],
      movementDate: DateTime.parse(map['movement_date']),
      isSynced: map['is_synced'] == 1,
    );
  }
}