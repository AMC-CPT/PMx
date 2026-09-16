# NONMEM 7.6 on Ubuntu 22.04 with gfortran and OpenMPI. 15장의 Dockerfile.
# 이 파일을 NONMEM 배포본 폴더(nm760CD/)에 두고 그 폴더에서 docker build 한다.
# 라이선스 파일은 이미지에 넣지 않는다. 실행 때 -v 로 붙인다.

FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran gcc g++ make unzip \
    libopenmpi-dev openmpi-bin \
    && rm -rf /var/lib/apt/lists/*

COPY . /tmp/nm760CD
RUN chmod +x /tmp/nm760CD/SETUP76 /tmp/nm760CD/install_Linux* && \
    find /tmp/nm760CD/util -type f -exec chmod +x {} +

# 설치. 대화형 질문에 줄 답을 인자로 전부 준다.
RUN cd /tmp/nm760CD && \
    bash SETUP76 /tmp/nm760CD /opt/nm760 gfortran y /usr/bin/ar same rec q \
         unzip nonmem76e.zip nonmem76r.zip

RUN set -e && \
    # 진짜 mpi.mod 로 바꾼다 (NONMEM 의 것은 껍데기다)
    MPI_MOD=$(find /usr/lib -name 'mpi.mod' -path '*/gfortran*' | head -1) && \
    if [ -n "$MPI_MOD" ]; then cp "$MPI_MOD" /opt/nm760/resource/mpi.mod; fi && \
    # 그 mpi.mod 로 병렬 인터페이스를 다시 컴파일한다
    cd /opt/nm760/mpi/mpi_ling && \
    mpif90 -c -fno-range-check -I../../resource -J../../resource PNM_MPI.f90 && \
    # 32비트 라이브러리를 지우고 빈 stub 을 둔다. 링크는 mpif90 이 한다
    rm -f libmpich.a libfmpich2g.a && \
    ar rcs libmpich.a

RUN printf 'mpibinpath=/usr/bin\nmpilibpath=/opt/nm760/mpi/mpi_ling\nmpilibname=\n' \
    > /opt/nm760/nmloc

RUN cp /tmp/nm760CD/mpilinux8.pnm /opt/nm760/run/ && \
    cp /tmp/nm760CD/mpilinux_onecomputer.pnm /opt/nm760/run/ 2>/dev/null || true

RUN rm -rf /opt/nm760/*.zip /opt/nm760/SETUP* /opt/nm760/install_* \
           /opt/nm760/nonmem.lic \
           /opt/nm760/guides /opt/nm760/help /opt/nm760/html \
           /opt/nm760/examples /opt/nm760/runfiles /opt/nm760/source \
           /opt/nm760/run/*.EXE /opt/nm760/run/*win*.pnm && \
    find /opt/nm760 -name '*.bat' -delete

FROM ubuntu:22.04
LABEL description="NONMEM 7.6.0 with gfortran and OpenMPI on Ubuntu 22.04"
ENV DEBIAN_FRONTEND=noninteractive

# nmfe76 이 실행 때 컴파일·링크하므로 gfortran 과 MPI 개발 파일이 필요하다
RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran gcc libopenmpi-dev openmpi-bin \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/nm760 /opt/nm760

ENV PATH="/opt/nm760/run:/opt/nm760/util:${PATH}" \
    OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

WORKDIR /data
CMD ["/bin/bash"]
