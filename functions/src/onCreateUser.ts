import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Se activa cuando se crea un nuevo documento de usuario.
 * Asigna 7 días de prueba y 100 solicitudes gratuitas.
 */
export const onCreateUser = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const userData = snap.data();

    functions.logger.info(`Nuevo usuario creado: ${userId}`, { userId });

    // Calcular fecha de fin de prueba (7 días desde ahora)
    const now = new Date();
    const trialEnd = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);

    // Actualizar el documento con los valores iniciales
    await snap.ref.update({
      trialEndDate: admin.firestore.Timestamp.fromDate(trialEnd),
      totalRequestsUsed: 0,
      isLocked: false,
      diamonds: 0,
      role: "user",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    functions.logger.info(`Usuario ${userId} configurado con 7 días de prueba y 100 solicitudes`, {
      trialEnd: trialEnd.toISOString(),
    });

    return null;
  });
