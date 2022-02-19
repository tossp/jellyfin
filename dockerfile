FROM jellyfin/jellyfin:unstable

LABEL maintainer="TossPig <docker@TossP.com>" \
      version="0.0.1" \
      description="jellyfin 服务"
ENV TIMEZONE Asia/Shanghai

# https://repo.jellyfin.org/releases/server/debian/unstable/
# docker run --rm -it --device /dev/dri/renderD128:/dev/dri/renderD128  --entrypoint /bin/bash 
# docker run --rm -it --device /dev/dri/renderD128:/dev/dri/renderD128 tossp/jellyfin

# set Intel iHD driver versions
# https://dgpu-docs.intel.com/releases/index.html
ARG INTEL_LIBVA_VER="2.13.0+i643~u20.04"
ARG INTEL_GMM_VER="21.3.3+i643~u20.04"
ARG INTEL_iHD_VER="21.4.1+i643~u20.04"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y gnupg2 gnupg gnupg1  && \
    curl -s https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - && \
    echo 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' > /etc/apt/sources.list.d/intel-graphics.list && \
    apt update && \
    apt install -y intel-media-va-driver-non-free && \
    apt install -y vainfo && \
    apt install -y fontconfig fonts-noto-cjk-extra && \
    sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen && fc-cache -vf && fc-list && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
