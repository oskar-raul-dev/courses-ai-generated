<%--
  web-legacy — frontend JEE "antiguo" sobre Tomcat.

  Representa el monolito heredado que consume los microservicios.
  Aquí hace una llamada REST simple a catalog-node para listar
  productos y renderizarlos en JSP (server-side rendering clásico).

  Puedes migrarlo a TomEE o WildFly más adelante: ver docs/variantes.md
--%>
<%@ page import="java.net.*, java.io.*" contentType="text/html; charset=UTF-8" %>
<%
    // La URL del catálogo llega por variable de entorno (nombre DNS
    // interno de Kubernetes). Con valor por defecto para correr local.
    String catalogUrl = System.getenv().getOrDefault("CATALOG_URL", "http://localhost:3000");
    String json = "";
    try {
        URL url = new URL(catalogUrl + "/products");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = in.readLine()) != null) sb.append(line);
        in.close();
        json = sb.toString();
    } catch (Exception e) {
        json = "[Error consultando catálogo: " + e.getMessage() + "]";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>web-legacy — Tienda</title>
    <style>
        body { font-family: sans-serif; max-width: 700px; margin: 40px auto; }
        h1 { color: #333; }
        pre { background: #f4f4f4; padding: 16px; border-radius: 6px; }
        .badge { background: #8b5cf6; color: white; padding: 2px 8px; border-radius: 4px; font-size: 12px; }
    </style>
</head>
<body>
    <h1>Tienda <span class="badge">JEE / Tomcat</span></h1>
    <p>Este frontend heredado consume <code>catalog-node</code> por REST.</p>
    <h2>Catálogo (crudo desde el microservicio):</h2>
    <pre><%= json %></pre>
    <p><small>Servido por Tomcat. Catálogo desde: <%= catalogUrl %></small></p>
</body>
</html>
