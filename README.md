# OPO's pr-viewer
The problem this application solves:

 - OPO Forms use React Router, which as you may already know, uses the *browser* URI rules to identify which components to render. This can cause problems if the server is not configured accordingly.
 - S3 does not work well with react router, it does not have capacity for complex custom rules that can allow react router to work well with the backend.

The purpose of the PR viewer is to be a layer on top of S3, it basically runs Nginx which has great routing capabilities, and we configure it as a proxy between react and s3:

[Client / Browser] <-> [React] <-> [Nginx] <-> [S3]

To run:

```
git clone https://github.com/cityofaustin/opo-pr-viewer

cd opo-pr-viewer

docker build --no-cache -f Dockerfile -t cityofaustin/opo-pr-viewer .

docker run -it --rm -p 80:80/tcp cityofaustin/opo-pr-viewer
```

