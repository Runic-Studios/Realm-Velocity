FROM openjdk:17-jdk

WORKDIR /opt/velocity

COPY velocity.jar /opt/velocity/velocity.jar
COPY entrypoint.sh /opt/velocity/entrypoint.sh
RUN chmod +x /opt/velocity/entrypoint.sh

EXPOSE 25565

ENTRYPOINT ["/opt/velocity/entrypoint.sh"]
