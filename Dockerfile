# Build stage: compile the application
FROM maven:3.8.5-openjdk-11 AS build
WORKDIR /app
COPY . .
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
