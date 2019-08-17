# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "EvtGenBuilder"
version = v"0.1.0"

# Collection of sources required to build EvtGenBuilder
sources = [
    "http://lcgapp.cern.ch/project/simu/HepMC/download/HepMC-2.06.09.tar.gz" =>
    "c60724ca9740230825e06c0c36fb2ffe17ff1b1465e8656268a61dffe1611a08",

    "http://home.thep.lu.se/~torbjorn/pythia8/pythia8243.tgz" =>
    "f8ec27437d9c75302e192ab68929131a6fd642966fe66178dbe87da6da2b1c79",

    "https://phab.hepforge.org/source/evtgen.git" =>
    "c68aa6bda7c8ce69e9918bd73a81e02aef8af600",

    "http://photospp.web.cern.ch/photospp/resources/PHOTOS.3.61/PHOTOS.3.61.tar.gz" =>
    "8f9ae59d40e6ec077f5de69b21324745ff3a73e71f3ea22a539782029e0445f4",

    "http://tauolapp.web.cern.ch/tauolapp/resources/TAUOLA.1.1.6c/TAUOLA.1.1.6c-LHC.tar.gz" =>
    "482c3e28e0382a9458f0d944b6a3742d8cd2e775f663f3b5442944fc10dd6095",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
mkdir buildHEPMC
cd buildHEPMC/
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -Dmomentum:STRING=GEV -Dlength:STRING=MM ../HepMC-2.06.09/
make
make install
cd ..
rm -rf buildHEPMC/
mkdir build
cd pythia8243/
./configure --prefix=$prefix --host=$target
make 
make install
cd ../TAUOLA/
./configure --prefix=$prefix --host=$target --with-hepmc=$prefix --with-pythia8=$prefix
make
make install
cd ../PHOTOS/
./configure --prefix=$prefix --host=$target --with-hepmc=$prefix --with-pythia8=$prefix --with-tauola=$prefix
make
make install
cd ../build/
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DHEPMC2_ROOT_DIR=$prefix -DEVTGEN_PYTHIA=ON -DPYTHIA8_ROOT_DIR=$prefix -DEVTGEN_PHOTOS=ON -DPHOTOSPP_ROOT_DIR=$prefix -DEVTGEN_TAUOLA=ON -DTAUOLAPP_ROOT_DIR=$prefix ../evtgen/ 
make
make install
cd ..
rm -rf build/

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libEvtGenExternal", :libEvtGenExternal),
    LibraryProduct(prefix, "libTauolaCxxInterface", :libTauolaCxxInterface),
    LibraryProduct(prefix, "libPhotosppHEPEVT", :libPhotosppHEPEVT),
    LibraryProduct(prefix, "libPhotosppHepMC", :libPhotosppHepMC),
    LibraryProduct(prefix, "libPhotosppHepMC", :libPhotosppHepMC),
    LibraryProduct(prefix, "libPhotosppHEPEVT", :libPhotosppHEPEVT),
    LibraryProduct(prefix, "libPhotospp", :libPhotospp),
    LibraryProduct(prefix, "libHepMCfio", :libHepMCfio),
    LibraryProduct(prefix, "libHepMC", :libHepMC),
    LibraryProduct(prefix, "libPhotospp", :libPhotospp),
    LibraryProduct(prefix, "libTauolaFortran", :libTauolaFortran),
    LibraryProduct(prefix, "libEvtGen", :libEvtGen)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

