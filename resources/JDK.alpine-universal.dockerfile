# Universal multi-stage Dockerfile for ALL Spring Boot applications
# Works with both MVC (Servlet) and Reactive (WebFlux/Gateway) apps
# Automatically handles layer extraction failures gracefully

# Stage 1: Extract JAR layers with fallback
ARG BASE_IMAGE='cicdtools/jre-runner-alpine'

FROM ${BASE_IMAGE} AS extractor

WORKDIR /opt/app

# Copy JAR file
COPY ./target/*.jar app.jar

# Try to extract JAR layers, create marker file on success
# Using new Spring Boot 4.2+ syntax
RUN (java -Djarmode=tools -jar app.jar extract --layers --destination extracted && \
     touch extracted/.layered) || \
    (echo "WARN: Layer extraction not supported, using monolithic JAR" && \
     mkdir -p extracted && \
     cp app.jar extracted/app.jar && \
     touch extracted/.monolithic)

# Stage 2: Runtime image with conditional setup
FROM ${BASE_IMAGE}

LABEL maintainer="maintainer@knowhowto.dev"
ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

# JVM optimization for containers - works for both MVC and Reactive
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

# Copy everything from extractor
COPY --from=extractor /opt/app/extracted/ ./

# Set entrypoint based on which marker file exists
ENTRYPOINT ["sh", "-c", "if [ -f .layered ]; then java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher; else java $JAVA_OPTS -jar app.jar; fi"]
EXPOSE 8080
