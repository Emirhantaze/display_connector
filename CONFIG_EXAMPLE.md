# Display Connector Configuration Example

## Extruder Configuration

To configure the number of extruders in your system, add the following to your `display_connector.cfg` file:

```ini
[general]
# Number of extruders in your system
# Default: 1 (if not specified)
# Range: 1-10
# Examples:
#   extruder_count = 1    # Single extruder (default)
#   extruder_count = 2    # Dual extruder setup
#   extruder_count = 3    # Triple extruder setup
extruder_count = 2
```

## How It Works

- **extruder_count**: Specifies how many extruders your printer has
  - Value `1` = Single extruder (uses "extruder" in Klipper)
  - Value `2` = Dual extruder (uses "extruder" and "extruder1" in Klipper)
  - Value `3` = Triple extruder (uses "extruder", "extruder1", "extruder2" in Klipper)
  - And so on up to 10 extruders

## Extruder Naming Convention

The system automatically generates extruder names based on Klipper's naming:
- First extruder: `extruder`
- Second extruder: `extruder1`
- Third extruder: `extruder2`
- Fourth extruder: `extruder3`
- etc.

## Example Configurations

### Single Extruder (Default)
```ini
[general]
extruder_count = 1
```

### Dual Extruder
```ini
[general]
extruder_count = 2
```

### Triple Extruder
```ini
[general]
extruder_count = 3
```

## Notes

- The extruder count is read when the display connector starts
- If you change the count, restart the display connector service
- The system will automatically:
  - Subscribe to temperature updates for all configured extruders
  - Show the correct number of options in the extruder selection menu
  - Control the correct extruder when setting temperatures
  - Display the selected extruder's temperature on all screens

## Custom Touch Actions for Extruder Selection

The extruder selection page uses custom touch actions. By default, it supports up to 3 extruders with these coordinates:

```python
"extruder_select": {
    (10, 54, 257, 114): "select_extruder_0",   # First extruder
    (10, 127, 257, 187): "select_extruder_1",  # Second extruder
    (10, 200, 257, 260): "select_extruder_2",  # Third extruder (if needed)
}
```

If you have more than 3 extruders, you'll need to add additional touch areas in `src/response_actions.py` following the same pattern.

