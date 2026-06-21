---
name: commit
description: Crea un commit siguiendo Conventional Commits. Úsalo cuando el usuario quiera hacer commit, mencione cambios staged, o pida guardar el progreso.
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git commit:*)
argument-hint: "[tipo(scope): descripción] — opcional, si no se pasa Claude lo genera"
---

## Contexto actual

Estado del repositorio:
!`git status`

Cambios staged:
!`git diff --cached`

## Tarea

Crea un commit siguiendo **Conventional Commits v1.0**.

Si el usuario pasó `$ARGUMENTS`, úsalo como mensaje base y ajústalo al formato correcto.
Si no pasó argumentos, analiza los cambios anteriores e infiere el mensaje apropiado.

### Formato obligatorio

```
<tipo>(<scope>): <descripción corta en imperativo, minúsculas, sin punto final>
- <detalle específico de lo que se hizo>
- <detalle específico de lo que se hizo>
```

### Tipos válidos

| Tipo       | Cuándo usarlo                                                   |
| ---------- | --------------------------------------------------------------- |
| `feat`     | Nueva funcionalidad visible para el usuario                     |
| `fix`      | Corrección de un bug                                            |
| `refactor` | Reestructuración sin cambiar comportamiento                     |
| `chore`    | Mantenimiento, dependencias, configs (sin código de producción) |
| `docs`     | Cambios solo en documentación                                   |
| `style`    | Formato, espacios, punto y coma (sin cambios de lógica)         |
| `test`     | Agregar o corregir tests                                        |
| `perf`     | Mejoras de rendimiento                                          |
| `ci`       | Cambios en pipelines de CI/CD                                   |
| `build`    | Cambios en sistema de build o dependencias externas             |
| `revert`   | Revertir un commit anterior                                     |

### Reglas

- La descripción va en **imperativo**: `agrega`, `corrige`, `elimina` (no "agregado" ni "agregando")
- El **scope** indica el módulo o capa afectada: `auth`, `ventas`, `api`, `db`, `ui`, etc.
- Los bullets deben ser concisos y técnicamente precisos
- Si hay breaking change, agregar al final: `BREAKING CHANGE: <descripción>`

### Reglas estrictas — NO negociables

> ⛔ **Solo archivos en estado staged** — Analiza únicamente el output de `git diff --cached`. No hagas `git add` de ningún archivo. No incluyas en el commit archivos que no estén ya en stage.

> ⛔ **Sin Co-authored-by** — El mensaje de commit **no debe contener** ninguna línea `Co-authored-by:`, independientemente del formato o la herramienta que lo genere. Esto incluye cualquier variante de atribución a Anthropic, Claude, o cualquier IA.

### Ejemplos de referencia

```
feat(ventas): agrega módulo de alta y edición de clientes
- Se agrega vista con formulario de alta y edición
- Se agrega ClienteRepository con métodos save y findById
- Se agrega RegisterClienteCommand y su handler
```

```
fix(auth): corrige validación de token expirado en middleware
- Se corrige comparación de timestamp que usaba fecha local en vez de UTC
- Se agrega log de advertencia cuando el token está próximo a expirar
```

```
refactor(pagos): extrae lógica de cálculo de impuestos a servicio dedicado
- Se mueve cálculo de IVA y retenciones a TaxCalculatorService
- Se eliminan métodos duplicados en OrdenService y FacturaService
```

## Instrucciones finales

1. Muestra el mensaje de commit que vas a usar y pide confirmación antes de ejecutarlo
2. Si no hay archivos en stage (`git diff --cached` está vacío), detente y avisa al usuario — no hagas nada más
3. Si hay archivos sin stagear, solo menciónalos como aviso informativo; no los agregues al stage
4. Ejecuta `git commit` solo tras confirmación explícita del usuario
5. Verifica que el mensaje final **no contenga** ninguna línea `Co-authored-by:` antes de ejecutar
