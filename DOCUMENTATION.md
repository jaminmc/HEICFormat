# Documentation Overview

This project includes comprehensive documentation for building and installing the HEICFormat plugin.

## Quick Reference

| File | Purpose | Size |
|------|---------|------|
| **README.md** | Main documentation - Quick start and build instructions | 5.1K |
| **CMAKE_BUILD.md** | Detailed CMake reference and troubleshooting | 8.8K |
| **SDK_SETUP.md** | Adobe Photoshop SDK setup guide | 4.4K |
| **CHANGELOG.md** | History of changes and improvements | - |

## Scripts

| File | Purpose | Size |
|------|---------|------|
| **build.sh** | Build automation with options (--debug, --arch, --clean) | 3.3K |
| **install.sh** | Installation to shared Adobe plugin directory | 3.5K |
| **check_plugin.sh** | Diagnostic tool to verify installation | 4.0K |

## Getting Started

1. **New users**: Start with [README.md](README.md) Quick Start section
2. **SDK issues**: See [SDK_SETUP.md](SDK_SETUP.md)
3. **Build problems**: Check [CMAKE_BUILD.md](CMAKE_BUILD.md) Troubleshooting
4. **Installation verification**: Run `./check_plugin.sh`

## Key Locations

**Plugin Installation**:
```
/Library/Application Support/Adobe/Plug-Ins/CC/File Formats/HEICFormat.plugin
```

**Source Structure**:
```
HEICFormat/
├── common/          # Core plugin code
├── mac/             # macOS UI code
├── build/           # Build output (generated)
└── *.md, *.sh       # Documentation and scripts
```

**Expected SDK Structure**:
```
~/src/photoshopsdk/pluginsdk/photoshopapi/
```

## Common Tasks

```bash
# Build and install
./build.sh && ./install.sh

# Debug build
./build.sh --debug

# Force specific architecture
./build.sh --arch arm64

# Verify installation
./check_plugin.sh

# Clean rebuild
./build.sh --clean
```

## Support

- Check [CMAKE_BUILD.md](CMAKE_BUILD.md) Troubleshooting section
- Run `./check_plugin.sh` for diagnostic information
- Check Console.app filtered by "Photoshop" for plugin loading errors
- Ensure plugin cache is cleared: `rm -rf ~/Library/Caches/Adobe/Photoshop*/PluginCache`
