<?php
// productos.php

// 1. Configuramos las cabeceras para que la respuesta siempre sea JSON
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // Permite peticiones desde el frontend

// 2. Incluimos el archivo de conexión
require_once 'conexion.php';

// 3. Capturamos el método de la petición (GET, POST, PUT, DELETE)
$metodo = $_SERVER['REQUEST_METHOD'];

switch ($metodo) {
    case 'GET': // Operación de Lectura (Read)
        try {
            $stmt = $pdo->query("SELECT * FROM producto");
            $productos = $stmt->fetchAll();

            // TRUCO JSONB: Postgres devuelve el JSONB como un String de texto.
            // Para que PHP lo devuelva como un objeto JSON real, lo decodificamos.
            foreach ($productos as &$prod) {
                if (isset($prod['especificaciones'])) {
                    $prod['especificaciones'] = json_decode($prod['especificaciones']);
                }
            }

            echo json_encode([
                "status" => "success",
                "total" => count($productos),
                "data" => $productos
            ]);

        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => "Error al consultar productos"]);
        }
        break;

    case 'POST': // Operación de Creación (Create)
        try {
            $inputJSON = file_get_contents('php://input');
            $data = json_decode($inputJSON, true);

            if (!is_array($data) || !isset($data['id_producto']) || !isset($data['nombre'])) {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "Faltan datos obligatorios (id_producto o nombre)"]);
                break;
            }

            // Validación de tipos básicos
            if (isset($data['precio_actual']) && !is_numeric($data['precio_actual'])) {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "precio_actual debe ser numérico"]);
                break;
            }
            if (isset($data['stock_actual']) && !is_numeric($data['stock_actual'])) {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "stock_actual debe ser numérico"]);
                break;
            }

            $sql = "INSERT INTO producto (id_producto, id_categoria, sku, nombre, precio_actual, stock_actual, especificaciones) 
                    VALUES (:id_producto, :id_categoria, :sku, :nombre, :precio_actual, :stock_actual, :especificaciones)";

            $stmt = $pdo->prepare($sql);

            // TRUCO JSONB: convertir especificaciones a String JSON para guardarlo en la columna JSONB
            $especificacionesJSON = isset($data['especificaciones']) ? json_encode($data['especificaciones']) : '{}';

            $stmt->execute([
                ':id_producto' => $data['id_producto'],
                ':id_categoria' => $data['id_categoria'] ?? null,
                ':sku' => $data['sku'] ?? null,
                ':nombre' => $data['nombre'],
                ':precio_actual' => $data['precio_actual'] ?? 0,
                ':stock_actual' => $data['stock_actual'] ?? 0,
                ':especificaciones' => $especificacionesJSON
            ]);

            http_response_code(201); // Creado
            echo json_encode([
                "status" => "success",
                "message" => "Producto registrado correctamente"
            ]);

        } catch (PDOException $e) {
            // Si el ID ya existe o la categoría no existe, caerá aquí
            http_response_code(400);
            echo json_encode(["status" => "error", "message" => "No se pudo crear el producto (id_producto duplicado o id_categoria inválido)"]);
        }
        break;

    case 'PUT': // Operación de Actualización (Update)
        try {
            $inputJSON = file_get_contents('php://input');
            $data = json_decode($inputJSON, true);

            if (!is_array($data) || !isset($data['id_producto'])) {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "Falta el id_producto para actualizar"]);
                break;
            }
            if (!isset($data['precio_actual']) || !isset($data['stock_actual'])) {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "Faltan precio_actual o stock_actual"]);
                break;
            }
            if (!is_numeric($data['precio_actual']) || !is_numeric($data['stock_actual'])) {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "precio_actual y stock_actual deben ser numéricos"]);
                break;
            }

            $sql = "UPDATE producto SET precio_actual = :precio, stock_actual = :stock WHERE id_producto = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':precio' => $data['precio_actual'],
                ':stock' => $data['stock_actual'],
                ':id' => $data['id_producto']
            ]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(["status" => "error", "message" => "No existe un producto con ese id_producto"]);
                break;
            }

            echo json_encode(["status" => "success", "message" => "Inventario y precio actualizados"]);

        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(["status" => "error", "message" => "Error al actualizar el producto"]);
        }
        break;

    case 'DELETE': // Operación de Eliminación (Delete)
        try {
            $inputJSON = file_get_contents('php://input');
            $data = json_decode($inputJSON, true);

            if (!is_array($data) || !isset($data['id_producto'])) {
                http_response_code(400);
                echo json_encode(["status" => "error", "message" => "Falta el id_producto para eliminar"]);
                break;
            }

            $sql = "DELETE FROM producto WHERE id_producto = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([':id' => $data['id_producto']]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(["status" => "error", "message" => "No existe un producto con ese id_producto"]);
                break;
            }

            echo json_encode(["status" => "success", "message" => "Producto eliminado del sistema"]);

        } catch (PDOException $e) {
            // Si el producto está en una venta, PostgreSQL bloqueará el borrado por la clave foránea
            http_response_code(409); // Conflicto
            echo json_encode(["status" => "error", "message" => "No se puede eliminar porque tiene transacciones asociadas."]);
        }
        break;

    default:
        http_response_code(405); // Método no permitido
        echo json_encode(["status" => "error", "message" => "Método no soportado"]);
        break;
}
