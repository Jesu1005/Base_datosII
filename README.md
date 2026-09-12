# InventaTech

**Proyecto 3 (Grupo 3): Sistema de Gestión de Inventario y Ventas de una Tienda** — inventario, proveedores, ventas, clientes y órdenes de compra para una tienda de productos electrónicos, desarrollado como proyecto de la asignatura **Sistemas de Bases de Datos II** (UNEG - Ingeniería en Informática).

El proyecto implementa una **arquitectura de datos multimodelo en PostgreSQL + JSONB**, combinando el modelo relacional (transacciones ACID) con capacidades semiestructuradas para fichas técnicas dinámicas de productos, más datos temporales para el histórico de variaciones de precios y un motor de validación XML/XPath para interoperabilidad con sistemas externos.

## Contexto

Una tienda de productos electrónicos desea gestionar su inventario, proveedores, ventas, clientes y órdenes de compra. Actualmente, el control se realiza mediante hojas de cálculo y no existe integración entre los procesos.

## Problema

- El inventario no está actualizado en tiempo real.
- Las ventas no se asocian correctamente con los productos.
- No se lleva control de los proveedores.
- Es difícil generar reportes de ventas.
- No existe un historial de compras por cliente.

## Objetivos

**General:** Diseñar una arquitectura de datos multimodelo que centralice la gestión de inventarios, ventas, proveedores y clientes de InventaTech, garantizando integridad transaccional y flexibilidad en el almacenamiento de especificaciones dinámicas.

**Específicos:**
- Modelar el esquema relacional y semiestructurado en PostgreSQL (ACID + atributos JSONB para fichas técnicas dinámicas).
- Implementar trazabilidad de precios y stock en tiempo real mediante esquemas históricos y triggers.
- Desarrollar un motor de validación y extracción XML/XPath para interoperabilidad con proveedores y facturación electrónica.

## Stack tecnológico

| Componente | Tecnología |
|---|---|
| Motor de base de datos | PostgreSQL 17 |
| Modelo semiestructurado | JSONB |
| Interoperabilidad | XML + DTD + XPath |
| Backend/API | PHP 8.2 (PDO) |
| Contenedores | Docker / Docker Compose |

## Usuarios del sistema

- **Cliente**: consulta de productos y visualización de su historial de compras.
- **Vendedor**: registro de transacciones de venta e interfaz con el stock.
- **Administrador de inventario**: alta/baja de productos, control de stock y órdenes de compra.
- **Gerente de tienda**: tableros de control y reportes analíticos de ventas.
- **Proveedor**: consulta de órdenes de compra asignadas y suministro de catálogos.

## Procesos principales

- Registrar productos
- Registrar categorías
- Registrar proveedores
- Registrar clientes
- Registrar ventas
- Registrar órdenes de compra
- Actualizar inventario
- Generar reportes de ventas

## Preguntas que el sistema debe responder

- ¿Qué productos existen en una categoría?
- ¿Qué productos tiene un proveedor?
- ¿Qué ventas realizó un cliente?
- ¿Cuál es el producto más vendido?
- ¿Qué productos tienen bajo inventario?
- ¿Cuántas ventas se realizaron en un mes?
- ¿Qué clientes compraron en una fecha determinada?
- ¿Qué productos se vendieron en una venta específica?
- ¿Qué proveedores suministran una categoría?
- ¿Cuál es el total de ventas por mes?

## Especificación tecnológica y enfoque de datos

- **SGBD asignado**: PostgreSQL + **JSONB** (enfoque multimodelo).
- **Manejo de datos especializados (Semana IV)**: datos temporales y estructuras variables — fichas técnicas cambiantes de artículos de tecnología almacenadas en `JSONB` e histórico de variaciones de precios de productos a lo largo del tiempo.

## Modelo de datos

Objetos del dominio:

- `Producto`
- `Categoría`
- `Proveedor`
- `Cliente`
- `Venta`
- `DetalleVenta`
- `OrdenCompra`
- `DetalleOrden`
- `HistoricoPrecio` (datos temporales/históricos de precios)

Las **especificaciones técnicas** de los productos (procesador, RAM, voltaje, puertos, etc.) se almacenan como **JSONB**, permitiendo atributos dinámicos sin rediseñar el esquema.

## Estructura del repositorio

