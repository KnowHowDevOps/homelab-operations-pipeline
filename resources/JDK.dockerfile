ARG BASE_IMAGE

FROM $BASE_IMAGE

LABEL maintainer="maintainer@knowhowto.dev"
ARG VCS_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
# JVM optimization for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -XX:+UseStringDeduplication"

WORKDIR /opt/app

COPY ./target/*.jar /opt/app/app.jar

ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -Duser.timezone=UTC -jar /opt/app/app.jar"]
EXPOSE 8080
