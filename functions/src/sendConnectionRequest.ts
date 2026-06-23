import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const sendConnectionRequest = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Debe estar autenticado");
  }

  const senderId = context.auth.uid;
  const { receiverId } = data;

  if (!receiverId || typeof receiverId !== "string") {
    throw new functions.https.HttpsError("invalid-argument", "receiverId es requerido");
  }

  if (senderId === receiverId) {
    throw new functions.https.HttpsError("invalid-argument", "No puedes enviarte una solicitud a ti mismo");
  }

  const db = admin.firestore();
  const senderRef = db.collection("users").doc(senderId);

  try {
    const senderDoc = await senderRef.get();
    if (!senderDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Usuario remitente no encontrado");
    }
    const senderData = senderDoc.data()!;

    // Verificar si está bloqueado
    if (senderData.isLocked) {
      throw new functions.https.HttpsError("failed-precondition", "Tu cuenta está bloqueada");
    }

    // Verificar trial
    const trialEndDate = senderData.trialEndDate?.toDate();
    if (trialEndDate && new Date() > trialEndDate) {
      await senderRef.update({ isLocked: true });
      throw new functions.https.HttpsError("failed-precondition", "Tu período de prueba ha expirado");
    }

    // Verificar límite de solicitudes
    const totalRequestsUsed = senderData.totalRequestsUsed || 0;
    if (totalRequestsUsed >= 100) {
      await senderRef.update({ isLocked: true });
      throw new functions.https.HttpsError("failed-precondition", "Has alcanzado el límite de 100 solicitudes");
    }

    // Verificar que el receptor existe
    const receiverDoc = await db.collection("users").doc(receiverId).get();
    if (!receiverDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Usuario receptor no encontrado");
    }

    // Crear la solicitud
    const requestId = senderId < receiverId ? `${senderId}-${receiverId}` : `${receiverId}-${senderId}`;
    const requestRef = db.collection("friend_requests").doc(requestId);
    const requestDoc = await requestRef.get();

    if (requestDoc.exists) {
      const requestData = requestDoc.data()!;
      if (requestData.status === "pending") {
        throw new functions.https.HttpsError("already-exists", "Ya existe una solicitud pendiente");
      }
      if (requestData.status === "accepted") {
        throw new functions.https.HttpsError("already-exists", "Ya son contactos");
      }
    }

    await requestRef.set({
      from: senderId,
      to: receiverId,
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await senderRef.update({
      totalRequestsUsed: admin.firestore.FieldValue.increment(1),
    });

    functions.logger.info(`Solicitud enviada de ${senderId} a ${receiverId}`);

    return {
      success: true,
      remainingRequests: 100 - (totalRequestsUsed + 1),
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error("Error al enviar solicitud:", error);
    throw new functions.https.HttpsError("internal", "Error interno");
  }
});
