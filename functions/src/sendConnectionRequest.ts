import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Envía una solicitud de conexión entre dos usuarios.
 * Valida límites de prueba (7 días y 100 solicitudes).
 */
export const sendConnectionRequest = functions.https.onCall(async (data, context) => {
  // 1. Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Debe estar autenticado para enviar solicitudes."
    );
  }

  const senderId = context.auth.uid;
  const { receiverId } = data;

  // 2. Validar datos
  if (!receiverId || typeof receiverId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "receiverId es requerido y debe ser un string."
    );
  }

  if (senderId === receiverId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "No puedes enviarte una solicitud a ti mismo."
    );
  }

  const db = admin.firestore();
  const senderRef = db.collection("users").doc(senderId);
  const receiverRef = db.collection("users").doc(receiverId);
  try {
    // 3. Obtener datos del remitente
    const senderDoc = await senderRef.get();
    if (!senderDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Usuario remitente no encontrado.");
    }

    const senderData = senderDoc.data()!;

    // 4. Verificar si el usuario está bloqueado
    if (senderData.isLocked) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Tu cuenta está bloqueada. Contacta a tu patrocinador para obtener diamantes."
      );
    }

    // 5. Verificar límite de tiempo de prueba (7 días)
    const trialEndDate = senderData.trialEndDate?.toDate();
    if (trialEndDate && new Date() > trialEndDate) {
      await senderRef.update({ isLocked: true });
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Tu período de prueba ha expirado. Contacta a tu patrocinador para continuar."
      );
    }

    // 6. Verificar límite de solicitudes (100)
    const totalRequestsUsed = senderData.totalRequestsUsed || 0;
    if (totalRequestsUsed >= 100) {
      await senderRef.update({ isLocked: true });
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Has alcanzado el límite de 100 solicitudes. Contacta a tu patrocinador para continuar."
      );
    }

    // 7. Verificar que el receptor existe
    const receiverDoc = await receiverRef.get();
    if (!receiverDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Usuario receptor no encontrado.");
    }

    // 8. Verificar si ya existe una solicitud entre estos usuarios
    const requestId = senderId < receiverId ? `${senderId}-${receiverId}` : `${receiverId}-${senderId}`;
    const requestRef = db.collection("friend_requests").doc(requestId);
    const requestDoc = await requestRef.get();

    if (requestDoc.exists) {
      const requestData = requestDoc.data()!;      if (requestData.status === "pending") {
        throw new functions.https.HttpsError(
          "already-exists",
          "Ya existe una solicitud pendiente entre estos usuarios."
        );
      }
      if (requestData.status === "accepted") {
        throw new functions.https.HttpsError(
          "already-exists",
          "Ya son contactos."
        );
      }
    }

    // 9. Crear la solicitud
    await requestRef.set({
      from: senderId,
      to: receiverId,
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 10. Incrementar contador de solicitudes
    await senderRef.update({
      totalRequestsUsed: admin.firestore.FieldValue.increment(1),
    });

    functions.logger.info(`Solicitud enviada de ${senderId} a ${receiverId}`, {
      senderId,
      receiverId,
      totalRequestsUsed: totalRequestsUsed + 1,
    });

    return {
      success: true,
      message: "Solicitud enviada exitosamente.",
      remainingRequests: 100 - (totalRequestsUsed + 1),
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    functions.logger.error("Error al enviar solicitud:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error interno al procesar la solicitud."
    );
  }
});EOF

# 4. Crear Cloud Function acceptConnectionRequest
echo "🔥 Creando Cloud Function acceptConnectionRequest..."
cat > functions/src/acceptConnectionRequest.ts << 'EOF'
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Acepta una solicitud de conexión y crea los contactos mutuos.
 * En el futuro, esto integrará con Google Contacts API.
 */
export const acceptConnectionRequest = functions.https.onCall(async (data, context) => {
  // 1. Verificar autenticación
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Debe estar autenticado para aceptar solicitudes."
    );
  }

  const receiverId = context.auth.uid;
  const { requestId } = data;

  // 2. Validar datos
  if (!requestId || typeof requestId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "requestId es requerido."
    );
  }

  const db = admin.firestore();
  const requestRef = db.collection("friend_requests").doc(requestId);

  try {
    // 3. Obtener la solicitud
    const requestDoc = await requestRef.get();
    if (!requestDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Solicitud no encontrada.");
    }

    const requestData = requestDoc.data()!;

    // 4. Verificar que el receptor es el usuario actual
    if (requestData.to !== receiverId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "No tienes permiso para aceptar esta solicitud."
      );    }

    // 5. Verificar que la solicitud está pendiente
    if (requestData.status !== "pending") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Esta solicitud ya fue procesada."
      );
    }

    const senderId = requestData.from;

    // 6. Actualizar la solicitud a aceptada
    await requestRef.update({
      status: "accepted",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 7. Crear contactos mutuos (subcolección 'contacts')
    const batch = db.batch();

    // Agregar receptor a los contactos del remitente
    const senderContactRef = db
      .collection("users")
      .doc(senderId)
      .collection("contacts")
      .doc(receiverId);
    batch.set(senderContactRef, {
      addedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Agregar remitente a los contactos del receptor
    const receiverContactRef = db
      .collection("users")
      .doc(receiverId)
      .collection("contacts")
      .doc(senderId);
    batch.set(receiverContactRef, {
      addedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // 8. TODO: En el futuro, aquí llamaremos a Google Contacts API
    // para crear los contactos en la agenda de Google de ambos usuarios.

    functions.logger.info(`Solicitud aceptada: ${senderId} <-> ${receiverId}`, {
      senderId,
      receiverId,
      requestId,    });

    return {
      success: true,
      message: "Solicitud aceptada exitosamente. Contactos creados.",
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    functions.logger.error("Error al aceptar solicitud:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error interno al procesar la solicitud."
    );
  }
});
