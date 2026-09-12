<?php
// conexion.php
// Las credenciales ahora vienen de variables de entorno (definidas en docker-compose.yml
// o en un archivo .env que NUNCA se sube al repositorio).

$host     = getenv('DB_HOST') ?: 'db';
$port     = getenv('DB_PORT') ?: '5432';
$dbname   = getenv('DB_NAME') ?: 'inventa_tech';
$user     = getenv('DB_USER') ?: 'postgres';
$password = getenv('DB_PASSWORD');

if (!$password) {
    header('Content-Type: application/json');
    http_response_code(500);
    die(json_encode([
        "status" => "error",
        "message" => "No se configuró DB_PASSWORD. Revisa tu archivo .env o docker-compose.yml"
    ]));
}

try {
    // DSN (Data Source Name) para PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";

    // Crear la instancia PDO
    $pdo = new PDO($dsn, $user, $password);

    // Configurar PDO para que lance excepciones si hay errores
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    // Configurar para que devuelva los datos como arrays asociativos
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

} catch (PDOException $e) {
    // Si falla, devolvemos un JSON con el error y el código HTTP correcto
    header('Content-Type: application/json');
    http_response_code(500);
    die(json_encode(["status" => "error", "message" => "Error de conexión a la base de datos"]));
}
