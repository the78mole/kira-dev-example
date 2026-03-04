# apps/

This directory stores per-design artefacts that are deployed to the K26 via
**xmutil** without requiring a full system reimage.

## Directory layout

```
apps/
└── <design-name>/
    ├── <design-name>.bit      # Partial FPGA bitstream (PL configuration)
    ├── <design-name>.dtbo     # Device-tree overlay for the PL design
    └── shell.json             # xmutil metadata (name, description, type)
```

## Example `shell.json`

```json
{
    "shell_type": "XRT_FLAT",
    "num_slots": "1"
}
```

## Loading a design at runtime

```bash
# List available accelerator designs
xmutil listapps

# Unload the currently active design (if any)
xmutil unloadapp

# Load a new design (no reboot required)
xmutil loadapp <design-name>
```

Place each hardware design in its own subdirectory named identically to the
design so that `xmutil` can discover it automatically from `/lib/firmware/xilinx/`.
