#!/bin/sh

# Make a movie from individual screenshots
# (C) Michael Renner <michael.renner@gmx.de>
# DD0UL in Munich

WORKDIR=~/Projects/wsprfilm
DATUM=$(date +%d.%m.%Y)
mkdir -p ${WORKDIR}/${DATUM}
cd ${WORKDIR}/${DATUM}

sleep 30
C=1
BAND="20m 100mW"
POWER="5m random wire ant"
INTERVAL=300
YEAR=$(date +%Y)
# For a period of 300s with 288 screenshots (300s * 288 = 86400s) the film includes 24h (60s * 60m * 24h = 86400s)
COUNT=288

while [ ${C} -lt ${COUNT} ] ; do
	EPOCHE=$(date +%s)
	C=$(echo ${C} + 1 | bc)
	scrot ${EPOCHE}.png
	# UTC time
	DATE=$(date -u +%d.%m.%Y" "%H:%M)

	# Cut the image. "1560x650" is the geometrie, "288+396" is the offset
	/usr/bin/convert -crop 1560x650+288+396 ${EPOCHE}.png tmp_crop.jpg

	# Lable the picture. "NorthWest" and "1200,140" bzw. "1200,100" stand for the position (the upper left corner)
	/usr/bin/convert tmp_crop.jpg -gravity NorthWest -fill red -font Times-Bold -pointsize 36 -draw "text 1200,180 '${POWER}'" tmp_power.jpg
	/usr/bin/convert tmp_power.jpg -gravity NorthWest -fill red -font Times-Bold -pointsize 36 -draw "text 1200,140 '${BAND}'" tmp_band.jpg
	/usr/bin/convert tmp_band.jpg -gravity NorthWest -fill red -font Times-Bold -pointsize 36 -draw "text 1200,100 '${DATE}'" ${EPOCHE}.jpg
	rm tmp_crop.jpg tmp_band.jpg
        sleep ${INTERVAL}
        C=$(echo ${C} + 1 | bc)
done
ls -ltr *.jpg | while read line ; do
	S=$(echo ${line} | awk '{ print $5 }')
	F=$(echo ${line} | awk '{ print $9 }')
	D=$(echo ${line} | awk '{ print $8 }')
	echo "Variablen: S=${S}, F=${F}, D=${D}"
	/usr/bin/convert ${F} -gravity NorthWest -font Times-Bold -pointsize 36 -draw "text 1600,500 '${D}'" 2_${F}

	# replace empty pictures
	# To use this feature create a nice image with "your" file dimensions
	# maybe Selenium can do this task much better
	#if [ ${S} -lt 1000000 ] ; then
	#	cp -p NoSignal.png ${F}
	#	echo $F wurde ersetzt
	#fi
	#/usr/bin/convert -crop 1300x640+500+400 2_${F} 1_${F} 

done

#/usr/bin/ffmpeg -framerate 2 -pattern_type glob -i '2_*.jpg'  -c:v libx264 -r 30 -pix_fmt yuv420p -vf scale=1024x768 -y wspr_80m.mp4
/usr/bin/ffmpeg -framerate 1/1 -pattern_type glob -i '2_*.jpg'  -c:v libx264 -r 30 -pix_fmt yuv420p -vf scale=1560x560 -y wspr_${DATUM}.mp4

rm -f 2_*
exit


# Auswertung des Histograms:
# cat rohliste.txt | awk '{ print $11 }' | while read line ; do echo ${line::-2}00 ; done | sort | uniq -c  | awk '{ print $2","$1 }' | sort -n > histogram.csv
# (C) Michael Renner <dd0ul@darc.de>
