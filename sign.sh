#!/bin/bash

KEYSDIR="$1"
OUTFILE="$2"

if [ -z "$KEYSDIR" ]; then
    KEYSDIR="$HOME/.android-certs"
fi

if [ -z "$OUTFILE" ]; then
    OUTFILE="signed-target_files.zip"
fi

#/media/iceows/Projets/iceows/arrow/build/tools/releasetools/
sign_target_files_apks -o -d $KEYSDIR \
    --extra_apks AdServicesApk.apk=$KEYSDIR/releasekey \
    --extra_apks FederatedCompute.apk=$KEYSDIR/releasekey \
    --extra_apks HalfSheetUX.apk=$KEYSDIR/releasekey \
    --extra_apks HealthConnectBackupRestore.apk=$KEYSDIR/releasekey \
    --extra_apks HealthConnectController.apk=$KEYSDIR/releasekey \
    --extra_apks OsuLogin.apk=$KEYSDIR/releasekey \
    --extra_apks SafetyCenterResources.apk=$KEYSDIR/releasekey \
    --extra_apks ServiceConnectivityResources.apk=$KEYSDIR/releasekey \
    --extra_apks ServiceUwbResources.apk=$KEYSDIR/releasekey \
    --extra_apks ServiceWifiResources.apk=$KEYSDIR/releasekey \
    --extra_apks WifiDialog.apk=$KEYSDIR/releasekey \
    $OUT/obj/PACKAGING/target_files_intermediates/*-target_files*.zip \
    $OUTFILE
