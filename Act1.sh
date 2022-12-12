# sudo apt install ffmpeg
# video 4kvideo.mp4
# 

# 3.from library ffmpeg, change aspect ratio 16:9 to 4:3 and 4:3 to 16:9
#   ffmpeg -i $1 -aspect 4:3 output_4_3.mp4
#   ffmpeg -i $1 -aspect 16:9 output_16_9.mp4


# 5.from library ffmpeg, extract audio from video
ffmpeg -i $1 -vn -f f32le -acodec pcm_f32le -ac 2 output-audio.raw
#ffmpeg -i $1 -vn -acodec copy output-audio.raw
