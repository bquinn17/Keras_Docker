ARG cuda_version=10.1
ARG cudnn_version=7
FROM nvidia/cuda:${cuda_version}-cudnn${cudnn_version}-devel-ubuntu18.04

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      bzip2 \
      g++ \
      git \
      graphviz \
      libgl1-mesa-glx \
      libhdf5-dev \
      openmpi-bin \
      wget && \
    rm -rf /var/lib/apt/lists/*

# Install conda
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN wget --quiet --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh && \
    echo "c59b3dd3cad550ac7596e0d599b91e75d88826db132e4146030ef471bb434e9a *Miniconda3-4.2.12-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash /Miniconda3-4.2.12-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.2.12-Linux-x86_64.sh && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh

# Install Python packages and keras
ENV NB_USER keras
ENV NB_UID 1000

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chown $NB_USER $CONDA_DIR -R && \
    mkdir -p /src && \
    chown $NB_USER /src

# USER $NB_USER

ARG python_version=3.6.8

RUN conda install -y python=${python_version} && \
    pip install --upgrade pip && \
    pip install \
      sklearn_pandas \
      tensorflow-gpu \
      cntk-gpu \
      tldextract \
      seaborn \
      xgboost \
      imageio \
      --ignore-installed six

RUN conda install -y \
      bcolz \
      h5py \
      matplotlib \
      mkl \
      nose \
      notebook \
      Pillow \
      pandas \
      pydot \
      pygpu \
      pyyaml \
      scikit-learn \
      six \
      theano
    
WORKDIR /src

RUN git clone --branch 2.4.0 git://github.com/keras-team/keras.git /src && pip install -e '/src[tests]' && \
    pip install git+git://github.com/keras-team/keras.git && \
    conda clean -yt

# Add PyTorch
RUN conda install -y pytorch torchvision cudatoolkit=10.1 -c pytorch

# # Add ImageAI
# RUN conda install -y imageai -c powerai

ADD theanorc /home/keras/.theanorc

ENV PYTHONPATH=/src/:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/cuda-10.2/lib64:$LD_LIBRARY_PATH

WORKDIR /src

EXPOSE 8888

CMD jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root