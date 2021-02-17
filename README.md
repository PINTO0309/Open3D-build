# Open3D-build
Provide Docker build sequences of Open3D for various environments.  
**https://github.com/intel-isl/Open3D**

## 1. Docker Image Environment
- Ubuntu 18.04 x86_64
- CUDA 11.0
- cuDNN 8.0
- TensorFlow v2.4.1 (Build from source code. It will be downloaded automatically during docker build.)
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
--   Build PyTorch Ops ....................... OFF
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

## 5. Appendix
### 5-1. TensorFlow (CUDA enabled) build command
```bash
$ sudo bazel build \
    --config=cuda \
    --config=noaws \
    --config=nohdfs \
    --config=nonccl \
    --config=v2 \
    --define=tflite_pip_with_flex=true \
    --define=tflite_with_xnnpack=true \
    //tensorflow/tools/pip_package:build_pip_package
```