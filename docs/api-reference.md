# TraceMoney — Referencia de API

Documento de referencia para clientes (web, mobile, etc.) que consuman la API de TraceMoney.
La interfaz web existente implementa todas las funcionalidades descritas aquí y puede usarse como guía de comportamiento esperado.

> **Este documento refleja el contrato real serializado por el backend.** Los endpoints
> devuelven los _read models_ tal cual (sin un `response_model` de Pydantic), por lo que la
> forma exacta en el cable es la que produce el `jsonable_encoder` de FastAPI. Presta especial
> atención a la sección **Tipos de datos en el contrato** — sobre todo a los montos.

---

## Información general

| Atributo            | Valor                                                                                                                                         |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Base URL            | `http://localhost:8000/api/v1` (o `https://<host>:8000/api/v1` si se sirve con TLS — ver `docs/plans/backend-https-uvicorn-tls.md`)           |
| Autenticación       | Ninguna (app de un solo usuario)                                                                                                              |
| Moneda              | MXN                                                                                                                                           |
| Montos              | En **responses** se serializan como **número JSON** (ej. `1500.0`). En **requests** se aceptan número o cadena (ej. `"1500.00"`). Ver abajo.  |
| Fechas              | `YYYY-MM-DD` en zona horaria local. **Nunca enviar fechas derivadas de `.toISOString()` en JavaScript** — usar la fecha local del dispositivo |
| Content-Type        | `application/json`                                                                                                                            |
| Swagger interactivo | `http://localhost:8000/docs`                                                                                                                  |

---

## Tipos de datos en el contrato

El backend devuelve los read models directamente, sin un `response_model`. La serialización
la hace `jsonable_encoder` de FastAPI, con estas reglas (verificadas contra el código):

| Tipo en el dominio                                              | En el **response** (JSON)                                     | En el **request** (JSON)                                     |
| --------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------ |
| `Decimal` (montos, tasas, CAT)                                  | **Número** — ej. `1500.0`, `29.9`, `0.0`                      | Número **o** cadena: `1500.00` o `"1500.00"` (ambos válidos) |
| `float` (porcentajes: `*_pct`, `percentage`, `paid_percentage`) | Número — ej. `41.0`                                           | n/a (solo lectura)                                           |
| `int` (días, meses, plazos)                                     | Número entero — ej. `12`                                      | Número entero                                                |
| `UUID`                                                          | Cadena — ej. `"7b844cb9-…"`                                   | Cadena UUID                                                  |
| `date`                                                          | Cadena `YYYY-MM-DD` — ej. `"2026-06-17"`                      | Cadena `YYYY-MM-DD`                                          |
| `datetime` (`created_at`)                                       | Cadena ISO **sin zona horaria** — ej. `"2026-06-17T18:30:00"` | n/a (solo lectura)                                           |
| `None`                                                          | `null`                                                        | `null` u omitir (según el campo)                             |

> ⚠️ **Importante para los montos.**
>
> - En las respuestas, un `Decimal` se emite como **número JSON**, no como cadena. La
>   precisión de ceros a la derecha **no** se preserva: `Decimal("1500.00")` llega como
>   `1500.0`, y `Decimal("8200.00")` como `8200.0`. El cliente debe **formatear para
>   mostrar** (2 decimales, separador de miles, símbolo `$`).
> - Por ser número JSON (IEEE-754 doble), para aritmética monetaria exacta conviene
>   redondear/normalizar en el cliente, o tratar el valor como dinero con una librería
>   decimal antes de sumar.
> - En los **requests**, los modelos Pydantic declaran `Decimal`, que acepta tanto número
>   como cadena. **Se recomienda enviar el monto como cadena** (`"350.00"`) para no perder
>   precisión por el redondeo de punto flotante del propio cliente.

---

## Formato de errores

Existen **dos formas de error** según el origen:

### 1. Errores de dominio / negocio (envelope `code` + `message`)

Los lanzados por la lógica de la aplicación (`DomainException`) usan este envelope:

```json
{
  "detail": {
    "code": "EXPENSE_NOT_FOUND",
    "message": "El gasto indicado no existe."
  }
}
```

| HTTP Status                | Cuándo se usa                                                                  |
| -------------------------- | ------------------------------------------------------------------------------ |
| `404 Not Found`            | El `code` del error termina en `_NOT_FOUND` (o lo contiene, según el endpoint) |
| `422 Unprocessable Entity` | Cualquier otro error de dominio (regla de negocio violada)                     |

### 2. Errores de validación de la petición (formato estándar de FastAPI)

Si el **cuerpo o los parámetros** no cumplen el esquema (campo faltante, tipo inválido,
fecha mal formada, etc.), FastAPI responde `422` con su formato estándar — **no** el
envelope `code`/`message`:

