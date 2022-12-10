#!/bin/bash


#1.1 Cambio de resolución: A full HD, HD y un tamaño menor, a elección (800x600, 640x480, etc)
#ffmpeg -i $1 -vf scale=1280:720 -preset slow -crf 18 "output6."$OUT_FORMAT

# 1.3 extracción de un fragmento del video en tiempo
#ffmpeg -i $1 -map 0 -default_mode infer_no_subs -ss 00:03:00 -to 00:10:00 -c copy "Output."$2
arrIN=(${1//./ })
OUT_FORMAT=${arrIN[1]} 
FORMATOPIXELES=| exiftool 4kvideo.mp4 | grep 'Image Size'

echo $FORMATOPIXELES | sed 's:^::; /: / s:::'
# Set comma as delimiter
IFS=': '
echo $arrIN
#Read the split words into an array based on comma delimiter
readarray -d _ -t arr <<<"$FORMATOPIXELES"
VAR=| read $FORMATOPIXELES
read -a arrIN <<< "$VAR"
echo $arrIN

FORMATOPIXELES=${arrIN[1]}


ffmpeg -i $1 -vf crop=960:540:480:270 "recorte."$OUT_FORMAT