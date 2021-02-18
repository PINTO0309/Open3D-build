# Open3D-build
Provide Docker build sequences of Open3D for various environments.  
**https://github.com/intel-isl/Open3D**

## 1. Docker Image Environment
- Ubuntu 18.04 x86_64
- CUDA 11.0
- cuDNN 8.0
- TensorFlow v2.4.1 (Build from source code. It will be downloaded automatically during docker build.)
- PyTorch v1.7.1 (Build from source code. It will be downloaded automatically during docker build.)
- Open3D 0.12.0

## 2. Default build parameters
```
-- ========================================================================
-- Open3D 0.12.0 Configuration Summary
-- ========================================================================
-- Enabled Features:
--   OpenMP .................................. ON
--   Headless Rendering ...................... OFF
--   Azure Kinect Support .................... ON
--   Intel RealSense Support ................. ON
--   CUDA Support ............................ ON
--   Build GUI ............................... ON
--   Build Shared Library .................... ON
--   Build Unit Tests ........................ OFF
--   Build Examples .......................... 
--   Build Python Module ..................... ON
--   - with Jupyter Notebook Support ......... ON
--   Build TensorFlow Ops .................... ON
--   Build PyTorch Ops ....................... ON
--   Build Benchmarks ........................ ON
--   Bundle Open3D-ML ........................ ON
--   Build RPC interface ..................... ON
--   Force GLIBCXX_USE_CXX11_ABI= ............ 1
-- ========================================================================
-- Third-Party Dependencies:
--   EIGEN3 .................................. yes (build from source)
--   FAISS ................................... no
--   FILAMENT ................................ yes (build from source)
--   FLANN ................................... yes (build from source)
--   FMT ..................................... yes (build from source)
--   GLEW .................................... yes (build from source)
--   GLFW .................................... yes (build from source)
--   GOOGLETEST .............................. no
--   IMGUI ................................... yes (build from source)
--   JPEG .................................... yes (build from source)
--   JSONCPP ................................. yes (build from source)
--   LIBLZF .................................. yes (build from source)
--   OPENGL .................................. yes (build from source)
--   PNG ..................................... yes (build from source)
--   PYBIND11 ................................ yes (build from source)
--   QHULL ................................... yes (build from source)
--   LIBREALSENSE ............................ yes (build from source)
--   TINYFILEDIALOGS ......................... yes (build from source)
--   TINYGLTF ................................ yes (build from source)
--   TINYOBJLOADER ........................... yes (build from source)
-- ========================================================================
```

## 3. Usage - Docker Build
You can customize the Dockerfile to build and run your own container images on your own.
```bash
$ version=0.12.0
$ git clone -b ${version} https://github.com/PINTO0309/Open3D-build.git
$ cd Open3D-build
$ docker build -t pinto0309/open3d-build:latest .

$ docker run --gpus all -it --rm \
    -v `pwd`:/workspace \
    -e LOCAL_UID=$(id -u $USER) \
    -e LOCAL_GID=$(id -g $USER) \
    pinto0309/open3d-build:latest bash
```

## 4. Usage - Docker Pull / Run
You can download and run a pre-built container image from Docker Hub.
```bash
$ docker run --gpus all -it --rm \
    -v `pwd`:/workspace \
    -e LOCAL_UID=$(id -u $USER) \
    -e LOCAL_GID=$(id -g $USER) \
    pinto0309/open3d-build:latest bash
```
## 5. Usage - pip installer
You can download and install the released Wheel installer.
```bash
$ wget https://github.com/PINTO0309/Open3D-build/releases/download/v0.12.0/open3d-0.12.0+313315d9-cp36-cp36m-linux_x86_64.whl \
  && wget https://github.com/PINTO0309/Open3D-build/releases/download/v0.12.0/tensorflow-2.4.1-cp36-cp36m-linux_x86_64.whl \
  && wget https://github.com/PINTO0309/Open3D-build/releases/download/v0.12.0/torch-1.7.0a0-cp36-cp36m-linux_x86_64.whl \
  && wget https://github.com/PINTO0309/Open3D-build/releases/download/v0.12.0/torchaudio-0.7.0a0+a853dff-cp36-cp36m-linux_x86_64.whl \
  && wget https://github.com/PINTO0309/Open3D-build/releases/download/v0.12.0/torchvision-0.8.0a0+2f40a48-cp36-cp36m-linux_x86_64.whl \
  && sudo pip3 install --upgrade *.whl
```

## 6. Appendix
### 6-1. TensorFlow (CUDA enabled) build command
```bash
$ git clone -b v2.4.1 https://github.com/tensorflow/tensorflow.git
$ cd tensorflow
$ sudo ./configure
$ sudo bazel build \
    --config=cuda \
    --config=noaws \
    --config=nohdfs \
    --config=nonccl \
    --config=v2 \
    //tensorflow/tools/pip_package:build_pip_package
```
### 6-2. PyTorch (CUDA enabled) build command
**https://github.com/PINTO0309/PyTorch-build**
```bash
$ git clone -b v1.7.1 --recursive https://github.com/pytorch/pytorch
$ cd pytorch \
    && sed -i -e "/^#ifndef THRUST_IGNORE_CUB_VERSION_CHECK$/i #define THRUST_IGNORE_CUB_VERSION_CHECK" \
                 /usr/local/cuda/targets/x86_64-linux/include/thrust/system/cuda/config.h \
    && cat /usr/local/cuda/targets/x86_64-linux/include/thrust/system/cuda/config.h \
    && sed -i -e "/^if(DEFINED GLIBCXX_USE_CXX11_ABI)/i set(GLIBCXX_USE_CXX11_ABI 1)" \
                 CMakeLists.txt \
    && pip3 install -r requirements.txt \
    && python3 setup.py build \
    && python3 setup.py bdist_wheel \
    && cd ..

$ git clone -b v0.8.2 https://github.com/pytorch/vision.git
$ cd vision \
    && pip3 install /pytorch/dist/*.whl \
    && python3 setup.py build \
    && python3 setup.py bdist_wheel \
    && cd ..

$ git clone -b v0.7.2 https://github.com/pytorch/audio.git
$ cd audio \
    && apt-get install -y sox libsox-dev \
    && python3 setup.py build \
    && python3 setup.py bdist_wheel \
    && cd ..
```
