# Simple non-layered Dockerfile for Spring Boot applications
# Use this for services where layer extraction fails
# Simpler and more reliable, but less optimal caching

ARG BASE_IMAGE='cicdtools/jre-runner-alpine'

FROM ${BASE_IMAGE}

LABEL maintainer="maintainer@knowhowto.dev"
ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

# JVM optimization for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:+UseG1GC \
    -XX:+UseStringDeduplication \
    -XX:+UseCompressedOops \
    -XX:+UseCompressedClassPointers \
    -XX:MaxMetaspaceSize=256m \
    -Djava.security.egd=file:/dev/./urandom \
    -Duser.timezone=UTC"

WORKDIR /opt/app

# Copy JAR file directly - no layer extraction
COPY ./target/*.jar app.jar

# Simple entrypoint - just run the JAR
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
EXPOSE 8080
