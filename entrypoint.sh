#!/bin/sh

cd usr/local/share/scrcpy/

adb connect 192.168.0.194:5555

adb push /usr/local/share/scrcpy/scrcpy-server /data/local/tmp/scrcpy-server-manual.jar
adb forward tcp:1111 localabstract:scrcpy

adb shell CLASSPATH=/data/local/tmp/scrcpy-server-manual.jar app_process / com.genymobile.scrcpy.Server 2.6.1 \
	tunnel_forward=true \
	audio=false \
	control=false \
	cleanup=false \
	raw_stream=true \
	camera_size=1280x720 \
	video_source=camera \
	camera_high_speed=true \
	camera_fps=120

exit 1
