class Transaction {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String type; // 'charge' or 'payment'

  Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      amount: json['amount'].toDouble(),
      type: json['type'],
    );
  }
}

class TenantLedger {
  final String id;
  final String tenantId;
  final List<Transaction> transactions;
  final double balance;

  TenantLedger({
    required this.id,
    required this.tenantId,
    required this.transactions,
    required this.balance,
  });

  factory TenantLedger.fromJson(Map<String, dynamic> json) {
    return TenantLedger(
      id: json['_id'],
      tenantId: json['tenant'],
      transactions: (json['transactions'] as List)
          .map((tx) => Transaction.fromJson(tx))
          .toList(),
      balance: json['balance'].toDouble(),
    );
  }
} 