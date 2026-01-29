This dockerfile was created to simply deploy a minimal qgis-server that is self contained in a single image. If you are in search for a micro-service architecture, please consider other docker images that may better fit in production Kubernetes clusters.

## Pre-built Images

Available on Docker Hub:

```
docker pull kwinsch/qgis-server-docker:ltr    # Long-term release
docker pull kwinsch/qgis-server-docker:lr     # Latest release
```

Versioned tags are also available (e.g., `v3.40.15-ltr-1`).

## Local Build

To build the Docker container run `docker build --build-arg QGIS_TRACK=ltr -t qgis-server-docker:ltr .` which will build the image to your local docker registry. Valid tracks are `ltr`, `lr`, and `dev`.

Then deploy it with `docker run --rm -v /tmp/qgis:/var/local/qgis -p 8004:80 --name qgis-server qgis-server-docker:ltr`. This maps the host directory `/tmp/qgis` into the container. Modify this path and the port to your liking. The `--rm` flag deletes the container after termination.

## Project Structure

Organize projects the same way as in QGIS Desktop. The `.qgs` file and all referenced layers must be within the same directory tree:

```
/tmp/qgis/projects/
  myproject/
    myproject.qgs
    data/
      roads.gpkg
      parcels.shp
```

All layer paths in the project must be relative. Layers outside the project directory will not be accessible to the server.

## Example URLs

```
http://server/services/ogc?MAP=myproject/myproject.qgs&SERVICE=WMS
http://server/services/ogc?MAP=folder1/subfolder/project.qgs&SERVICE=WMS
```

Where `server` is your IP address or domain name of the docker host. If you run on a port different than `80`, also add the configured port. E.g. `http://192.168.1.100:8004/services/ogc?MAP=folder1/subfolder/project.qgs&SERVICE=WMS`. The MAP query parameter shall be the relative path to your project folder. Say you placed your QGIS project `deploy.qgs` in `/tmp/qgis/projects/public/deploy.qgs`, the project should be reachable under `http://192.168.1.100:8004/services/ogc?MAP=public/deploy.qgs&SERVICE=WMS`

Use at your own risk and have a look at the files before execution.

## Reverse Proxy

The container can be used behind a reverse proxy. Authentication is handled at the proxy level (e.g., `.htpasswd`, OAuth, SSO) - choose what fits your environment.

Example nginx configuration:

```
server {
...
    # Gzip
    gzip off;

    location / {

        proxy_pass http://<your-qgis-server-IP>:8004$request_uri;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Proto http;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_request_buffering off;

        # Increase timeout for long-running requests
        proxy_read_timeout 3600;
        proxy_send_timeout 3600;
...

    }

}
```
