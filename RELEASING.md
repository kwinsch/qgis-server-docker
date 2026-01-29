# Release Workflow

## Check Upstream Versions

Visit https://qgis.org/resources/roadmap/ and note:

| Track | Column | Current (Jan 2026) | After Feb 2026 |
|-------|--------|-------------------|----------------|
| LTR | Long-Term Repo | 3.40.x | 3.44.x |
| LR | Latest | 3.44.x | 4.0.x |
| Dev | (master) | 3.99/4.0 | 4.1+ |

## Local Test (Optional)

```bash
# Build specific track with buildah
buildah bud --build-arg QGIS_TRACK=ltr -t test:ltr .
buildah bud --build-arg QGIS_TRACK=lr -t test:lr .
buildah bud --build-arg QGIS_TRACK=dev -t test:dev .

# List built images
buildah images

# Run container to verify QGIS version (requires podman)
podman run --rm test:ltr /usr/lib/cgi-bin/qgis_mapserv.fcgi --version
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
