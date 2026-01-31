# base_image_name is expected to be overridden
ARG BASE_IMAGE='know-how.download/library/nodejs-runner'

FROM $BASE_IMAGE

LABEL maintainer="maintainer@knowhowto.dev"
ARG VCS_REFERENCE
ARG BUILD_VERSION_REFERENCE
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}
ENV APPLICATION_BUILD_VERSION=${BUILD_VERSION_REFERENCE}

WORKDIR /opt/app

COPY ./ /opt/app

EXPOSE 3000

CMD [ "pnpm", "start" ]
