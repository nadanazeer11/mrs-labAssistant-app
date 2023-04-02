class InventorySummary{
  String itemName;
  int quantity;
  int borrowedCount;
  int availableCount;
  int deadCount;

  InventorySummary({required this.itemName,
    required this.borrowedCount,required this.availableCount,
    required this.deadCount,
    required this.quantity});
}