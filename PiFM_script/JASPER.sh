#!/bin/sh

#sudo avconv -i /home/pi/radio/tetris.mp3 -f ogg - | sox -t ogg - -t wav - | /home/pi/rpitx/./pifmrds -freq 103.1 -audio -
#/home/pi/rpitx/./pifmrds -freq 103.1 -audio jasper_verjaardag_radio.wav
#sox --norm -t ogg /home/pi/radio/dj.ogg -c 2 -t wav - firfit /home/pi/radio/75usPreEmphasis.ff | /home/pi/rpitx/./pifmrds -freq 103.1 -audio -

sleep 30

/home/pi/radio/./wav_fm /home/pi/radio/jasper_verjaardag_radio.wav 103100000
exit
