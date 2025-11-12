<h1 align="center">Elegoo Neptune 4 Display Connector</h1>
<h3 align="center">Multi-Extruder / Multi-Material Edition</h3>

![GitHub License](https://img.shields.io/github/license/Emirhantaze/display_connector) ![GitHub top language](https://img.shields.io/github/languages/top/Emirhantaze/display_connector) ![Static Badge](https://img.shields.io/badge/Python-3.11-blue?logo=python&logoColor=white)

A display connector that allows you to use the original Elegoo touchscreen with your Neptune 4 3D printer running stock Klipper firmware. This project enables full touchscreen functionality without requiring custom firmware modifications.

**This fork has been specifically modified to add comprehensive multi-extruder and multi-material printing support**, allowing you to control multiple extruders directly from the touchscreen interface.

## Supported Printers

This project is specifically designed for **Elegoo Neptune 4** series printers with **original stock firmware**:

- Elegoo Neptune 4
- Elegoo Neptune 4 Pro
- Elegoo Neptune 4 Plus
- Elegoo Neptune 4 Max

## Supported Displays and Firmware

- **TJC4827X243_011** (Elegoo Neptune 4 Display)
  - Firmware 1.2.11
  - Firmware 1.2.12
  - Firmware 1.2.14

## Features

- **Multi-Extruder/Multi-Material Support** - Control up to 10 extruders from the touchscreen
  - Extruder selection menu for switching between tools
  - Individual temperature control for each extruder
  - Real-time temperature display for active extruder
  - Easy configuration via `display_connector.cfg`
- Full touchscreen control with stock Klipper installation
- Real-time temperature monitoring and control
- Print progress tracking and control
- File browser and print selection
- Bed leveling controls
- Movement controls
- Settings and configuration access

## Installation

Running the `display-service-installer.sh` script on your printer should be enough to get everything working.

```bash
# SSH into your printer
ssh mks@<printer-ip>

# Clone the repository
cd ~
git clone https://github.com/Emirhantaze/display_connector.git
cd display_connector

# Run the installer
chmod +x install_services.sh
./install_services.sh
```

## Configuration

Configuration options can be set in `~/klipper_config/display_connector.cfg`. 

### Multi-Extruder Setup

To configure multiple extruders, add the following to your `display_connector.cfg`:

```ini
[general]
extruder_count = 2  # Set to the number of extruders (1-10)
```

See [CONFIG_EXAMPLE.md](CONFIG_EXAMPLE.md) for detailed configuration examples and multi-extruder setup instructions.

## Credits and Acknowledgments

This project is a fork of the [OpenNeptune3D display_connector](https://github.com/OpenNeptune3D/display_connector) project. The original project was created to support the OpenNeptune custom firmware ecosystem.

**Original Project:** [OpenNeptune3D/display_connector](https://github.com/OpenNeptune3D/display_connector)

This fork has been modified to focus specifically on supporting **Elegoo Neptune 4 series printers with stock/original firmware**, removing dependencies on custom firmware while maintaining the excellent touchscreen integration functionality.

We are grateful to the OpenNeptune3D team and contributors for their foundational work that made this project possible.

## License

This project maintains the same license as the original OpenNeptune3D project. See [LICENSE](LICENSE) for details.