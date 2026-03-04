---
name: build-xilinx-image
description: Baut das Xilinx/Kria Yocto-Image reproduzierbar mit KAS, inkl. expliziter Lizenz-Zustimmung und /tmp-basierten Build-Pfaden.
---

# Build Xilinx Image (Kria K26)

## Zweck

Diese Skill-Anleitung standardisiert den Build des Kria-K26-Images in diesem Repository.
Sie stellt sicher, dass:

- die Xilinx-Lizenz-Zustimmung explizit gesetzt ist,
- große Build-Artefakte standardmäßig außerhalb des Workspace liegen,
- ein reproduzierbarer Build-Befehl verwendet wird.

## Voraussetzungen

- Dev Container ist gestartet.
- `kas` ist verfügbar.
- Du befindest dich im Repository-Root.

## Standard-Build (empfohlen)

```bash
ACCEPT_XILINX_LICENSE=1 ./scripts/build-xilinx-image.sh
```

Der Wrapper setzt standardmäßig:

- Abbruch, falls `ACCEPT_XILINX_LICENSE` nicht auf `1` gesetzt ist
- `LICENSE_FLAGS_ACCEPTED` mit `xilinx`
- `KIRA_BITBAKE_CACHE_DIR=/tmp/bitbake-cache`
- `DL_DIR=/tmp/yocto-downloads`
- `SSTATE_DIR=/tmp/yocto-sstate-cache`
- `TMPDIR=/tmp/yocto-tmp`
- `XSCT_STAGING_DIR=/tmp/yocto-xsct`

## Explizite Lizenz-Zustimmung

Wenn du die Zustimmung bewusst im Aufruf sichtbar machen willst:

```bash
ACCEPT_XILINX_LICENSE=1 ./scripts/build-xilinx-image.sh
```

Optional mit eigenen Pfaden:

```bash
ACCEPT_XILINX_LICENSE=1 \
KIRA_BITBAKE_CACHE_DIR=/tmp/bitbake-cache \
DL_DIR=/tmp/yocto-downloads \
SSTATE_DIR=/tmp/yocto-sstate-cache \
TMPDIR=/tmp/yocto-tmp \
XSCT_STAGING_DIR=/tmp/yocto-xsct \
./scripts/build-xilinx-image.sh
```

## Ergebnisartefakte

Bei Standardpfaden liegen die Images unter:

```text
/tmp/yocto-tmp/deploy/images/k26-smk/
```

## Cleanup

Workspace aufräumen:

```bash
./scripts/cleanup-yocto-workspace.sh
```

Zusätzlich `/tmp`-Caches entfernen:

```bash
./scripts/cleanup-yocto-workspace.sh --tmp
```

## Troubleshooting (kurz)

- Build bricht mit Lizenzfehler ab: `ACCEPT_XILINX_LICENSE=1` setzen.
- `/tmp` ist zu klein: Pfade (`TMPDIR`, `DL_DIR`, `SSTATE_DIR`) auf ein größeres Volume umbiegen.
- Bestehender BitBake-Prozess blockiert Cleanup: Build zuerst stoppen, dann Cleanup erneut ausführen.
