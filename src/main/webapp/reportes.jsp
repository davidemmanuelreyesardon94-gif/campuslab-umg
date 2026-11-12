<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ include file="WEB-INF/includes/header.jsp" %>
<div class="d-flex justify-content-between align-items-center mb-3 no-print">
    <h3 class="fw-bold">Módulo 7: Reportes HTML y Configuraciones</h3>
    <button class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalConfig"><i class="bi bi-bookmark-plus"></i> Guardar Configuración</button>
</div>

<div class="row g-2 mb-4 no-print">
    <div class="col-auto"><a href="reportes?tipo=inventario" class="btn btn-dark">1. Inventario</a></div>
    <div class="col-auto"><a href="reportes?tipo=reservas" class="btn btn-dark">2. Reservas</a></div>
    <div class="col-auto"><a href="reportes?tipo=uso_equipos" class="btn btn-dark">3. Uso de Equipos</a></div>
    <div class="col-auto"><a href="reportes?tipo=mantenimientos" class="btn btn-dark">4. Mantenimientos</a></div>
    <div class="col-auto"><a href="reportes?tipo=prestamos" class="btn btn-dark">5. Préstamos</a></div>
    <div class="col-auto"><a href="reportes?tipo=incidencias" class="btn btn-dark">6. Incidencias</a></div>
</div>

<c:if test="${not empty reporteActual}">
    <div class="card shadow-sm mb-4" id="contenedorReporteOficial">
        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center flex-wrap gap-2">
            <h5 class="mb-0" id="tituloReporteOficial">REPORTE OFICIAL: ${reporteActual}</h5>
            <div class="d-flex gap-2 no-print">
                <button type="button" onclick="descargarReporteHTML()" class="btn btn-sm btn-warning fw-semibold">
                    <i class="bi bi-filetype-html"></i> Descargar HTML
                </button>
                <button type="button" onclick="window.print()" class="btn btn-sm btn-light">
                    <i class="bi bi-printer"></i> Imprimir / Guardar PDF
                </button>
            </div>
        </div>
        <div class="card-body" id="cuerpoReporteOficial">
            <p class="text-muted small">Generado por: ${sessionScope.nombreCompleto} | Fecha: <%= new java.util.Date() %></p>
            <c:choose>
                <c:when test="${empty filas}">
                    <div class="alert alert-info">No existen resultados registrados para este reporte.</div>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped">
                            <thead class="table-secondary">
                                <tr><c:forEach var="col" items="${columnas}"><th>${col}</th></c:forEach></tr>
                            </thead>
                            <tbody>
                                <c:forEach var="fila" items="${filas}">
                                    <tr><c:forEach var="celda" items="${fila}"><td>${celda}</td></c:forEach></tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <p class="fw-bold text-end mb-0">Total de registros: ${filas.size()}</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <script>
        function descargarReporteHTML() {
            const titulo = document.getElementById('tituloReporteOficial').innerText;
            const contenido = document.getElementById('cuerpoReporteOficial').innerHTML;
            const htmlCompleto = `<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>\${titulo} - CampusLab UMG</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f8fafc; padding: 2rem; font-family: system-ui, -apple-system, sans-serif; }
        .report-box { background: #fff; border-radius: 12px; box-shadow: 0 4px 16px rgba(0,0,0,0.08); overflow: hidden; }
        .report-header { background: #0d6efd; color: #fff; padding: 1.25rem 1.5rem; }
    </style>
</head>
<body>
    <div class="container">
        <div class="report-box">
            <div class="report-header d-flex justify-content-between align-items-center">
                <h4 class="mb-0">\${titulo}</h4>
                <span class="badge bg-light text-primary">CampusLab UMG</span>
            </div>
            <div class="p-4">
                \${contenido}
            </div>
        </div>
    </div>
</body>
</html>`;
            const blob = new Blob([htmlCompleto], { type: 'text/html;charset=utf-8' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            const nombreLimpio = titulo.replace(/[^a-zA-Z0-9_-]/g, '_').toLowerCase();
            a.href = url;
            a.download = nombreLimpio + '.html';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }
    </script>
</c:if>

<div class="card shadow-sm no-print">
    <div class="card-header fw-bold">Configuraciones de Reportes Guardadas</div>
    <table class="table mb-0 align-middle">
        <thead><tr><th>Nombre</th><th>Tipo</th><th>Filtros</th><th>Acciones</th></tr></thead>
        <tbody>
            <c:forEach var="c" items="${configs}">
                <tr>
                    <td>${c.nombre}</td>
                    <td>${c.tipo}</td>
                    <td><code>${c.filtros}</code></td>
                    <td>
                        <a href="reportes?tipo=${c.tipo}" class="btn btn-sm btn-primary">Ejecutar</a>
                        <form id="delCfg${c.id}" method="post" action="reportes" class="d-inline">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="${c.id}">
                            <button type="button" class="btn btn-sm btn-outline-danger" onclick="promptConfirmacion('delCfg${c.id}', '¿Eliminar configuración?', 'Se borrará ${c.nombre}.', false)">Eliminar</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div class="modal fade" id="modalConfig" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="reportes">
            <div class="modal-header"><h5 class="modal-title">Guardar Configuración de Reporte</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <input type="hidden" name="accion" value="guardar">
                <div class="mb-2"><label>Nombre *</label><input type="text" name="nombre" class="form-control" required></div>
                <div class="mb-2"><label>Tipo de Reporte *</label>
                    <select name="tipo_reporte" class="form-select">
                        <option value="inventario">Inventario</option>
                        <option value="reservas">Reservas</option>
                        <option value="uso_equipos">Uso de Equipos</option>
                        <option value="mantenimientos">Mantenimientos</option>
                        <option value="prestamos">Préstamos</option>
                        <option value="incidencias">Incidencias</option>
                    </select>
                </div>
                <div class="mb-2"><label>Filtros</label><input type="text" name="filtros" class="form-control" value="todos"></div>
            </div>
            <div class="modal-footer"><button type="submit" class="btn btn-primary">Guardar</button></div>
        </form>
    </div>
</div>
<%@ include file="WEB-INF/includes/footer.jsp" %>