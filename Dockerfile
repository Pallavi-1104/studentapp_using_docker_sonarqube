# Build stage: compile the application
# Build stage
FROM maven:3.8.5-openjdk-11 AS build
WORKDIR /app
COPY . .  # Ensure mysql-connector.zip is in the same directory as this Dockerfile

# Unzip the mysql-connector.jar to /app/lib
RUN apt-get update && apt-get install -y unzip && \
    unzip mysql-connector.jar -d /app/lib

# Build the application
RUN mvn clean package -DskipTests

# Final image: use Tomcat to run the WAR
FROM tomcat:9.0-jdk11
LABEL maintainer="Your Name <you@example.com>"

# Clean default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your built WAR into Tomcat
COPY student.war /usr/local/tomcat/webapps/ROOT.war

# Add MySQL connector to Tomcat lib (JDBC will pick it up)
COPY mysql-connector.jar /usr/local/tomcat/lib/

EXPOSE 8080

# Default Tomcat CMD already handles startup

# Final image
FROM openjdk:11-jre-slim
WORKDIR /app

# Copy the war file and MySQL connector jar
COPY --from=build /app/target/student.war app.jar
COPY mysql-connector.jar /app/lib/mysql-connector.jar

# Create a non-root user and switch to it for security
RUN useradd -ms /bin/bash appuser
USER appuser

EXPOSE 8080

# Run the jar file with MySQL connector
CMD ["java", "-cp", "app.jar:/app/lib/mysql-connector.jar", "com.studentapp.StudentApp"]