```json
{
  "detail": [
    {
      "type": "missing",
      "loc": ["body", "amount"],
      "msg": "Field required",
      "input": { "...": "..." }
    }
  ]
}
```

> Los clientes deben distinguir ambos: si `detail` es un **objeto** con `code`/`message`,
> es un error de negocio; si es un **arreglo**, es un error de validación de esquema.

### Respuestas de éxito

| HTTP Status      | Body                                 |
| ---------------- | ------------------------------------ |
| `201 Created`    | `{ "id": "<uuid>" }`                 |
| `204 No Content` | _(sin body)_                         |
| `200 OK`         | El recurso o la colección solicitada |

---

## Enumeraciones

### `account_type`

| Valor     | Descripción                         |
| --------- | ----------------------------------- |
| `DEBITO`  | Tarjeta de débito / cuenta de banco |
| `CREDITO` | Tarjeta de crédito                  |

### `payment_method` (gastos)

| Valor           | Descripción                                        |
| --------------- | -------------------------------------------------- |
| `EFECTIVO`      | Pago en efectivo                                   |
| `DEBITO`        | Cobro a tarjeta de débito (requiere `account_id`)  |
| `CREDITO`       | Cobro a tarjeta de crédito (requiere `account_id`) |
| `TRANSFERENCIA` | Transferencia bancaria                             |

### `tag` (gastos)

| Valor      | Descripción                              |
| ---------- | ---------------------------------------- |
| `FIJO`     | Gasto fijo recurrente (renta, servicios) |
| `VARIABLE` | Gasto variable discrecional              |
| `HORMIGA`  | Gasto pequeño y frecuente                |

### `source` (ingresos)

`SUELDO` · `FREELANCE` · `BONO` · `INVERSION` · `RENTA` · `OTRO`

### `status` (planes, préstamos)

`ACTIVO` · `CANCELADO`

### `payment_status`

`PENDIENTE` · `PAGADO`

### `movement_type` (movimientos de cuenta)

| Valor             | Descripción                             |
| ----------------- | --------------------------------------- |
| `CAPITAL_INICIAL` | Primera asignación de saldo a la cuenta |
| `AJUSTE_CAPITAL`  | Corrección posterior de saldo           |
| `TRANSFER_IN`     | Dinero recibido de otra cuenta          |
| `TRANSFER_OUT`    | Dinero enviado a otra cuenta            |

---

## Health check

```
GET /health
```

**Response `200`**

```json
{ "status": "ok", "service": "tracemoney" }
```

---

## Cuentas `/api/v1/accounts`

### Listar cuentas

```
GET /api/v1/accounts
```

**Response `200`** — `AccountResponse[]`

```json
[
  {
    "id": "7b844cb9-e656-400b-9932-160b3d6942c6",
    "account_type": "DEBITO",
    "bank_name": "BBVA",
    "color": "#6366f1",
    "credit_limit": null,
    "cut_day": null,
    "payment_due_day": null,
    "created_at": "2026-06-01T10:00:00"
  }
]
```

| Campo             | Tipo JSON             | Notas                          |
| ----------------- | --------------------- | ------------------------------ |
| `id`              | string (UUID)         |                                |
| `account_type`    | string                | `DEBITO` \| `CREDITO`          |
| `bank_name`       | string                |                                |
| `color`           | string                | Hex CSS                        |
| `credit_limit`    | number \| null        | Solo crédito; `null` en débito |
| `cut_day`         | int \| null           | Solo crédito                   |
| `payment_due_day` | int \| null           | Solo crédito                   |
| `created_at`      | string (ISO datetime) |                                |

> Para tarjetas de crédito, `credit_limit`, `cut_day` y `payment_due_day` tendrán valor.
> Para débito, esos tres campos son `null`.

---

### Crear cuenta

```
POST /api/v1/accounts
```

**Body**

```json
{
  "account_type": "DEBITO",
  "bank_name": "BBVA",
  "color": "#6366f1",
  "credit_limit": null,
  "cut_day": null,
  "payment_due_day": null
}
```

| Campo             | Tipo                 | Requerido    | Notas                      |
| ----------------- | -------------------- | ------------ | -------------------------- |
| `account_type`    | string               | Sí           | `DEBITO` \| `CREDITO`      |
| `bank_name`       | string               | Sí           | Nombre del banco o apodo   |
| `color`           | string               | No           | Hex CSS, default `#6366f1` |
| `credit_limit`    | number\|string\|null | Solo crédito | Límite de la tarjeta       |
| `cut_day`         | int\|null            | Solo crédito | Día del mes (1–31)         |
| `payment_due_day` | int\|null            | Solo crédito | Día del mes (1–31)         |

**Response `201`**

```json
{ "id": "7b844cb9-e656-400b-9932-160b3d6942c6" }
```

