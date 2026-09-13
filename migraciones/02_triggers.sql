-- =====================================================================
-- InventaTech — Semana III — Parte 2: Triggers de validación y auditoría
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. VALIDACIONES DECLARATIVAS (CHECK constraints)
-- ---------------------------------------------------------------------
-- No son triggers, pero son la forma correcta de garantizar reglas
-- simples de dominio sin necesidad de código procedimental.

ALTER TABLE public.producto
    ADD CONSTRAINT chk_producto_precio_no_negativo CHECK (precio_actual >= 0),
    ADD CONSTRAINT chk_producto_stock_no_negativo CHECK (stock_actual >= 0);

ALTER TABLE public.detalle_venta
    ADD CONSTRAINT chk_detalle_venta_cantidad_positiva CHECK (cantidad > 0),
    ADD CONSTRAINT chk_detalle_venta_precio_no_negativo CHECK (precio_unit >= 0);

ALTER TABLE public.detalle_orden
    ADD CONSTRAINT chk_detalle_orden_cantidad_positiva CHECK (cantidad > 0),
    ADD CONSTRAINT chk_detalle_orden_precio_no_negativo CHECK (precio_compra >= 0);

ALTER TABLE public.orden_compra
    ADD CONSTRAINT chk_orden_compra_estado_valido
        CHECK (estado IN ('pendiente', 'recibida', 'cancelada'));


-- ---------------------------------------------------------------------
-- 1. AUDITORÍA — tabla + trigger sobre cambios de precio y stock
-- ---------------------------------------------------------------------

CREATE TABLE public.auditoria (
    id_auditoria    SERIAL PRIMARY KEY,
    tabla           VARCHAR(50)  NOT NULL,
    id_registro     VARCHAR(20)  NOT NULL,
    campo           VARCHAR(50)  NOT NULL,
    valor_anterior  TEXT,
    valor_nuevo     TEXT,
    usuario_bd      VARCHAR(50)  DEFAULT CURRENT_USER,
    fecha_hora      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_auditar_producto()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.precio_actual IS DISTINCT FROM NEW.precio_actual THEN
        INSERT INTO public.auditoria (tabla, id_registro, campo, valor_anterior, valor_nuevo)
        VALUES ('producto', NEW.id_producto, 'precio_actual',
                OLD.precio_actual::text, NEW.precio_actual::text);
    END IF;

    IF OLD.stock_actual IS DISTINCT FROM NEW.stock_actual THEN
        INSERT INTO public.auditoria (tabla, id_registro, campo, valor_anterior, valor_nuevo)
        VALUES ('producto', NEW.id_producto, 'stock_actual',
                OLD.stock_actual::text, NEW.stock_actual::text);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditar_producto
    AFTER UPDATE ON public.producto
    FOR EACH ROW
    EXECUTE FUNCTION fn_auditar_producto();


-- ---------------------------------------------------------------------
-- 2. VALIDAR STOCK ANTES DE VENDER
-- ---------------------------------------------------------------------
-- Este trigger SOLO valida: impide insertar una línea de venta si no
-- hay stock suficiente. NO descuenta el stock — eso lo hace el
-- procedimiento almacenado "registrar_venta" (Semana III, Parte 3),
-- que es el lugar correcto para esa lógica de negocio.

CREATE OR REPLACE FUNCTION fn_validar_stock_venta()
RETURNS TRIGGER AS $$
DECLARE
    v_stock_actual INTEGER;
BEGIN
    SELECT stock_actual INTO v_stock_actual
    FROM public.producto
    WHERE id_producto = NEW.id_producto
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El producto % no existe', NEW.id_producto;
    END IF;

    IF v_stock_actual < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto %: disponible %, solicitado %',
            NEW.id_producto, v_stock_actual, NEW.cantidad;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_stock_venta
    BEFORE INSERT ON public.detalle_venta
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_stock_venta();
