# pwsp-opendeck-playlists
This repository contains a set of scripts intended for use with OpenDeck software to play audio playlists. Currently, the Elgato software does not support Linux systems, and that includes the default audio player included with the software that can play a shuffled playlist. Using these scripts and a couple of Linux packages, you can easily set up macros on OpenDeck to play a shuffled playlist, complete with controls for pausing, skipping, etc.

## Prerequisites
These scripts were written on a CachyOS Linux system. That said, most of the commands used are simple bash commands included on any Linux device.

That said, first, your device must be able to read bash commands and execute bash scripts.

Audio is played using Pipewire Soundpad. It may be possible to rewrite it to use something like Strawberry, but that is for future me or you to figure out. :) Make sure you can execute PWSP via the command line. The Pipewire Soundpad repository can be found here:
https://github.com/arabianq/pipewire-soundpad

There is a music playlist selector script that uses zenity. Zenity was included in my installation, but some distributions may not include it. If you are using OpenDeck, I would be shocked if your distribution doesn't include it. If you are running a distribution that doesn't include zenity and are happy with it, you are probably a better power user than I am. :)

While not required for any of these to work, I did make these specifically to have functionality in OpenDeck. The repository for OpenDeck can be found here:
https://github.com/nekename/OpenDeck

## Creating a Playlist
