# web-legacy — frontend JEE sobre Tomcat 9 (Java 8), estilo "2017".
#
# Empaquetamos el JSP directamente como webapp ROOT de Tomcat.
# En un proyecto real construirías un .war con Maven; aquí lo
# simplificamos copiando el webapp directo para foco en Kubernetes.
#
# Para variantes con TomEE o WildFly, ver docs/variantes.md

FROM tomcat:9-jre8

# Quitamos las apps de ejemplo que trae Tomcat por defecto.
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiamos nuestro JSP como la app ROOT (accesible en "/").
COPY src/main/webapp/ /usr/local/tomcat/webapps/ROOT/

EXPOSE 8080
CMD ["catalina.sh", "run"]
