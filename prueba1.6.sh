ffmpeg -i $1 -vn -f f32le -acodec pcm_f32le -ac 2 output.raw

ffmpeg -f f32le -ac 2 -i output.raw audio.$2
