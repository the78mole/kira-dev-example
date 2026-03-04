# Kria K26 Yocto Development Environment

A professional, reproducible **Yocto / KAS** build environment for the
**AMD Kria K26 SOM** (SM-K26-XCL2GI), packaged as a VS Code Dev Container so
every developer gets an identical toolchain regardless of their host OS.

---

## Why KAS + Dev Containers instead of PetaLinux?

| | PetaLinux (monolithic) | This repo (KAS + DevContainers) |
|---|---|---|
| **Reproducibility** | Installer-dependent, version drift | Pinned layer commits, Docker image |
| **CI/CD friendly** | Requires GUI installer | `kas build kas/k26-smk.yml` – single command |
| **Layer flexibility** | Wrapped BSP, hard to customise | Full Yocto layer graph, add/remove freely |
| **Team on-boarding** | Install PetaLinux per machine | `git clone` + open in VS Code |
| **Disk footprint** | Duplicated per project | Shared Docker volumes |

**KAS** is a lightweight Python tool that reads a single YAML file
(`kas/k26-smk.yml`) and:
1. Clones all required Yocto layers at the correct revisions.
2. Writes `bblayers.conf` and `local.conf` automatically.
3. Invokes BitBake – so the whole build is one command.

---

## Repository Structure

```
kira-dev-example/
├── .devcontainer/
│   ├── Dockerfile          # Ubuntu 22.04 + all Yocto deps + kas + builder user
│   └── devcontainer.json   # VS Code Dev Container configuration
├── apps/
│   └── example-design/     # Placeholder: .bit, .dtbo, shell.json per PL design
├── kas/
│   └── k26-smk.yml         # KAS build descriptor (layers, machine, distro)
├── layers/
│   └── meta-customer-app/  # Custom Yocto layer template
├── scripts/
│   └── flash-sd.sh         # Helper: write .wic image to SD card
└── README.md
```

---

## Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (≥ 4.x)
  configured with **≥ 8 GB RAM** and **≥ 4 CPU cores** (16 GB / 8 cores recommended)
- [VS Code](https://code.visualstudio.com/) with the
  [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension

### Opening the project in VS Code

```bash
git clone https://github.com/the78mole/kira-dev-example.git
code kira-dev-example
```

VS Code will detect the `.devcontainer/` folder and prompt:

> **Reopen in Container**

Click it (or run **Dev Containers: Reopen in Container** from the Command
Palette).  Docker will build the image on the first run (~5 minutes), then
drop you into a fully configured shell as the `builder` user.

---

## Build Process

Inside the Dev Container terminal:

```bash
kas build kas/k26-smk.yml
```

KAS will:
1. Clone `openembedded-core`, `meta-openembedded`, `meta-xilinx`,
   `meta-xilinx-tools`, and `meta-kria` at the `mickledore` branch.
2. Generate `build/conf/bblayers.conf` and `build/conf/local.conf`.
3. Launch BitBake to build `petalinux-image-minimal` for `k26-smk`.

The resulting image is written to:

```
build/tmp/deploy/images/k26-smk/petalinux-image-minimal-k26-smk.wic.bz2
```

> **Note:** A full build takes 2–4 hours on an 8-core machine.
> Subsequent builds reuse the `sstate-cache` and are much faster.

---

## First Boot – Writing the SD Card

### Using `dd` (Linux / macOS)

```bash
# Decompress and write in one step (replace /dev/sdX with your SD card device)
bzcat build/tmp/deploy/images/k26-smk/petalinux-image-minimal-k26-smk.wic.bz2 \
    | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
sudo sync
```

Or use the helper script (validates the device and asks for confirmation):

```bash
./scripts/flash-sd.sh \
    build/tmp/deploy/images/k26-smk/petalinux-image-minimal-k26-smk.wic.bz2 \
    /dev/sdX
```

### Using BalenaEtcher (Windows / macOS / Linux GUI)

1. Open [BalenaEtcher](https://www.balena.io/etcher/).
2. **Flash from file** → select the `.wic.bz2` image.
3. **Select target** → choose your SD card.
4. Click **Flash!**

---

## Working with Hardware Overlays (xmutil)

The K26 supports dynamic PL (FPGA fabric) reconfiguration at runtime using
**xmutil** – no reboot required.

### Prepare the design artefacts

Place the following files for each hardware design in
`/lib/firmware/xilinx/<design-name>/` on the target:

| File | Description |
|------|-------------|
| `<design>.bit` | Partial FPGA bitstream |
| `<design>.dtbo` | Device-tree overlay |
| `shell.json` | xmutil metadata |

Templates live in `apps/example-design/` in this repository.

### Runtime commands on the K26

```bash
# List registered accelerator designs
xmutil listapps

# Unload the currently active design
xmutil unloadapp

# Load a new design (no reboot needed)
xmutil loadapp <design-name>
```

---

## Customisation

### Adding a package to the image

Edit `kas/k26-smk.yml` and append the package to `local_conf_footer`:

```yaml
local_conf_footer:
  general: |
    IMAGE_INSTALL:append = " htop vim"
```

Then rebuild:

```bash
kas build kas/k26-smk.yml
```

### Adding a custom recipe

1. Place your `.bb` recipe under
   `layers/meta-customer-app/recipes-<category>/<name>/<name>_<version>.bb`.
2. Add the recipe name to `IMAGE_INSTALL:append` in `kas/k26-smk.yml`.

### Switching the Yocto release

Change the `refspec` values in `kas/k26-smk.yml` from `mickledore` to the
desired release branch (e.g., `langdale`), then rebuild.

---

## Useful Resources

- [AMD Kria KV260 / K26 Product Page](https://www.amd.com/en/products/systems-and-optimization/adaptive-computing/kria.html)
- [meta-xilinx on GitHub](https://github.com/Xilinx/meta-xilinx)
- [meta-kria on GitHub](https://github.com/Xilinx/meta-kria)
- [KAS Documentation](https://kas.readthedocs.io/)
- [Yocto Project Documentation](https://docs.yoctoproject.org/)

---

## License

[MIT](LICENSE)
