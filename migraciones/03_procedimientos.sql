-- =====================================================================
-- InventaTech — Semana III — Parte 3: Procedimientos almacenados
-- =====================================================================
-- Usamos CREATE PROCEDURE (no FUNCTION) porque estas operaciones no
-- calculan un valor puro, sino que ejecutan una secuencia de pasos con
-- efectos secundarios (insertar, actualizar varias tablas) — es el uso
-- clásico de un procedimiento almacenado, invocado con CALL.

-- ---------------------------------------------------------------------
-- 1. registrar_venta
-- ---------------------------------------------------------------------
-- Registra una venta completa en una sola operación atómica:
--   1) valida que el cliente exista
--   2) crea la fila en "venta"
--   3) inserta cada línea en "detalle_venta" al precio_actual vigente
--      (el trigger trg_validar_stock_venta rechaza la línea si no hay
--      stock suficiente, abortando TODA la transacción)
--   4) descuenta el stock de cada producto vendido
--   5) calcula y guarda venta.total
--
-- Si cualquier paso falla (cliente inexistente, producto inexistente,
-- stock insuficiente), Postgres revierte automáticamente todo lo que
-- el procedimiento alcanzó a hacer — no queda una venta a medias.
--
-- p_items es un arreglo JSON: '[{"id_producto":"PRD-001","cantidad":2}]'
-- p_id_venta es INOUT: se le pasa NULL y el procedimiento devuelve el
-- id_venta generado.

CREATE OR REPLACE PROCEDURE registrar_venta(
    IN p_id_cliente VARCHAR,
    IN p_items JSONB,
    INOUT p_id_venta VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_det_venta   VARCHAR(20);
    v_item           JSONB;
    v_id_producto    VARCHAR(20);
    v_cantidad       INTEGER;
    v_precio_actual  NUMERIC(10,2);
    v_total          NUMERIC(12,2) := 0;
    v_next_venta     INT;
    v_next_det       INT;
BEGIN
    -- Validar cliente
    IF NOT EXISTS (SELECT 1 FROM public.cliente WHERE id_cliente = p_id_cliente) THEN
        RAISE EXCEPTION 'El cliente % no existe', p_id_cliente;
    END IF;

    IF p_items IS NULL OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'La venta debe incluir al menos un producto';
    END IF;

    -- Generar id_venta siguiendo el patrón "VNT-0001"
    SELECT COALESCE(MAX(SUBSTRING(id_venta FROM 5)::int), 0) + 1 INTO v_next_venta
    FROM public.venta WHERE id_venta ~ '^VNT-[0-9]+$';
    p_id_venta := 'VNT-' || LPAD(v_next_venta::text, 4, '0');

    INSERT INTO public.venta (id_venta, id_cliente, fecha, total)
    VALUES (p_id_venta, p_id_cliente, CURRENT_TIMESTAMP, 0);

    -- Procesar cada línea del pedido
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_id_producto := v_item->>'id_producto';
        v_cantidad    := (v_item->>'cantidad')::integer;

        IF v_cantidad IS NULL OR v_cantidad <= 0 THEN
            RAISE EXCEPTION 'Cantidad inválida para el producto %', v_id_producto;
        END IF;

        SELECT precio_actual INTO v_precio_actual
        FROM public.producto WHERE id_producto = v_id_producto;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'El producto % no existe', v_id_producto;
        END IF;

        SELECT COALESCE(MAX(SUBSTRING(id_det_venta FROM 4)::int), 0) + 1 INTO v_next_det
        FROM public.detalle_venta WHERE id_det_venta ~ '^DV-[0-9]+$';
        v_id_det_venta := 'DV-' || LPAD(v_next_det::text, 4, '0');

        -- El trigger trg_validar_stock_venta valida el stock aquí mismo;
        -- si no alcanza, lanza excepción y se revierte todo el procedimiento.
        INSERT INTO public.detalle_venta (id_det_venta, id_venta, id_producto, cantidad, precio_unit)
        VALUES (v_id_det_venta, p_id_venta, v_id_producto, v_cantidad, v_precio_actual);

        UPDATE public.producto
           SET stock_actual = stock_actual - v_cantidad
         WHERE id_producto = v_id_producto;

        v_total := v_total + (v_cantidad * v_precio_actual);
    END LOOP;

    UPDATE public.venta SET total = v_total WHERE id_venta = p_id_venta;
END;
$$;


-- ---------------------------------------------------------------------
-- 2. recibir_orden_compra
-- ---------------------------------------------------------------------
-- Marca una orden de compra como 'recibida' y suma al stock de cada
-- producto la cantidad indicada en sus líneas de detalle_orden.
-- Es el contraparte de registrar_venta: aquí el stock sube en vez de bajar.

CREATE OR REPLACE PROCEDURE recibir_orden_compra(IN p_id_orden VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado_actual VARCHAR(20);
BEGIN
    SELECT estado INTO v_estado_actual
    FROM public.orden_compra WHERE id_orden = p_id_orden;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La orden de compra % no existe', p_id_orden;
    END IF;

    IF v_estado_actual = 'recibida' THEN
        RAISE EXCEPTION 'La orden % ya fue marcada como recibida anteriormente', p_id_orden;
    END IF;

    UPDATE public.orden_compra
       SET estado = 'recibida'
     WHERE id_orden = p_id_orden;

    UPDATE public.producto p
       SET stock_actual = p.stock_actual + d.cantidad
      FROM public.detalle_orden d
     WHERE d.id_orden = p_id_orden
       AND p.id_producto = d.id_producto;
END;
$$;


-- ---------------------------------------------------------------------
-- Ejemplos de uso (no descomentar en producción, solo referencia):
-- ---------------------------------------------------------------------
-- CALL registrar_venta('CLI-901', '[{"id_producto":"PRD-001","cantidad":2}]', NULL);
-- CALL recibir_orden_compra('ORD-001');