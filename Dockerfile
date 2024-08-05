# Use the official OpenJDK 17 JRE as the base image
FROM openjdk:17-jre

# Add the JAR file to the container
ADD /jenkins/workspace/Nam-trend-multibranch_main/jarstaging/com/valaxy/demo-workshop/2.1.3/demo-workshop-2.1.3.jar demo-workshop.jar

# Define the entry point to run the application
ENTRYPOINT ["java", "-jar", "demo-workshop.jar"]
