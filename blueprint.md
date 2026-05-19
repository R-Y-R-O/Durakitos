
# Blueprint: Proyecto Conecta

## 1. Visión General del Proyecto

Este documento describe el plan de desarrollo para "Conecta", una aplicación social avanzada con una estructura jerárquica de gestión. La aplicación permite a los usuarios comunicarse y colaborar bajo un modelo organizativo claro (Creador > Admin > Super Agente > Agente), con una economía interna basada en "diamantes" para la gestión de recursos.

---

## 2. Log de Desarrollo (Funcionalidades Completadas)

- **Módulo 1: Fundación y Autenticación:**
  - Configuración del proyecto, arquitectura de navegación con `go_router`.
  - Implementación de un flujo de autenticación completo con Firebase (Registro y Login).

- **Módulo 2: Comunicación y Conexiones:**
  - Sistema de búsqueda de usuarios y gestión de solicitudes de amistad.
  - Agenda de contactos y servicio de chat 1-a-1 en tiempo real con Firestore.
  - Pantalla principal con un resumen de las conversaciones activas.

- **Módulo 3: Implementación de la Jerarquía de Roles (Plan B - Client-Side Logic):**
  - **Rediseño del `UserModel`:** Se implementó un nuevo modelo de datos en `lib/models/user_model.dart` con un `enum Role` (`creator`, `admin`, `super_agent`, `agent`, `user`), un campo `sponsorId` para la jerarquía y un campo `diamonds` para la economía interna.
  - **`UserProvider`:** Se creó un `ChangeNotifierProvider` para cargar y mantener en memoria los datos del usuario actual, incluyendo su rol, durante toda la sesión.
  - **Lógica de Carga:** La `SplashScreen` ahora se encarga de cargar los datos del `UserProvider` después del login, asegurando que el rol esté disponible antes de llegar a la pantalla principal.

- **Módulo 4: Panel de Gestión (V1 - Economía):**
  - **Acceso Restringido:** Se ha creado una ruta `/admin` y un botón en la `HomeScreen` que solo es visible para roles de gestión (`creator`, `admin`, `super_agent`).
  - **Vista Jerárquica:** El panel muestra automáticamente una lista de los subordinados directos del usuario (aquellos que tienen su `userId` como `sponsorId`).
  - **Asignación de Diamantes:**
    - Se ha implementado una UI para dar diamantes a los subordinados a través de un diálogo de confirmación.
    - La transferencia de diamantes se realiza de forma segura y atómica usando **Transacciones de Firestore**, previniendo la pérdida de datos.
    - La UI se actualiza en tiempo real después de cada transacción.

---

## 3. Plan de Desarrollo (Próximos Pasos)

### Módulo 5: Panel de Gestión (V2 - Gestión de Equipo)

**Objetivo:** Permitir a los superiores gestionar los roles y la estructura de su equipo directo.

**Plan Técnico:**

1.  **UI para Gestión de Roles:**
    - Se añadirá un nuevo `IconButton` en el `ListTile` de cada subordinado para gestionar su rol.
    - Al pulsarlo, se mostrará un `AlertDialog` o un `PopupMenu` con los roles a los que se puede ascender o descender al usuario.

2.  **Lógica de Promoción Jerárquica:**
    - La lista de roles disponibles para la promoción será dinámica y restringida:
      - Un `creator` podrá designar `admin`.
      - Un `admin` podrá designar `super_agent`.
      - Un `super_agent` podrá designar `agent`.
    - Se implementará la lógica para que un usuario no pueda ser ascendido a un rol igual o superior al de su superior.

3.  **Actualización en Firestore:**
    - Al confirmar un cambio de rol, se actualizará el campo `role` del documento del usuario en Firestore.
    - Se considerará qué sucede con el `sponsorId`. Al ascender a alguien, ¿cambia su padrino? (Por ahora, supondremos que no).

4.  **UI para Asignar/Cambiar Padrino:**
    - (Futuro) Se podría añadir una función para que un `admin` o `creator` pueda reasignar un agente de un `super_agent` a otro.

### Módulo 6: Estadísticas y Reportes

**Objetivo:** Proveer a los gestores de herramientas para visualizar el rendimiento de su equipo.

**Plan Técnico:**

- El panel de gestión mostrará estadísticas clave para cada subordinado:
  - **Cantidad de Miembros:** Un contador que muestre cuántos subordinados tiene a su vez esa persona (ej: cuántos `agent` tiene un `super_agent`). Esto requerirá una consulta adicional.
  - **Volumen de Diamantes:** Estadísticas sobre cuántos diamantes ha movido o generado esa persona.
