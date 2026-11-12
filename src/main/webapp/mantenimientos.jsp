<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ include file="WEB-INF/includes/header.jsp" %>
<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold">Módulo 3: Mantenimientos</h3>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalMant"><i class="bi bi-tools"></i> Programar Mantenimiento</button>
</div>
<div class="card shadow-sm">
    <table class="table table-hover mb-0 align-middle">
        <thead class="table-dark">
            <tr><th>ID</th><th>Equipo</th><th>Inicio</th><th>Fin</th><th>Motivo</th><th>Observaciones</th><th>Estado</th><th>Acciones</th></tr>
        </thead>
        <tbody>
            <c:forEach var="m" items="${lista}">
                <tr>
                    <td>#${m.id}</td>
                    <td class="fw-bold">${m.equipo}</td>
                    <td>${m.inicio}</td>
                    <td>${m.fin}</td>
                    <td>${m.motivo}</td>
                    <td>${m.observaciones}</td>
                    <td><span class="badge ${m.estado == 'programado' ? 'bg-warning text-dark' : (m.estado == 'finalizado' ? 'bg-success' : 'bg-danger')}">${m.estado}</span></td>
                    <td>
                        <c:if test="${m.estado == 'programado'}">
                            <form id="finMant${m.id}" method="post" action="mantenimientos" class="d-inline">
                                <input type="hidden" name="accion" value="finalizar">
                                <input type="hidden" name="id" value="${m.id}">
                                <button type="button" class="btn btn-sm btn-success" onclick="promptConfirmacion('finMant${m.id}', '¿Finalizar mantenimiento?', 'El equipo volverá a estar disponible.', false)">Finalizar</button>
                            </form>
                            <form id="anuMant${m.id}" method="post" action="mantenimientos" class="d-inline">
                                <input type="hidden" name="accion" value="anular">
                                <input type="hidden" name="id" value="${m.id}">
                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="promptConfirmacion('anuMant${m.id}', 'Anular Mantenimiento', 'Indica el motivo de la anulación:', true, 'motivo_anulacion')">Anular</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div class="modal fade" id="modalMant" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="mantenimientos">
            <div class="modal-header"><h5 class="modal-title">Programar Mantenimiento</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <input type="hidden" name="accion" value="crear">
                <div class="mb-2"><label>Equipo *</label>
                    <select name="id_equipo" class="form-select" required>
                        <c:forEach var="item" items="${equipos}"><option value="${item.id}">${item.label}</option></c:forEach>                </div>
                <div class="mb-2"><label>Fecha y Hora Inicio *</label><input type="datetime-local" name="fecha_inicio" class="form-control" required></div>
                <div class="mb-2"><label>Fecha y Hora Fin *</label><input type="datetime-local" name="fecha_fin" class="form-control" required></div>
                <div class="mb-2"><label>Motivo *</label><input type="text" name="motivo" class="form-control" required></div>
                <div class="mb-2"><label>Observaciones</label><textarea name="observaciones" class="form-control"></textarea></div>
            </div>
            <div class="modal-footer"><button type="submit" class="btn btn-primary">Guardar</button></div>
        </form>
    </div>
</div>
<%@ include file="WEB-INF/includes/footer.jsp" %>
