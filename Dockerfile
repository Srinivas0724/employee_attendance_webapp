# Part 1: Build the project using Maven
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Part 2: Run the app using Tomcat server
FROM tomcat:10.1-jdk17
# Remove default Tomcat apps to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy our built app into the Tomcat webapps folder
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]