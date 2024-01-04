ARG BASE_IMAGE

FROM $BASE_IMAGE

LABEL maintainer="maintainer@knowhowto.dev"
ARG VCS_REFERENCE
ENV APPLICATION_VCS_REFERENCE ${VCS_REFERENCE}

WORKDIR /opt/app

COPY ./ /opt/app

EXPOSE 3000

CMD [ "pnpm", "start" ]
