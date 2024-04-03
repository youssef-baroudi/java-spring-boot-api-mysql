#FROM openjdk:11
#COPY target/easy-notes-spring-boot-mysql-1.0.0-SNAPSHOT.jar app.jar
#EXPOSE 8080
#ENTRYPOINT ["java","-jar","/app.jar"]

FROM maven:3.8.5-openjdk-17

WORKDIR /java-spring-mysql
COPY . .
CMD mvn spring-boot:run