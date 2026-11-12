<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="WEB-INF/includes/header.jsp" %>
<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold">Módulo 1: Gestión de Solicitantes</h3>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalNuevo"><i class="bi bi-plus-lg"></i> Nuevo Solicitante</button>
</div>
<form class="row g-2 mb-3" method="get" action="solicitantes">
    <div class="col-md-4"><input type="text" name="q" value="${q}" class="form-control" placeholder="Buscar por código o nombre..."></div>
    <div class="col-auto"><button class="btn btn-outline-secondary">Buscar</button></div>
</form>
<div class="card shadow-sm">
    <table class="table table-hover mb-0 align-middle">
        <thead class="table-dark">
            <tr><th>Código</th><th>Nombre Completo</th><th>Correo</th><th>Departamento</th><th>Estado</th><th>Acciones</th></tr>
        </thead>
        <tbody>
            <c:forEach var="s" items="${lista}">
                <tr>
                    <td class="fw-bold">${s.codigo}</td>
                    <td>${s.nombre}</td>
                    <td>${s.correo}</td>
                    <td>${s.departamento}</td>
                    <td><span class="badge ${s.estado == 'activo' ? 'bg-success' : 'bg-secondary'}">${s.estado}</span></td>
                    <td>
                        <c:if test="${s.estado == 'activo'}">
                            <form id="bajaSol${s.id}" method="post" action="solicitantes" class="d-inline">
                                <input type="hidden" name="accion" value="baja">
                                <input type="hidden" name="id" value="${s.id}">
                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="promptConfirmacion('bajaSol${s.id}', '¿Desactivar solicitante?', 'Se aplicará baja lógica a ${s.nombre}. No podrá hacer nuevas reservas.', false)">Desactivar</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div class="modal fade" id="modalNuevo" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="solicitantes">
            <div class="modal-header"><h5 class="modal-title">Registrar Solicitante</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <input type="hidden" name="accion" value="crear">
                <div class="mb-2"><label>Código Único *</label><input type="text" name="codigo" class="form-control" placeholder="DOC-005" required></div>
                <div class="mb-2"><label>Nombre Completo *</label><input type="text" name="nombre" class="form-control" required></div>
                <div class="mb-2"><label>Correo Institucional *</label><input type="email" name="correo" class="form-control" required></div>
                <div class="mb-2"><label>Carrera / Departamento *</label><input type="text" name="departamento" class="form-control" required></div>
            </div>
            <div class="modal-footer"><button type="submit" class="btn btn-primary">Guardar</button></div>
        </form>
    </div>
</div>
<%@ include file="WEB-INF/includes/footer.jsp" %>
