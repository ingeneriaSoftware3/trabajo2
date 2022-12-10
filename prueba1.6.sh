#!/bin/bash

ffmpeg -i $1 -vn -format f32le -acodec pcm_f32le -vn -c:a copy output.mp3


#ffmpeg -i output.raw -f f32le -ac 2 audio.$2

ffmpeg -i $1 -vf scale=1280:720 -preset slow -crf 18 output6.$2