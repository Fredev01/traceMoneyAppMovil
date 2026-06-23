# Fix — Conexión al backend (API) desde Android

## Contexto

La app (`trace_money`) consume una API REST local de FastAPI. Al correr en el
**emulador de Android** las peticiones no llegaban al backend. Este documento
deja registrada la solución para no volver a investigarla en futuros desarrollos.

> **TL;DR:** En emulador el host es `10.0.2.2` (no `localhost`), y para HTTPS local
> con certificado autofirmado hay que aceptar ese certificado **solo en debug**
> vía `badCertificateCallback` en Dio.

---

## Síntomas / log que NO es el problema

Estas líneas aparecen en el log pero **son inofensivas** y despistan:

| Línea de log | Qué es | Acción |
|---|---|---|
| `I/Choreographer: Skipped 141 frames!` | Jank de arranque (trabajo en main thread al iniciar) | Ignorar |
| `D/InsetsController: hide(ime())` / `ImeTracker ... PHASE_CLIENT_ALREADY_HIDDEN` | Eventos del teclado (IME) | Ignorar |
| `W/ple.trace_money: userfaultfd: MOVE ioctl seems unsupported: Connection timed out` | Warning del **ART (GC del runtime)** en el emulador. El "Connection timed out" engaña: **no es un error de red** | Ignorar |

**El error real de red se ve como** `HandshakeException` / `CERTIFICATE_VERIFY_FAILED`
(cuando el backend ya sirve HTTPS con cert autofirmado) o un timeout de conexión
(cuando se apunta a `localhost` en vez de `10.0.2.2`).

---

## Causas y soluciones

### 1. `localhost` no apunta al host desde el emulador

Dentro del emulador Android, `localhost` / `127.0.0.1` se refiere **al propio
dispositivo virtual**, no a la máquina de desarrollo. El alias correcto es:

```dart
// lib/core/network/api_constants.dart
static const baseUrl = 'https://10.0.2.2:8000/api/v1';
```

| Entorno | Host a usar |
|---|---|
| Emulador Android | `10.0.2.2` |
| Dispositivo físico (misma red Wi-Fi) | IP LAN de la máquina, ej. `192.168.x.x` |
| Emulador Genymotion | `10.0.3.2` |
| iOS Simulator | `localhost` (sí funciona ahí) |

> Además, el servidor FastAPI/uvicorn debe escuchar en `0.0.0.0`, no solo en
> `127.0.0.1`, para ser alcanzable desde el emulador:
> `uvicorn main:app --host 0.0.0.0 --port 8000`

### 2. HTTPS local con certificado autofirmado

Android (y por tanto Dio) rechaza por defecto los certificados autofirmados
durante el handshake TLS. Para desarrollo se acepta el certificado **solo en
modo debug**; en release la validación TLS se mantiene intacta.

```dart
// lib/core/network/dio_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

DioClient._()
    : dio = Dio(BaseOptions(/* ... */)) {
  if (kDebugMode) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient()
        ..badCertificateCallback = (cert, host, port) => true,
    );
  }
}
```

> ⚠️ Nunca omitir la validación TLS fuera de `kDebugMode`. En producción el
> backend debe presentar un certificado válido (CA reconocida).

### 3. Manifest de Android

- `android.permission.INTERNET` es **obligatorio** para cualquier petición.
- `android:usesCleartextTraffic="true"` **solo** se necesita para HTTP sin TLS.
  Al usar HTTPS se elimina (es un smell de seguridad mantenerlo).

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        android:label="trace_money"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

> Si en algún momento se necesita HTTP en claro (ej. backend sin TLS), volver a
> agregar `android:usesCleartextTraffic="true"` al `<application>`, o mejor, usar
> un `network_security_config.xml` que lo limite a dominios concretos.

---

## Parseo: montos como número vs string (200 OK pero "Error inesperado.")

**Síntoma:** las peticiones funcionan (200 OK) pero las pantallas de Cuentas,
Ingresos y Deudas muestran "Error inesperado.". Es un error de **parseo**, no de
red: Dio recibe la respuesta pero el `.fromJson` lanza un cast y cae en el
`catch` genérico del repositorio.

**Causa:** el contrato (`docs/api-reference.md`) define los montos como **string
decimal** (`"1500.00"`), pero el backend los serializa como **número JSON**:

