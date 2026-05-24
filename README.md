# 📱 Durakitos - Sistema de Enlace y Crecimiento de Audiencia (WhatsApp)

## 🎯 Objetivo Principal: Sincronización de Contactos Mutuos
El propósito central de Durakitos es facilitar que los usuarios amplíen su alcance en WhatsApp de manera legítima y mutua. La app permite que personas con intereses afines se envíen solicitudes; una vez aceptadas, ambos usuarios quedan agendados en sus respectivos teléfonos.

### Flujo de Valor:
1. **El Enlace:** Al aceptarse una solicitud, la app gestiona la creación del contacto.
2. **WhatsApp Sync:** Al estar agendados mutuamente, el algoritmo de WhatsApp habilita la visualización de **Estados de WhatsApp**.
3. **El Resultado:** Aumento orgánico de vistas en los estados, ideal para emprendedores y creadores que buscan visibilidad.

## 💎 El Sistema de Diamantes (Monetización)
El diamante es el activo que permite el acceso a esta red de contactos y su valor es de **$100 pesos**.

- **Acceso por Diamantes:** Para que un usuario nuevo pueda registrarse y empezar a enviar solicitudes, debe consumir **1 Diamante**.
- **Control de Registro:** Ningún usuario puede entrar a la red sin haber adquirido un diamante a través de la cadena de distribución.
- **Utilidad del Sistema:** Es el método para sacarle provecho económico a la plataforma, convirtiendo cada registro en un ingreso neto.

## 👑 Jerarquía de Distribución y Ventas
Para escalar el negocio, el sistema se divide en 4 niveles de gestión de diamantes:

1. **Owner (Tú):** Creador del inventario global. Vendes diamantes a los Administradores.
2. **Administradores:** Compran al Owner y gestionan su red de Super Agentes.
3. **Super Agentes:** Compran a los Administradores y suministran a los Agentes.
4. **Agentes:** Venden el acceso (diamante) al Usuario Final y lo ayudan a registrarse para empezar a conectar.

## 🛠️ Especificaciones Técnicas (Firebase)
### 1. Gestión de Solicitudes
- El sistema debe manejar una colección de `solicitudes` (Pendiente, Aceptada, Rechazada).
- Al marcarse como "Aceptada", la app debe activar la función de exportación/creación de contacto para asegurar que WhatsApp reconozca la relación.

### 2. Consumo de Créditos
- El descuento de **1 Diamante** ocurre únicamente en el momento del `signUp`.
- El sistema valida el `invite_code` del Agente; si tiene saldo, se crea el usuario y se descuenta el crédito al Agente.

### 3. Seguridad de Saldos
- Los saldos son intocables para el usuario. Solo el nivel superior inmediato puede asignar diamantes tras confirmar el pago manual.
- Las **Firestore Rules** bloquean cualquier intento de edición manual del campo `balance`.

## 📊 Administración y Estadísticas (Excel)
El sistema genera reportes diarios para el Owner y Administradores:
- **Ventas Diarias:** `Registros nuevos * $100`.
- **Rendimiento de Red:** Cuántos contactos nuevos se han generado por cada rama de la jerarquía.
- **Inventario:** Diamantes disponibles en cada nivel para prever nuevas compras.

## 🎨 Identidad Visual
- **Colores:** Azul Profesional (#003d9b) y Blanco.
- **Enfoque:** Interfaz rápida, estilo agenda de contactos, optimizada para móviles.
