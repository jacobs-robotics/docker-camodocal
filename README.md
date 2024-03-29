# CamOdoCal Docker Container

Docker container with the [CamOdoCal](https://github.com/hengli/camodocal) camera calibration software.

## Getting Started


### Prerequisites

#### Latest test with

* [Docker](https://docs.docker.com/install/) --> 20.10.7  
* [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker) --> 20.10.7 (Note that you need NVDIA drivers)

Please use a docker and nvidia-docker version that is compatible with these versions.

~~In order to build and run the docker container, the following is needed:~~

~~* [Docker](https://docs.docker.com/install/) >= 1.12~~  
~~* [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker) (Note that you need NVDIA drivers)~~

### Installing

After cloning the repository, run the next command (UNIX systems):

```
./docker_helper.sh --build
```

### Usage

After the container is built; run the following command:

```
./docker_helper.sh --run [CAMODOCAL_COMMAND]
```

where CAMODOCAL_COMMAND is a string with the instruction and parameters needed by camodocal as defined in the [CamOdoCal repository](https://github.com/hengli/camodocal). For example:

```
./docker_helper.sh --run-rm "stereo_calib -w 8 -h 6 -s 0.06 --camera-model kannala-brandt -i /root/input_data -o /root/output_data"
```

The */input_data* and */output_data* directories are mounted to the docker container for the user to save the files needed to run these commands as well as their output. Please, be sure to add the */root* parent directory when writing the path to these directories. You can always run the *--help* command to see a list of available parameters:

```
./docker_helper.sh --run-rm "intrinsic_calib --help"
```

#### ATTENTION/BUG

When using the ```intrinsic_calib``` command it was pointed out that the output files cannot be access by the host. Unfortunately the original Camodocal software hardcodes the output directory and filenames for this use case. 

To enable users of this docker version use the "intrinsic calibration", the next command allows the user to enter the created container in the directory of the Camodocal executables to run them as they would natively. The user will have to manually move the output files into the */root/output_data* directory in the container so that the host can access them. Example:

```
hostuser@hostmachine:~/docker-camodocal$ ./docker_helper.sh --run-keep
root@hostcamodocal:~/camodocal/build/bin# ./intrinsic_calib -w 8 -h 6 -s 0.06 --opencv --camera-model pinhole -p img_ -e .png -i /root/input_data/my_images
root@hostcamodocal:~/camodocal/build/bin# mv camera* ../../../output_data/.
root@hostcamodocal:~/camodocal/build/bin# chmod -R a+rw ../../../output_data/*
root@hostcamodocal:~/camodocal/build/bin# exit
hostuser@hostmachine:~/docker-camodocal$
```

## Tips & Comments

* If an error about GTK appears, try the ``xhost +`` command in your host machine to enable connections to the X server from the docker container.
This will allow you to see the window displays from the Camodocal software.

* The docker image uses the next library versions: **Eigen 3.2.10**, **Ceres 1.11.0**, **OpenCV 3.4.7** as they have been reported to solve common encountered bugs during compilation and runtime.

* If runtime errors appear related to the Jacobian matrix not defined, try using the ``--opencv`` flag as part of the CAMODOCAL_COMMAND to set opencv as the module to detect the corners of the calibration checkerboads.



## References

In case of using this software for research activities, please reference this repository as well as the following paper. See the full list of papers related to CamOdoCal in its [repository](https://github.com/hengli/camodocal)):

```
- Lionel Heng, Paul Furgale, and Marc Pollefeys,
Leveraging Image-based Localization for Infrastructure-based Calibration of a Multi-camera Rig, Journal of Field Robotics (JFR), 2015.
```
