# Ultra-slim distroless Dockerfile for Spring Boot applications
# Distroless images contain only the application and runtime dependencies
# No shell, package managers, or unnecessary tools = smaller attack surface

# Stage 1: Extract JAR layers
FROM eclipse-temurin:21-jre-alpine AS extractor

WORKDIR /opt/app
COPY ./target/*.jar app.jar

# Extract JAR layers for optimal Docker layer caching
# Using new Spring Boot 4.2+ syntax
RUN java -Djarmode=tools -jar app.jar extract --layers --destination extracted

# Stage 2: Distroless runtime (smallest possible image)
FROM gcr.io/distroless/java21-debian12:nonroot

LABEL maintainer="maintainer@knowhowto.dev"
ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

# JVM optimization for containers
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:+UseG1GC \
    -XX:+UseStringDeduplication \
    -XX:+UseCompressedOops \
    -XX:+UseCompressedClassPointers \
    -XX:MaxMetaspaceSize=256m \
    -Djava.security.egd=file:/dev/./urandom \
    -Duser.timezone=UTC"

WORKDIR /app

# Copy extracted layers in order of change frequency
COPY --from=extractor --chown=nonroot:nonroot /opt/app/extracted/dependencies/ ./
COPY --from=extractor --chown=nonroot:nonroot /opt/app/extracted/spring-boot-loader/ ./
COPY --from=extractor --chown=nonroot:nonroot /opt/app/extracted/snapshot-dependencies/ ./
COPY --from=extractor --chown=nonroot:nonroot /opt/app/extracted/application/ ./

# Distroless images run as non-root by default
USER nonroot

EXPOSE 8080

# Note: Distroless has no shell, so we use exec form
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
