#FROM openjdk:11
#COPY target/easy-notes-spring-boot-mysql-1.0.0-SNAPSHOT.jar app.jar
#EXPOSE 8080
#ENTRYPOINT ["java","-jar","/app.jar"]

#FROM maven:3.8.5-openjdk-17
#
#WORKDIR /java-spring-mysql
#COPY . .
#CMD mvn spring-boot:run


# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY ./target/easy-notes-spring-boot-mysql-4.0.0-SNAPSHOT.jar /app

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run spring-mysql-demo.jar when the container launches
CMD ["java", "-jar", "easy-notes-spring-boot-mysql-4.0.0-SNAPSHOT.jar"]