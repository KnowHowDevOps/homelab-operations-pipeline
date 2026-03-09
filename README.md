# 🚁 Drone CI Pipeline Repository

This repository contains a collection of Drone CI YAML pipelines designed to work with the [DroneExternalConfig](https://github.com/0x1a8510f2/DroneExternalConfig) plugin functionality.

## 📁 Project Structure

The repository is organized into different directories containing pipeline configurations:

### 🏗️ Pipeline Collections

- **`IQKV/`** - Contains sample and quickstart pipelines for various Java Spring Boot applications:
  - Sample applications (WebMVC, Reactive, Vaadin Chat, etc.)
  - Quickstart templates (JPA JWT, AMQP, Kafka, REST APIs)
- **`dimdnk/`** - Contains standardized pipeline templates for:
  - Spring Boot components (HTTP, Security, Kafka, Cache, etc.)
  - Project layout templates (Maven, UI projects, documentation)
  - Development tooling (Checkstyle configuration)

## 🎯 Features

- **Modular Pipeline Design** - Reusable pipeline components for different project types
- **Spring Boot Focus** - Specialized pipelines for Spring Boot applications
- **Multiple Deployment Scenarios** - Support for various deployment patterns
- **Standardized Templates** - Consistent project structure and CI/CD practices

## 🚀 Usage

These pipelines are designed to be used with the DroneExternalConfig plugin, which allows referencing external pipeline configurations from this repository.

### Pipeline Categories

1. **Quickstart Pipelines** - Ready-to-use templates for common application types
2. **Sample Pipelines** - Example configurations for specific use cases
3. **Component Pipelines** - Modular pipeline parts for custom compositions
4. **Layout Pipelines** - Project structure and tooling setup

## 🛠️ Development

This repository uses modern development tools and practices:

- **Node.js** (≥22.15.0) for development tooling
- **Prettier** for code formatting
- **Stylelint** for CSS/SCSS linting
- **Husky** for Git hooks
- **Commitizen** for conventional commits
- **Semantic Release** for automated versioning

### Available Scripts

```bash
# Format code
pnpm formatter:write

# Check formatting
pnpm formatter:check

# Run linting
pnpm lint

# Create release
pnpm release
```
