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

None currently.

## When to Use

- Qt6 transition requires additional/different packages
- Upstream repository has broken dependencies needing workaround
- Track needs different Ubuntu base version
- Temporary fix while waiting for upstream patch

## Notes

- Override Dockerfile must be complete (not a patch)
- Build args (`QGIS_TRACK`, `UBUNTU_CODENAME`) are still passed
- Document reason for override in this file when adding one
