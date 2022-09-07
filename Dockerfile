FROM jenkins/jenkins:latest
USER root
RUN apt-get update && apt-get clean && apt-get autoremove
RUN mkdir /srv/backup && chown jenkins:jenkins /srv/backup
USER jenkins
RUN echo latest > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN echo latest > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkins:jenkins config_jenkins /var/jenkins_home