---

### Actualizar cuenta

```
PUT /api/v1/accounts/{account_id}
```

**Body** — todos los campos requeridos (PUT completo). No incluye `account_type`.

```json
{
  "bank_name": "BBVA Débito",
  "color": "#10b981",
  "credit_limit": null,
  "cut_day": null,
  "payment_due_day": null
}
```

| Campo             | Tipo                 | Requerido |
| ----------------- | -------------------- | --------- |
| `bank_name`       | string               | Sí        |
| `color`           | string               | Sí        |
| `credit_limit`    | number\|string\|null | No        |
| `cut_day`         | int\|null            | No        |
| `payment_due_day` | int\|null            | No        |

**Response `204`**

---

### Eliminar cuenta

```
DELETE /api/v1/accounts/{account_id}
```

**Response `204`**

---

### Asignar capital (saldo inicial o ajuste)

```
POST /api/v1/accounts/{account_id}/capital
```

Registra el saldo de una cuenta de débito. Puede llamarse varias veces; el primer registro crea un movimiento `CAPITAL_INICIAL`, los siguientes crean `AJUSTE_CAPITAL`.

**Body**

```json
{
  "amount": "5000.00",
  "movement_date": "2026-06-17",
  "note": "Saldo inicial"
}
```

| Campo           | Tipo           | Requerido |
| --------------- | -------------- | --------- |
| `amount`        | number\|string | Sí        |
| `movement_date` | date           | Sí        |
| `note`          | string\|null   | No        |

**Response `204`**

---

### Transferir entre cuentas de débito

```
POST /api/v1/accounts/{account_id}/transfer
```

Transfiere saldo de la cuenta origen (`account_id`) a la cuenta destino. Ambas deben ser de tipo `DEBITO`.

**Body**

```json
{
  "target_account_id": "uuid-de-la-cuenta-destino",
  "amount": "2000.00",
  "transfer_date": "2026-06-17",
  "note": "Pago de renta"
}
```

| Campo               | Tipo           | Requerido |
| ------------------- | -------------- | --------- |
| `target_account_id` | string (UUID)  | Sí        |
| `amount`            | number\|string | Sí        |
| `transfer_date`     | date           | Sí        |
| `note`              | string\|null   | No        |

**Response `204`**

> Genera dos movimientos: `TRANSFER_OUT` en la cuenta origen y `TRANSFER_IN` en la cuenta destino.

---

### Estado financiero de una cuenta

```
GET /api/v1/accounts/{account_id}/status
```

Devuelve métricas calculadas en tiempo real (`AccountStatusResponse`). Si la cuenta no existe → `404`.

**Response `200`** (ejemplo de cuenta de **crédito**)

```json
{
  "id": "uuid",
  "account_type": "CREDITO",
  "bank_name": "BBVA",
  "color": "#6366f1",
  "balance": null,
  "credit_limit": 20000.0,
  "cut_day": 5,
  "payment_due_day": 25,
  "current_cycle_charges": 3500.0,
  "total_owed": 8200.0,
  "available_limit": 11800.0,
  "utilization_pct": 41.0,
  "next_payment_amount": 8200.0,
  "next_payment_date": "2026-07-25",
  "days_to_cut": 18,
  "days_to_payment": 38
}
```

| Campo                                                                                           | Tipo JSON              | Débito | Crédito |
| ----------------------------------------------------------------------------------------------- | ---------------------- | ------ | ------- |
| `id`, `account_type`, `bank_name`, `color`                                                      | string                 | ✓      | ✓       |
| `balance`                                                                                       | number \| null         | valor  | `null`  |
| `credit_limit`, `current_cycle_charges`, `total_owed`, `available_limit`, `next_payment_amount` | number \| null         | `null` | valor   |
| `cut_day`, `payment_due_day`, `days_to_cut`, `days_to_payment`                                  | int \| null            | `null` | valor   |
| `utilization_pct`                                                                               | number (float) \| null | `null` | valor   |
| `next_payment_date`                                                                             | date \| null           | `null` | valor   |

> Para cuentas de **débito**: solo `balance` tiene valor; los demás campos son `null`.
> Para cuentas de **crédito**: `balance` es `null`; el resto de campos tienen valor.

---

### Historial de movimientos

```
GET /api/v1/accounts/{account_id}/movements
```

**Response `200`** — `AccountMovementResponse[]`

```json
[
  {
    "id": "uuid",
    "account_id": "uuid",
    "movement_type": "TRANSFER_OUT",
    "amount": 2000.0,
    "movement_date": "2026-06-17",
    "note": "Pago de renta",
    "related_account_id": "uuid-cuenta-destino"
  }
]
```

> `related_account_id` es `null` excepto en movimientos de tipo `TRANSFER_IN` / `TRANSFER_OUT`.

