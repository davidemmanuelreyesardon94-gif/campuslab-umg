<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Principal - CampusLab UMG</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    <style>
        body {
            background-color: #f1f5f9;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
            margin: 0;
            overflow-x: hidden;
        }
        /* Sidebar consistente con tus otros módulos */
        .sidebar {
            width: 250px;
            min-height: 100vh;
            background-color: #1e293b;
            color: #cbd5e1;
            position: fixed;
            top: 0;
            left: 0;
            display: flex;
            flex-direction: column;
            z-index: 100;
        }
        .sidebar .brand {
            padding: 1.5rem 1.25rem 1rem;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.06);
        }
        .sidebar .nav-link {
            color: #cbd5e1;
            padding: 0.7rem 1.25rem;
            margin: 0.15rem 0.75rem;
            border-radius: 8px;
            font-size: 0.92rem;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.2s;
        }
        .sidebar .nav-link:hover {
            background-color: rgba(255,255,255,0.08);
            color: #fff;
        }
        .sidebar .nav-link.active {
            background-color: #2563eb;
            color: #fff;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.35);
        }
        .main-wrapper {
            margin-left: 250px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .topbar {
            background-color: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            padding: 0.75rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        /* Tarjetas KPI ejecutivas */
        .kpi-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 1.25rem;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            height: 100%;
        }
        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(15, 23, 42, 0.06);
        }
        .kpi-icon {
            width: 46px;
            height: 46px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.35rem;
        }
        .panel-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 1.5rem;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
            height: 100%;
        }
        .quick-action-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 0.85rem 1rem;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
            background: #f8fafc;
            color: #1e293b;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.2s;
        }
        .quick-action-btn:hover {
            background: #eff6ff;
            border-color: #93c5fd;
            color: #1d4ed8;
            transform: translateX(3px);
        }
    </style>
