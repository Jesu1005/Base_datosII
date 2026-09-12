# InventaTech

Sistema de gestión de inventarios, ventas, proveedores y clientes para la tienda de tecnología **InventaTech**, desarrollado como proyecto de la asignatura **Sistemas de Bases de Datos II** (UNEG - Ingeniería en Informática).

El proyecto implementa una **arquitectura de datos multimodelo en PostgreSQL**, combinando el modelo relacional (transacciones ACID) con capacidades semiestructuradas (JSONB) para fichas técnicas dinámicas de productos, además de un motor de validación XML/XPath para interoperabilidad con sistemas externos.

## Descripción del problema

Actualmente la empresa gestiona sus operaciones mediante hojas de cálculo descentralizadas y aisladas, lo que genera:

- **Desincronización de inventario**: pérdida de trazabilidad del stock en tiempo real.
- **Desvinculación transaccional**: omisión de integridad referencial entre ventas y los ítems del catálogo.
- **Ceguera de proveedores y clientes**: ausencia de un modelo estructurado para proveedores e historial analítico de compras.
- **Deficiencia analítica**: imposibilidad de generar reportes de rendimiento consolidados.
- **Rigidez en especificaciones de producto**: incapacidad de almacenar fichas técnicas cambiantes en esquemas relacionales rígidos.

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

## Integrantes

- Erick Sumoza 26.262.467
- Yusdelis Rondón 31.159.747
- Joan Rodríguez 31.058.697
- Diana Gamboa 30.110.098
- Jesús Guzmán 30.857.207

*UNEG — Universidad Nacional Experimental de Guayana. Ciudad Guayana, agosto de 2026.*