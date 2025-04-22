FROM jenkins/jenkins:lts-jdk17
USER root

# Install Docker CLI
RUN apt-get update && \
    apt-get install -y docker.io wget apt-transport-https gnupg lsb-release

# Match Docker group ID with host (if needed), then add Jenkins to the group
RUN groupmod -g 110 docker || true && \
    usermod -aG docker jenkins
# Install Trivy (official method)
RUN apt-get update && apt-get install -y wget curl gnupg lsb-release && \
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

#Install sonar-scanner
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip && \
    unzip sonar-scanner-cli-*.zip -d /opt && \
    mv /opt/sonar-scanner-* /opt/sonar-scanner && \
    ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

USER jenkins