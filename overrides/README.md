# Dockerfile Overrides

Place a complete `Dockerfile` in `overrides/<track>/` to override the default build for that track.

## Structure

```
overrides/
  ltr/
    Dockerfile    # Used instead of root Dockerfile for LTR builds
  lr/
    Dockerfile    # Used instead of root Dockerfile for LR builds
  dev/
    Dockerfile    # Used instead of root Dockerfile for Dev builds
```

## Active Overrides

### LTR → Ubuntu Noble (24.04)

QGIS 3.44.x (LTR) depends on Qt5, which was removed from Ubuntu Resolute (26.04).
The LTR override pins the base image to Noble where Qt5 packages are available.

**Remove when:** LTR moves to a Qt6-based version (QGIS 4.2 LTR, expected Jul 2026).

## When to Use

- Qt6 transition requires additional/different packages
- Upstream repository has broken dependencies needing workaround
- Track needs different Ubuntu base version
- Temporary fix while waiting for upstream patch

## Notes

- Override Dockerfile must be complete (not a patch)
- Build args (`QGIS_TRACK`, `UBUNTU_CODENAME`) are still passed
- Document reason for override in this file when adding one
