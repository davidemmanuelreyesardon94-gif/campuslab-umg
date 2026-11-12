<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/includes/header.jsp" %>
<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold">Módulo 4: Reservas y Asignación Automática</h3>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalReserva"><i class="bi bi-cpu"></i> Nueva Reserva Automática</button>
</div>
<div class="card shadow-sm">
    <table class="table table-hover mb-0 align-middle">
        <thead class="table-dark">
            <tr><th>ID</th><th>Solicitante</th><th>Horario</th><th>Tipo / Cant</th><th>Estrategia</th><th>Equipos Asignados</th><th>Comentarios</th><th>Estado</th><th>Acciones</th></tr>
        </thead>
        <tbody>
            <c:forEach var="r" items="${reservas}">
                <tr>
                    <td>#${r.id}</td>
                    <td>${r.solicitante}</td>
                    <td><small>${r.inicio}<br>al ${r.fin}</small></td>
                    <td class="text-capitalize">${r.tipo} (${r.cantidad}) <c:if test="${r.ram != null}"><br><small class="text-muted">Min ${r.ram}GB</small></c:if></td>
                    <td><span class="badge bg-info text-dark">${r.estrategia}</span></td>
                    <td class="fw-bold text-primary">${r.equipos != null ? r.equipos : '-'}</td>
                    <td><small class="text-muted">${not empty r.comentarios ? r.comentarios : 'Sin comentarios'}</small></td>
                    <td><span class="badge ${r.estado == 'confirmada' ? 'bg-success' : (r.estado == 'finalizada' ? 'bg-primary' : 'bg-danger')}">${r.estado}</span></td>
                    <td>
                        <c:if test="${r.estado == 'confirmada'}">
                            <form id="cancRes${r.id}" method="post" action="reservas">
                                <input type="hidden" name="accion" value="cancelar">
                                <input type="hidden" name="id" value="${r.id}">
                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="promptConfirmacion('cancRes${r.id}', '¿Cancelar Reserva #${r.id}?', 'Se liberarán los equipos asignados automáticamente.', false)">Cancelar</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div class="modal fade" id="modalReserva" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="reservas">
            <div class="modal-header"><h5 class="modal-title">Motor de Asignación Automática</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <input type="hidden" name="accion" value="crear">
                <div class="mb-2"><label>Solicitante Activo *</label>
                    <select name="id_solicitante" class="form-select" required>
                        <c:forEach var="s" items="${solicitantes}"><option value="${s.id}">${s.label}</option></c:forEach>
                    </select>
                </div>
                <div class="row">
                    <div class="col-6 mb-2"><label>Inicio *</label><input type="datetime-local" name="fecha_inicio" class="form-control" required></div>
                    <div class="col-6 mb-2"><label>Fin *</label><input type="datetime-local" name="fecha_fin" class="form-control" required></div>
                </div>
                <div class="row">
                    <div class="col-6 mb-2"><label>Tipo Equipo *</label>
                        <select name="tipo_equipo" class="form-select">
                            <option value="computadora">Computadora</option>
                            <option value="proyector">Proyector</option>
                        </select>
                    </div>
                    <div class="col-6 mb-2"><label>Cantidad *</label><input type="number" name="cantidad" value="1" min="1" class="form-control" required></div>
                </div>
                <div class="row">
                    <div class="col-6 mb-2"><label>RAM Mínima (GB)</label><input type="number" name="ram_minima" value="8" class="form-control"></div>
                    <div class="col-6 mb-2"><label>Estrategia (Pattern) *</label>
                        <select name="estrategia" class="form-select">
                            <option value="menor_uso">Menor Uso Acumulado</option>
                            <option value="ajuste_capacidad">Ajuste de Capacidad (RAM)</option>
                        </select>
                    </div>
                </div>
                <div class="mb-2"><label>Motivo de Uso *</label><input type="text" name="motivo_uso" class="form-control" placeholder="Práctica de Laboratorio" required></div>
                <div class="mb-2">
                    <label>Comentarios / Observaciones <span class="text-muted small">(opcional)</span></label>
                    <textarea name="comentarios" class="form-control" rows="2" maxlength="255" placeholder="Ej. Requiere software instalado previamente o cable HDMI adicional..."></textarea>
                </div>
            </div>
            <div class="modal-footer"><button type="submit" class="btn btn-success">Ejecutar Asignación y Confirmar</button></div>
        </form>
    </div>
</div>
<%@ include file="WEB-INF/includes/footer.jsp" %>