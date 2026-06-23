import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const onCreateUser = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;    const userData = snap.data();

    functions.logger.info(`Nuevo usuario creado: ${userId}`, { userId });

    // Solo actualizar si no tiene trialEndDate (usuarios nuevos)
    if (!userData?.trialEndDate) {
      const trialEnd = new Date();
      trialEnd.setDate(trialEnd.getDate() + 7);

      await snap.ref.update({
        trialEndDate: admin.firestore.Timestamp.fromDate(trialEnd),
        totalRequestsUsed: 0,
        isLocked: false,
        diamonds: userData?.diamonds || 0,
        role: userData?.role || "user",
      });
    }

    return null;
  });