```
.
├── docs/
│   └── Semana 1 proyecto.docx      # Informe semanal (modelado, XML, XPath)
├── inventa_tech/
│   ├── conexion.php                # Conexión PDO a PostgreSQL
│   ├── productos.php               # API REST de productos (GET/POST/PUT/DELETE)
│   └── prueba.http                 # Ejemplos de peticiones HTTP
├── copia_de_la_BD                  # Backup de la base de datos (pg_dump)
├── Dockerfile                      # Imagen PHP 8.2 + Apache + driver pgsql
└── docker-compose.yml              # Orquestación web + PostgreSQL 17
```

## API de productos

Endpoints expuestos en `inventa_tech/productos.php` (respuestas en JSON):

| Método | Acción |
|---|---|
| `GET` | Listar todos los productos |
| `POST` | Crear un producto (valida `id_producto` y `nombre`) |
| `PUT` | Actualizar precio y stock |
| `DELETE` | Eliminar un producto (bloqueado si tiene transacciones asociadas) |

Ejemplo de creación de producto:

```http
POST http://localhost/inventa_tech/productos.php
Content-Type: application/json

{
  "id_producto": "PRD-002",
  "id_categoria": "CAT-01",
  "sku": "LAP-GAMER-16",
  "nombre": "Laptop Gamer RTX",
  "precio_actual": 1850.50,
  "stock_actual": 12,
  "especificaciones": {
    "procesador": "AMD Ryzen 9",
    "ram": "32GB",
    "grafica": "RTX 4070"
  }
}
```

Más ejemplos en [inventa_tech/prueba.http](inventa_tech/prueba.http).

## Puesta en marcha

```bash
docker compose up --build
```

- **Web/API**: `http://localhost/inventa_tech/productos.php`
- **PostgreSQL**: `localhost:5432` (usuario `postgres`, BD `inventa_tech`)

## XML y XPath

El informe (`docs/Semana 1 proyecto.docx`) incluye un documento `inventario.xml` validado por un DTD (`inventario.dtd`) y cinco consultas XPath, entre ellas:

```xpath
//producto[number(stock) <= 5]/concat(nombre, ' - $', precio_actual)
//producto[@id_categoria='CAT-01']/nombre/text()
```

## Plan semanal (Grupo 3)

**Proyecto asignado:** Sistema de Gestión de Inventario y Ventas | **Tecnología/SGBD:** PostgreSQL + JSONB | **Enfoque:** Multimodelo (Relacional + JSON)

### Entregables por semana

| Semana | Entregables |
|---|---|
| **I — Modelado, Fundamentos XML y Consultas Iniciales** | Documento técnico + archivos de modelo: nombre del proyecto, descripción del problema, justificación, objetivo general, tres objetivos específicos, usuarios del sistema, cinco procesos principales, lista inicial de objetos, modelo conceptual (Diagrama de Clases UML/ER), diez preguntas del sistema, documento XML inicial, DTD de validación y cinco consultas XPath ✅ *[docs/Semana 1 proyecto.docx](docs/Semana%201%20proyecto.docx)* |
| **II — Arquitectura, Persistencia e Interfaz Web (JSON + PHP)** | Integración del modelo con una aplicación web funcional: configuración/conexión de la BD (PostgreSQL+JSONB), interfaz web en PHP con respuestas JSON y operaciones CRUD operativas ✅ *[inventa_tech/](inventa_tech/)* |
| **III — Reglas de Negocio, Mecanismos de Búsqueda y Distribución** | Triggers (validación/auditoría), procedimientos almacenados (PL/pgSQL), vistas optimizadas e índices; mecanismos de búsqueda avanzados y simulación de fragmentación/distribución de datos o almacenamiento remoto |
| **IV — Incorporación de Datos Especializados** | Datos temporales y no estructurados: histórico de precios y catálogos de especificaciones de productos dinámicos en JSONB |
| **V — Integración Final, Presentación y Cuadro Comparativo** | Defensa pública con demostración en vivo, lámina con cuadro comparativo técnico (Relacional Puro, Multimodelo JSONB/XML, NoSQL Documental, Espacial PostGIS) y entrega del repositorio final |

## Integrantes

- Erick Sumoza 26.262.467
- Yusdelis Rondón 31.159.747
- Joan Rodríguez 31.058.697
- Diana Gamboa 30.110.098
- Jesús Guzmán 30.857.207

*UNEG — Universidad Nacional Experimental de Guayana. Ciudad Guayana, agosto de 2026.*