<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ include file="WEB-INF/includes/header.jsp" %>
<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold">Módulo 5: Préstamos y Devoluciones</h3>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalPrestamo"><i class="bi bi-box-arrow-right"></i> Registrar Entrega Física</button>
</div>
<div class="card shadow-sm">
    <table class="table table-hover mb-0 align-middle">
        <thead class="table-dark">
            <tr><th>ID</th><th>Reserva</th><th>Solicitante</th><th>Recibió</th><th>Equipos Entregados</th><th>Devolución Prevista</th><th>Estado</th><th>Acciones</th></tr>
        </thead>
        <tbody>
            <c:forEach var="p" items="${prestamos}">
                <tr>
                    <td>#${p.id}</td>
                    <td>Reserva #${p.idReserva}</td>
                    <td>${p.solicitante}</td>
                    <td>${p.recibidoPor}</td>
                    <td class="fw-bold">${p.equipos}</td>
                    <td>${p.prevista}</td>
                    <td><span class="badge ${p.estado == 'abierto' ? 'bg-warning text-dark' : 'bg-success'}">${p.estado}</span></td>
                    <td>
                        <c:if test="${p.estado == 'abierto'}">
                            <form id="devPres${p.id}" method="post" action="prestamos">
                                <input type="hidden" name="accion" value="devolver">
                                <input type="hidden" name="id" value="${p.id}">
                                <button type="button" class="btn btn-sm btn-success" onclick="promptConfirmacion('devPres${p.id}', 'Registrar Devolución', 'Indica la condición física en la que regresan los equipos:', true, 'condicion')">Registrar Devolución</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div class="modal fade" id="modalPrestamo" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="prestamos">
            <div class="modal-header"><h5 class="modal-title">Entregar Equipos de Reserva Confirmada</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <input type="hidden" name="accion" value="entregar">
                <div class="mb-2"><label>Reserva Confirmada *</label>
                    <select name="id_reserva" class="form-select" required>
                        <c:forEach var="rc" items="${reservasConfirmadas}"><option value="${rc.id}">${rc.label}</option></c:forEach>
                    </select>
                </div>
                <div class="mb-2"><label>Nombre de quien recibe físicamente *</label><input type="text" name="recibido_por" class="form-control" required></div>
                <div class="mb-2"><label>Observaciones de entrega</label><textarea name="observaciones" class="form-control"></textarea></div>
            </div>
            <div class="modal-footer"><button type="submit" class="btn btn-primary">Confirmar Entrega</button></div>
        </form>
    </div>
</div>
<%@ include file="WEB-INF/includes/footer.jsp" %>
