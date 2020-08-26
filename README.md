GEE repository: https://github.com/google/earthenterprise

Feel free to use the opensource code, but if you take it to your repository, please fork and reference this repository :)

# GEEDocker


Build and run Google Earth Enterprise with docker

### Create all images with runChain script:
To create all of the images run runChain.sh\
The script runChain.sh accepts the following flags:
* --tag <wanted_tag> (to specify wanted GEE tag, Default is [5.3.5-1610.20](https://github.com/google/earthenterprise/releases/tag/5.3.5-1610.20))
* --test (for running the GEE tests to check that the build was successful)
* --tutorial (for creating an additional fusion image with the tutorial files)
* --admin_password <wanted_password> (for changing default server password)

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
or the following, to set server password:
```sh
cd server
bash install.sh --admin_password <wanted_password>
```
**Refer to https://www.opengee.org/geedocs/5.2.2/answer/3470759.html for information about server password**\
\
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
** you should first edit the install.sh file and add your root password **


# Running GEE


Start server:
```sh
cd server
bash run.sh
```
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
bash run.sh
```
** you should first edit the run.sh file and choose local port for mapping **\
\
To start gee fusion (including tutorial), or server with bash entrypoint add --entrypoint flag:
```sh
bash fusion/run.sh --entrypoint
bash server/run.sh --entrypoint
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
