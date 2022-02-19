FROM jellyfin/jellyfin:unstable

LABEL maintainer="TossPig <docker@TossP.com>" \
      version="0.0.1" \
      description="jellyfin 服务"

ENV TIMEZONE Asia/Shanghai

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

# https://repo.jellyfin.org/releases/server/debian/unstable/
# docker run --rm -it --device /dev/dri/renderD128:/dev/dri/renderD128  --entrypoint /bin/bash 
# docker run --rm -it --device /dev/dri/renderD128:/dev/dri/renderD128 tossp/jellyfin

# https://github.com/intel/compute-runtime/releases
ARG GMMLIB_VERSION=22.0.2
ARG IGC_VERSION=1.0.10200
ARG NEO_VERSION=22.07.22465
ARG LEVEL_ZERO_VERSION=1.3.22465

# Install dependencies:
# mesa-va-drivers: needed for AMD VAAPI. Mesa >= 20.1 is required for HEVC transcoding.
# curl: healthcheck
RUN apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates gnupg wget apt-transport-https curl \
 && wget -O - https://repo.jellyfin.org/jellyfin_team.gpg.key | apt-key add - \
 && echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" | tee /etc/apt/sources.list.d/jellyfin.list \
 && apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y \
   mesa-va-drivers \
   jellyfin-ffmpeg \
   openssl \
   locales \
# Intel VAAPI Tone mapping dependencies:
# Prefer NEO to Beignet since the latter one doesn't support Comet Lake or newer for now.
# Do not use the intel-opencl-icd package from repo since they will not build with RELEASE_WITH_REGKEYS enabled.
    # curl -s https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - && \
    # echo 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' > /etc/apt/sources.list.d/intel-graphics.list && \
    # apt install -y intel-media-va-driver-non-free vainfo && \
 && mkdir intel-compute-runtime \
 && cd intel-compute-runtime \
 && wget https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-gmmlib_${GMMLIB_VERSION}_amd64.deb \
 && wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC_VERSION}/intel-igc-core_${IGC_VERSION}_amd64.deb \
 && wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC_VERSION}/intel-igc-opencl_${IGC_VERSION}_amd64.deb \
 && wget https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-opencl-icd_${NEO_VERSION}_amd64.deb \
 && wget https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-level-zero-gpu_${LEVEL_ZERO_VERSION}_amd64.deb \
 && apt autoremove intel-* && dpkg -i *.deb \
 && cd .. \
 && rm -rf intel-compute-runtime \
 && apt install -y fontconfig fonts-noto-cjk-extra \
 && apt-get remove gnupg wget apt-transport-https -y \
 && apt-get clean autoclean -y \
 && apt-get autoremove -y \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* \
 && mkdir -p /cache /config /media \
 && chmod 777 /cache /config /media \
 && sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen && fc-cache -vf && fc-list && \
 rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
 
