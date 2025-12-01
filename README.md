HEIC Format Plug-in For Adobe Photoshop
===

A plug-in for Photoshop that adds functionality to save documents as HEIC format.

## Quick Start

```bash
# Install build tools and dependencies
brew install cmake pkg-config libheif x265

# Build and install LittleCMS 2 with fast float plugin (required)
curl -L -O https://downloads.sourceforge.net/project/lcms/lcms/2.16/lcms2-2.16.tar.gz
tar xzf lcms2-2.16.tar.gz && cd lcms2-2.16
./configure --with-fastfloat && make && sudo make install

# Download and extract Adobe Photoshop SDK to ~/src/photoshopsdk
# Get it from: https://console.adobe.io/downloads

# Build and install
cd ~/src/HEICFormat
./build.sh
./install.sh
```

Restart Photoshop and look for "HEIC Format" in **File → Save As**.

### Key Features

- ✅ **Universal compatibility** - Works on both Intel and Apple Silicon Macs
- ✅ **All Photoshop versions** - Single installation location for all versions (2020-2026+)
- ✅ **Automatic configuration** - Detects architecture and finds all dependencies
- ✅ **Self-contained** - All libraries statically linked, no runtime dependencies

## Usage

After installing and restarting Photoshop:

1. **File → Save As** - Select "HEIC Format" from the format dropdown
2. **Help → About Plug-ins** - Look for "HEIC Format..." to verify installation

### Troubleshooting

If the plugin doesn't appear:

```bash
# Verify installation
./check_plugin.sh

# Or manually check
ls -la "/Library/Application Support/Adobe/Plug-Ins/CC/File Formats/HEICFormat.plugin"

# Clear Photoshop plugin cache
rm -rf ~/Library/Caches/Adobe/Photoshop*/PluginCache
```

Make sure to **completely quit and restart Photoshop** (Cmd+Q, not just close windows).

## Building from Source

### Prerequisites

- [Adobe Photoshop SDK][5] (download from Adobe Console)
- [libheif][1], [x265][2], [LittleCMS 2][4] with [fast float plug-in][6]
- CMake 3.15+ and pkg-config
- Xcode Command Line Tools

### Build Instructions

#### 1. Install Build Tools and Dependencies

```bash
# Install build tools
brew install cmake pkg-config

# Install dependencies
brew install libheif x265 little-cms2
```

#### 2. Build LittleCMS 2 with Fast Float Plugin

The fast float plugin is required but not included in the Homebrew version:

```bash
cd ~/Downloads
curl -L -O https://downloads.sourceforge.net/project/lcms/lcms/2.16/lcms2-2.16.tar.gz
tar xzf lcms2-2.16.tar.gz
cd lcms2-2.16
./configure --with-fastfloat
make
sudo make install
```

#### 3. Install Adobe Photoshop SDK

Download the Adobe Photoshop SDK from [Adobe Console][5] and extract:

```bash
mkdir -p ~/src
cd ~/src
# Extract your downloaded SDK archive here
# It typically creates a folder containing pluginsdk/photoshopapi/
```

Expected structure:
```
~/src/
├── HEICFormat/                    # This repository
└── photoshopsdk/                  # Extracted SDK
    └── pluginsdk/
        └── photoshopapi/
            ├── photoshop/
            ├── pica_sp/
            └── ...
```

**Note:** If your SDK is in a different location, specify it when building:
```bash
cmake -B build -DPHOTOSHOP_SDK_PATH=/path/to/sdk/pluginsdk/photoshopapi
```

#### 4. Build and Install

```bash
cd ~/src/HEICFormat
./build.sh     # Builds for your Mac's architecture automatically
./install.sh   # Installs to shared Adobe directory
```

**Installation location:**
```
/Library/Application Support/Adobe/Plug-Ins/CC/File Formats/HEICFormat.plugin
```

This location works for **all Adobe Photoshop versions** automatically (2020-2026+).

Restart Photoshop and the plugin will appear in **File → Save As**.

### Advanced Options

```bash
./build.sh --help        # Show all options
./build.sh --debug       # Build debug version
./build.sh --arch arm64  # Force specific architecture
./build.sh --clean       # Clean build

./check_plugin.sh        # Verify plugin installation
```

## Additional Documentation

- [CMAKE_BUILD.md](CMAKE_BUILD.md) - Detailed CMake reference and troubleshooting
- [SDK_SETUP.md](SDK_SETUP.md) - Adobe Photoshop SDK setup guide
- `./check_plugin.sh` - Diagnostic tool to verify plugin installation

## Features

- Exports Photoshop documents to HEIC format
- Adjustable quality (0-100)
- Optional alpha channel support
- Color profile embedding (or convert to sRGB)
- Preserves EXIF and XMP metadata
- Compatible with macOS Preview and iOS Photos

### Plugin Options

- **Reveal in Finder** - Opens file location after saving (new files only)
- **Always convert to sRGB** - Overrides color profile embedding
- **Don't ask every time** - Uses saved settings (change via Help → About Plug-ins → HEIC Format)

## Limitations

- macOS only (10.13+) - Windows version not yet implemented
- Uses default x265 settings (not customizable)
- No thumbnail generation
- Not scriptable yet
- May crash Photoshop 22.3 if embedding color profiles (Adobe bug, use sRGB conversion instead)

## License

GPLv3 - Written for fun by jdp, 2021

[1]: https://github.com/strukturag/libheif
[2]: https://www.videolan.org/developers/x265.html
[3]: https://github.com/fnordware/SuperPNG
[4]: https://github.com/mm2/Little-CMS
[5]: https://console.adobe.io/downloads
[6]: https://www.littlecms.com/plugin
