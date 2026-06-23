import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// Importar las nuevas funciones
export { onCreateUser } from "./onCreateUser";
export { sendConnectionRequest } from "./sendConnectionRequest";
export { acceptConnectionRequest } from "./acceptConnectionRequest";

// Función existente: transferDiamonds
export const transferDiamonds = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "La función debe ser llamada por un usuario autenticado."
    );
  }

  const { receiverId, amount } = data;
  if (!(typeof receiverId === "string") || !(typeof amount === "number") || amount <= 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Los datos proporcionados no son válidos."
    );
  }

  const senderId = context.auth.uid;  if (senderId === receiverId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "No puedes enviarte diamantes a ti mismo."
    );
  }

  const db = admin.firestore();
  const senderRef = db.collection("users").doc(senderId);
  const receiverRef = db.collection("users").doc(receiverId);
  const transactionRef = db.collection("transactions").doc();

  try {
    await db.runTransaction(async (t) => {
      const senderDoc = await t.get(senderRef);
      const receiverDoc = await t.get(receiverRef);

      if (!senderDoc.exists || !receiverDoc.exists) {
        throw new functions.https.HttpsError("not-found", "Usuario no encontrado.");
      }

      const senderData = senderDoc.data()!;
      const senderDiamonds = senderData.diamonds || 0;

      if (senderData.role !== "creator" && senderDiamonds < amount) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "No tienes suficientes diamantes."
        );
      }

      if (senderData.role !== "creator") {
        t.update(senderRef, { diamonds: admin.firestore.FieldValue.increment(-amount) });
      }
      t.update(receiverRef, { diamonds: admin.firestore.FieldValue.increment(amount) });

      t.set(transactionRef, {
        senderId: senderId,
        senderName: senderData.displayName || "N/A",
        receiverId: receiverId,
        receiverName: receiverDoc.data()!.displayName || "N/A",
        amount: amount,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        type: "transfer",
      });
    });

    return { success: true, message: "Transferencia completada." };
  } catch (error) {
    functions.logger.error("Error en transferencia:", error);    throw new functions.https.HttpsError("internal", "Error interno.");
  }
});

// Función existente: setRoleOnUserUpdate
export const setRoleOnUserUpdate = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const oldData = change.before.data();

    if (newData.role === oldData.role) {
      return null;
    }

    const userId = context.params.userId;
    const newRole = newData.role;

    try {
      await admin.auth().setCustomUserClaims(userId, { role: newRole });
      functions.logger.info(`Custom claim 'role: ${newRole}' asignado a ${userId}.`);
      return null;
    } catch (error) {
      functions.logger.error(`Error al establecer custom claim para ${userId}:`, error);
      return null;
    }
  });
