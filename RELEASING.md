# Release Workflow

## Check Upstream Versions

Visit https://qgis.org/resources/roadmap/ and note:

| Track | Column | Current (Apr 2026) | Base Image |
|-------|--------|--------------------|--------------------|
| LTR | Long-Term Repo | 3.44.x | Noble 24.04 (Qt5) |
| LR | Latest | 4.0.x | Resolute 26.04 (Qt6) |
| Dev | (master) | 4.1+ | Resolute 26.04 (Qt6) |

> **Note:** QGIS 4.0+ requires Qt6. Noble (24.04) only has Qt5, so LTR uses
> an override Dockerfile (`overrides/ltr/Dockerfile`) pinned to Noble.
> LR and Dev use the default Dockerfile on Resolute. This split goes away
> when LTR moves to Qt6 (QGIS 4.2 LTR, expected Jul 2026).

## Local Test (Optional)

```bash
# LTR uses override Dockerfile (Noble/Qt5)
buildah bud -f overrides/ltr/Dockerfile -t test:ltr .

# LR and Dev use default Dockerfile (Resolute/Qt6)
buildah bud --build-arg QGIS_TRACK=lr -t test:lr .
buildah bud --build-arg QGIS_TRACK=dev -t test:dev .

# List built images
buildah images

# Verify QGIS version (requires podman)
podman run --rm test:ltr /usr/lib/cgi-bin/qgis_mapserv.fcgi --version
podman run --rm test:lr /usr/lib/cgi-bin/qgis_mapserv.fcgi --version
```

## Create Release

```bash
# LTR release
./tag-release.sh 3.44.8 ltr
git push origin v3.44.8-ltr-1

# Latest Release
./tag-release.sh 4.0.0 lr
git push origin v4.0.0-lr-1

# Dev (date auto-appended)
./tag-release.sh 4.1 dev
git push origin v4.1-dev-20260129-1
```

## Verify Build

1. **GitHub Actions**: https://github.com/kwinsch/qgis-server-docker/actions
   - Workflow triggered by tag push
   - "Parse tag" step shows correct track
   - "Build and push" completes without error

2. **Docker Hub**: https://hub.docker.com/r/kwinsch/qgis-server-docker/tags
   - Version tag exists (e.g., `v3.44.8-ltr-1`)
   - Track tag updated (e.g., `ltr`)

## Manual Build (workflow_dispatch)

For testing or rebuilds without creating a tag:

1. Go to Actions -> Docker Build and Push -> Run workflow
2. Select track, optionally set custom docker tag
3. Click "Run workflow"

## Overrides

If a track needs custom Dockerfile (e.g., Qt6 packages):

1. Create `overrides/<track>/Dockerfile`
2. Document in `overrides/README.md`
3. Workflow auto-detects and uses override

## Tag Format

| Track | Format | Example |
|-------|--------|---------|
| LTR | `v{X.Y.Z}-ltr-{N}` | `v3.44.8-ltr-1` |
| LR | `v{X.Y.Z}-lr-{N}` | `v4.0.0-lr-1` |
| Dev | `v{X.Y}-dev-{DATE}-{N}` | `v4.1-dev-20260129-1` |

## Docker Tags Generated

| Git Tag | Docker Tags |
|---------|-------------|
| `v3.44.8-ltr-1` | `v3.44.8-ltr-1`, `ltr` |
| `v4.0.0-lr-1` | `v4.0.0-lr-1`, `lr` |
| `v4.1-dev-20260129-1` | `v4.1-dev-20260129-1`, `dev` |
