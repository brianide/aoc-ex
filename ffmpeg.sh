ffmpeg -f pgm_pipe -y -i - -crf 8 -vcodec libvpx -vf scale="iw*4:ih*4" -sws_flags neighbor $1
