<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CampusLab UMG - Gestión de Laboratorio</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { background-color: #f4f6f9; }
        .sidebar { min-height: 100vh; background: #1e293b; color: white; }
        .sidebar a { color: #cbd5e1; text-decoration: none; padding: 12px 20px; display: block; border-radius: 6px; margin: 4px 10px; }
        .sidebar a:hover, .sidebar a.active { background: #3b82f6; color: white; }
        @media print { .no-print { display: none !important; } }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <nav class="col-md-2 d-none d-md-block sidebar py-4 no-print">
            <div class="text-center mb-4">
                <h4 class="fw-bold text-info"><i class="bi bi-cpu"></i> CampusLab</h4>
                <small class="text-secondary">UMG - Ingeniería</small>
            </div>
            <a href="dashboard"><i class="bi bi-speedometer2 me-2"></i> Panel Principal</a>
            <a href="solicitantes"><i class="bi bi-people me-2"></i> 1. Solicitantes</a>
            <a href="equipos"><i class="bi bi-pc-display me-2"></i> 2. Inventario</a>
            <a href="mantenimientos"><i class="bi bi-tools me-2"></i> 3. Mantenimientos</a>
            <a href="reservas"><i class="bi bi-calendar-check me-2"></i> 4. Reservas</a>
            <a href="prestamos"><i class="bi bi-box-arrow-right me-2"></i> 5. Préstamos</a>
            <a href="incidencias"><i class="bi bi-exclamation-triangle me-2"></i> 6. Incidencias</a>
            <a href="reportes"><i class="bi bi-file-earmark-bar-graph me-2"></i> 7. Reportes HTML</a>
            <hr class="border-secondary mx-3">
            <a href="javascript:confirmarLogout()" class="text-danger"><i class="bi bi-box-arrow-left me-2"></i> Cerrar Sesión</a>
        </nav>
        <main class="col-md-10 ms-sm-auto px-md-4 py-4">
            <div class="d-flex justify-content-between align-items-center pb-3 mb-4 border-bottom no-print">
                <span class="text-muted">Operador activo: <strong>${sessionScope.nombreCompleto}</strong> (${sessionScope.rol})</span>
                <span class="badge bg-success"><i class="bi bi-hdd-network"></i> Tomcat + MySQL Docker</span>
            </div>
