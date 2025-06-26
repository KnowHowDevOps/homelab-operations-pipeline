ARG BASE_IMAGE

FROM $BASE_IMAGE

LABEL maintainer="maintainer@knowhowto.dev"
ARG VCS_REFERENCE
ENV APPLICATION_VCS_REFERENCE ${VCS_REFERENCE}

COPY ./dist /usr/share/nginx/html

ENTRYPOINT ["nginx", "-g", "daemon off;"]