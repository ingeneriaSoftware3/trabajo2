#!/bin/bash

#Separar extensión del archivo de video para que haya consistencia en la extensión de salida

DONE="0"

if ((($2 == "1" | $2 == "3") & $# == "9"))
then
    arrIN=(${1//./ })
    OUT_FORMAT=${arrIN[1]} 
    #Extracción de rangos para los parámetros
    WIDE_INFO=$(exiftool 4kvideo.mp4 | grep 'Image Width'  )
    HEIGHT_INFO=$(exiftool 4kvideo.mp4 | grep 'Image Height')
    DURACIONVIDEO_INFO=$(exiftool 4kvideo.mp4 | grep 'Media Duration')
    #Rango tamaño del video
    arrIN2=(${WIDE_INFO//:/ })
    SIZE_WIDE=${arrIN2[2]}
    arrIN3=(${HEIGHT_INFO//:/ })
    SIZE_HEIGHT=${arrIN3[2]}
    #Rango duración del video
    arrIN4=(${DURACIONVIDEO_INFO//:/ })
    DURACIONVIDEO=(${arrIN4[2]})

    #---------------------DEBUG-----------------------
    # echo "Duración del video: "$DURACIONVIDEO
    # echo "Alto del video en pixeles: "$SIZE_WIDE
    # echo "Ancho del video en pixeles: "$SIZE_HEIGHT
    # echo $1
    #-------------------------------------------------

    #1.1 Cambio de resolución: A full HD, HD y un tamaño menor, a elección (800x600, 640x480, etc)
    arrIN4=(${4//x/ })
    WIDE=${arrIN4[0]}
    echo $WIDE
    HEIGHT=${arrIN4[1]}
    if (($WIDE <= $SIZE_WIDE))
    then
        if (($HEIGHT <= $SIZE_HEIGHT))
        then
            ffmpeg -i $1 -vf scale=$4 -preset slow -crf 18 "output"$4"."$OUT_FORMAT
        else
            echo "Wrong size "$4", size must be equal or less than the original resolution "$SIZE_WIDE"x"$SIZE_HEIGHT
        fi
    else
        echo "Wrong size "$4", size must be equal or less than the original resolution "$SIZE_WIDE"x"$SIZE_HEIGHT
    fi
    1.2 Cambio de tasa de aspecto 16:9 a 5:4 y viceversa.
    ffmpeg -i $1 -aspect 4:3 output4_3.$OUT_FORMAT
    ffmpeg -i $1 -aspect 16:9 output16_9.$OUT_FORMAT

    # 1.3 extracción de un fragmento del video en tiempo
    arrIN5=(${5//:/ })
    arrIN6=(${6//:/ })
    arrIN7=(${DURACIONVIDEO//./ })
    DURACIONVIDEO_INT=${arrIN7[0]}
    declare -i START_TIME=$((${arrIN5[2]}+${arrIN5[1]}*60+${arrIN5[0]}*60*60))
    declare -i END_TIME=$((${arrIN6[2]}+${arrIN6[1]}*60+${arrIN6[0]}*60*60))

    #--------------------------------DEBUG--------------------------------------
    # echo $START_TIME
    # echo $END_TIME
    # echo $DURACIONVIDEO_INT
    #echo ((($START_TIME <= $DURACIONVIDEO) & ($END_TIME <= $DURACIONVIDEO)))
    #---------------------------------------------------------------------------

    if (($START_TIME <= $DURACIONVIDEO_INT & $END_TIME <= $DURACIONVIDEO_INT))
    then
        ffmpeg -i $1 -map 0 -default_mode infer_no_subs -ss $5 -to $6 -c copy "Output_Fragment."$OUT_FORMAT
    else
        echo "Wrong cutting time starting in: "$5" and enging in: "$6", the start and end of the cut must be less or equal than the original lenght: "$DURACIONVIDEO
    fi
    # 1.4 Recorte de un área rectangular del video, escogiendo punto superior izquierdo e inferior derecho
    if (($7 <= $SIZE_WIDE & $8 <= $SIZE_HEIGHT))
    then
        ffmpeg -i $1 -vf crop=$7":"$8 "recorte."$OUT_FORMAT
    else
        echo "Wrong size "$7" or "$8", size of both points must be equal or less than the original resolution "$SIZE_WIDE"x"$SIZE_HEIGHT
    fi
    #1.5 Extracción de audio de parte del video a formato raw
    ffmpeg -i $1 -vn -f f32le -acodec pcm_f32le -ac 2 output-audio.raw

    #1.6 Codificación del audio a flac/ogg/mp3
    ffmpeg -f f32le -ac 2 -i output-audio.raw output-audio.$9
    DONE="1"
fi

if (($2 != "1" & (($2 == "2" & $# == "3") | ($2 == "3" & $# == 9))))
then
    echo "Programa mpicc en camino..."
else
    if (($DONE == "0"))
    then
        echo "USAGE: bash Unificaion\ de\ respuestas.bash [dirección al archivo de video mp4] [Si corre la prueba de transcodificación (1), de algoritmo distribuido (2), o ambas(3)]"
        echo "                                                        [número de hilos sobre los cuales correr el algoritmo distribuído (si no aplica = 0, si desea todos = -1)]"
        echo "                                                        [tamaño de salida del video (800x600 | 640x480 | etc ...)] [tiempo de inicio del corte al video] [tiempo de corte al video]"
        echo "                                                        [posición superior izquerda para el recorte del video] [posición inferior derecha para el recorte del video]"
        echo "                                                        [formato de salida para el video (ogg/mp3/flac)]"
        echo "            Ejemplos:"
        echo "                    Ejecución de sólo las pruebas de transcodificación:"
        echo "                    bash Unificaion\ de\ respuestas.bash 4kvideo.mp4 1 0 800x600  00:03:00  00:05:00 960:540 480:270 mp3"
        echo ""
        echo "                    Ejecución de sólo la prueba de algoritmo distribuído:"
        echo "                    bash Unificaion\ de\ respuestas.bash 4kvideo.mp4 2 -1"
        echo ""
        echo "                    Ejecución de ambas pruebas:"
        echo "                    bash Unificaion\ de\ respuestas.bash 4kvideo.mp4 3 4 1280x1024 00:00:00  01:02:00 0:0 680:270 ogg"
    fi
fi

