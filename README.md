# pyrealsense2 for macOS

English | [简体中文](./README.zh-CN.md)

[![MacOS Build](https://github.com/yugasun/pyrealsense2-mac/actions/workflows/main.yml/badge.svg)](https://github.com/yugasun/pyrealsense2-mac/actions/workflows/main.yml)
[![MacOS Test](https://github.com/yugasun/pyrealsense2-mac/actions/workflows/test.yml/badge.svg)](https://github.com/yugasun/pyrealsense2-mac/actions/workflows/test.yml)
[![PyPI](https://img.shields.io/pypi/v/pyrealsense2-mac)](https://pypi.org/project/pyrealsense2-mac/)

Prebuilt pyrealsense2 packages of the [librealsense](https://github.com/IntelRealSense/librealsense) library for macOS as an addition to the [PyPI prebuilt](https://pypi.org/project/pyrealsense2/) packages by Intel.

### Prebuilt
To install the prebuilt wheel packages from this repository, run the following command (macOSX librealsense is included):

```bash
pip install pyrealsense2-mac
```

*Supported Platforms & Versions*

- OS: macOS 13+ (Big Sur)
- Architecture: `Intel (x86_64)`, `Apple Silicon (arm64)`
- Python: `3.10`

#### requirements.txt

To use `pyrealsense2` in a `requirements.txt` in combination with `pyrealsense2-mac` use the following lines. This will install either the official Windows / Linux version or the MacOSX pre-built wheel package.

```bash
pyrealsense2; platform_system == "Windows" or platform_system == "Linux"
pyrealsense2-mac; platform_system == "Darwin"
```

#### Sudo

Since `2.50.0` the realsense binaries have to run under sudo on some MacOS to find a device.
To run `realsense-viewer` under sudo, use the following command:

```bash
sudo realsense-viewer
```

### Manual Build

#### Prerequisites
Install [homebrew](https://brew.sh/) and the following packages:

```bash
sudo xcode-select --install
brew install cmake pkg-config openssl
brew install python@3.10
```

And set up a new python virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate
```

#### Build

Run the build script in your preferred shell.

```bash
bash build.sh
```

Build for a specific macos version, default is `13`:

```bash
bash build.sh -m 11
```

It is possible to set the [tag version](https://github.com/IntelRealSense/librealsense/tags) to build older releases, default is `v2.54.1`:

```bash
bash build.sh -t v2.51.1
```

The prebuild wheel files are copied into the `./dist` directory. By default, the dylib is added to the wheel file with the delocate toolkit. It is possible to disable this behaviour for just the python build:

```bash
bash build.sh --disable-delocate
```

#### Multi-Architecture Packages

The build script creates binaries which are targeted to `arm64` and `x86_64`. At the moment I could not find a way to tell the wheel package to set a *universal* tag. For now it is just possible to rename the wheel and change the architecture to the other platform and the package will work there too.

#### Installation

To install the wheel package just use the default pip install command.

```bash
pip install pyrealsense2_mac-2.54.1-cp310-cp310-macosx_13_universal2.whl
```


### License

MIT License
