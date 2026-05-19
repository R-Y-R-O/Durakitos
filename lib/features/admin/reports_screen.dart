
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/transaction_model.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

enum TimeRange { today, week, month, all }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  TimeRange _selectedRange = TimeRange.week;
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  void _fetchTransactions() {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    if (userId == null) {
      setState(() {
        _transactionsFuture = Future.value([]);
      });
      return;
    }

    setState(() {
      _transactionsFuture = _getTransactionsForUser(userId, _selectedRange);
    });
  }

  Future<List<TransactionModel>> _getTransactionsForUser(String userId, TimeRange range) async {
    final firestore = FirebaseFirestore.instance;
    
    // Determinar el rango de fechas para la consulta
    DateTime now = DateTime.now();
    DateTime startDate;
    switch (range) {
      case TimeRange.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimeRange.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case TimeRange.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case TimeRange.all:
        startDate = DateTime(2000); // Una fecha muy antigua para incluir todo
        break;
    }

    // Consultas para transacciones enviadas y recibidas
    final sentQuery = firestore
        .collection('transactions')
        .where('senderId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .get();

    final receivedQuery = firestore
        .collection('transactions')
        .where('receiverId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .get();

    final results = await Future.wait([sentQuery, receivedQuery]);
    
    final sentDocs = results[0].docs;
    final receivedDocs = results[1].docs;

    final allDocs = [...sentDocs, ...receivedDocs];

    // Evitar duplicados si una persona se envía a sí misma
    final uniqueDocs = { for (var doc in allDocs) doc.id: doc }.values.toList();

    // Mapear a modelos y ordenar por fecha
    final transactions = uniqueDocs.map((doc) => TransactionModel.fromFirestore(doc.data(), doc.id)).toList();
    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Más reciente primero

    return transactions;
  }

  void _updateRange(TimeRange range) {
    if (range != _selectedRange) {
      setState(() {
        _selectedRange = range;
      });
      _fetchTransactions();
    }
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ChoiceChip(label: const Text('Hoy'), selected: _selectedRange == TimeRange.today, onSelected: (selected) => _updateRange(TimeRange.today)),
          ChoiceChip(label: const Text('Semana'), selected: _selectedRange == TimeRange.week, onSelected: (selected) => _updateRange(TimeRange.week)),
          ChoiceChip(label: const Text('Mes'), selected: _selectedRange == TimeRange.month, onSelected: (selected) => _updateRange(TimeRange.month)),
          ChoiceChip(label: const Text('Todos'), selected: _selectedRange == TimeRange.all, onSelected: (selected) => _updateRange(TimeRange.all)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<UserProvider>(context, listen: false).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Transacciones'),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay transacciones en este período.'));
                }

                final transactions = snapshot.data!;

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isSender = tx.senderId == currentUserId;
                    final amountPrefix = isSender ? '-' : '+';
                    final amountColor = isSender ? Colors.red : Colors.green;
                    final displayText = isSender ? 'Enviaste a ...' : 'Recibiste de ...'; // Simplificado

                    return ListTile(
                      leading: Icon(isSender ? Icons.arrow_upward : Icons.arrow_downward, color: amountColor),
                      title: Text('$displayText ${tx.amount} diamantes'),
                      subtitle: Text(DateFormat.yMd().add_jms().format(tx.timestamp.toDate())),
                      trailing: Text('$amountPrefix${tx.amount}', style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
