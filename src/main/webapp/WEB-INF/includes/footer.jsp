<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
</main>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    <c:if test="${not empty sessionScope.msgSuccess}">
        Swal.fire({ icon: 'success', title: '¡Operación Exitosa!', text: '${sessionScope.msgSuccess}', confirmButtonColor: '#3b82f6' });
        <c:remove var="msgSuccess" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.msgError}">
        Swal.fire({ icon: 'error', title: 'Atención / Conflicto', text: '${sessionScope.msgError}', confirmButtonColor: '#ef4444' });
        <c:remove var="msgError" scope="session"/>
    </c:if>

    function confirmarLogout() {
        Swal.fire({
            title: '¿Cerrar sesión?',
            text: 'Tendrás que volver a ingresar tus credenciales.',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Sí, salir',
            cancelButtonText: 'Cancelar'
        }).then((result) => {
            if (result.isConfirmed) window.location.href = 'login?action=logout';
        });
    }

    function promptConfirmacion(formId, titulo, texto, requiereMotivo, inputName) {
        if (requiereMotivo) {
            Swal.fire({
                title: titulo,
                text: texto,
                input: 'text',
                inputPlaceholder: 'Escribe el motivo aquí...',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Confirmar',
                cancelButtonText: 'Cancelar',
                inputValidator: (value) => {
                    if (!value) return '¡Debes ingresar un motivo obligatorio!';
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    const form = document.getElementById(formId);
                    const hidden = document.createElement('input');
                    hidden.type = 'hidden';
                    hidden.name = inputName;
                    hidden.value = result.value;
                    form.appendChild(hidden);
                    form.submit();
                }
            });
        } else {
            Swal.fire({
                title: titulo,
                text: texto,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                confirmButtonText: 'Sí, ejecutar',
                cancelButtonText: 'Cancelar'
            }).then((result) => {
                if (result.isConfirmed) document.getElementById(formId).submit();
            });
        }
    }
</script>
</body>
</html>