```jsonc
// /accounts — lo que realmente devuelve el backend
{ "credit_limit": 8000.0, "cut_day": 21, ... }   // ❌ doc dice "8000.00" (string)
```

Así, `json['credit_limit'] as String` lanza
`type 'double' is not a subtype of type 'String'`. Solo fallaba en filas con
monto (cuentas `CREDITO`); las `DEBITO` tienen `credit_limit: null` y pasaban.

**Solución (lado app):** parsear montos de forma tolerante a número o string con
los helpers de `lib/core/utils/json_parsers.dart`:

```dart
String? asDecimalStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num) return value.toStringAsFixed(2);
  return value.toString();
}
String asDecimalString(dynamic value) => asDecimalStringOrNull(value) ?? '0.00';
```

Usar estos helpers en **todos** los campos de dinero de los modelos
(`amount`, `credit_limit`, `balance`, `total_owed`, `available_limit`,
`current_cycle_charges`, `next_payment_amount`, …). Nunca `json['x'] as String`
para un monto.

> Alternativa (lado backend): serializar los `Decimal` como string en Pydantic
> para cumplir el contrato. Mientras eso no ocurra, los helpers protegen la app.

**Diagnóstico:** para ver la respuesta cruda y el error exacto, el `DioClient`
tiene un `LogInterceptor` (solo `kDebugMode`) y los repos loguean el error de
parseo con `dart:developer log(...)` antes de devolver el `Failure`.

---

## "Connection closed before full header was received" (intermitente)

**Síntoma:** al entrar **por primera vez** a una pantalla tras unos segundos de
inactividad, la petición falla con:

```
DioException [unknown]: null
HttpException: Connection closed before full header was received
```

Al reintentar (segunda entrada) ya funciona.

**Causa:** race condition de **keep-alive** del `HttpClient` de `dart:io`. HTTP/1.1
reutiliza la conexión TCP; uvicorn cierra las conexiones ociosas tras su
`--timeout-keep-alive` (5s por defecto). Si el pool del cliente toma una conexión
que el servidor ya cerró, el socket muere antes de recibir headers. La segunda
vez ya hay una conexión fresca, por eso "se arregla solo".

> Se acentúa en dev local (keep-alive corto + red local), pero no es exclusivo de
> dev: cualquier servidor/proxy que cierre conexiones ociosas puede provocarlo.

**Solución:**

1. **`RetryInterceptor`** (`lib/core/network/retry_interceptor.dart`) — reintenta
   errores de conexión transitorios (`connectionError`, timeouts, y
   `HttpException`/`SocketException` bajo `unknown`). Solo métodos **idempotentes**
   (GET/HEAD/DELETE/PUT) para no duplicar POST. Aplica en debug y release.
2. **`idleTimeout` del `HttpClient`** (debug) por debajo del keep-alive de uvicorn
   (3s < 5s), para que sea el cliente quien suelte la conexión ociosa primero.

---

## Checklist rápido cuando "no conecta al backend"

1. ¿El backend escucha en `0.0.0.0:8000`? (no solo `127.0.0.1`)
2. ¿`baseUrl` usa `10.0.2.2` en emulador / IP LAN en físico? (no `localhost`)
3. ¿Existe `<uses-permission android:name="android.permission.INTERNET" />`?
4. Si es HTTPS con cert autofirmado: ¿está el `badCertificateCallback` activo en debug?
5. Si es HTTP en claro: ¿está `usesCleartextTraffic="true"`?
6. Ignorar los warnings de `Choreographer`, `ImeTracker` y `userfaultfd`.

---

## Archivos involucrados

- `lib/core/network/api_constants.dart` — `baseUrl`
- `lib/core/network/dio_client.dart` — adapter TLS + `LogInterceptor` + retry + `idleTimeout`
- `lib/core/network/retry_interceptor.dart` — reintento de errores de conexión transitorios
- `android/app/src/main/AndroidManifest.xml` — permiso INTERNET / cleartext
- `lib/core/utils/json_parsers.dart` — helpers de montos tolerantes a número/string
- `lib/features/*/infrastructure/models/*_model.dart` — uso de los helpers
- `lib/features/*/infrastructure/repositories/*_impl.dart` — `log(...)` del error de parseo
