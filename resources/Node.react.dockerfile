# ---------------------------------------------------------------------------
# React / Vite SPA image
# Builds the app with Node.js, serves the static output via Nginx.
# Defaults are tuned for Vite (output: dist/).
# Override DIST_DIR=build for Create React App projects.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Build args – override any of these from the pipeline
# ---------------------------------------------------------------------------
ARG BASE_IMAGE='cicdtools/nodejs-runner'
ARG NGINX_IMAGE='cicdtools/nginx-runner'

# Package manager command used to install dependencies
ARG PKG_MANAGER='pnpm'

# Script name passed to the package manager for the build step
ARG BUILD_SCRIPT='build'

# Vite outputs to dist/ by default; CRA uses build/
ARG DIST_DIR='dist'

# Working directory inside the build container
ARG WORKDIR='/opt/app'

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
# Stage 2: Nginx static runtime
# ---------------------------------------------------------------------------
FROM $NGINX_IMAGE AS runtime

LABEL maintainer="maintainer@knowhowto.dev"

ARG DIST_DIR
ARG WORKDIR

ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

COPY --from=builder ${WORKDIR}/${DIST_DIR} /usr/share/nginx/html

ENTRYPOINT ["nginx", "-g", "daemon off;"]