---

## Gastos `/api/v1/expenses`

### Crear gasto

```
POST /api/v1/expenses
```

**Body**

```json
{
  "amount": "350.00",
  "description": "Despensa semanal",
  "category_id": "uuid-de-categoria",
  "tag": "VARIABLE",
  "payment_method": "DEBITO",
  "expense_date": "2026-06-17",
  "account_id": "uuid-de-cuenta"
}
```

| Campo            | Tipo                | Requerido   | Notas                                                 |
| ---------------- | ------------------- | ----------- | ----------------------------------------------------- |
| `amount`         | number\|string      | Sí          | Mayor que 0                                           |
| `description`    | string              | Sí          |                                                       |
| `category_id`    | string (UUID)       | Sí          | UUID de una categoría existente                       |
| `tag`            | string              | Sí          | `FIJO` \| `VARIABLE` \| `HORMIGA`                     |
| `payment_method` | string              | Sí          | Ver enum `payment_method`                             |
| `expense_date`   | date                | Sí          |                                                       |
| `account_id`     | string (UUID)\|null | Condicional | Requerido si `payment_method` es `DEBITO` o `CREDITO` |

**Response `201`**

```json
{ "id": "uuid" }
```

---

### Editar gasto

```
PUT /api/v1/expenses/{expense_id}
```

Todos los campos son opcionales; solo se actualizan los que se envíen con valor distinto de `null`.

**Body**

```json
{
  "amount": "400.00",
  "description": "Despensa semanal (ajuste)",
  "category_id": "uuid",
  "tag": "VARIABLE",
  "payment_method": "EFECTIVO",
  "expense_date": "2026-06-17",
  "account_id": null
}
```

**Response `204`**

---

### Eliminar gasto

```
DELETE /api/v1/expenses/{expense_id}
```

**Response `204`**

---

### Gastos por semana

```
GET /api/v1/expenses/week?week_start=2026-06-15&week_end=2026-06-21
```

| Query param  | Tipo | Requerido |
| ------------ | ---- | --------- |
| `week_start` | date | Sí        |
| `week_end`   | date | Sí        |

**Response `200`** — `ExpenseResponse[]`

```json
[
  {
    "id": "uuid",
    "amount": 350.0,
    "description": "Despensa semanal",
    "category_id": "uuid",
    "category_name": "Alimentación",
    "tag": "VARIABLE",
    "payment_method": "DEBITO",
    "expense_date": "2026-06-17",
    "created_at": "2026-06-17T18:30:00",
    "account_id": "uuid"
  }
]
```

| Campo           | Tipo JSON             | Notas                                    |
| --------------- | --------------------- | ---------------------------------------- |
| `amount`        | number                |                                          |
| `category_name` | string \| null        | Nombre resuelto de la categoría          |
| `account_id`    | string (UUID) \| null | `null` si pago en efectivo/transferencia |

> **Rango semanal recomendado:** lunes a domingo. Calcular la fecha del lunes de la semana actual usando la fecha **local** del dispositivo.

---

### Gastos por mes

```
GET /api/v1/expenses/month?year=2026&month=6
```

| Query param      | Tipo          | Requerido | Notas                     |
| ---------------- | ------------- | --------- | ------------------------- |
| `year`           | int           | Sí        |                           |
| `month`          | int           | Sí        | 1–12                      |
| `category_id`    | string (UUID) | No        | Filtra por categoría      |
| `tag`            | string        | No        | Filtra por etiqueta       |
| `payment_method` | string        | No        | Filtra por método de pago |

**Response `200`** — `ExpenseResponse[]` (mismo esquema que semana)

---

### Listar categorías

```
GET /api/v1/expenses/categories
```

**Response `200`** — `CategoryResponse[]`

```json
[
  {
    "id": "uuid",
    "name": "Alimentación",
    "parent_id": null,
    "color": "#10b981"
  },
  {
    "id": "uuid",
    "name": "Restaurantes",
    "parent_id": "uuid-alimentacion",
    "color": "#10b981"
  }
]
```

> Las categorías pueden ser jerárquicas (padre → hijo). `parent_id = null` indica categoría raíz.

---

### Crear categoría

```
POST /api/v1/expenses/categories
```

**Body**

```json
{
  "name": "Transporte",
  "color": "#f59e0b",
  "parent_id": null
}
```

| Campo       | Tipo                | Requerido | Notas                      |
| ----------- | ------------------- | --------- | -------------------------- |
| `name`      | string              | Sí        |                            |
| `color`     | string              | No        | Hex CSS, default `#6366f1` |
| `parent_id` | string (UUID)\|null | No        | Categoría padre            |

**Response `201`** → `{ "id": "uuid" }`

---

### Editar categoría

