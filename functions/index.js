
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Se activa cada vez que un documento de usuario es actualizado.
 * Si el campo 'role' cambia, actualiza los Custom Claims del usuario
 * para que coincidan.
 */
exports.setRoleOnUserUpdate = functions.firestore
    .document("users/{userId}")
    .onUpdate(async (change, context) => {
      const newData = change.after.data();
      const oldData = change.before.data();

      // Si el rol no ha cambiado, no hacemos nada.
      if (newData.role === oldData.role) {
        console.log(`El rol para ${context.params.userId} no ha cambiado.`);
        return null;
      }

      const userId = context.params.userId;
      const newRole = newData.role;

      console.log(
          `Detectado cambio de rol para ${userId}. Nuevo rol: ${newRole}`,
      );

      try {
        // Establecer el custom claim en el objeto de autenticación del usuario
        await admin.auth().setCustomUserClaims(userId, {role: newRole});
        console.log(
            `¡Éxito! Custom claim 'role: ${newRole}' asignado a ${userId}.`,
        );
        return null;
      } catch (error) {
        console.error(
            `Error al establecer custom claim para ${userId}:`,
            error,
        );
        return null;
      }
    });
