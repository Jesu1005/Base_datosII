-- =====================================================================
-- InventaTech — Semana III — Parte 1: Índices
-- =====================================================================
-- Postgres NO crea índice automático sobre columnas FK (solo sobre la
-- columna referenciada, vía su PK). Sin estos índices, cada JOIN o
-- WHERE por estas columnas hace un table scan completo.

-- --- Índices sobre llaves foráneas ---

CREATE INDEX idx_producto_id_categoria ON public.producto (id_categoria);
CREATE INDEX idx_producto_id_proveedor ON public.producto (id_proveedor);

CREATE INDEX idx_detalle_venta_id_venta ON public.detalle_venta (id_venta);
CREATE INDEX idx_detalle_venta_id_producto ON public.detalle_venta (id_producto);

CREATE INDEX idx_detalle_orden_id_orden ON public.detalle_orden (id_orden);
CREATE INDEX idx_detalle_orden_id_producto ON public.detalle_orden (id_producto);

CREATE INDEX idx_historico_precio_id_producto ON public.historico_precio (id_producto);

CREATE INDEX idx_venta_id_cliente ON public.venta (id_cliente);

CREATE INDEX idx_orden_compra_id_proveedor ON public.orden_compra (id_proveedor);

-- --- Índice para reportes por fecha (ventas del mes, del día, etc.) ---

CREATE INDEX idx_venta_fecha ON public.venta (fecha);
CREATE INDEX idx_orden_compra_fecha_emision ON public.orden_compra (fecha_emision);

-- --- Índice GIN para búsquedas dentro del JSONB de especificaciones ---
-- Permite consultas rápidas del tipo:
--   SELECT * FROM producto WHERE especificaciones @> '{"ram": "16GB"}';
--   SELECT * FROM producto WHERE especificaciones ? 'garantia_meses';

CREATE INDEX idx_producto_especificaciones_gin ON public.producto USING GIN (especificaciones);

-- --- Índice de texto completo para búsqueda de productos por nombre/sku ---
-- Se usa en la Parte 5 (búsqueda avanzada). Requiere la extensión pg_trgm
-- para hacer búsquedas por similitud/substring eficientes (ej. ILIKE '%laptop%').

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_producto_nombre_trgm ON public.producto USING GIN (nombre gin_trgm_ops);
