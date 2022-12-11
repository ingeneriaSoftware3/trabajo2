#!/bin/bash

# Argumentos a pedir: Nombre de archivo, si va a correr una, la otra o ambas pruebas (valores 1, 2, 3), número de hilos sobre los cuales correr el programa mpicc
#			    tamaño de salida 1.1, tiempo de inicio de corte 1.3, tiempo final de corte 1.3, posición para el corte punto 1 en , posición para el corte punto 2,
#			    formato de salida para 1.6

# Hay que realizar las verificaciónes de cada argumento de entrada para lanzar error o cortar la ejecución 

#Separar extensión del archivo de video para que haya consistencia en la extensión de salida
arrIN=(${1//./ })
OUT_FORMAT=${arrIN[1]} 
#Extracción 
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
# ----if para ver si se corre la prueba 1, 2 o ambas-----

# if $<índice donde quede la variable> == 1 || 3

#1.1 Cambio de resolución: A full HD, HD y un tamaño menor, a elección (800x600, 640x480, etc)
#ffmpeg -i $1 -vf scale=1280:720 -preset slow -crf 18 "output6."$OUT_FORMAT

#1.2 Cambio de tasa de aspecto 16:9 a 5:4 y viceversa.
ffmpeg -i $1 -aspect 4:3 output4_3.mp4
ffmpeg -i $1 -aspect 16:9 output16_9.mp4

# 1.3 extracción de un fragmento del video en tiempo
#ffmpeg -i $1 -map 0 -default_mode infer_no_subs -ss 00:03:00 -to 00:10:00 -c copy "Output."$2

# 1.4 Recorte de un área rectangular del video, escogiendo punto superior izquierdo e inferior derecho
ffmpeg -i $1 -vf crop=960:540:480:270 "recorte."$OUT_FORMAT

#1.5 Extracción de audio de parte del video a formato raw
ffmpeg -i input-video.avi -vn -acodec copy output-audio.aac

#1.6 Codificación del audio a flac/ogg/mp3
ffmpeg -f f32le -ac 2 -i $1 audio.$<variable en la que quede el parámetro>

# if $<índice donde quede la variable> == 2 || 3

#2 Programa mpicc