```
PUT /api/v1/expenses/categories/{category_id}
```

**Body** — ambos campos requeridos.

```json
{
  "name": "Transporte público",
  "color": "#f59e0b"
}
```

**Response `204`**

---

## Ingresos `/api/v1/income`

### Registrar ingreso

```
POST /api/v1/income
```

**Body**

```json
{
  "amount": "18000.00",
  "source": "SUELDO",
  "income_date": "2026-06-15",
  "note": "Quincena junio",
  "account_id": "uuid-cuenta-debito"
}
```

| Campo         | Tipo                | Requerido | Notas                                  |
| ------------- | ------------------- | --------- | -------------------------------------- |
| `amount`      | number\|string      | Sí        |                                        |
| `source`      | string              | Sí        | Ver enum `source`                      |
| `income_date` | date                | Sí        |                                        |
| `note`        | string\|null        | No        |                                        |
| `account_id`  | string (UUID)\|null | No        | Cuenta de débito que recibe el ingreso |

**Response `201`** → `{ "id": "uuid" }`

---

### Editar ingreso

```
PUT /api/v1/income/{income_id}
```

**Body** — `amount`, `source` e `income_date` requeridos; `note` y `account_id` opcionales (PUT completo).

```json
{
  "amount": "18000.00",
  "source": "SUELDO",
  "income_date": "2026-06-15",
  "note": null,
  "account_id": null
}
```

**Response `204`**

---

### Eliminar ingreso

```
DELETE /api/v1/income/{income_id}
```

**Response `204`**

---

### Ingresos por mes

```
GET /api/v1/income/month?year=2026&month=6
```

**Response `200`** — `IncomeResponse[]`

```json
[
  {
    "id": "uuid",
    "amount": 18000.0,
    "source": "SUELDO",
    "note": "Quincena junio",
    "income_date": "2026-06-15",
    "created_at": "2026-06-15T09:00:00",
    "account_id": "uuid"
  }
]
```

---

## Deudas `/api/v1/debts`

El contexto de deudas maneja dos entidades independientes:

- **Planes a meses (MSI)** — compras diferidas en tarjeta de crédito
- **Préstamos personales** — créditos con amortización calculada por CAT anual

Ambas entidades requieren una **tarjeta de crédito** registrada en `/debts/cards`.

---

### Tarjetas de crédito (deudas)

> Estas tarjetas son entidades del contexto de **deudas** (para asociar planes y préstamos).
> Las cuentas de crédito del contexto de **cuentas** son independientes y se usan para rastrear gastos.

#### Listar tarjetas

```
GET /api/v1/debts/cards
```

**Response `200`** — `CreditCardResponse[]`

```json
[
  {
    "id": "uuid",
    "bank_name": "BBVA Azul",
    "credit_limit": 20000.0,
    "cut_day": 5,
    "payment_due_day": 25,
    "color": "#3b82f6",
    "created_at": "2026-01-10T10:00:00"
  }
]
```

#### Crear tarjeta

```
POST /api/v1/debts/cards
```

**Body**

```json
{
  "bank_name": "BBVA Azul",
  "credit_limit": "20000.00",
  "cut_day": 5,
  "payment_due_day": 25,
  "color": "#3b82f6"
}
```

| Campo             | Tipo           | Requerido | Notas                      |
| ----------------- | -------------- | --------- | -------------------------- |
| `bank_name`       | string         | Sí        |                            |
| `credit_limit`    | number\|string | Sí        |                            |
| `cut_day`         | int            | Sí        | Día del mes (1–31)         |
| `payment_due_day` | int            | Sí        | Día del mes (1–31)         |
| `color`           | string         | No        | Hex CSS, default `#6366f1` |

**Response `201`** → `{ "id": "uuid" }`

#### Actualizar tarjeta

```
PUT /api/v1/debts/cards/{card_id}
```

**Body** — igual que crear, pero `color` también requerido (todos los campos).

**Response `204`**

---

### Planes a meses (MSI)

#### Listar planes activos

```
GET /api/v1/debts/plans/active
```

**Response `200`** — `ActivePlanResponse[]`

```json
[
  {
    "plan_id": "uuid",
    "concept": "iPhone 15",
    "bank_name": "BBVA Azul",
    "total_amount": 18000.0,
    "num_installments": 12,
    "purchase_date": "2026-01-15",
    "interest_rate": 0.0,
    "credit_card_id": "uuid",
    "status": "ACTIVO",
    "payments": [
      {
        "payment_id": "uuid",
        "month_number": 1,
        "amount": 1500.0,
        "due_date": "2026-02-05",
        "status": "PAGADO",
        "paid_amount": 1500.0
      },
      {
        "payment_id": "uuid",
        "month_number": 2,
        "amount": 1500.0,
        "due_date": "2026-03-05",
        "status": "PENDIENTE",
        "paid_amount": null
      }
    ]
  }
]
```

