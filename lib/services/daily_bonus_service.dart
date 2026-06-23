import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyBonusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  Future<bool> canClaimBonus() async {
    final userDoc = await _firestore.collection('users').doc(_userId).get();
    final data = userDoc.data();
    
    if (data == null) return false;
    
    final lastClaim = data['lastBonusClaim'] as Timestamp?;
    if (lastClaim == null) return true;
    
    final now = DateTime.now();
    final lastClaimDate = lastClaim.toDate();
        // Verificar si pasó un día desde el último claim
    return now.difference(lastClaimDate).inHours >= 24;
  }

  Future<int> claimBonus({bool isVip = false}) async {
    final canClaim = await canClaimBonus();
    if (!canClaim) {
      throw Exception('Ya reclamaste tu bonus hoy');
    }

    final bonusAmount = isVip ? 15 : 5;

    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection('users').doc(_userId);
      final userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) throw Exception('Usuario no encontrado');
      
      final currentDiamonds = userDoc.data()?['diamonds'] ?? 0;
      
      transaction.update(userRef, {
        'diamonds': currentDiamonds + bonusAmount,
        'lastBonusClaim': FieldValue.serverTimestamp(),
      });
    });

    return bonusAmount;
  }

  Stream<int> watchBonusStatus() {
    return _firestore.collection('users').doc(_userId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return 0;
      
      final lastClaim = data['lastBonusClaim'] as Timestamp?;
      if (lastClaim == null) return 1; // Puede reclamar
      
      final now = DateTime.now();
      final lastClaimDate = lastClaim.toDate();
      final hoursSinceClaim = now.difference(lastClaimDate).inHours;
      
      return hoursSinceClaim >= 24 ? 1 : 0;
    });
  }
}
