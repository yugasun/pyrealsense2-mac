#!/bin/bash

macos=""
tag=""
root=""
libusbPath=""
libusbTag=""
dist=""
disableDelocate=false

# get arguments
while getopts ":m:t:r:l:v:d:-:" opt; do
  case ${opt} in
  m)
    macos=$OPTARG
    ;;
  t)
    tag=$OPTARG
    ;;
  r)
    root=$OPTARG
    ;;
  l)
    libusbPath=$OPTARG
    ;;
  v)
    libusbTag=$OPTARG
    ;;
  d)
    dist=$OPTARG
    ;;
  -)
    case "${OPTARG}" in
    disable-delocate)
      disableDelocate=true
      ;;
    *)
      echo "Invalid option: --${OPTARG}" >&2
      exit 1
      ;;
    esac
    ;;
  \?)
    echo "Invalid option: $OPTARG" 1>&2
    exit 1
    ;;
  :)
    echo "Invalid option: $OPTARG requires an argument" 1>&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

# set defaults
if [ -z "$macos" ]; then
  macos="13"
fi

if [ -z "$tag" ]; then
  tag="v2.54.1"
fi

if [ -z "$root" ]; then
  root="librealsense"
fi

if [ -z "$libusbPath" ]; then
  libusbPath="libusb"
fi

if [ -z "$libusbTag" ]; then
  libusbTag="v1.0.26"
fi

if [ -z "$dist" ]; then
  dist="dist"
fi

echo "build options:"
echo "tag: $tag"
echo "macos: $macos"
echo "root: $root"
echo "libusbPath: $libusbPath"
echo "libusbTag: $libusbTag"
echo "dist: $dist"
echo "disableDelocate: $disableDelocate"
echo ""

function replace_strings_in_file() {
  SearchString=$1
  ReplaceString=$2
  FullPathToFile=$3
  content=$(cat "$FullPathToFile" | sed "s|$SearchString|$ReplaceString|g")
  echo "$content" >"$FullPathToFile"
}

# cleanup
rm -rf "$root"
rm -rf "$libusbPath"

echo "building libusb universal..."
git clone --depth 1 --branch "$libusbTag" "https://github.com/libusb/libusb" "$libusbPath"

libusb_include=$(realpath "$libusbPath/libusb")

pushd "$libusbPath/Xcode"

mkdir build
xcodebuild -scheme libusb -configuration Release -derivedDataPath "$PWD/build" MACOSX_DEPLOYMENT_TARGET="$macos"

pushd "build/Build/Products/Release"

libusb_binary=$(realpath "libusb-1.0.0.dylib")
popd
popd

echo ""
echo "Lib USB Paths"
echo $libusb_include
echo $libusb_binary
echo ""

# building librealsense
echo "creating librealsense python lib version $tag ..."
pythonWrapperDir="wrappers/python"

# clone
if [ "$tag" = "nightly" ]; then
  echo "using nightly version..."
  git clone --depth 1 "https://github.com/IntelRealSense/librealsense.git" $root
else
  echo "using release version..."
  git clone --depth 1 --branch $tag "https://github.com/IntelRealSense/librealsense.git" $root
fi

pushd $root

# build with python support
mkdir build
pushd build

cmake .. -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DCMAKE_THREAD_LIBS_INIT="-lpthread" \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DBUILD_PYTHON_BINDINGS=bool:true \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_EXAMPLES=false \
  -DBUILD_WITH_OPENMP=false \
  -DBUILD_UNIT_TESTS=OFF \
  -DBUILD_GRAPHICAL_EXAMPLES=OFF \
  -DHWM_OVER_XU=false \
  -DOPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="$macos" \
  -DLIBUSB_INC="$libusb_include" \
  -DLIBUSB_LIB="$libusb_binary" \
  -G Xcode

xcodebuild -scheme realsense2 -configuration Release MACOSX_DEPLOYMENT_TARGET=$macos
xcodebuild -scheme pybackend2 -configuration Release MACOSX_DEPLOYMENT_TARGET=$macos
xcodebuild -scheme pyrealsense2 -configuration Release MACOSX_DEPLOYMENT_TARGET=$macos

popd

# copy libusb library
cp -a $libusb_binary $pythonWrapperDir/pyrealsense2
cp -a $libusb_binary build/Release

# copy realsense libraries
cp -a build/Release/*.dylib $pythonWrapperDir/pyrealsense2

# copy python libraries
cp -a build/wrappers/python/Release/*.so $pythonWrapperDir/pyrealsense2

# build bdist_wheel
pushd $pythonWrapperDir

python find_librs_version.py ../../ pyrealsense2

replace_strings_in_file "name=package_name" "name=\"pyrealsense2-mac\"" setup.py
replace_strings_in_file "https://github.com/IntelRealSense/librealsense" "https://github.com/yugasun/pyrealsense2-mac" setup.py

pip install wheel
python setup.py bdist_wheel --plat-name=macosx_"$macos"_0_universal2

# delocate wheel
if [ "$disableDelocate" = false ]; then
  pip install delocate
  delocate-wheel -v dist/*.whl
fi
popd
popd

# copy dist files
mkdir -p $dist
cp -a $root/wrappers/python/dist/* $dist

echo ""
echo "Finished! The build files are in $dist"
