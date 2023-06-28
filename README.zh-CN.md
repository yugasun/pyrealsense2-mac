# Mac 版 pyrealsense2 

[English](./README.md) | 简体中文

[![MacOS Build](https://github.com/yugasun/pyrealsense2-mac/actions/workflows/main.yml/badge.svg)](https://github.com/yugasun/pyrealsense2-mac/actions/workflows/main.yml)
[![MacOS Test](https://github.com/yugasun/pyrealsense2-mac/actions/workflows/test.yml/badge.svg)](https://github.com/yugasun/pyrealsense2-mac/actions/workflows/test.yml)
[![PyPI](https://img.shields.io/pypi/v/pyrealsense2-mac)](https://pypi.org/project/pyrealsense2-mac/)

本库为 macOS 的[librealsense](https://github.com/IntelRealSense/librealsense) 库构建了预安装的 pyrealsense2 软件包，以补充由英特尔提供的 [PyPI预构建](https://pypi.org/project/pyrealsense2/) 软件包。

### 预构建

要从此存储库安装预构建的wheel包，请运行以下命令（macOS librealsense已包括在内）：

```bash
pip install pyrealsense2-mac
```

*支持的平台和版本*

- 操作系统：`macOS 13+（Big Sur）`
- 架构：`Intel（x86_64）`，`Apple Silicon（arm64）`
- Python：`3.10`

#### requirements.txt

要在`requirements.txt`中使用`pyrealsense2`与`pyrealsense2-mac`组合，请使用以下行。这将安装官方Windows / Linux版本或MacOSX预构建的wheel包。

```bash
pyrealsense2; platform_system == "Windows" or platform_system == "Linux"
pyrealsense2-mac; platform_system == "Darwin"
```

#### 不需要 Sudo

运行 `realsense-viewer`：

```bash
realsense-viewer
```

### 手动构建

#### 先决条件
安装[homebrew](https://brew.sh/)和以下软件包：

```bash
sudo xcode-select --install
brew install cmake pkg-config openssl
brew install python@3.10
```

并设置新的python虚拟环境：

```bash
python3 -m venv venv
source venv/bin/activate
```

#### 构建

在首选shell中运行构建脚本。

```bash
bash build.sh
```

构建特定的macos版本，默认为`13`，比如指定为 `11`：

```bash
bash build.sh -m 11
```

可以将[标签版本](https://github.com/IntelRealSense/librealsense/tags)设置为构建旧版本：

```bash
bash build.sh -t v2.49.0
```

预构建的wheel文件将被复制到`./dist`目录中。默认情况下，使用delocate工具包将dylib添加到wheel文件中。可以仅禁用此行为以供Python构建：

```bash
bash build.sh --disable-delocate
```

#### 多架构软件包

构建脚本创建了针对`arm64`和`x86_64`的二进制文件。目前我无法找到一种方法来告诉wheel包设置*通用*标签。现在只需要重命名wheel并将架构更改为另一个平台，软件包也将在那里运行。

#### 安装

要安装wheel软件包，请使用默认 pip install 命令。

```bash
pip install pyrealsense2_mac-2.54.1-cp310-cp310-macosx_13_universal2.whl
```

## License

[MIT License](./LICENSE)