#!/bin/bash
# usage: source alias-storm.sh

# compilation parameters

# multi-core compilation
export COMPILE_JOBS=4
# single-core compilation:
# export COMPILE_JOBS=1

# environment variables

export SYNTHESIS=`pwd`
export PREREQUISITES=$SYNTHESIS/prerequisites
export SYNTHESIS_ENV=$SYNTHESIS/env

export STORM_BLD=$SYNTHESIS/storm/build
export STORM_BLD_DEBUG=$SYNTHESIS/storm/build_debug

export STORMPY_BLD=$SYNTHESIS/stormpy/build

# environment aliases

alias enva='source $SYNTHESIS_ENV/bin/activate'
alias envd='deactivate'


### prerequisites ##############################################################

storm-dependencies() {
    sudo apt update
    sudo apt -y install build-essential git automake cmake libboost-all-dev libcln-dev libgmp-dev libginac-dev libglpk-dev libhwloc-dev libz3-dev libxerces-c-dev libeigen3-dev
    sudo apt -y install texlive-latex-extra
    sudo apt -y install maven uuid-dev python3-dev libffi-dev libssl-dev python3-pip python3-venv
    # sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
}

prerequisites-download() {
    mkdir -p $PREREQUISITES
    cd $PREREQUISITES
    git clone --depth 1 --branch master14 https://github.com/ths-rwth/carl carl
    git clone --depth 1 https://github.com/moves-rwth/pycarl.git pycarl
    git clone --depth 1 --branch cvc5-1.0.0 https://github.com/cvc5/cvc5.git cvc5
    # TODO: use original SWITSS repo after merge request
    # git clone --depth 1 --branch paynt-integration https://github.com/JakubFrejlach/switss.git switss
    cd -
}

storm-download() {
    cd $SYNTHESIS
    git clone -b synthesis git@github.com:randriu/storm.git storm
    git clone -b synthesis git@github.com:randriu/stormpy.git stormpy
    cd -
}

python-environment() {
    python3 -m venv $SYNTHESIS_ENV
    enva
    pip3 install pytest pytest-runner pytest-cov numpy scipy pysmt z3-solver click
    pip3 install toml
    pip3 install Cython scikit-build
    envd
}

prerequisites-build-carl() {
    mkdir -p $PREREQUISITES/carl/build
    cd $PREREQUISITES/carl/build
    cmake -DUSE_CLN_NUMBERS=ON -DUSE_GINAC=ON -DTHREAD_SAFE=ON ..
    make lib_carl --jobs $COMPILE_JOBS
    #[TEST] make test
    cd -
}

prerequisites-build-pycarl() {
    cd $PREREQUISITES/pycarl
    enva
    python3 setup.py build_ext --jobs $COMPILE_JOBS develop
    #[TEST] python3 setup.py test
    envd
    cd -
}

prerequisites-build-cvc5() {
    cd $PREREQUISITES/cvc5
    enva
    ./configure.sh --prefix="." --auto-download --python-bindings
    cd build
    make --jobs $COMPILE_JOBS
    make install
    envd
    cd -
}

prerequisites-build-switss() {
    # configuration
    cd $PREREQUISITES/switss
    enva
    pip3 install -r requirements.txt
    python3 setup.py install
    envd
    cd -
}

### storm and stormpy ##########################################################

storm-config() {
    mkdir -p $STORM_BLD
    cd $STORM_BLD
    cmake ..
    cd -
}

storm-config-debug() {
    mkdir -p $STORM_BLD_DEBUG
    cd $STORM_BLD_DEBUG
    cmake .. -DSTORM_DEVELOPER=ON -DSTORM_USE_LTO=OFF
    cd -
}

storm-build() {
    cd $STORM_BLD
    make storm-main storm-synthesis --jobs $COMPILE_JOBS
    # make check --jobs $COMPILE_JOBS
    cd -
}

storm-build-debug() {
    cd $STORM_BLD_DEBUG
    make storm-main storm-synthesis --jobs $COMPILE_JOBS
    cd -
}

stormpy-build() {
    cd $SYNTHESIS/stormpy
    enva
    python3 setup.py build_ext --storm-dir $STORM_BLD --jobs $COMPILE_JOBS develop
    # python3 setup.py test
    envd
    cd -
}

stormpy-build-debug() {
    cd $SYNTHESIS/stormpy
    enva
    python3 setup.py build_ext --storm-dir $STORM_BLD_DEBUG --jobs $COMPILE_JOBS develop
    # python3 setup.py test
    envd
    cd -
}

# paynt-install() {
#     cd $SYNTHESIS/paynt
#     enva
#     python3 setup.py install
#     # python3 setup.py test
#     envd
#     cd -
# }

synthesis-install() {
    
    # install dependencies
    storm-dependencies
    # download prerequisites
    prerequisites-download
    # download synthesis versions of storm & stormpy
    storm-download
    # setup python environment
    python-environment
    
    # build prerequisites
    prerequisites-build-carl
    prerequisites-build-pycarl
    prerequisites-build-cvc5
    # prerequisites-build-switss

    # build storm & stormpy
    storm-config
    storm-build
    stormpy-build

    # check
    # TODO
}

