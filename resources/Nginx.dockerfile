ARG BASE_IMAGE

FROM $BASE_IMAGE

LABEL maintainer="maintainer@knowhowto.dev"
ARG VCS_REFERENCE
ARG SOURCE_DIR
ENV APPLICATION_VCS_REFERENCE=${VCS_REFERENCE}

COPY ${SOURCE_DIR} /usr/share/nginx/html

ENTRYPOINT ["nginx", "-g", "daemon off;"]