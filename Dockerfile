 Use an official OpenJDK image with Java 21 as the base.
FROM openjdk:21-jdk-slim

# Set the Jenkins LTS version. It's recommended to use the latest LTS.
ARG JENKINS_VERSION=2.466.1

# Set the download URL for the Jenkins WAR file using a stable path.
# We are using the major.minor version number (2.466) in the URL.
ENV JENKINS_URL=https://updates.jenkins.io/download/war-stable/2.466/jenkins.war

# Set the working directory inside the container.
WORKDIR /usr/local/jenkins

# Download the Jenkins WAR file and install required dependencies.
# The 'libfreetype6' and 'fontconfig' packages are necessary for Jenkins to run correctly
# because they are required for generating graphical elements like charts.
RUN apt-get update && apt-get install -y wget libfreetype6 fontconfig && \
    wget -O jenkins.war ${JENKINS_URL} && \
    rm -rf /var/lib/apt/lists/*

# Expose the default Jenkins port.
EXPOSE 8080

# The command to run when the container starts.
CMD ["java", "-Djava.awt.headless=true", "-jar", "jenkins.war"]
