# Optimized multi-stage Dockerfile for Spring Boot REACTIVE applications (WebFlux/Gateway)
# Use this for: Spring Cloud Gateway, WebFlux-based services
# For MVC/Servlet apps, use JDK.alpine.dockerfile instead

# Stage 1: Extract JAR layers
ARG BASE_IMAGE='cicdtools/jre-runner-alpine'

FROM ${BASE_IMAGE} AS extractor

WORKDIR /opt/app

# Copy JAR file
COPY ./target/*.jar app.jar

# Extract JAR layers for optimal Docker layer caching
# Using new Spring Boot 4.2+ syntax
# Note: Reactive apps may have different layer structure
RUN java -Djarmode=tools -jar app.jar extract --layers --destination extracted || \
    (echo "Layer extraction failed, falling back to list-layers" && \
     java -Djarmode=tools -jar app.jar list-layers && \
     java -Djarmode=tools -jar app.jar extract --layers --destination extracted)

# Stage 2: Runtime image with extracted layers
FROM ${BASE_IMAGE}

LABEL maintainer="maintainer@knowhowto.dev"
ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

# JVM optimization for reactive/netty workloads
ENV JAVA_OPTS="-XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:+UseG1GC \
    -XX:+UseStringDeduplication \
    -XX:+UseCompressedOops \
    -XX:+UseCompressedClassPointers \
    -XX:MaxMetaspaceSize=256m \
    -Dreactor.netty.ioWorkerCount=4 \
    -Dreactor.netty.pool.maxConnections=500 \
    -Djava.security.egd=file:/dev/./urandom \
    -Duser.timezone=UTC"

WORKDIR /opt/app

# Copy extracted layers in order of change frequency (least to most)
# This maximizes Docker layer caching
COPY --from=extractor /opt/app/extracted/dependencies/ ./
COPY --from=extractor /opt/app/extracted/spring-boot-loader/ ./
COPY --from=extractor /opt/app/extracted/snapshot-dependencies/ ./
COPY --from=extractor /opt/app/extracted/application/ ./

# Use Spring Boot's JarLauncher for layered execution
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
EXPOSE 8080
