# ---------------------------------------------------------------------------
# Generic Node.js application image
# All values are parametrizable via build args.
# For framework-specific variants see:
#   Node.react.dockerfile  – React / Vite SPA
#   Node.astro.dockerfile  – Astro (static or SSR)
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Build args – override any of these from the pipeline
# ---------------------------------------------------------------------------
ARG BASE_IMAGE='cicdtools/nodejs-runner'

# Package manager command used to install dependencies
ARG PKG_MANAGER='pnpm'

# Script name passed to the package manager for the build step
ARG BUILD_SCRIPT='build'

# Script name passed to the package manager to start the app at runtime
ARG START_SCRIPT='start'

# Working directory inside the container
ARG WORKDIR='/opt/app'

# Port the application listens on
ARG APP_PORT='3000'

# ---------------------------------------------------------------------------
# Stage 1: build
# ---------------------------------------------------------------------------
FROM $BASE_IMAGE AS builder

ARG PKG_MANAGER
ARG BUILD_SCRIPT
ARG WORKDIR

ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

WORKDIR ${WORKDIR}

COPY ./ ${WORKDIR}

RUN ${PKG_MANAGER} install --frozen-lockfile

RUN ${PKG_MANAGER} run ${BUILD_SCRIPT}

# ---------------------------------------------------------------------------
# Stage 2: runtime
# ---------------------------------------------------------------------------
FROM $BASE_IMAGE AS runtime

LABEL maintainer="maintainer@knowhowto.dev"

ARG PKG_MANAGER
ARG START_SCRIPT
ARG WORKDIR
ARG APP_PORT

ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

WORKDIR ${WORKDIR}

COPY --from=builder ${WORKDIR} ${WORKDIR}

EXPOSE ${APP_PORT}

CMD ${PKG_MANAGER} run ${START_SCRIPT}
