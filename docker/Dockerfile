# NONMEM 7.6 on Ubuntu 22.04 with gfortran and OpenMPI. The Dockerfile of Ch 15.
# Put this file in the NONMEM distribution folder (nm760CD/) and build from there.
# The licence file does not go into the image. Attach it with -v at run time.

FROM ubuntu:22.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran gcc g++ make unzip \
    libopenmpi-dev openmpi-bin \
    && rm -rf /var/lib/apt/lists/*

COPY . /tmp/nm760CD
RUN chmod +x /tmp/nm760CD/SETUP76 /tmp/nm760CD/install_Linux* && \
    find /tmp/nm760CD/util -type f -exec chmod +x {} +

# Install. Every answer to the interactive questions is supplied as an argument.
RUN cd /tmp/nm760CD && \
    bash SETUP76 /tmp/nm760CD /opt/nm760 gfortran y /usr/bin/ar same rec q \
         unzip nonmem76e.zip nonmem76r.zip

RUN set -e && \
    # swap in the real mpi.mod (NONMEM's is a shell)
    MPI_MOD=$(find /usr/lib -name 'mpi.mod' -path '*/gfortran*' | head -1) && \
    if [ -n "$MPI_MOD" ]; then cp "$MPI_MOD" /opt/nm760/resource/mpi.mod; fi && \
    # recompile the parallel interface against that mpi.mod
    cd /opt/nm760/mpi/mpi_ling && \
    mpif90 -c -fno-range-check -I../../resource -J../../resource PNM_MPI.f90 && \
    # delete the 32-bit libraries and leave an empty stub. mpif90 does the linking
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

# nmfe76 compiles and links at run time, so gfortran and the MPI dev files are needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran gcc libopenmpi-dev openmpi-bin \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/nm760 /opt/nm760

ENV PATH="/opt/nm760/run:/opt/nm760/util:${PATH}" \
    OMPI_ALLOW_RUN_AS_ROOT=1 \
    OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

WORKDIR /data
CMD ["/bin/bash"]
