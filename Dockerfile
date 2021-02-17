FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu18.04

ENV OPEN3DVER=v0.12.0

# Install dependencies (1)
RUN apt-get update && apt-get install -y \
        automake autoconf libpng-dev nano wget npm \
        curl zip unzip libtool swig zlib1g-dev pkg-config \
        git wget xz-utils python3-mock libpython3-dev \
        libpython3-all-dev python3-pip g++ gcc make \
        pciutils cpio gosu git liblapack-dev liblapacke-dev

# Install dependencies (2)
#   Install TensorFlow v2.4.1 for CUDA11.0+cuDNN8.0, built from source code.
#   Because GLIBCXX_USE_CXX11_ABI needs to be turned on.
RUN pip3 install --upgrade pip \
    && pip3 install --upgrade onnx \
    && pip3 install --upgrade onnxruntime \
    && pip3 install --upgrade gdown \
    && pip3 install cmake==3.18.4 \
    && gdown --id 17GulM-XoRPJDEoU0CiM6zFcIMSPcXsOU \
    && pip3 install --force-reinstall tensorflow-2.4.1-cp36-cp36m-linux_x86_64.whl \
    && rm tensorflow-2.4.1-cp36-cp36m-linux_x86_64.whl \
    && find / -name "libtensorflow_framework*" \
    && pip3 install --upgrade pyyaml \
    && pip3 install --upgrade ninja \
    && pip3 install --upgrade yapf \
    && pip3 install --upgrade six \
    && pip3 install --upgrade wheel \
    && pip3 install --upgrade moc \
    # && pip3 install torch==1.7.1+cu110 \
    #                 torchvision==0.8.2+cu110 \
    #                 torchaudio===0.7.2 \
    #                 -f https://download.pytorch.org/whl/torch_stable.html \
    && ldconfig

# Build
#   Bypass CUDA and CUB version checks.
RUN git clone -b ${OPEN3DVER} --recursive https://github.com/intel-isl/Open3D \
    && cd Open3D \
    && git submodule update --init --recursive \
    && git clone -b master https://github.com/intel-isl/Open3D-ML \
    && chmod +x util/install_deps_ubuntu.sh \
    && sed -i 's/SUDO=${SUDO:=sudo}/SUDO=${SUDO:=}/g' \
              util/install_deps_ubuntu.sh \
    && util/install_deps_ubuntu.sh assume-yes \
    && sed -i -e "/^#ifndef THRUST_IGNORE_CUB_VERSION_CHECK$/i #define THRUST_IGNORE_CUB_VERSION_CHECK" \
                 /usr/local/cuda/targets/x86_64-linux/include/thrust/system/cuda/config.h \
    && cat /usr/local/cuda/targets/x86_64-linux/include/thrust/system/cuda/config.h \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=${HOME}/open3d \
             -DPYTHON_EXECUTABLE=$(which python3) \
             -DBUILD_PYTHON_MODULE=ON \
             -DBUILD_SHARED_LIBS=ON \
             -DBUILD_EXAMPLES=OFF \
             -DBUILD_UNIT_TESTS=OFF \
             -DBUILD_BENCHMARKS=ON \
             -DBUILD_CUDA_MODULE=ON \
             -DBUILD_CACHED_CUDA_MANAGER=ON \
             -DBUILD_GUI=ON \
             -DBUILD_JUPYTER_EXTENSION=ON \
             -DWITH_OPENMP=ON \
             -DWITH_IPPICV=ON \
             -DENABLE_HEADLESS_RENDERING=OFF \
             -DSTATIC_WINDOWS_RUNTIME=ON \
             -DGLIBCXX_USE_CXX11_ABI=ON \
             -DBUILD_RPC_INTERFACE=ON \
             -DUSE_BLAS=ON \
             -DBUILD_FILAMENT_FROM_SOURCE=OFF \
             -DWITH_FAISS=OFF \
             -DBUILD_LIBREALSENSE=ON \
             -DUSE_SYSTEM_LIBREALSENSE=OFF \
             -DBUILD_AZURE_KINECT=ON \
             -DBUILD_TENSORFLOW_OPS=ON \
             -DBUILD_PYTORCH_OPS=OFF \
             -DBUNDLE_OPEN3D_ML=ON \
             -DOPEN3D_ML_ROOT=../Open3D-ML \
            #  -DCMAKE_FIND_DEBUG_MODE=ON \
             ..

RUN cd /Open3D/build \
    && make -j$(nproc)

RUN cd /Open3D/build \
    # Only one of each of the following lines can be selected.
    #   (1) install -> Build and install the C++ shared library
    #   (2) install-pip-package -> Install pip-package
    #   (3) python-package -> Build the Python package
    #   (4) conda-package -> Building the conda package
    #   (5) pip-package -> Build the pip wheel file
    && make install && ldconfig \
    # && make -j$(nproc) install-pip-package
    # && make -j$(nproc) python-package
    # && make -j$(nproc) conda-package
    && make -j$(nproc) pip-package

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

WORKDIR /workspace
