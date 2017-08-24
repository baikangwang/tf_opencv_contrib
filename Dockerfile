
FROM ubuntu:16.04
MAINTAINER Baker Wang <baikangwang@hotmail.com>

#usage: docker run -it -v notebooks:/notebooks -p 8888:8888 -p 6006:6006 kevin8093/test_tf 

# Supress warnings about missing front-end. As recommended at:
# http://stackoverflow.com/questions/22466255/is-it-possibe-to-answer-dialog-questions-when-installing-under-docker
ARG DEBIAN_FRONTEND=noninteractive

# using China mirror for ubuntu
RUN sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//http:\/\/mirrors\.163\.com\/ubuntu\//g' /etc/apt/sources.list && \
    apt update && \
    apt install -y --no-install-recommends apt-utils \
    # Developer Essentials
    git curl vim unzip openssh-client wget \
    # Build tools
    build-essential cmake \
    # OpenBLAS
    libopenblas-dev \
    #
    # Python 3.5
    #
    # For convenience, alisas (but don't sym-link) python & pip to python3 & pip3 as recommended in:
    # http://askubuntu.com/questions/351318/changing-symlink-python-to-python3-causes-problems
    python3.5 python3.5-dev python3-pip && \
    pip3 install --no-cache-dir --upgrade pip setuptools -i http://pypi.douban.com/simple --trusted-host pypi.douban.com && \
    echo "alias python='python3'" >> /root/.bash_aliases && \
    echo "alias pip='pip3'" >> /root/.bash_aliases && \
    # Pillow and it's dependencies
    apt install -y --no-install-recommends libjpeg-dev zlib1g-dev && \
    pip3 --no-cache-dir install Pillow -i http://pypi.douban.com/simple --trusted-host pypi.douban.com && \
    # Common libraries
    pip3 --no-cache-dir install -i http://pypi.douban.com/simple --trusted-host pypi.douban.com \
    numpy scipy sklearn scikit-image pandas matplotlib && \
    #
    # Jupyter Notebook
    #
    pip3 --no-cache-dir install jupyter -i http://pypi.douban.com/simple --trusted-host pypi.douban.com && \
    # Allow access from outside the container, and skip trying to open a browser.
    # NOTE: disable authentication token for convenience. DON'T DO THIS ON A PUBLIC SERVER.
    mkdir /root/.jupyter && \
    echo "c.NotebookApp.ip = '*'" \
         "\nc.NotebookApp.open_browser = False" \
         "\nc.NotebookApp.token = ''" \
         > /root/.jupyter/jupyter_notebook_config.py && \
    #
    # Tensorflow 1.0.1 - CPU
    #
    pip3 install --no-cache-dir --upgrade tensorflow -i http://pypi.douban.com/simple --trusted-host pypi.douban.com && \
    #
    # OpenCV 3.2
    #
    # Dependencies
    apt-get install -y --no-install-recommends \
    libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libgtk2.0-dev \
    liblapacke-dev checkinstall && \
    # Get source from github
    #git clone https://github.com/opencv/opencv.git /usr/local/src/opencv && \
    #git clone https://github.com/opencv/opencv_contrib.git /usr/local/src/opencv_contrib && \
    wget https://github.com/opencv/opencv/archive/3.3.0.tar.gz -O opencv-3.3.0.tar.gz && \
    tar -xvf opencv-3.3.0.tar.gz && \
    mv opencv-3.3.0 /usr/local/src/opencv && \
    wget https://github.com/opencv/opencv_contrib/archive/3.3.0.tar.gz -O opencv_contrib-3.3.0.tar.gz && \
    tar -xvf opencv_contrib-3.3.0.tar.gz && \
    mv opencv_contrib-3.3.0 /usr/local/src/opencv_contrib && \
    # Compile
    cd /usr/local/src/opencv && mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D BUILD_TESTS=OFF \
          -D BUILD_opencv_gpu=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D WITH_IPP=OFF \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules -D BUILD_opencv_xfeatures2d=OFF /usr/local/src/opencv \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules -D BUILD_opencv_dnn_modern=OFF /usr/local/src/opencv \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules -D BUILD_opencv_dnns_easily_fooled=OFF /usr/local/src/opencv \
          -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
          .. && \
    make -j"$(nproc)" && \
    make install && \
    #
    # Cleanup
    #
    cd && rm opencv-3.3.0.tar.gz && rm opencv_contrib-3.3.0.tar.gz && \
    cd /usr/local/src/opencv && rm -r build && \
    apt clean && \
    apt autoremove 
#
# Jupyter Notebook : 8888
# Tensorboard : 6006
#
EXPOSE 8888 6006

COPY run_jupyter.sh /
COPY notebooks /notebooks

WORKDIR "/notebooks"
CMD ["/run_jupyter.sh", "--allow-root"]