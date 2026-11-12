<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - CampusLab UMG</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            position: relative;
            min-height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: radial-gradient(circle at center, #1e293b 0%, #0f172a 100%);
            overflow: hidden;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
        }

        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background: url('${pageContext.request.contextPath}/img/escudo-umg.png') no-repeat center center;
            background-size: 620px auto;
            filter: blur(3px) drop-shadow(0 0 30px rgba(59, 130, 246, 0.25));
            opacity: 0.35;
            z-index: 0;
            pointer-events: none;
        }

        .login-card {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 400px;
            background: rgba(255, 255, 255, 0.93);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.35);
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.65);
            padding: 2.5rem 2rem;
        }

        .brand-title {
            color: #0d6efd;
            font-weight: 700;
            letter-spacing: -0.5px;
        }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="text-center mb-4">
            <h3 class="brand-title mb-1">CampusLab UMG</h3>
            <p class="text-muted small mb-0">Sistema de Gestión de Laboratorio Universitario</p>
        </div>

        <c:if test="${not empty error or param.error != null}">
            <div class="alert alert-danger py-2 small text-center" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-1"></i>
                ${not empty error ? error : 'Usuario o contraseña incorrectos'}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="mb-3">
                <label for="username" class="form-label fw-semibold small">Usuario</label>
                <input type="text" class="form-control" id="username" name="username" value="admin" required autofocus>
            </div>
            <div class="mb-4">
                <label for="password" class="form-label fw-semibold small">Contraseña</label>
                <input type="password" class="form-control" id="password" name="password" value="admin123" required>
            </div>
            <button type="submit" class="btn btn-primary w-100 fw-semibold py-2">
                Iniciar Sesión
            </button>
        </form>

        <div class="text-center mt-4">
            <span class="text-muted small">Demo: admin / admin123</span>
        </div>
    </div>
</body>
</html>