# Changelog

## 2024-12-01 - CMake Build System & Apple Silicon Support

### Major Changes

- **Added CMake build system** - Modern, cross-platform build configuration
- **Apple Silicon (ARM64) support** - Fixed plugin to work on M1/M2/M3 Macs
- **Automatic architecture detection** - Builds for host architecture automatically
- **Static linking** - All dependencies statically linked for self-contained plugin
- **Shared plugin location** - Installs to `/Library/Application Support/Adobe/Plug-Ins/CC/File Formats/`
  - Works with all Photoshop versions (2020-2026+) from single installation

### Fixed Issues

1. **ARM64 Code Descriptor** - Added `CodeMacARM64` to resource file for Photoshop 2025+ compatibility
2. **Dynamic Library Dependencies** - Changed to static linking to eliminate Homebrew runtime dependencies
3. **Code Signing** - Added proper ad-hoc code signing with runtime hardening for Apple Silicon
4. **Info.plist** - Fixed template variable expansion issues

### New Files

- `CMakeLists.txt` - CMake build configuration
- `build.sh` - Simple build script with options
- `install.sh` - Installation script for shared plugin directory
- `check_plugin.sh` - Diagnostic tool to verify plugin installation
- `Info.plist` - Proper bundle metadata file
- `.gitignore` - Build artifacts exclusion

### Documentation

- `README.md` - Comprehensive quick start and build instructions
- `CMAKE_BUILD.md` - Detailed CMake reference and troubleshooting
- `SDK_SETUP.md` - Adobe Photoshop SDK setup guide

### Build Features

- Auto-detects host architecture (Intel or Apple Silicon)
- Uses pkg-config for dependency detection
- Compiles SDK sources as Objective-C++ where needed
- Includes Rez resource compilation
- Post-install permission fixing

### Compatibility

- **macOS**: 10.13+ (High Sierra and later)
- **Architectures**: Intel (x86_64) and Apple Silicon (arm64)
- **Photoshop**: CC 2020 through 2026+ (all versions)

### Dependencies

- libheif (statically linked)
- x265 (statically linked)
- LittleCMS 2 with fast float plugin (statically linked)
- System frameworks only at runtime

---

## Previous Versions

See git history for changes prior to CMake migration.

