This dockerfile was created to simply deploy a minimal qgis-server that is self contained in a single image. If you are in search for a micro-service architecture, please consider other docker images that may better fit in production Kubernetes clusters.

To build the Docker container run `sudo docker build -t qgis-server-docker:latest .` which will build and push the image to your local docker registry.

Then deploy it with `sudo docker run --rm -v /tmp/qgis:/var/local/qgis -p 8004:80 --name qgis-server qgis-server-docker:latest`. As you may have identified, this will map the local directory `tmp/qgis` to serve as the project folder. Once started, you can simply drop your QGIS project files and layers into `/tmp/qgis/projects`. Modify this path and the desired port to your liking. The `--rm` flag will delete the container after termination. Choose other flags for persistent deployment or create a corresponding Docker compose file.

Example URL's
```
    # - http://server/services/ogc?MAP=project.qgs&SERVICE=WMS
    # - http://server/services/ogc?MAP=folder1/subfolder/project.qgs&SERVICE=WMS
```
Where `server` is your IP address or domain name of the docker host. If you run on a port different than `80`, also add the configured port. E.g. `http://192.168.1.100:8004/services/ogc?MAP=folder1/subfolder/project.qgs&SERVICE=WMS`. The MAP query parameter shall be the relative path to your project folder. Say you placed your QGIS project `deploy.qgs` in `/tmp/qgis/projects/public/deploy.qgs`, the project should be reachable under `http://192.168.1.100:8004/services/ogc?MAP=folder1/public/deploy.qgs&SERVICE=WMS`

Use at your own risk and have a look at the files before execution.

The container can be used behind a reverse proxy. Relevant nginx part of the configuration would look something like the following:

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
