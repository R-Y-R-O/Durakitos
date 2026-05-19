
import 'package:cloud_firestore/cloud_firestore.dart';

// Definimos los tipos de transacciones que pueden existir.
// Esto nos dará flexibilidad a futuro (ej: transferencias, bonos, cargos, etc.)
enum TransactionType {
  transfer,
  bonus,
  charge,
  initial,
}

class TransactionModel {
  final String id;          // ID único de la transacción
  final String senderId;    // ID del usuario que envía
  final String receiverId;  // ID del usuario que recibe
  final int amount;         // Cantidad de diamantes (siempre positivo)
  final TransactionType type; // El tipo de transacción
  final Timestamp timestamp;  // La fecha y hora exactas del registro

  TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  // Método para convertir los datos de Firestore a un objeto TransactionModel
  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TransactionModel(
      id: id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      amount: data['amount'] ?? 0,
      // Convertimos el string de Firestore a nuestro enum
      type: TransactionType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'transfer'),
        orElse: () => TransactionType.transfer,
      ),
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Método para convertir nuestro objeto TransactionModel a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': type.name, // Guardamos el enum como un string simple
      'timestamp': timestamp,
    };
  }
}
