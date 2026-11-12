<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ include file="WEB-INF/includes/header.jsp" %>
<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold">Módulo 6: Incidencias de Equipos</h3>
    <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#modalInc"><i class="bi bi-exclamation-circle"></i> Reportar Falla</button>
</div>
<div class="card shadow-sm">
    <table class="table table-hover mb-0 align-middle">
        <thead class="table-dark">
            <tr><th>ID</th><th>Equipo</th><th>Prioridad</th><th>Descripción Falla</th><th>Responsable</th><th>Solución</th><th>Estado</th><th>Acciones</th></tr>
        </thead>
        <tbody>
            <c:forEach var="i" items="${lista}">
                <tr>
                    <td>#${i.id}</td>
                    <td class="fw-bold">${i.equipo}</td>
                    <td><span class="badge ${i.prioridad == 'alta' ? 'bg-danger' : (i.prioridad == 'media' ? 'bg-warning text-dark' : 'bg-info')}">${i.prioridad}</span></td>
                    <td>${i.descripcion}</td>
                    <td>${i.responsable}</td>
                    <td>${i.solucion != null ? i.solucion : '-'}</td>
                    <td><span class="badge ${i.estado == 'resuelta' ? 'bg-success' : 'bg-secondary'}">${i.estado}</span></td>
                    <td>
                        <c:if test="${i.estado == 'abierta' || i.estado == 'en_atencion'}">
                            <form id="resInc${i.id}" method="post" action="incidencias" class="d-inline">
                                <input type="hidden" name="accion" value="resolver">
                                <input type="hidden" name="id" value="${i.id}">
                                <button type="button" class="btn btn-sm btn-success" onclick="promptConfirmacion('resInc${i.id}', 'Resolver Incidencia #${i.id}', 'Describe la solución técnica aplicada:', true, 'solucion')">Resolver</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div class="modal fade" id="modalInc" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="incidencias">
            <div class="modal-header"><h5 class="modal-title">Registrar Incidencia</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <input type="hidden" name="accion" value="crear">
                <div class="mb-2"><label>Equipo Afectado *</label>
                    <select name="id_equipo" class="form-select" required>
                        <c:forEach var="item" items="${equipos}"><option value="${item.id}">${item.label}</option></c:forEach>                    </select>
                </div>
                <div class="mb-2"><label>Prioridad *</label>
                    <select name="prioridad" class="form-select">
                        <option value="baja">Baja</option>
                        <option value="media" selected>Media</option>
                        <option value="alta">Alta</option>
                    </select>
                </div>
                <div class="mb-2"><label>Descripción de la falla *</label><textarea name="descripcion" class="form-control" required></textarea></div>
                <div class="mb-2"><label>Responsable de seguimiento *</label><input type="text" name="responsable" class="form-control" value="Soporte Técnico UMG" required></div>
            </div>
            <div class="modal-footer"><button type="submit" class="btn btn-danger">Guardar Incidencia</button></div>
        </form>
    </div>
</div>
<%@ include file="WEB-INF/includes/footer.jsp" %>
