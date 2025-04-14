FROM amazoncorretto:21-alpine

WORKDIR /opt/velocity

COPY server/ /opt/velocity

RUN chmod +x /opt/paper/palimpsest &&  \
    chmod +x /opt/paper/entrypoint.sh \

EXPOSE 25565

ENTRYPOINT ["/opt/velocity/entrypoint.sh"]