| Campo                    | Tipo JSON      | Notas                                  |
| ------------------------ | -------------- | -------------------------------------- |
| `total_amount`           | number         |                                        |
| `interest_rate`          | number         | Tasa anual %; `0.0` si MSI sin interés |
| `credit_card_id`         | string (UUID)  |                                        |
| `status`                 | string         | `ACTIVO` \| `CANCELADO`                |
| `payments[]`             | array          | Tabla de mensualidades (ver abajo)     |
| `payments[].paid_amount` | number \| null | `null` si pendiente                    |

#### Crear plan

```
POST /api/v1/debts/plans
```

**Body**

```json
{
  "credit_card_id": "uuid",
  "concept": "iPhone 15",
  "total_amount": "18000.00",
  "num_installments": 12,
  "annual_interest_rate": "0",
  "purchase_date": "2026-01-15"
}
```

| Campo                  | Tipo           | Requerido | Notas                                      |
| ---------------------- | -------------- | --------- | ------------------------------------------ |
| `credit_card_id`       | string (UUID)  | Sí        | Tarjeta de crédito existente               |
| `concept`              | string         | Sí        | Descripción de la compra                   |
| `total_amount`         | number\|string | Sí        | Monto total de la compra                   |
| `num_installments`     | int            | Sí        | Número de mensualidades                    |
| `annual_interest_rate` | number\|string | No        | Tasa anual en %, default `0` (sin interés) |
| `purchase_date`        | date           | Sí        | Fecha de compra                            |

**Response `201`** → `{ "id": "uuid" }`

> Nota: en el **request** el campo se llama `annual_interest_rate`; en el **response** del
> plan activo se expone como `interest_rate`.

#### Editar plan

```
PUT /api/v1/debts/plans/{plan_id}
```

**Body** — solo `concept` es requerido; el resto opcionales (`null` = no cambiar).

```json
{
  "concept": "iPhone 15 Pro",
  "total_amount": null,
  "num_installments": null,
  "annual_interest_rate": null,
  "purchase_date": null
}
```

**Response `204`**

#### Cancelar plan

```
DELETE /api/v1/debts/plans/{plan_id}
```

Soft-delete: cambia `status` a `CANCELADO`. Los pagos ya realizados se conservan.

**Response `204`**

#### Marcar mensualidad como pagada

```
POST /api/v1/debts/plans/{plan_id}/payments/{payment_id}/pay
```

**Body**

```json
{
  "paid_amount": "1500.00"
}
```

| Campo         | Tipo                 | Requerido | Notas                                               |
| ------------- | -------------------- | --------- | --------------------------------------------------- |
| `paid_amount` | number\|string\|null | No        | Si se omite/`null`, se registra el monto programado |

**Response `204`**

#### Marcar múltiples mensualidades como pagadas

```
POST /api/v1/debts/plans/{plan_id}/payments/bulk-pay
```

**Body**

```json
{
  "payment_ids": ["uuid-payment-1", "uuid-payment-2"],
  "paid_amount": "3000.00"
}
```

| Campo         | Tipo                 | Requerido | Notas                                                                    |
| ------------- | -------------------- | --------- | ------------------------------------------------------------------------ |
| `payment_ids` | string[] (UUID)      | Sí        | IDs de las mensualidades                                                 |
| `paid_amount` | number\|string\|null | No        | Total distribuido entre los pagos; `null` = monto programado de cada uno |

**Response `204`**

#### Registrar pago extra

```
POST /api/v1/debts/plans/{plan_id}/extra-payment
```

**Body**

```json
{
  "extra_amount": "500.00"
}
```

| Campo          | Tipo           | Requerido |
| -------------- | -------------- | --------- |
| `extra_amount` | number\|string | Sí        |

**Response `204`**

#### Deudas del mes (MSI)

```
GET /api/v1/debts/month?year=2026&month=6
```

**Response `200`** — `MonthDebtSummaryResponse`

```json
{
  "year": 2026,
  "month": 6,
  "total": 4500.0,
  "payments": [
    {
      "payment_id": "uuid",
      "plan_id": "uuid",
      "concept": "iPhone 15",
      "bank_name": "BBVA Azul",
      "amount": 1500.0,
      "due_date": "2026-06-05",
      "status": "PENDIENTE",
      "paid_amount": null,
      "month_number": 6,
      "num_installments": 12
    }
  ]
}
```

---

### Préstamos personales

Los préstamos se amortizan usando el CAT anual y generan una tabla de pagos con desglose de capital e interés.

#### Crear préstamo

```
POST /api/v1/debts/loans
```

**Body**

