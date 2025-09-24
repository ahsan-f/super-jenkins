# Use an official OpenJDK image as the base.
# It already has a Java Runtime Environment, which is necessary to run Jenkins.
FROM openjdk:11-jdk-slim

# Set an argument for the Jenkins WAR file version.
# This makes your Dockerfile more flexible.
ARG JENKINS_VERSION=2.462

# Set the download URL for the Jenkins WAR file.
ENV JENKINS_URL=https://updates.jenkins.io/download/war/${JENKINS_VERSION}/jenkins.war

# Set the working directory inside the container.
WORKDIR /usr/local/jenkins

# Download the Jenkins WAR file.
# The 'wget' command is used to download the file from the specified URL.
# The '-O' flag saves the file with the name 'jenkins.war'.
# The fix: added `libfreetype6` and `fontconfig` to the `apt-get install` command.
RUN apt-get update && apt-get install -y wget libfreetype6 fontconfig && \
    wget -O jenkins.war ${JENKINS_URL} && \
    rm -rf /var/lib/apt/lists/*

# Expose the default Jenkins port.
EXPOSE 8080

# The command to run when the container starts.
# This executes the Jenkins WAR file.
CMD ["java", "-Djava.awt.headless=true", "-jar", "jenkins.war"]
