#FROM openjdk:11
#COPY target/easy-notes-spring-boot-mysql-1.0.0-SNAPSHOT.jar app.jar
#EXPOSE 8080
#ENTRYPOINT ["java","-jar","/app.jar"]

# this method allow to exclude the target folder to be committed
FROM openjdk:17-jdk-slim

WORKDIR /app
COPY . .
CMD mvn spring-boot:run

# this method force to commit target folder to github => see by every one and developer
# used if we deploy .jar to apache directly
# Use an official OpenJDK runtime as a parent image
#FROM openjdk:17-jdk-slim

# Set the working directory to /app
#WORKDIR /app

# Copy the current directory contents into the container at /app
#COPY ./target/easy-notes-spring-boot-mysql-1.0.0.jar /app

# Make port 8080 available to the world outside this container
#EXPOSE 8080

# Run spring-mysql-demo.jar when the container launches
#CMD ["java", "-jar", "easy-notes-spring-boot-mysql-1.0.0.jar"]