```json
{
  "card_id": "uuid-tarjeta-credito",
  "concept": "Préstamo personal BBVA",
  "capital": "50000.00",
  "cat_anual": "29.9",
  "plazo_meses": 24,
  "loan_date": "2026-06-01"
}
```

| Campo         | Tipo           | Requerido | Notas                                |
| ------------- | -------------- | --------- | ------------------------------------ |
| `card_id`     | string (UUID)  | Sí        | Tarjeta de crédito asociada          |
| `concept`     | string         | Sí        | Descripción del préstamo             |
| `capital`     | number\|string | Sí        | Monto total del préstamo             |
| `cat_anual`   | number\|string | Sí        | CAT anual en porcentaje (ej. `29.9`) |
| `plazo_meses` | int            | Sí        | Número de meses del crédito          |
| `loan_date`   | date           | Sí        | Fecha de inicio del préstamo         |

**Response `201`** → `{ "id": "uuid" }`

#### Detalle de un préstamo

```
GET /api/v1/debts/loans/{loan_id}
```

Si el préstamo no existe → `404`.

**Response `200`** — `LoanDetailResponse`

```json
{
  "loan_id": "uuid",
  "concept": "Préstamo personal BBVA",
  "capital": 50000.0,
  "cat_anual": 29.9,
  "plazo_meses": 24,
  "loan_date": "2026-06-01",
  "bank_name": "BBVA Azul",
  "card_id": "uuid",
  "status": "ACTIVO"
}
```

#### Editar préstamo

```
PUT /api/v1/debts/loans/{loan_id}
```

**Body** — solo `concept` es requerido; el resto opcionales (`null` = no cambiar).

```json
{
  "concept": "Préstamo personal BBVA (ajuste)",
  "capital": null,
  "cat_anual": null,
  "plazo_meses": null,
  "loan_date": null
}
```

**Response `204`**

#### Cancelar préstamo

```
DELETE /api/v1/debts/loans/{loan_id}
```

Soft-delete: `status` → `CANCELADO`.

**Response `204`**

#### Pagos de préstamos del mes

```
GET /api/v1/debts/loans/month?year=2026&month=6
```

**Response `200`** — `MonthLoanSummaryResponse`

```json
{
  "year": 2026,
  "month": 6,
  "total": 2800.0,
  "payments": [
    {
      "payment_id": "uuid",
      "loan_id": "uuid",
      "concept": "Préstamo personal BBVA",
      "bank_name": "BBVA Azul",
      "month_number": 1,
      "cuota": 2800.0,
      "interes": 620.0,
      "abono_capital": 2180.0,
      "saldo_final": 47820.0,
      "due_date": "2026-07-01",
      "status": "PENDIENTE",
      "paid_amount": null
    }
  ]
}
```

| Campo (payment) | Tipo JSON      | Notas                           |
| --------------- | -------------- | ------------------------------- |
| `cuota`         | number         | Pago mensual total              |
| `interes`       | number         | Parte de interés del pago       |
| `abono_capital` | number         | Parte de capital del pago       |
| `saldo_final`   | number         | Saldo de capital tras este pago |
| `paid_amount`   | number \| null | `null` si pendiente             |

#### Marcar pago de préstamo como pagado

```
POST /api/v1/debts/loans/{loan_id}/payments/{payment_id}/pay
```

**Body**

```json
{
  "paid_amount": "2800.00"
}
```

| Campo         | Tipo                 | Requerido | Notas                                               |
| ------------- | -------------------- | --------- | --------------------------------------------------- |
| `paid_amount` | number\|string\|null | No        | Si se omite/`null`, se registra el monto programado |

**Response `204`**

---

## Analytics `/api/v1/analytics`

### Dashboard mensual

```
GET /api/v1/analytics/dashboard?year=2026&month=6
```

Agrega en un solo request todos los datos necesarios para la pantalla principal (`DashboardSummaryResponse`).

**Response `200`**

