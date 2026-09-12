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
            // Preparamos y ejecutamos la consulta
            $stmt = $pdo->query("SELECT * FROM producto");
            $productos = $stmt->fetchAll();

            // TRUCO JSONB: Postgres devuelve el JSONB como un String de texto.
            // Para que PHP lo devuelva como un objeto JSON real, lo decodificamos.
            foreach ($productos as &$prod) {
                if (isset($prod['especificaciones'])) {
                    $prod['especificaciones'] = json_decode($prod['especificaciones']);
                }
            }

            // Enviamos la respuesta exitosa
            echo json_encode([
                "status" => "success",
                "total" => count($productos),
                "data" => $productos
            ]);

        } catch (PDOException $e) {
            echo json_encode(["status" => "error", "message" => $e->getMessage()]);
        }
        break;
    case 'POST': // Operación de Creación (Create)
        try {
            // 1. Leer el JSON que envía el frontend o Thunder Client
            $inputJSON = file_get_contents('php://input');
            $data = json_decode($inputJSON, true); // Convertirlo a un array de PHP

            // 2. Validación básica para que no inserten productos vacíos
            if (!isset($data['id_producto']) || !isset($data['nombre'])) {
                echo json_encode(["status" => "error", "message" => "Faltan datos obligatorios (id_producto o nombre)"]);
                break;
            }

            // 3. Preparar la consulta SQL (evita inyecciones SQL usando ':parametros')
            $sql = "INSERT INTO producto (id_producto, id_categoria, sku, nombre, precio_actual, stock_actual, especificaciones) 
                    VALUES (:id_producto, :id_categoria, :sku, :nombre, :precio_actual, :stock_actual, :especificaciones)";
            
            $stmt = $pdo->prepare($sql);

            // TRUCO JSONB: Si mandaron especificaciones, las volvemos a convertir a String JSON 
            // porque PostgreSQL necesita recibir un string para guardarlo en la columna JSONB
            $especificacionesJSON = isset($data['especificaciones']) ? json_encode($data['especificaciones']) : '{}';

            // 4. Ejecutar la consulta inyectando los valores de forma segura
            $stmt->execute([
                ':id_producto' => $data['id_producto'],
                ':id_categoria' => $data['id_categoria'] ?? null, // Si no viene, pone null
                ':sku' => $data['sku'] ?? null,
                ':nombre' => $data['nombre'],
                ':precio_actual' => $data['precio_actual'] ?? 0,
                ':stock_actual' => $data['stock_actual'] ?? 0,
                ':especificaciones' => $especificacionesJSON
            ]);

            // 5. Responder con éxito
            http_response_code(201); // 201 significa "Creado"
            echo json_encode([
                "status" => "success",
                "message" => "Producto registrado correctamente"
            ]);

        } catch (PDOException $e) {
            // Si el ID ya existe o la categoría no existe, caerá aquí
            http_response_code(400); // 400 significa "Bad Request"
            echo json_encode(["status" => "error", "message" => "Error de base de datos: " . $e->getMessage()]);
        }
        break;
    case 'PUT': // Operación de Actualización (Update)
        try {
            $inputJSON = file_get_contents('php://input');
            $data = json_decode($inputJSON, true);

            if (!isset($data['id_producto'])) {
                echo json_encode(["status" => "error", "message" => "Falta el id_producto para actualizar"]);
                break;
            }

            // Actualizaremos el precio y el stock como ejemplo
            $sql = "UPDATE producto SET precio_actual = :precio, stock_actual = :stock WHERE id_producto = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([
                ':precio' => $data['precio_actual'],
                ':stock' => $data['stock_actual'],
                ':id' => $data['id_producto']
            ]);

            echo json_encode(["status" => "success", "message" => "Inventario y precio actualizados"]);

        } catch (PDOException $e) {
            echo json_encode(["status" => "error", "message" => "Error de base de datos: " . $e->getMessage()]);
        }
        break;

    case 'DELETE': // Operación de Eliminación (Delete)
        try {
            $inputJSON = file_get_contents('php://input');
            $data = json_decode($inputJSON, true);

            if (!isset($data['id_producto'])) {
                echo json_encode(["status" => "error", "message" => "Falta el id_producto para eliminar"]);
                break;
            }

            $sql = "DELETE FROM producto WHERE id_producto = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute([':id' => $data['id_producto']]);

            echo json_encode(["status" => "success", "message" => "Producto eliminado del sistema"]);

        } catch (PDOException $e) {
            // Si el producto está en una venta, PostgreSQL bloqueará el borrado por la clave foránea
            http_response_code(409); // Conflicto
            echo json_encode(["status" => "error", "message" => "No se puede eliminar porque tiene transacciones asociadas."]);
        }
        break;
    

    default:
        // Si intentan usar un método que aún no programamos
        echo json_encode(["status" => "error", "message" => "Método no soportado"]);
        break;
}
?>