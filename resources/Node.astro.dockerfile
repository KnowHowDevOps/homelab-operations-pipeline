# ---------------------------------------------------------------------------
# Astro application image
# Supports both Astro output modes:
#   static (default) – built to dist/, served by Nginx
#   server / hybrid  – SSR, served by Node.js
#
# Set ASTRO_OUTPUT=server (or hybrid) and the runtime stage switches
# automatically to Node.js instead of Nginx.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Build args – override any of these from the pipeline
# ---------------------------------------------------------------------------
ARG BASE_IMAGE='know-how.download/library/nodejs-runner'
ARG NGINX_IMAGE='know-how.download/library/nginx-runner'

# Package manager command used to install dependencies
ARG PKG_MANAGER='pnpm'

# Script name passed to the package manager for the build step
ARG BUILD_SCRIPT='build'

# Script name passed to the package manager to start the SSR server
ARG START_SCRIPT='start'

# Astro output mode: static | server | hybrid
# Must match the `output` value in astro.config.*
ARG ASTRO_OUTPUT='static'

# Static build output directory (used when ASTRO_OUTPUT=static)
ARG DIST_DIR='dist'

# Port the SSR server listens on (used when ASTRO_OUTPUT=server|hybrid)
ARG APP_PORT='4321'

# Working directory inside the container
ARG WORKDIR='/opt/app'

# ---------------------------------------------------------------------------
# Stage 1: build
# ---------------------------------------------------------------------------
FROM $BASE_IMAGE AS builder

ARG PKG_MANAGER
ARG BUILD_SCRIPT
ARG WORKDIR
ARG ASTRO_OUTPUT

ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

# Expose the output mode to the Astro build if needed by astro.config
ENV ASTRO_OUTPUT=${ASTRO_OUTPUT}

WORKDIR ${WORKDIR}

COPY ./ ${WORKDIR}

RUN ${PKG_MANAGER} install --frozen-lockfile

RUN ${PKG_MANAGER} run ${BUILD_SCRIPT}

# ---------------------------------------------------------------------------
# Stage 2a: Nginx static runtime  (ASTRO_OUTPUT=static)
# ---------------------------------------------------------------------------
FROM $NGINX_IMAGE AS runtime-static

LABEL maintainer="maintainer@knowhowto.dev"

ARG DIST_DIR
ARG WORKDIR

ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

COPY --from=builder ${WORKDIR}/${DIST_DIR} /usr/share/nginx/html

ENTRYPOINT ["nginx", "-g", "daemon off;"]

# ---------------------------------------------------------------------------
# Stage 2b: Node.js SSR runtime  (ASTRO_OUTPUT=server or hybrid)
# ---------------------------------------------------------------------------
FROM $BASE_IMAGE AS runtime-ssr

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
