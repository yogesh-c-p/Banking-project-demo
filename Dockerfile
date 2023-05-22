FROM openjdk:11
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} my-app.jar
ENTRYPOINT ["java","-jar","my-app.jar"]
