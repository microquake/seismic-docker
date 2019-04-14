from python:3.6 as builder 

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
 gfortran \
 swig \
 libatlas-dev liblapack-dev \
 libhdf5-dev libfftw3-dev \
 libxft-dev \
 libxml2-dev libxslt-dev zlib1g-dev \
 libpng-dev \
 libxext-dev build-essential

ENV CFLAGS "-I/usr/include/hdf5/serial"
RUN git clone git://github.com/microquake/nlloc.git
RUN cd nlloc && make

COPY pyproject* /
RUN pip install virtualenv
RUN virtualenv -p python3.6 ve
RUN /ve/pip install poetry
RUN /ve/poetry install


FROM python:3.6

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
 swig \
 libatlas liblapack \
 libhdf5 libfftw3 \
 libxft \
 libxml2 libxslt zlib1g \
 libpng \
 libxext

COPY --from=builder nlloc/fmm2grid nlloc/fpfit2hyp nlloc/Grid2GMT \
    nlloc/Grid2Time nlloc/GridCascadingDecimate nlloc/hypoe2hyp \
    nlloc/interface2fmm nlloc/Loc2ddct nlloc/LocSum nlloc/NLDiffLoc \
    nlloc/NLLoc nlloc/oct2grid nlloc/PhsAssoc nlloc/scat2latlon \
    nlloc/Time2Angles nlloc/Time2EQ nlloc/Vel2Grid nlloc/Vel2Grid3D /usr/bin

RUN pip install virtualenv
COPY --from=builder /ve /ve

RUN mkdir -p /app
WORKDIR /app