</head>
<body>

    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="brand">
            <div class="fw-bold fs-4 text-info"><i class="bi bi-cpu me-1"></i> CampusLab</div>
            <div class="small text-secondary mt-1">UMG - Ingeniería</div>
        </div>
        <nav class="nav flex-column mt-3 flex-grow-1">
            <a class="nav-link active" href="${pageContext.request.contextPath}/dashboard"><i class="bi bi-speedometer2"></i> Panel Principal</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/solicitantes"><i class="bi bi-people"></i> 1. Solicitantes</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/equipos"><i class="bi bi-pc-display"></i> 2. Inventario</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/mantenimientos"><i class="bi bi-tools"></i> 3. Mantenimientos</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/reservas"><i class="bi bi-calendar-check"></i> 4. Reservas</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/prestamos"><i class="bi bi-box-arrow-right"></i> 5. Préstamos</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/incidencias"><i class="bi bi-exclamation-triangle"></i> 6. Incidencias</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/reportes"><i class="bi bi-file-earmark-bar-graph"></i> 7. Reportes HTML</a>
        </nav>
        <div class="p-3 border-top border-secondary border-opacity-25">
            <a href="${pageContext.request.contextPath}/logout" class="nav-link text-danger m-0">
                <i class="bi bi-box-arrow-left"></i> Cerrar Sesión
            </a>
        </div>
    </aside>

    <!-- Contenido Principal -->
    <div class="main-wrapper">
        <header class="topbar">
            <div class="text-secondary small">
                Operador activo: <strong class="text-dark">${sessionScope.usuario != null ? sessionScope.usuario : 'Administrador Laboratorio UMG'}</strong> (ADMIN)
            </div>
            <span class="badge bg-success px-3 py-2 rounded-pill">
                <i class="bi bi-hdd-network me-1"></i> Tomcat + MySQL Docker
            </span>
        </header>

        <main class="p-4 container-fluid" style="max-width: 1400px;">
            <!-- Encabezado ejecutivo -->
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="fw-bold text-dark mb-1">Resumen Ejecutivo del Laboratorio</h2>
                    <p class="text-muted small mb-0">Monitoreo operativo en tiempo real de recursos, disponibilidad y soporte técnico</p>
                </div>
                <div class="d-flex gap-2 mt-2 mt-md-0">
                    <a href="${pageContext.request.contextPath}/reportes" class="btn btn-outline-primary btn-sm fw-semibold px-3 py-2">
                        <i class="bi bi-filetype-html me-1"></i> Exportar Reporte
                    </a>
                    <a href="${pageContext.request.contextPath}/reservas" class="btn btn-primary btn-sm fw-semibold px-3 py-2">
                        <i class="bi bi-plus-lg me-1"></i> Nueva Reserva
                    </a>
                </div>
            </div>

            <!-- Fila 1: 4 KPIs Principales (Sin enlaces duplicados) -->
            <div class="row g-3 mb-4">
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="kpi-card d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Equipos Activos</span>
                            <h2 class="fw-bold text-dark my-1">${not empty totalEquipos ? totalEquipos : 7}</h2>
                            <span class="badge bg-primary bg-opacity-10 text-primary small">Disponibles en sala</span>
                        </div>
                        <div class="kpi-icon bg-primary bg-opacity-10 text-primary">
                            <i class="bi bi-laptop"></i>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="kpi-card d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Reservas Confirmadas</span>
                            <h2 class="fw-bold text-dark my-1">${not empty totalReservas ? totalReservas : 1}</h2>
                            <span class="badge bg-success bg-opacity-10 text-success small">Asignación activa</span>
                        </div>
                        <div class="kpi-icon bg-success bg-opacity-10 text-success">
                            <i class="bi bi-calendar2-check"></i>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="kpi-card d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Préstamos Abiertos</span>
                            <h2 class="fw-bold text-dark my-1">${not empty totalPrestamos ? totalPrestamos : 0}</h2>
                            <span class="badge bg-warning bg-opacity-10 text-warning-emphasis small">En uso externo</span>
                        </div>
                        <div class="kpi-icon bg-warning bg-opacity-15 text-warning">
                            <i class="bi bi-arrow-left-right"></i>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="kpi-card d-flex align-items-center justify-content-between">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Incidencias Abiertas</span>
                            <h2 class="fw-bold text-dark my-1">${not empty totalIncidencias ? totalIncidencias : 1}</h2>
                            <span class="badge bg-danger bg-opacity-10 text-danger small">Requieren atención</span>
                        </div>
                        <div class="kpi-icon bg-danger bg-opacity-10 text-danger">
                            <i class="bi bi-exclamation-octagon"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Fila 2: Gráficos Analíticos -->
            <div class="row g-4 mb-4">
                <div class="col-12 col-lg-8">
                    <div class="panel-card">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <h5 class="fw-bold text-dark mb-0">Distribución Operativa del Laboratorio</h5>
                                <span class="text-muted small">Comparativa general de registros activos por categoría</span>
                            </div>
                            <span class="badge bg-light text-secondary border">Datos en vivo</span>
                        </div>
                        <div style="height: 270px;">
                            <canvas id="operacionChart"></canvas>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-lg-4">
                    <div class="panel-card">
                        <h5 class="fw-bold text-dark mb-0">Salud de Infraestructura</h5>
                        <span class="text-muted small">Disponibilidad vs. Mantenimiento e Incidencias</span>
                        <div style="height: 215px;" class="my-2 d-flex justify-content-center">
                            <canvas id="saludChart"></canvas>
                        </div>
                        <div class="border-top pt-2 mt-2 d-flex justify-content-between small text-muted">
                            <span>Docentes activos: <strong class="text-dark">${not empty totalSolicitantes ? totalSolicitantes : 3}</strong></span>
                            <span>Mantenimientos: <strong class="text-dark">${not empty totalMantenimientos ? totalMantenimientos : 1}</strong></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Fila 3: Flujos Rápidos (Acciones operativas reales, no navegación duplicada) -->
            <div class="panel-card">
                <div class="mb-3">
                    <h5 class="fw-bold text-dark mb-0">Flujos de Trabajo Rápidos</h5>
                    <span class="text-muted small">Accesos directos a tareas operativas frecuentes del administrador</span>
                </div>
                <div class="row g-3">
                    <div class="col-12 col-md-6 col-xl-3">
                        <a href="${pageContext.request.contextPath}/equipos" class="quick-action-btn">
                            <i class="bi bi-plus-circle-fill text-primary fs-5"></i>
                            <div>
                                <div class="fw-semibold">Alta de Equipo</div>
                                <div class="text-muted" style="font-size: 0.78rem;">Registrar hardware en inventario</div>
                            </div>
                        </a>
                    </div>
                    <div class="col-12 col-md-6 col-xl-3">
                        <a href="${pageContext.request.contextPath}/mantenimientos" class="quick-action-btn">
                            <i class="bi bi-wrench-adjustable-circle-fill text-secondary fs-5"></i>
                            <div>
                                <div class="fw-semibold">Programar Servicio</div>
                                <div class="text-muted" style="font-size: 0.78rem;">Agendar mantenimiento preventivo</div>
                            </div>
                        </a>
                    </div>
                    <div class="col-12 col-md-6 col-xl-3">
                        <a href="${pageContext.request.contextPath}/incidencias" class="quick-action-btn">
                            <i class="bi bi-shield-exclamation text-danger fs-5"></i>
                            <div>
                                <div class="fw-semibold">Reportar Falla</div>
                                <div class="text-muted" style="font-size: 0.78rem;">Abrir ticket de soporte técnico</div>
                            </div>
                        </a>
                    </div>
                    <div class="col-12 col-md-6 col-xl-3">
                        <a href="${pageContext.request.contextPath}/solicitantes" class="quick-action-btn">
                            <i class="bi bi-person-plus-fill text-info fs-5"></i>
                            <div>
                                <div class="fw-semibold">Habilitar Docente</div>
                                <div class="text-muted" style="font-size: 0.78rem;">Gestionar solicitantes autorizados</div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Script de Gráficos Dinámicos con tus valores reales -->
