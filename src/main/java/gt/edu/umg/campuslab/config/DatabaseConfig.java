package gt.edu.umg.campuslab.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConfig {
    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver MySQL no encontrado", e);
        }
        String host = System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : "localhost";
        String port = System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : "3306";
        String db   = System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : "campuslab";
        String user = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";
        String pass = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "rootpassword";

        String url = "jdbc:mysql://" + host + ":" + port + "/" + db + "?sslMode=PREFERRED&allowPublicKeyRetrieval=true&serverTimezone=America/Guatemala";
        return DriverManager.getConnection(url, user, pass);
    }
}
