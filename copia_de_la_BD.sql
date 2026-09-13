--
-- PostgreSQL database dump
--

\restrict ZOWHOVNXCkJsjU2zxc1zA6OFiAplFNv7nuZ7cMda5Vpzs5WyzYzkocLTphYk5N3

-- Dumped from database version 17.11 (Debian 17.11-1.pgdg13+2)
-- Dumped by pg_dump version 17.11 (Debian 17.11-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria (
    id_categoria character varying(20) NOT NULL,
    nombre character varying(100),
    descripcion text
);


ALTER TABLE public.categoria OWNER TO postgres;

--
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cliente (
    id_cliente character varying(20) NOT NULL,
    rif_cedula character varying(20),
    nombre character varying(100),
    email character varying(100)
);


ALTER TABLE public.cliente OWNER TO postgres;

--
-- Name: detalle_orden; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_orden (
    id_det_orden character varying(20) NOT NULL,
    id_orden character varying(20),
    id_producto character varying(20),
    cantidad integer,
    precio_compra numeric(10,2)
);


ALTER TABLE public.detalle_orden OWNER TO postgres;

--
-- Name: detalle_venta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_venta (
    id_det_venta character varying(20) NOT NULL,
    id_venta character varying(20),
    id_producto character varying(20),
    cantidad integer,
    precio_unit numeric(10,2)
);


ALTER TABLE public.detalle_venta OWNER TO postgres;

--
-- Name: historico_precio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historico_precio (
    id_historico character varying(20) NOT NULL,
    id_producto character varying(20),
    precio numeric(10,2),
    fecha_inicio date,
    fecha_fin date
);


ALTER TABLE public.historico_precio OWNER TO postgres;

--
-- Name: orden_compra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orden_compra (
    id_orden character varying(20) NOT NULL,
    id_proveedor character varying(20),
    fecha_emision timestamp without time zone,
    estado character varying(20)
);


ALTER TABLE public.orden_compra OWNER TO postgres;

--
-- Name: producto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.producto (
    id_producto character varying(20) NOT NULL,
    id_categoria character varying(20),
    sku character varying(50),
    nombre character varying(100),
    precio_actual numeric(10,2),
    stock_actual integer,
    especificaciones jsonb,
    id_proveedor character varying(20)
);


ALTER TABLE public.producto OWNER TO postgres;

--
-- Name: proveedor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proveedor (
    id_proveedor character varying(20) NOT NULL,
    rif character varying(20),
    razon_social character varying(100),
    contacto character varying(50)
);


ALTER TABLE public.proveedor OWNER TO postgres;

--
-- Name: venta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.venta (
    id_venta character varying(20) NOT NULL,
    id_cliente character varying(20),
    fecha timestamp without time zone,
    total numeric(12,2)
);


ALTER TABLE public.venta OWNER TO postgres;

--
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id_categoria);


--
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- Name: detalle_orden detalle_orden_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_orden
    ADD CONSTRAINT detalle_orden_pkey PRIMARY KEY (id_det_orden);


--
-- Name: detalle_venta detalle_venta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_venta
    ADD CONSTRAINT detalle_venta_pkey PRIMARY KEY (id_det_venta);


--
-- Name: historico_precio historico_precio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historico_precio
    ADD CONSTRAINT historico_precio_pkey PRIMARY KEY (id_historico);


--
-- Name: orden_compra orden_compra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orden_compra
    ADD CONSTRAINT orden_compra_pkey PRIMARY KEY (id_orden);


--
-- Name: producto producto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_pkey PRIMARY KEY (id_producto);


--
-- Name: proveedor proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id_proveedor);


--
-- Name: venta venta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta
    ADD CONSTRAINT venta_pkey PRIMARY KEY (id_venta);


--
-- Name: idx_detalle_orden_id_orden; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_detalle_orden_id_orden ON public.detalle_orden USING btree (id_orden);


--
-- Name: idx_detalle_orden_id_producto; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_detalle_orden_id_producto ON public.detalle_orden USING btree (id_producto);


--
-- Name: idx_detalle_venta_id_producto; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_detalle_venta_id_producto ON public.detalle_venta USING btree (id_producto);


--
-- Name: idx_detalle_venta_id_venta; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_detalle_venta_id_venta ON public.detalle_venta USING btree (id_venta);


--
-- Name: idx_historico_precio_id_producto; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_historico_precio_id_producto ON public.historico_precio USING btree (id_producto);


--
-- Name: idx_orden_compra_fecha_emision; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orden_compra_fecha_emision ON public.orden_compra USING btree (fecha_emision);


--
-- Name: idx_orden_compra_id_proveedor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orden_compra_id_proveedor ON public.orden_compra USING btree (id_proveedor);


--
-- Name: idx_producto_especificaciones_gin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_producto_especificaciones_gin ON public.producto USING gin (especificaciones);


--
-- Name: idx_producto_id_categoria; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_producto_id_categoria ON public.producto USING btree (id_categoria);


--
-- Name: idx_producto_id_proveedor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_producto_id_proveedor ON public.producto USING btree (id_proveedor);


--
-- Name: idx_producto_nombre_trgm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_producto_nombre_trgm ON public.producto USING gin (nombre public.gin_trgm_ops);


--
-- Name: idx_venta_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_venta_fecha ON public.venta USING btree (fecha);


--
-- Name: idx_venta_id_cliente; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_venta_id_cliente ON public.venta USING btree (id_cliente);


--
-- Name: detalle_orden detalle_orden_id_orden_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_orden
    ADD CONSTRAINT detalle_orden_id_orden_fkey FOREIGN KEY (id_orden) REFERENCES public.orden_compra(id_orden);


--
-- Name: detalle_orden detalle_orden_id_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_orden
    ADD CONSTRAINT detalle_orden_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);


--
-- Name: detalle_venta detalle_venta_id_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_venta
    ADD CONSTRAINT detalle_venta_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);


--
-- Name: detalle_venta detalle_venta_id_venta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_venta
    ADD CONSTRAINT detalle_venta_id_venta_fkey FOREIGN KEY (id_venta) REFERENCES public.venta(id_venta);


--
-- Name: historico_precio historico_precio_id_producto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historico_precio
    ADD CONSTRAINT historico_precio_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.producto(id_producto);


--
-- Name: orden_compra orden_compra_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orden_compra
    ADD CONSTRAINT orden_compra_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id_proveedor);


--
-- Name: producto producto_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria(id_categoria);


--
-- Name: producto producto_id_proveedor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.producto
    ADD CONSTRAINT producto_id_proveedor_fkey FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id_proveedor);


--
-- Name: venta venta_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.venta
    ADD CONSTRAINT venta_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);


--
-- PostgreSQL database dump complete
--

\unrestrict ZOWHOVNXCkJsjU2zxc1zA6OFiAplFNv7nuZ7cMda5Vpzs5WyzYzkocLTphYk5N3

