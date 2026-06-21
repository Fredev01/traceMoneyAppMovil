# TraceMoney — Referencia de API

Documento de referencia para clientes (web, mobile, etc.) que consuman la API de TraceMoney.  
La interfaz web existente implementa todas las funcionalidades descritas aquí y puede usarse como guía de comportamiento esperado.

---

## Información general

| Atributo | Valor |
|---|---|
| Base URL | `http://localhost:8000/api/v1` |
| Autenticación | Ninguna (app de un solo usuario) |
| Moneda | MXN — los montos se manejan como cadenas decimales (ej. `"1500.00"`) |
| Fechas | `YYYY-MM-DD` en zona horaria local. **Nunca enviar fechas derivadas de `.toISOString()` en JavaScript** — usar la fecha local del dispositivo |
| Content-Type | `application/json` |
| Swagger interactivo | `http://localhost:8000/docs` |

---

## Formato de errores

Todos los errores devuelven este envelope:

```json
{
  "detail": {
    "code": "EXPENSE_NOT_FOUND",
    "message": "El gasto indicado no existe."
  }
}
```

| HTTP Status | Cuándo se usa |
|---|---|
| `201 Created` | Recurso creado; body: `{"id": "<uuid>"}` |
| `204 No Content` | Mutación exitosa sin body |
| `404 Not Found` | El `code` del error termina en `_NOT_FOUND` |
| `422 Unprocessable Entity` | Validación Pydantic o error de dominio |

---

## Enumeraciones

### `account_type`
| Valor | Descripción |
|---|---|
| `DEBITO` | Tarjeta de débito / cuenta de banco |
| `CREDITO` | Tarjeta de crédito |

### `payment_method` (gastos)
| Valor | Descripción |
|---|---|
| `EFECTIVO` | Pago en efectivo |
| `DEBITO` | Cobro a tarjeta de débito (requiere `account_id`) |
| `CREDITO` | Cobro a tarjeta de crédito (requiere `account_id`) |
| `TRANSFERENCIA` | Transferencia bancaria |

### `tag` (gastos)
| Valor | Descripción |
|---|---|
| `FIJO` | Gasto fijo recurrente (renta, servicios) |
| `VARIABLE` | Gasto variable discrecional |
| `HORMIGA` | Gasto pequeño y frecuente |

### `source` (ingresos)
`SUELDO` · `FREELANCE` · `BONO` · `INVERSION` · `RENTA` · `OTRO`

### `status` (planes e instalaciones)
`ACTIVO` · `CANCELADO`

### `payment_status`
`PENDIENTE` · `PAGADO`

### `movement_type` (movimientos de cuenta)
| Valor | Descripción |
|---|---|
| `CAPITAL_INICIAL` | Primera asignación de saldo a la cuenta |
| `AJUSTE_CAPITAL` | Corrección posterior de saldo |
| `TRANSFER_IN` | Dinero recibido de otra cuenta |
| `TRANSFER_OUT` | Dinero enviado a otra cuenta |

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
    "id": "uuid",
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

| Campo | Tipo | Requerido | Notas |
|---|---|---|---|
| `account_type` | `string` | Sí | `DEBITO` \| `CREDITO` |
| `bank_name` | `string` | Sí | Nombre del banco o apodo |
| `color` | `string` | No | Hex CSS, default `#6366f1` |
| `credit_limit` | `decimal\|null` | Solo crédito | Límite de la tarjeta |
| `cut_day` | `int\|null` | Solo crédito | Día del mes (1–31) |
| `payment_due_day` | `int\|null` | Solo crédito | Día del mes (1–31) |

**Response `201`**
```json
{ "id": "7b844cb9-e656-400b-9932-160b3d6942c6" }
```

---

### Actualizar cuenta
```
PUT /api/v1/accounts/{account_id}
```

