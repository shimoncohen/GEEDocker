GEE repository: https://github.com/google/earthenterprise

# GEEDocker


Build and run Google Earth Enterprise with docker

### Create all images with runChain script:
To create all of the images run runChain.sh\
The script runChain.sh accepts the following flags:
* --tag <wanted_tag> (to specify wanted GEE tag, Default is [5.3.5-1610.20](https://github.com/google/earthenterprise/releases/tag/5.3.5-1610.20))
* --test (for running the GEE tests to check that the build was successful)
* --tutorial (for creating an additional fusion image with the tutorial files)

### Use prebuilt images:
CI publishes images to GitHub Container Registry on every push to master:
* `ghcr.io/shimoncohen/geebuild:<gee_tag>` (the compiled GEE base, rebuilt only when `geeBuild/` changes)
* `ghcr.io/shimoncohen/geeserver`, `geefusion`, `fusiontutorial`, tagged `master` and `sha-<commit>`

`geefusion-ssh` is built in CI but not published (#10).
Images hold no credentials; they are supplied when the container starts (see Running GEE).

To skip the long GEE compile locally, build an image on top of the published base:
```sh
docker build --build-arg BASE_IMAGE=ghcr.io/shimoncohen/geebuild:5.3.5-1610.20 -t geeserver:v1 server
```

### Create images one by one:
If you wish to create each image independantly you may do so with the given scripts as following:

For the basic build run:
```sh
cd geeBuild
bash build.sh
```
or the following, to use a specific tag from GEE repository:
```sh
cd geeBuild
bash build.sh --tag <wanted_tag>
```
\
For the GEE server run:
```sh
cd server
bash install.sh
```
\
For the GEE fusion run:
```sh
cd fusion
bash install.sh
```
\
For the GEE fusion with tutorial files run:
```sh
cd fusion/tutorial
bash install.sh
```
\
For the GEE fusion with ability to connect by ssh run:
```sh
cd fusion/ssh
bash install.sh
```


# Running GEE


Start server:
```sh
cd server
bash run.sh --admin_password_file <path>
```
The file holds the admin password for user `geapacheuser` (the `/admin/` pages). The server refuses to start without it.
**Refer to https://www.opengee.org/geedocs/5.2.2/answer/3470759.html for information about server password**\
** make sure the server is running before starting fusion\
\
\
Start fusion:
```sh
cd fusion
bash run.sh
```
\
Start fusion with tutorial:
```sh
cd fusion/tutorial
bash run.sh
```
\
Start fusion with ssh ability:
```sh
cd fusion/ssh
bash run.sh --authorized_keys ~/.ssh/id_ed25519.pub
```
Log in as root with that key on `127.0.0.1:30022` (`ssh -p 30022 root@127.0.0.1`). Password login is disabled.\
\
To start gee fusion (including tutorial), or server with bash entrypoint add --entrypoint flag:
```sh
bash fusion/run.sh --entrypoint
bash server/run.sh --entrypoint --admin_password_file <path>
```


# Remove images and containers

Remove all of the images and containers created by running the script removeAll.sh

Remove individual images by running the script removeImage.sh as such:
```sh
bash removeImage.sh <image_name:tag>
```
\
Remove containers by running the script removeContainer.sh as such:
```sh
bash removeContainer.sh <container_name>
```
