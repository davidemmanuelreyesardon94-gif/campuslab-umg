<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ include file="WEB-INF/includes/header.jsp" %>
<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="fw-bold">Módulo 2: Inventario de Equipos</h3>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalEquipo"><i class="bi bi-plus-lg"></i> Registrar Equipo</button>
</div>
<form class="row g-2 mb-3" method="get" action="equipos">
    <div class="col-md-4"><input type="text" name="q" value="${q}" class="form-control" placeholder="Filtrar por código, descripción o tipo..."></div>
    <div class="col-auto"><button class="btn btn-outline-secondary">Filtrar</button></div>
</form>
<div class="card shadow-sm">
    <table class="table table-hover mb-0 align-middle">
        <thead class="table-dark">
            <tr><th>Código</th><th>Descripción</th><th>Tipo</th><th>Marca / Modelo</th><th>RAM</th><th>Ubicación</th><th>Estado</th><th>Acciones</th></tr>
        </thead>
        <tbody>
            <c:forEach var="e" items="${lista}">
                <tr>
                    <td class="fw-bold">${e.codigo}</td>
                    <td>${e.descripcion}</td>
                    <td class="text-capitalize">${e.tipo}</td>
                    <td>${e.marca} ${e.modelo}</td>
                    <td>${e.ram != null ? e.ram : 'N/A'} ${e.ram != null ? 'GB' : ''}</td>
                    <td>${e.ubicacion}</td>
                    <td><span class="badge ${e.estado == 'activo' ? 'bg-success' : 'bg-secondary'}">${e.estado}</span></td>
                    <td>
                        <c:if test="${e.estado == 'activo'}">
                            <form id="bajaEq${e.id}" method="post" action="equipos" class="d-inline">
                                <input type="hidden" name="accion" value="baja">
                                <input type="hidden" name="id" value="${e.id}">
                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="promptConfirmacion('bajaEq${e.id}', '¿Dar de baja equipo?', 'Se desactivará ${e.codigo} del inventario activo.', false)">Baja Lógica</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div class="modal fade" id="modalEquipo" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="equipos">
            <div class="modal-header"><h5 class="modal-title">Nuevo Equipo</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <input type="hidden" name="accion" value="crear">
                <div class="mb-2"><label>Código Inventario *</label><input type="text" name="codigo" class="form-control" placeholder="PC-LAB1-06" required></div>
                <div class="mb-2"><label>Descripción *</label><input type="text" name="descripcion" class="form-control" required></div>
                <div class="mb-2">
                    <label>Tipo *</label>
                    <select name="tipo" id="selectTipoEquipo" class="form-select" onchange="toggleOtroTipo()">
                        <option value="computadora">Computadora</option>
                        <option value="proyector">Proyector</option>
                        <option value="bocina">Bocina</option>
                        <option value="camara">Cámara</option>
                        <option value="otro">Otro</option>
                    </select>
                </div>
                <div class="mb-2 d-none" id="grupoOtroTipo">
                    <label>Especifique otro tipo de equipo *</label>
                    <input type="text" name="tipo_otro" id="inputOtroTipo" class="form-control" placeholder="Ej. Switch, Router, Micrófono...">
                </div>
                <div class="row">
                    <div class="col-6 mb-2"><label>Marca *</label><input type="text" name="marca" class="form-control" required></div>
                    <div class="col-6 mb-2"><label>Modelo *</label><input type="text" name="modelo" class="form-control" required></div>
                </div>
                <div class="mb-2" id="grupoRamEquipo"><label>RAM en GB (Obligatorio si es computadora)</label><input type="number" name="ram" id="inputRamEquipo" class="form-control" placeholder="16"></div>
                <div class="mb-2"><label>Ubicación *</label><input type="text" name="ubicacion" class="form-control" required></div>
            </div>
            <div class="modal-footer"><button type="submit" class="btn btn-primary">Guardar Equipo</button></div>
        </form>
    </div>
</div>

<script>
    function toggleOtroTipo() {
        const select = document.getElementById('selectTipoEquipo');
        const grupoOtro = document.getElementById('grupoOtroTipo');
        const inputOtro = document.getElementById('inputOtroTipo');
        const grupoRam = document.getElementById('grupoRamEquipo');
        const inputRam = document.getElementById('inputRamEquipo');

        if (select.value === 'otro') {
            grupoOtro.classList.remove('d-none');
            inputOtro.required = true;
            inputOtro.focus();
        } else {
            grupoOtro.classList.add('d-none');
            inputOtro.required = false;
            inputOtro.value = '';
        }

        if (select.value === 'computadora') {
            grupoRam.classList.remove('d-none');
        } else {
            grupoRam.classList.add('d-none');
            inputRam.value = '';
        }
    }
</script>
<%@ include file="WEB-INF/includes/footer.jsp" %>