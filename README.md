GEE repository: https://github.com/google/earthenterprise

# GEEDocker


Build and run Google Earth Enterprise with docker

### Create all images with runChain script:
To create all of the images run runChain.sh\
The script runChain.sh accepts the following flags:
* --tag <wanted_tag> (to specify wanted GEE tag, Default is [5.3.5-1610.20](https://github.com/google/earthenterprise/releases/tag/5.3.5-1610.20))
* --test (runs the GEE unit tests in the `test` stage of geeBuild/Dockerfile; CI runs them before publishing the base)
* --tutorial (for creating an additional fusion image with the tutorial files)

### Use prebuilt images:
CI publishes images to GitHub Container Registry on every push to master:
* `ghcr.io/shimoncohen/geebuild:<gee_tag>` (the compiled GEE base, rebuilt only when `geeBuild/` changes)
* `ghcr.io/shimoncohen/geeserver`, `geefusion`, `geefusion-ssh`, `fusiontutorial`, tagged `master` and `sha-<commit>`

`fusion/ssh/run.sh` expects the local name `geefusion-ssh:v1`, so pull and retag:
```sh
# only if you already have a local geefusion-ssh:v1; an older build still holds a root password hash
docker rmi geefusion-ssh:v1 2>/dev/null || true
docker pull ghcr.io/shimoncohen/geefusion-ssh:master
docker tag ghcr.io/shimoncohen/geefusion-ssh:master geefusion-ssh:v1
```
Also run `docker builder prune` to drop old build cache (see the ssh install notes below).

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
If an older `geefusion-ssh:v1` with root password login is present, `install.sh` removes it before building. Its layers can stay in the build cache and still hold the old password hash: run `docker builder prune` to drop them. `removeAll.sh` also prunes dangling images, which is where a replaced build ends up.


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
The container runs without `--privileged`. The port is bound to localhost only; to reach it from another machine, tunnel through the docker host:
```sh
ssh -L 30022:127.0.0.1:30022 <user>@<docker-host>
ssh -p 30022 root@127.0.0.1
```
SSH host keys are generated when the container starts, so every new container has different ones. Reconnecting after a restart makes ssh warn about a changed host key; remove the old entry with `ssh-keygen -R "[127.0.0.1]:30022"`.\
\
To start gee fusion (including tutorial), or server with bash entrypoint add --entrypoint flag:
```sh
bash fusion/run.sh --entrypoint
bash server/run.sh --entrypoint --admin_password_file <path>
```
`fusion/ssh/run.sh --entrypoint --authorized_keys <key>` skips `entrypoint.sh`, so sshd is not started for you. In that shell run:
```sh
ssh-keygen -A
install -d -m 700 /root/.ssh
install -m 600 /run/secrets/authorized_keys /root/.ssh/authorized_keys
/usr/sbin/sshd
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
