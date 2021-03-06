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
ARG GMMLIB_VERSION=21.2.1
ARG IGC_VERSION=1.0.8744
ARG NEO_VERSION=21.41.21220
ARG LEVEL_ZERO_VERSION=1.2.21220

# Install dependencies:
# mesa-va-drivers: needed for AMD VAAPI. Mesa >= 20.1 is required for HEVC transcoding.
# curl: healthcheck
RUN apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y ca-certificates gnupg wget apt-transport-https curl \
 && wget -nv -O - https://repo.jellyfin.org/jellyfin_team.gpg.key | apt-key add - \
 && echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/$( awk -F'=' '/^ID=/{ print $NF }' /etc/os-release ) $( awk -F'=' '/^VERSION_CODENAME=/{ print $NF }' /etc/os-release ) main" | tee /etc/apt/sources.list.d/jellyfin.list \
#  https://dgpu-docs.intel.com/installation-guides/ubuntu/ubuntu-focal.html
 && curl -s https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - \
 && echo 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' > /etc/apt/sources.list.d/intel-graphics.list \
 && apt-get update \
 && apt-get install --no-install-recommends --no-install-suggests -y \
   openssl \
   locales \
# Intel VAAPI Tone mapping dependencies:
# Prefer NEO to Beignet since the latter one doesn't support Comet Lake or newer for now.
# Do not use the intel-opencl-icd package from repo since they will not build with RELEASE_WITH_REGKEYS enabled.
 && apt autoremove intel-* -y \
#  && mkdir intel-compute-runtime \
#  && cd intel-compute-runtime \
#  && wget -nv https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-gmmlib_${GMMLIB_VERSION}_amd64.deb \
#  && wget -nv https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC_VERSION}/intel-igc-core_${IGC_VERSION}_amd64.deb \
#  && wget -nv https://github.com/intel/intel-graphics-compiler/releases/download/igc-${IGC_VERSION}/intel-igc-opencl_${IGC_VERSION}_amd64.deb \
#  && wget -nv https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-opencl_${NEO_VERSION}_amd64.deb \
#  && wget -nv https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-ocloc_${NEO_VERSION}_amd64.deb \
#  && wget -nv https://github.com/intel/compute-runtime/releases/download/${NEO_VERSION}/intel-level-zero-gpu_${LEVEL_ZERO_VERSION}_amd64.deb \
#  && dpkg -i *.deb \
#  && cd .. \
#  && rm -rf intel-compute-runtime \
 && apt install -y intel-opencl-icd intel-level-zero-gpu level-zero intel-media-va-driver-non-free libmfx1 vainfo \
 && apt install -y fontconfig fonts-noto-cjk-extra \
 && apt-get remove gnupg wget apt-transport-https -y \
 && apt-get clean autoclean -y \
 && apt-get autoremove -y \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* \
 && mkdir -p /cache /config /media \
 && chmod 777 /cache /config /media \
 && sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen && fc-cache -vf && fc-list && \
 rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