**Body** — mismo esquema que crear (todos los campos requeridos en PUT)
```json
{
  "bank_name": "BBVA Débito",
  "color": "#10b981",
  "credit_limit": null,
  "cut_day": null,
  "payment_due_day": null
}
```

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

| Campo | Tipo | Requerido |
|---|---|---|
| `amount` | `decimal` | Sí |
| `movement_date` | `date` | Sí |
| `note` | `string\|null` | No |

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

| Campo | Tipo | Requerido |
|---|---|---|
| `target_account_id` | `uuid string` | Sí |
| `amount` | `decimal` | Sí |
| `transfer_date` | `date` | Sí |
| `note` | `string\|null` | No |

**Response `204`**

> Genera dos movimientos: `TRANSFER_OUT` en la cuenta origen y `TRANSFER_IN` en la cuenta destino.

---

### Estado financiero de una cuenta
```
GET /api/v1/accounts/{account_id}/status
```

Devuelve métricas calculadas en tiempo real.

**Response `200`**
```json
{
  "id": "uuid",
  "account_type": "CREDITO",
  "bank_name": "BBVA",
  "color": "#6366f1",
  "balance": null,
  "credit_limit": "20000.00",
  "cut_day": 5,
  "payment_due_day": 25,
  "current_cycle_charges": "3500.00",
  "total_owed": "8200.00",
  "available_limit": "11800.00",
  "utilization_pct": 41.0,
  "next_payment_amount": "8200.00",
  "next_payment_date": "2026-07-25",
  "days_to_cut": 18,
  "days_to_payment": 38
}
```

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
    "amount": "2000.00",
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

| Campo | Tipo | Requerido | Notas |
|---|---|---|---|
| `amount` | `decimal` | Sí | Mayor que 0 |
| `description` | `string` | Sí | |
| `category_id` | `uuid string` | Sí | UUID de una categoría existente |
| `tag` | `string` | Sí | `FIJO` \| `VARIABLE` \| `HORMIGA` |
| `payment_method` | `string` | Sí | Ver enum `payment_method` |
| `expense_date` | `date` | Sí | |
| `account_id` | `uuid string\|null` | Condicional | Requerido si `payment_method` es `DEBITO` o `CREDITO` |

**Response `201`**
```json
{ "id": "uuid" }
```

---

### Editar gasto
```
PUT /api/v1/expenses/{expense_id}
```

Todos los campos son opcionales; solo se actualizan los que se envíen.

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

| Query param | Tipo | Requerido |
|---|---|---|
| `week_start` | `date` | Sí |
| `week_end` | `date` | Sí |

**Response `200`** — `ExpenseResponse[]`
```json
[
  {
    "id": "uuid",
    "amount": "350.00",
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

> **Rango semanal recomendado:** lunes a domingo. Calcular la fecha del lunes de la semana actual usando la fecha **local** del dispositivo.

---

### Gastos por mes
```
GET /api/v1/expenses/month?year=2026&month=6
```

| Query param | Tipo | Requerido | Notas |
|---|---|---|---|
| `year` | `int` | Sí | |
| `month` | `int` | Sí | 1–12 |
| `category_id` | `uuid string` | No | Filtra por categoría |
| `tag` | `string` | No | Filtra por etiqueta |
| `payment_method` | `string` | No | Filtra por método de pago |

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

**Response `201`** → `{ "id": "uuid" }`

---

### Editar categoría
```
PUT /api/v1/expenses/categories/{category_id}
```

**Body**
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

| Campo | Tipo | Requerido | Notas |
|---|---|---|---|
| `amount` | `decimal` | Sí | |
| `source` | `string` | Sí | Ver enum `source` |
| `income_date` | `date` | Sí | |
| `note` | `string\|null` | No | |
| `account_id` | `uuid string\|null` | No | Cuenta de débito que recibe el ingreso |

**Response `201`** → `{ "id": "uuid" }`

---

### Editar ingreso
```
PUT /api/v1/income/{income_id}
```

**Body** — todos los campos requeridos (PUT completo)
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
    "amount": "18000.00",
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
    "credit_limit": "20000.00",
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

**Response `201`** → `{ "id": "uuid" }`

#### Actualizar tarjeta
```
PUT /api/v1/debts/cards/{card_id}
```

**Body** — igual que crear (todos requeridos)

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
    "credit_card_id": "uuid",
    "total_amount": "18000.00",
    "num_installments": 12,
    "interest_rate": "0",
    "purchase_date": "2026-01-15",
    "status": "ACTIVO",
    "payments": [
      {
        "payment_id": "uuid",
        "month_number": 1,
        "amount": "1500.00",
        "due_date": "2026-02-05",
        "status": "PAGADO",
        "paid_amount": "1500.00"
      },
      {
        "payment_id": "uuid",
        "month_number": 2,
        "amount": "1500.00",
        "due_date": "2026-03-05",
        "status": "PENDIENTE",
        "paid_amount": null
      }
    ]
  }
]
```

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

