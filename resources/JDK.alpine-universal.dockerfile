# Universal multi-stage Dockerfile for ALL Spring Boot applications
# Works with both MVC (Servlet) and Reactive (WebFlux/Gateway) apps
# Automatically handles layer extraction failures gracefully

# Stage 1: Extract JAR layers with fallback
ARG BASE_IMAGE='know-how.download/library/jre-runner-alpine'

FROM ${BASE_IMAGE} AS extractor

WORKDIR /opt/app

# Copy JAR file
COPY ./target/*.jar app.jar

# Extract JAR layers with fallback for apps that don't support layering
# Using new Spring Boot 3.2+ syntax
RUN java -Djarmode=tools -jar app.jar extract --layers --destination extracted 2>/dev/null || \
    (echo "WARN: Layer extraction not supported, using monolithic JAR" && \
     mkdir -p extracted/application && \
     cp app.jar extracted/application/)

# Stage 2: Runtime image with extracted layers
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

# Copy extracted layers if they exist
# Use wildcard to handle cases where layers don't exist
COPY --from=extractor /opt/app/extracted/ ./

# Determine if we have layered JAR or monolithic JAR and set entrypoint accordingly
# If dependencies/ exists, we have layers; otherwise, run the JAR directly
RUN if [ -d "dependencies" ]; then \
        echo "Layered JAR detected"; \
    else \
        echo "Monolithic JAR detected"; \
    fi

# Use Spring Boot's JarLauncher for layered execution, or java -jar for monolithic
ENTRYPOINT ["sh", "-c", "if [ -d dependencies ]; then java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher; else java $JAVA_OPTS -jar application/app.jar; fi"]
EXPOSE 8080
