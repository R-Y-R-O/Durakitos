import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const acceptConnectionRequest = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Debe estar autenticado");
  }

  const receiverId = context.auth.uid;
  const { requestId } = data;

  if (!requestId) {
    throw new functions.https.HttpsError("invalid-argument", "requestId es requerido");
  }

  const db = admin.firestore();
  const requestRef = db.collection("friend_requests").doc(requestId);

  try {
    const requestDoc = await requestRef.get();
    if (!requestDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Solicitud no encontrada");
    }

    const requestData = requestDoc.data()!;
    if (requestData.to !== receiverId) {
      throw new functions.https.HttpsError("permission-denied", "No autorizado");
    }

    if (requestData.status !== "pending") {
      throw new functions.https.HttpsError("failed-precondition", "Ya procesada");    }

    const senderId = requestData.from;

    await requestRef.update({
      status: "accepted",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const batch = db.batch();

    batch.set(
      db.collection("users").doc(senderId).collection("contacts").doc(receiverId),
      { addedAt: admin.firestore.FieldValue.serverTimestamp() }
    );

    batch.set(
      db.collection("users").doc(receiverId).collection("contacts").doc(senderId),
      { addedAt: admin.firestore.FieldValue.serverTimestamp() }
    );

    await batch.commit();

    functions.logger.info(`Solicitud aceptada: ${senderId} <-> ${receiverId}`);

    return { success: true, message: "Contactos creados" };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error("Error al aceptar solicitud:", error);
    throw new functions.https.HttpsError("internal", "Error interno");
  }
});
