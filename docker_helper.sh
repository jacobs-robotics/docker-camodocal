#!/bin/bash

# initialize global variables
containerName=camodocal
containerTag=1.0
GREEN='\033[1;32m'
BLUE='\e[34m'
NC='\033[0m' # no color
user=`id -u -n`
userid=`id -u`
group=`id -g -n`
groupid=`id -g`
myhostname=hostcamodocal
no_proc=`nproc`
flag_issue_command=0

if [ $1 = "--help" ];then
	echo -e "${GREEN}>>> Possible commands:\n ${NC}"
	echo -e "${BLUE}--build		--- Build an image based on DockerFile in current dir\n"
	echo -e "${BLUE}--run-rm	--- Create--> run --> execute command --> remove and exit container${NC}\n"
	echo -e "${BLUE}--run-keep	--- Create--> run --> enter container and bash (container is removed when user exits the container)${NC}\n"
	flag_issue_command=1
fi

if [ "$1" = "--build" ]; then
	echo -e "${GREEN}>>> Building camodocal image ...${NC}"
	docker build -t ${user}/${containerName}:${containerTag} .
	flag_issue_command=1
fi

if [ "$1" = "--run-rm" ]; then

	echo -e "${GREEN}>>> Initializing "${containerName}" container...${NC}"
	
	#check for host devices
	DRI_ARGS=""
	if [ -d /dev/dri ]; then

		for f in `find /dev/dri -type c`; do
				DRI_ARGS="$DRI_ARGS --device=$f"
		done

		DRI_ARGS="$DRI_ARGS --privileged"
	fi


	docker run --rm -it --gpus all \
	$DRI_ARGS \
	--name="${containerName}" \
	--hostname="${myhostname}" \
	--net=default \
	--env="DISPLAY" \
	--env="QT_X11_NO_MITSHM=1" \
	--workdir="/root" \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	--volume=`pwd`/input_data:/root/input_data:rw \
	--volume=`pwd`/output_data:/root/output_data:rw \
	${user}/${containerName}:${containerTag} /bin/bash -c "cd /root/camodocal/build/bin && ./$2 && chmod -R a+rw /root/output_data/*"
	rc=$?; if [[ $rc != 0 && $rc != 1 ]]; then exit $rc; fi

	flag_issue_command=1
fi

if [ "$1" = "--run-keep" ]; then

	echo -e "${GREEN}>>> Initializing "${containerName}" container...${NC}"
	
	#check for host devices
	DRI_ARGS=""
	if [ -d /dev/dri ]; then

		for f in `find /dev/dri -type c`; do
				DRI_ARGS="$DRI_ARGS --device=$f"
		done

		DRI_ARGS="$DRI_ARGS --privileged"
	fi


	docker run --rm -it --gpus all \
	$DRI_ARGS \
	--name="${containerName}" \
	--hostname="${myhostname}" \
	--net=default \
	--env="DISPLAY" \
	--env="QT_X11_NO_MITSHM=1" \
	--workdir="/root" \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	--volume=`pwd`/input_data:/root/input_data:rw \
	--volume=`pwd`/output_data:/root/output_data:rw \
	${user}/${containerName}:${containerTag} /bin/bash -c "cd /root/camodocal/build/bin && /bin/bash"
	rc=$?; if [[ $rc != 0 && $rc != 1 ]]; then exit $rc; fi

	flag_issue_command=1
fi

if [ "$1" == "--terminal" ] || [ "$1" == "-t" ]; then
    echo -e "${GREEN}>>> Entering console in container ${container_name} ...${NC}"
    docker exec -ti ${container_name} /bin/bash -c "cd /root/camodocal/build/bin && /bin/bash"
    flag_issue_command=1
fi

if [[ $flag_issue_command == 0 ]]; then
    echo -e "${RED}>>>ERROR: Unknown or badly placed parameter ...$NC" >&2
    exit 1
fi
