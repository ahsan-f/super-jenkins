# Use an official OpenJDK image with Java 21 as the base.
# OpenJDK 21 is a Long-Term Support (LTS) version.
FROM openjdk:21-jdk-slim

# Set an argument for the Jenkins WAR file version.
# We'll use the latest LTS version, which is compatible with Java 21.
# We will use the latest LTS version from the jenkins.io website
ARG JENKINS_VERSION=2.466.1

# Set the download URL for the Jenkins WAR file.
ENV JENKINS_URL=https://updates.jenkins.io/download/war-stable/${JENKINS_VERSION}/jenkins.war

# Set the working directory inside the container.
WORKDIR /usr/local/jenkins

# Download the Jenkins WAR file and install required dependencies.
# The 'libfreetype6' and 'fontconfig' packages are necessary for Jenkins to run correctly.
RUN apt-get update && apt-get install -y wget libfreetype6 fontconfig && \
    wget -O jenkins.war ${JENKINS_URL} && \
    rm -rf /var/lib/apt/lists/*

# Expose the default Jenkins port.
EXPOSE 8080

# The command to run when the container starts.
# This executes the Jenkins WAR file.
CMD ["java", "-Djava.awt.headless=true", "-jar", "jenkins.war"]
