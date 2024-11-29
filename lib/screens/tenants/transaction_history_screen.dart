import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/payment_provider.dart';
// import '../../models/payment.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String tenantId;

  TransactionHistoryScreen({required this.tenantId});

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      Provider.of<PaymentProvider>(context, listen: false)
          .fetchTenantLedger(widget.tenantId);
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: Consumer<PaymentProvider>(
        builder: (ctx, paymentProvider, _) {
          if (paymentProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(paymentProvider.error!),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        paymentProvider.fetchTenantLedger(widget.tenantId),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final ledger = paymentProvider.ledger;
          if (ledger == null) {
            return Center(child: Text('No transactions found'));
          }

          return Column(
            children: [
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Balance:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Ksh. ${ledger.balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ledger.balance > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ledger.transactions.length,
                  itemBuilder: (ctx, index) {
                    final transaction = ledger.transactions[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.type == 'payment'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          child: Icon(
                            transaction.type == 'payment'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: transaction.type == 'payment'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        title: Text(transaction.description),
                        subtitle: Text(
                          DateFormat('MMM d, y - h:mm a')
                              .format(transaction.date),
                        ),
                        trailing: Text(
                          'Ksh. ${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: transaction.type == 'payment'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context),
        icon: Icon(Icons.add),
        label: Text('Add Transaction'),
      ),
    );
  }

  Future<void> _showAddTransactionDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    double? amount;
    String? description;
    String type = 'payment';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Transaction'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(labelText: 'Type'),
                items: [
                  DropdownMenuItem(value: 'payment', child: Text('Payment')),
                  DropdownMenuItem(value: 'charge', child: Text('Charge')),
                ],
                onChanged: (value) => type = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Ksh. ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
                onSaved: (value) => amount = double.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Enter description' : null,
                onSaved: (value) => description = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.of(ctx).pop(true);
              }
            },
          ),
        ],
      ),
    );

    if (confirmed == true && amount != null && description != null) {
      try {
        final provider = Provider.of<PaymentProvider>(context, listen: false);
        if (type == 'payment') {
          await provider.addPayment(widget.tenantId, amount!, description!);
        } else {
          await provider.addCharge(widget.tenantId, amount!, description!);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add transaction')),
        );
      }
    }
  }
}
