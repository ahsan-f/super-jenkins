# Dockerfile: jenkins-ngrok-builder/Dockerfile

# Use the official Jenkins Long-Term Support (LTS) image as the base
FROM jenkins/jenkins:lts

# Switch to the root user to install software
USER root

# Disable interactive prompts for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary build tools and dependencies.
# - apt-get update: Updates the package lists.
# - apt-get install -y: Installs packages without user interaction.
# - git: Essential for cloning repositories from GitHub.
# - curl, gnupg, lsb-release: Utilities for adding external repositories.
# - openjdk-11-jdk: Maven needs a JDK. Jenkins already has one but often good to explicitly define.
# - maven: Build tool for Java projects.
# - nodejs: JavaScript runtime and npm.
# - docker-cli: To interact with a Docker daemon (e.g., Docker-in-Docker or a remote daemon).
# - unzip: Required for ngrok.
RUN apt-get update && \
    apt-get install -y software-properties-common && \
        git \
        curl \
        gnupg \
        lsb-release \
        openjdk-11-jdk \
        unzip && \
    
    # Add Node.js 16.x repository and install Node.js
    curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \

    # Install Maven
    apt-get install -y maven && \

    # Install Docker CLI (client)
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \

    # Download and install Ngrok
    curl -sS -o /tmp/ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && \
    unzip /tmp/ngrok.zip -d /usr/local/bin && \
    rm /tmp/ngrok.zip && \
    chmod +x /usr/local/bin/ngrok && \
    # Download and install jq
    apt-get install -y git curl gnupg lsb-release openjdk-11-jdk unzip jq && \

    # Clean up apt caches to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add a script to start Jenkins and Ngrok
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose Jenkins ports
EXPOSE 8080
EXPOSE 50000

# Set the entrypoint to our custom script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command for Jenkins
CMD ["jenkins"]

# Switch back to the 'jenkins' user for security
USER jenkins
