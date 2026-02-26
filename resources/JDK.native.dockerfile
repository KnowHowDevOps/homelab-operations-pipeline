# GraalVM Native Image Dockerfile - smallest runtime footprint
# Compiles Spring Boot to native binary for fastest startup and lowest memory

# Stage 1: Build native image
FROM ghcr.io/graalvm/native-image-community:21-muslib AS builder

WORKDIR /build

# Install Maven
RUN microdnf install -y wget tar gzip && \
    wget https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && \
    tar xzf apache-maven-3.9.6-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.6/bin/mvn /usr/local/bin/mvn && \
    rm apache-maven-3.9.6-bin.tar.gz

# Copy source
COPY pom.xml ./
COPY src ./src

# Build native image (this takes time but produces smallest runtime)
RUN mvn -Pnative native:compile -DskipTests

# Stage 2: Minimal runtime (Alpine or scratch)
FROM alpine:3.19

RUN apk add --no-cache libstdc++ && \
    addgroup -g 1001 -S appuser && \
    adduser -u 1001 -S appuser -G appuser

WORKDIR /app

# Copy only the native binary (no JVM needed!)
COPY --from=builder --chown=appuser:appuser /build/target/*-exec /app/application

USER appuser

EXPOSE 8080

# Direct binary execution - no JVM overhead
ENTRYPOINT ["/app/application"]