```json
{
  "year": 2026,
  "month": 6,
  "total_income": 18000.0,
  "total_expenses": 8500.0,
  "total_debt_payments": 4300.0,
  "net_balance": 5200.0,
  "total_active_debt": 62000.0,
  "category_breakdown": [
    {
      "category_id": "uuid",
      "category_name": "Alimentación",
      "total": 3200.0,
      "percentage": 37.6,
      "color": "#10b981"
    }
  ],
  "tag_breakdown": [
    {
      "tag": "VARIABLE",
      "total": 5100.0,
      "percentage": 60.0
    }
  ],
  "monthly_history": [
    {
      "year": 2026,
      "month": 4,
      "total_income": 18000.0,
      "total_expenses": 7200.0,
      "total_debt_payments": 4300.0,
      "net_balance": 6500.0
    }
  ],
  "active_debts": [
    {
      "plan_id": "uuid",
      "concept": "iPhone 15",
      "bank_name": "BBVA Azul",
      "total_amount": 18000.0,
      "remaining_balance": 13500.0,
      "paid_percentage": 25.0,
      "next_payment_amount": 1500.0,
      "next_payment_date": "2026-07-05"
    }
  ],
  "credit_card_status": [
    {
      "account_id": "uuid",
      "bank_name": "BBVA",
      "color": "#3b82f6",
      "credit_limit": 20000.0,
      "cut_day": 5,
      "payment_due_day": 25,
      "current_cycle_charges": 3500.0,
      "total_owed": 8200.0,
      "available_limit": 11800.0,
      "utilization_pct": 41.0,
      "next_payment_amount": 8200.0,
      "next_payment_date": "2026-07-25",
      "days_to_cut": 18,
      "days_to_payment": 38
    }
  ],
  "debit_accounts": [
    {
      "account_id": "uuid",
      "bank_name": "BBVA Débito",
      "color": "#6366f1",
      "balance": 12500.0
    }
  ]
}
```

Notas de tipos en el dashboard:

- Todos los montos (`total_*`, `net_balance`, `total`, `balance`, `*_amount`, `remaining_balance`, etc.) son **números**.
- `percentage`, `paid_percentage`, `utilization_pct` son **números** (float).
- `active_debts[].next_payment_date` es **string** (`YYYY-MM-DD`) o `null`.
- `credit_card_status[].next_payment_date` es **string** (`YYYY-MM-DD`) o `null`; el resto de sus montos y días siempre tienen valor.

---

### Estado de tarjeta de crédito (analytics)

```
GET /api/v1/analytics/cards/{account_id}/status
```

Mismo esquema que `GET /api/v1/accounts/{account_id}/status` (`AccountStatusResponse`) pero bajo el prefijo de analytics. Usa el `account_id` del contexto de **cuentas** (no el `id` de `/debts/cards`). Si no existe → `404`.

**Response `200`** — ver esquema de `AccountStatusResponse` en la sección Cuentas.

---

## Guía de implementación para clientes

### Manejo de montos

- En **responses**, los montos llegan como **números JSON** (ej. `1500.0`), sin preservar
  ceros a la derecha. Formatéalos en el cliente para mostrar (2 decimales, `$`, miles).
- Por ser números de punto flotante, evita acumular errores: redondea a 2 decimales o usa
  una librería decimal para la aritmética monetaria.
- En **requests**, envía los montos como **cadena** (`"350.00"`) para no perder precisión.

### Manejo de fechas

- Usar **siempre** la fecha local del dispositivo, nunca UTC.
- Al enviar una fecha al API, formatear como `YYYY-MM-DD` usando los componentes locales del `Date` (año, mes, día).
- Al mostrar fechas recibidas del API (`YYYY-MM-DD`), no pasar por `new Date(string)` directamente en JavaScript — puede desplazarlas un día. Parsear los componentes manualmente o usar una librería con soporte de zona horaria.
- `created_at` llega como datetime ISO **sin zona horaria** (`2026-06-17T18:30:00`); interpretarlo como hora local.

### Manejo de errores

- Si `detail` es un **objeto** `{ code, message }` → error de negocio; mostrar `message` y
  ramificar por `code` (los que terminan en `_NOT_FOUND` ⇒ `404`).
- Si `detail` es un **arreglo** → error de validación de esquema (FastAPI); revisar `loc`/`msg`.

### Flujos principales

#### Registrar un gasto

1. Obtener categorías: `GET /expenses/categories`
2. Obtener cuentas (si pago con tarjeta): `GET /accounts`
3. Crear el gasto: `POST /expenses`
4. Refrescar la lista: `GET /expenses/week` o `GET /expenses/month`

#### Dashboard

- Un solo request: `GET /analytics/dashboard?year=YYYY&month=M`
- Contiene todo lo necesario para la pantalla principal

#### Flujo de deudas

1. Registrar tarjeta: `POST /debts/cards`
2. Crear plan (`POST /debts/plans`) o préstamo (`POST /debts/loans`) asociado a la tarjeta
3. Consultar pagos del mes: `GET /debts/month` y `GET /debts/loans/month`
4. Marcar pagos como pagados: endpoints `/pay` (y `/payments/bulk-pay` para varios)

#### Vista semanal de gastos

- Calcular el lunes de la semana actual con la fecha local
- Enviar `week_start` (lunes) y `week_end` (domingo) en `YYYY-MM-DD`
- Para navegar semanas, sumar/restar 7 días al offset

### Convenciones de IDs

- Todos los IDs son **UUID** en formato string.
- Al crear un recurso, el API devuelve el UUID generado en `{ "id": "uuid" }`.
- Guardar el ID localmente para operaciones posteriores (editar, eliminar, marcar como pagado).
