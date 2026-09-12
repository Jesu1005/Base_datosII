<?php
// conexion.php
$host = 'db';
$port = '5432';
$dbname = 'inventa_tech';
$user = 'postgres'; // usuario de pgAdmin
$password = '***REDACTED***'; // clave de Postgres

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
    // Si falla, devolvemos un JSON con el error
    header('Content-Type: application/json');
    die(json_encode(["error" => "Error de conexión: " . $e->getMessage()]));
}
?>