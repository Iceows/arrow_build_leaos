#!/bin/bash

# # To increase swap file to 32 Go
# sudo bash
# dd if=/dev/zero of=/var/tmp/oomswap bs=1M count=32768
# chmod 600 /var/tmp/oomswap
# mkswap /var/tmp/oomswap
# swapon /var/tmp/oomswap
# 
# # To change swappiness to 70 (default 60)
# cat /proc/sys/vm/swappiness
# sysctl vm.swappiness=70
# vm.swappiness = 70
#

echo ""
echo "ArrowOS Buildbot - LeaOS version Android 13"
echo "Executing in 5 seconds - CTRL-C to exit"
echo "If you have killed process increase the swap file please"
echo ""
sleep 5

if [ $# -lt 1 ]
then
    echo "Not enough arguments - exiting"
    echo ""
    exit 1
fi

MODE=${1}
NOSYNC=false
GOOGLEAPPS=false

for var in "${@:2}"
do
    if [ ${var} == "nosync" ]
    then
        NOSYNC=true
    fi
   
    if [[ ${var} == *"64BG"* ]] 
    then
        GOOGLEAPPS=true
    fi
done



echo "Building with NoSync : $NOSYNC - Mode : ${MODE} - GoogleApps : ${GOOGLEAPPS}"



# Abort early on error
set -eE
trap '(\
echo;\
echo \!\!\! An error happened during script execution;\
echo \!\!\! Please check console output for bad sync,;\
echo \!\!\! failed patch application, etc.;\
echo\
)' ERR

START=`date +%s`
BUILD_DATE="$(date +%Y%m%d)"
WITHOUT_CHECK_API=true
ORIGIN_FOLDER="$(dirname "$(readlink -f -- "$0")")"


export OUT_DIR=/home/iceows/build/Arrow13

repo init -u https://github.com/ArrowOS/android_manifest.git -b arrow-13.1

prep_build() {
	echo "Preparing local manifests"
	rm -rf .repo/local_manifests
	mkdir -p .repo/local_manifests
	cp ./arrow_build_leaos/local_manifests_leaos/*.xml .repo/local_manifests
	echo ""

	echo "Syncing repos"
        repo sync --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j$(nproc --all)


	echo "Setting up build environment"
	source build/envsetup.sh &> /dev/null
	mkdir -p ~/build-output
	echo ""
}

apply_patches() {
    echo "Applying patch group ${1}"
    bash ./arrow_build_leaos/apply-patches.sh ./arrow_patches_leaos/patches/${1}
}

prep_device() {
    :
}

build_device() {
	:
}

finalize_device() {
    :
}


finalize_treble() {
    cd device/phh/treble
    bash generate.sh arrow
    cd ../../..
    	
    echo "Copying last arrow.mk"
    cp ./arrow_build_leaos/arrow.mk ./device/phh/treble/arrow.mk
    echo ""
    
    echo "remove anim charger last arrow.mk"
    rm -rf device/phh/treble/charger
}


build_treble() {
    case "${1}" in
        ("64BGS") TARGET=treble_arm64_bgS;;  
        ("64BGN") TARGET=treble_arm64_bgN;;
        ("64BGZ") TARGET=treble_arm64_bgZ;;
        ("64BVS") TARGET=treble_arm64_bvS;;
        ("64BVN") TARGET=treble_arm64_bvN;;
        ("64BVZ") TARGET=treble_arm64_bvZ;;
        (*) echo "Invalid target - exiting"; exit 1;;
    esac
    lunch ${TARGET}-userdebug

    make -j8 systemimage

    mv $OUT/system.img ~/build-output/Arrow-A13-$BUILD_DATE-${TARGET}.img
}

if ${NOSYNC}
then
    echo "ATTENTION: syncing/patching skipped!"
    echo ""
    echo "Setting up build environment"
    source build/envsetup.sh &> /dev/null
    echo ""

else

    echo ""
    prep_build
    
    echo "Applying patches"
    apply_patches trebledroid
    apply_patches iceows
    apply_patches nazim664
fi

finalize_treble
echo ""
    
for var in "${@:2}"
do
    if [ ${var} == "nosync" ]
    then
        continue
    fi
    echo "Starting build for ${MODE} ${var}"
    build_${MODE} ${var}
done
ls ~/build-output | grep 'Arrow' || true

END=`date +%s`
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))
echo "Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo ""
