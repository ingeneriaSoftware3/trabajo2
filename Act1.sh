# sudo apt install ffmpeg
# video 4kvideo.mp4
# 

# 3.from library ffmpeg, change aspect ratio 16:9 to 4:3 and 4:3 to 16:9
#   ffmpeg -i input.mp4 -aspect 4:3 output.mp4
#   ffmpeg -i input.mp4 -aspect 16:9 output.mp4


# 5.from library ffmpeg, extract audio from video
#   ffmpeg -i input-video.avi -vn -acodec copy output-audio.aac