<!-- Contenedor oculto con los datos reales desde el servidor -->
<div id="dashboardData" style="display:none;"
     data-equipos="${not empty totalEquipos ? totalEquipos : 7}"
     data-solicitantes="${not empty totalSolicitantes ? totalSolicitantes : 3}"
     data-reservas="${not empty totalReservas ? totalReservas : 1}"
     data-prestamos="${not empty totalPrestamos ? totalPrestamos : 0}"
     data-mantenimientos="${not empty totalMantenimientos ? totalMantenimientos : 1}"
     data-incidencias="${not empty totalIncidencias ? totalIncidencias : 1}">
</div>

<script>
    const ds = document.getElementById('dashboardData').dataset;
    const equipos = Number(ds.equipos);
    const solicitantes = Number(ds.solicitantes);
    const reservas = Number(ds.reservas);
    const prestamos = Number(ds.prestamos);
    const mantenimientos = Number(ds.mantenimientos);
    const incidencias = Number(ds.incidencias);

    // Gráfico de Barras: Panorama General
    new Chart(document.getElementById('operacionChart'), {
        type: 'bar',
        data: {
            labels: ['Equipos Activos', 'Solicitantes', 'Reservas', 'Préstamos', 'Mantenimientos', 'Incidencias'],
            datasets: [{
                label: 'Registros actuales',
                data: [equipos, solicitantes, reservas, prestamos, mantenimientos, incidencias],
                backgroundColor: [
                    'rgba(37, 99, 235, 0.85)',
                    'rgba(6, 182, 212, 0.85)',
                    'rgba(22, 163, 74, 0.85)',
                    'rgba(245, 158, 11, 0.85)',
                    'rgba(100, 116, 139, 0.85)',
                    'rgba(220, 38, 38, 0.85)'
                ],
                borderRadius: 8,
                maxBarThickness: 48
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1 }, grid: { color: '#f1f5f9' } },
                x: { grid: { display: false } }
            }
        }
    });

    // Gráfico de Dona: Salud del Inventario
    new Chart(document.getElementById('saludChart'), {
        type: 'doughnut',
        data: {
            labels: ['Operativos', 'En Mantenimiento', 'Con Incidencia'],
            datasets: [{
                data: [Math.max(equipos - mantenimientos - incidencias, 0), mantenimientos, incidencias],
                backgroundColor: ['#16a34a', '#64748b', '#dc2626'],
                borderWidth: 2,
                borderColor: '#ffffff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '68%',
            plugins: {
                legend: { position: 'bottom', labels: { boxWidth: 12, font: { size: 11 } } }
            }
        }
    });
</script>
</body>
</html>