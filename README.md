This dockerfile was created to simply deploy a minimal qgis-server that is self contained in a single image. If you are in search for a micro-service architecture, please consider other docker images that may better fit in production Kubernetes clusters.

To build the Docker container run `sudo docker build -t qgis-server-docker:latest .`.

Then deploy it with `sudo docker run --rm -v /tmp/qgis:/var/local/qgis -p 8004:80 --name qgis-server b_qgis:latest`. As you may have identified, this will map the local directory `tmp/qgis` to serve as the project folder. Once started, you can simply drop your QGIS project files and layers into `/tmp/qgis/projects`. Modify this path and the desired port to your liking.

Use at your own risk.

The container can be used behind a reverse proxy. Relevant part of the configuration would look something like the following:

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
