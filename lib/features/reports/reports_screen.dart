
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:conecta/providers/user_provider.dart';

// Enum para definir los rangos de tiempo de los reportes
enum ReportRange {
  today,
  thisWeek,
  thisMonth,
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportRange _selectedRange = ReportRange.thisWeek; // Rango por defecto
  late Stream<QuerySnapshot> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _updateTransactionsStream();
  }

  // Determina las fechas de inicio y fin según el rango seleccionado
  Map<String, DateTime> _calculateDateRange() {
    final now = DateTime.now();
    late DateTime startDate;
    final endDate = now;

    switch (_selectedRange) {
      case ReportRange.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case ReportRange.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case ReportRange.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }
    return {'start': startDate, 'end': endDate};
  }

  // Actualiza el stream de Firestore cuando cambia el rango
  void _updateTransactionsStream() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;
    if (userId == null) return;

    final range = _calculateDateRange();

    // Creamos la consulta que busca transacciones donde el usuario actual
    // es el emisor O el receptor, dentro del rango de fechas.
    var query = FirebaseFirestore.instance
        .collection('transactions')
        .where('timestamp', isGreaterThanOrEqualTo: range['start'])
        .where('timestamp', isLessThanOrEqualTo: range['end'])
        .orderBy('timestamp', descending: true);
        // Esta consulta requiere un índice compuesto en Firestore.
        // La herramienta de Firebase te pedirá crearlo automáticamente.

    // Filtramos en el cliente, ya que Firestore no soporta OR en campos diferentes.
    setState(() {
      _transactionsStream = query.snapshots().map((snapshot) {
        final docs = snapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['senderId'] == userId || data['receiverId'] == userId;
        }).toList();
        return QuerySnapshot(docs: docs, metadata: snapshot.metadata);
      });
    });
  }

  void _onRangeChanged(ReportRange? newRange) {
    if (newRange != null) {
      setState(() {
        _selectedRange = newRange;
      });
      _updateTransactionsStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Transacciones'),
      ),
      body: Column(
        children: [
          // Segmento de control para cambiar el rango de fechas
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<ReportRange>(
              segments: const [
                ButtonSegment(value: ReportRange.today, label: Text('Hoy')),
                ButtonSegment(value: ReportRange.thisWeek, label: Text('Semana')),
                ButtonSegment(value: ReportRange.thisMonth, label: Text('Mes')),
              ],
              selected: {_selectedRange},
              onSelectionChanged: (Set<ReportRange> newSelection) {
                _onRangeChanged(newSelection.first);
              },
            ),
          ),
          // StreamBuilder para mostrar la lista de transacciones
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _transactionsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.docs.isEmpty) {
                  return const Center(child: Text('No hay transacciones en este período.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final bool isSender = data['senderId'] == Provider.of<UserProvider>(context, listen: false).user?.id;
                    final amount = data['amount'];
                    final otherParty = isSender ? data['receiverName'] : data['senderName'];
                    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                    return ListTile(
                      leading: isSender
                          ? const Icon(Icons.arrow_upward, color: Colors.red)
                          : const Icon(Icons.arrow_downward, color: Colors.green),
                      title: Text(isSender ? 'Enviaste $amount a $otherParty' : 'Recibiste $amount de $otherParty'),
                      subtitle: Text(timestamp?.toLocal().toString() ?? 'Fecha no disponible'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  );
  }
}

