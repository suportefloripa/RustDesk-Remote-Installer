<?php
$token = "<TOKEN_AQUI>";
$to = "suporte@dominio.com";
$from = "nao-responder@dominio.com";
$id = isset($_GET['id']) ? $_GET['id'] : '';
$key = isset($_GET['key']) ? $_GET['key'] : '';
$org = isset($_GET['org']) ? $_GET['org'] : '';
$tech = isset($_GET['tech']) ? $_GET['tech'] : '';
if ($key !== $token || !$id) { http_response_code(401); echo "unauthorized"; exit; }
$subject = "RustDesk ID" . $id;
$message = "ID: " . $id . "; Org: " . $org . "; Tech: " . $tech;
$headers = "From: " . $from;
if (filter_var($to, FILTER_VALIDATE_EMAIL)) { mail($to, $subject, $message, $headers); }
echo "ok";
?>