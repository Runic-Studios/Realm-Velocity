FROM openjdk:17-jdk

WORKDIR /opt/velocity

COPY velocity.jar /opt/velocity/velocity.jar
COPY entrypoint.sh /opt/velocity/entrypoint.sh
COPY plugins/ /opt/velocity/plugins/

RUN chmod +x /opt/velocity/entrypoint.sh

EXPOSE 25565

ENTRYPOINT ["/opt/velocity/entrypoint.sh"]
