import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// // Start writing functions
// // https://firebase.google.com/docs/functions/typescript

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

/**
 * Transfiere diamantes entre dos usuarios.
 * Es una función "callable", lo que significa que la app la puede llamar directamente
 * y Firebase se encarga de la autenticación del usuario que la llama.
 */
export const transferDiamonds = functions.https.onCall(async (data, context) => {
  // 1. Verificación de autenticación
  // Si context.auth es nulo, significa que el usuario no está logueado.
  // La función lanzará un error automáticamente.
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "La función debe ser llamada por un usuario autenticado."
    );
  }

  // 2. Validación de datos de entrada
  const { receiverId, amount } = data;
  if (!(typeof receiverId === "string") || !(typeof amount === "number") || amount <= 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Los datos proporcionados no son válidos (receiverId: string, amount: number > 0)."
    );
  }

  const senderId = context.auth.uid;

  // No se puede transferir a uno mismo
  if (senderId === receiverId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "No puedes enviarte diamantes a ti mismo."
    );
  }

  // 3. Lógica de la transacción en un entorno seguro (servidor)
  const db = admin.firestore();
  const senderRef = db.collection("users").doc(senderId);
  const receiverRef = db.collection("users").doc(receiverId);
  const transactionRef = db.collection("transactions").doc();

  try {
    await db.runTransaction(async (t) => {
      const senderDoc = await t.get(senderRef);
      const receiverDoc = await t.get(receiverRef);

      if (!senderDoc.exists || !receiverDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Uno de los usuarios no fue encontrado."
        );
      }

      const senderData = senderDoc.data()!;
      const senderDiamonds = senderData.diamonds || 0;

      // Si el sender es el 'creator', no se le descuentan diamantes.
      if (senderData.role !== 'creator' && senderDiamonds < amount) {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "No tienes suficientes diamantes para realizar esta transferencia."
        );
      }

      const receiverDiamonds = receiverDoc.data()!.diamonds || 0;

      // Actualización de balances
      if (senderData.role !== 'creator') {
         t.update(senderRef, { diamonds: admin.firestore.FieldValue.increment(-amount) });
      }
      t.update(receiverRef, { diamonds: admin.firestore.FieldValue.increment(amount) });

      // Registro de la transacción
      t.set(transactionRef, {
          senderId: senderId,
          senderName: senderData.displayName || "N/A",
          receiverId: receiverId,
          receiverName: receiverDoc.data()!.displayName || "N/A",
          amount: amount,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          type: 'transfer',
        });
    });

    return { success: true, message: "Transferencia completada con éxito." };

  } catch (error) {
    // El logging en Cloud Functions es crucial para depurar.
    functions.logger.error("Error en la transferencia de diamantes:", error);
    // Re-lanzamos el error para que el cliente lo reciba.
    throw new functions.https.HttpsError(
      "internal",
      "Ocurrió un error interno al procesar la transacción.",
      error
    );
  }
});