| Campo | Tipo | Requerido | Notas |
|---|---|---|---|
| `credit_card_id` | `uuid string` | Sí | Tarjeta de crédito existente |
| `concept` | `string` | Sí | Descripción de la compra |
| `total_amount` | `decimal` | Sí | Monto total de la compra |
| `num_installments` | `int` | Sí | Número de mensualidades |
| `annual_interest_rate` | `decimal` | No | Tasa anual en %, default `0` (sin interés) |
| `purchase_date` | `date` | Sí | Fecha de compra |

**Response `201`** → `{ "id": "uuid" }`

#### Editar plan
```
PUT /api/v1/debts/plans/{plan_id}
```

**Body**
```json
{
  "concept": "iPhone 15 Pro",
  "total_amount": null,
  "num_installments": null,
  "annual_interest_rate": null,
  "purchase_date": null
}
```

> Solo `concept` es requerido; el resto son opcionales.

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

> `paid_amount` es opcional — si se omite, se registra el monto programado como pagado.

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

> `paid_amount` es el total distribuido entre los pagos seleccionados. Si es `null`, se usa el monto programado de cada uno.

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
  "total": "4500.00",
  "payments": [
    {
      "payment_id": "uuid",
      "plan_id": "uuid",
      "concept": "iPhone 15",
      "bank_name": "BBVA Azul",
      "amount": "1500.00",
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

| Campo | Tipo | Requerido | Notas |
|---|---|---|---|
| `card_id` | `uuid string` | Sí | Tarjeta de crédito asociada |
| `concept` | `string` | Sí | Descripción del préstamo |
| `capital` | `decimal` | Sí | Monto total del préstamo |
| `cat_anual` | `decimal` | Sí | CAT anual en porcentaje (ej. `29.9`) |
| `plazo_meses` | `int` | Sí | Número de meses del crédito |
| `loan_date` | `date` | Sí | Fecha de inicio del préstamo |

**Response `201`** → `{ "id": "uuid" }`

#### Detalle de un préstamo
```
GET /api/v1/debts/loans/{loan_id}
```

**Response `200`** — `LoanDetailResponse`
```json
{
  "loan_id": "uuid",
  "concept": "Préstamo personal BBVA",
  "capital": "50000.00",
  "cat_anual": "29.9",
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

**Body**
```json
{
  "concept": "Préstamo personal BBVA (ajuste)",
  "capital": null,
  "cat_anual": null,
  "plazo_meses": null,
  "loan_date": null
}
```

> Solo `concept` es requerido; el resto son opcionales.

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
  "total": "2800.00",
  "payments": [
    {
      "payment_id": "uuid",
      "loan_id": "uuid",
      "concept": "Préstamo personal BBVA",
      "bank_name": "BBVA Azul",
      "month_number": 1,
      "cuota": "2800.00",
      "interes": "620.00",
      "abono_capital": "2180.00",
      "saldo_final": "47820.00",
      "due_date": "2026-07-01",
      "status": "PENDIENTE",
      "paid_amount": null
    }
  ]
}
```

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

> `paid_amount` es opcional.

**Response `204`**

---

## Analytics `/api/v1/analytics`

### Dashboard mensual
```
GET /api/v1/analytics/dashboard?year=2026&month=6
```

Agrega en un solo request todos los datos necesarios para la pantalla principal.

**Response `200`** — `DashboardSummaryResponse`
```json
{
  "year": 2026,
  "month": 6,
  "total_income": "18000.00",
  "total_expenses": "8500.00",
  "total_debt_payments": "4300.00",
  "net_balance": "5200.00",
  "total_active_debt": "62000.00",
  "category_breakdown": [
    {
      "category_id": "uuid",
      "category_name": "Alimentación",
      "total": "3200.00",
      "percentage": 37.6,
      "color": "#10b981"
    }
  ],
  "tag_breakdown": [
    {
      "tag": "VARIABLE",
      "total": "5100.00",
      "percentage": 60.0
    }
  ],
  "monthly_history": [
    {
      "year": 2026,
      "month": 4,
      "total_income": "18000.00",
      "total_expenses": "7200.00",
      "total_debt_payments": "4300.00",
      "net_balance": "6500.00"
    }
  ],
  "active_debts": [
    {
      "plan_id": "uuid",
      "concept": "iPhone 15",
      "bank_name": "BBVA Azul",
      "total_amount": "18000.00",
      "remaining_balance": "13500.00",
      "paid_percentage": 25.0,
      "next_payment_amount": "1500.00",
      "next_payment_date": "2026-07-05"
    }
  ],
  "credit_card_status": [
    {
      "account_id": "uuid",
      "bank_name": "BBVA",
      "color": "#3b82f6",
      "credit_limit": "20000.00",
      "cut_day": 5,
      "payment_due_day": 25,
      "current_cycle_charges": "3500.00",
      "total_owed": "8200.00",
      "available_limit": "11800.00",
      "utilization_pct": 41.0,
      "next_payment_amount": "8200.00",
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
      "balance": "12500.00"
    }
  ]
}
```

---

### Estado de tarjeta de crédito (analytics)
```
GET /api/v1/analytics/cards/{account_id}/status
```

Mismo esquema que `GET /api/v1/accounts/{account_id}/status` pero bajo el prefijo de analytics. Usa el `account_id` del contexto de **cuentas** (no el `id` de `/debts/cards`).

**Response `200`** — ver esquema de `AccountStatusResponse` en la sección Cuentas.

---

## Guía de implementación para mobile

### Manejo de fechas
- Usar **siempre** la fecha local del dispositivo, nunca UTC.
- Al enviar una fecha al API, formatear como `YYYY-MM-DD` usando los componentes locales del `Date` (año, mes, día).
- Al mostrar fechas recibidas del API (`YYYY-MM-DD`), no pasar por `new Date(string)` directamente en JavaScript — puede desplazarlas un día. Parsear los componentes manualmente o usar una librería con soporte de zona horaria.

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
2. Crear plan o préstamo asociado a la tarjeta
3. Consultar pagos del mes: `GET /debts/month` y `GET /debts/loans/month`
4. Marcar pagos como pagados: endpoints `/pay`

#### Vista semanal de gastos
- Calcular el lunes de la semana actual con la fecha local
- Enviar `week_start` (lunes) y `week_end` (domingo) en `YYYY-MM-DD`
- Para navegar semanas, sumar/restar 7 días al offset

### Convenciones de IDs
- Todos los IDs son **UUID v4** en formato string
- Al crear un recurso, el API devuelve el UUID generado en `{ "id": "uuid" }`
- Guardar el ID localmente para operaciones posteriores (editar, eliminar, marcar como pagado)
