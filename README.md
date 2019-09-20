# slp_to_mp4

## Purpose
The slp_to_mp4 automates recording `.slp` files to `.mp4` files.

## Features
* Converts `.slp` files to `.mp4` files in 480p, 720p, and 1080p.
* Can convert as many `.slp` files at a time as your computer will allow.

## How Does It Work?
The script starts by creating duplicate dolphin instances. It creates a queue of `.slp` files to record, then leverages Slippi Desktop App to open to `.slp` file in Dolphin. Dolphin has the ability to create a video (`.avi` file) of the emulation. The `.avi` file is the scaled, trimmed, centered, and converted to `.mp4` files in an output directory.

## Prerequisites
* Slippi Desktop App
* dolphin-emu (slippi)
  * Linux: `sh -c "$(curl -Ls https://github.com/project-slippi/Slippi-FM-installer/raw/master/setup` or [slippi.gg/downloads](slippi.gg/downloads)
  * macOS/Windows: [slippi.gg/downloads](slippi.gg/downloads)
* A clean Melee ISO

## Warning
* Using this script will create as many dolphin duplicates specified in the script settings.
* This will be a resource intensive process, more so depending on parallelism and dolphin resolution scaling.
* This will be a storage intensive process, depending on the number of `.slp` files to be converted to `.mp4` files.
* This will apply configuration to Slippi Desktop App
* Only tested on Ubuntu 18.04 - Scripts for macOS and Windows will be coming.
* It is NOT recommended to run this script as root user.

## Setup
* Navigate to the folder you wish to install slp_to_mp4 and `git clone https://github.com/gfrankel97/slp_to_mp4.git`
* Install all requirements specified in `settings/bash_requirements` with your preferred package manager (`apt`, `brew`, etc.)
* Enter the settings in `settings/settings.json`
  ```json
  {
    "path_to_slp_files": "<PATH_TO_SLIPPI_FILES_TO_CONVERT_TO_MP4_FILES>",
    "path_to_dolphin_base": "<PATH_TO_DIRECTORY_THAT_CONTAINS_DOLPHIN_BIN>",
    "path_to_dolphin_temp": "<PATH_TO_CREATE_DOLPHIN_DUPLICATES_IN>",
    "path_to_slippi_desktop_app": "<PATH_TO_SLIPPI_DESKTOP_APP_BIN>",
    "path_to_slippi_desktop_app_data_dir": "<PATH_THAT_CONTAINS_SLIPPI_CONFIG>",
    "output_dir": "<DIRECTORY_TO_OUTPUT_MP4_FILES>",
    "resolution_scale_factor": "<RESOLUTION_SCALE_FACTOR>",
    "parallelism": "<NUMBER_OF_DOLPHIN_AND_FFMPEG_INSTANCES_TO_RUN_IN_PARALLEL>"
  }
  ```
    * Note:
      * `"resolution_scale_factor": "1"` is 480p
      * `"resolution_scale_factor": "2"` is 720p
      * `"resolution_scale_factor": "3"` is 1080p
    * `"parallelism"` is the number of Dolphin instances AND FFmpeg instances running at the same time. If there is a less Dolphin instances open than the settings for `"parallelism"`, then FFmpeg is converting the Dolphin dump to MP4. 
* Enter settings in `settings/slippi_desktop_app_settings.json`
  ```json
  {
    "previousVersion": "1.5.0-dev",
    "settings": {
        "isoPath": "<PATH_TO_MELEE_ISO>",
        "rootSlpPath": "<PATH_TO_SLIPPI_FILES>",
        "playbackDolphinPath": "<PATH_TO_DIRECTORY_THAT_CONTAINS_DOLPHIN_BIN>"
    }
  }
  ```
  * Note that `settings.playbackDolphinPath` and `path_to_dolphin_base` must match.
  * This is the same file that is in Slippi Desktop App `%AppData%` or `~/.config` and can be copied from there if you wish to keep other settings like Console Connections.
  
## Running the script
* From the directory you installed slp_to_mp4, run `bash slp_to_mp4.sh` or mark it as executable `chmod +x slp_to_mp4.sh` and run it with `./slp_to_mp4.sh`
* The script will validate your settings, check for files that should exist (like Melee ISO), and then begin the conversions.


## Extra Information
* My computer can comfortably convert 3 `.slp` files to `.mp4` at  files at a time at 720p.
  * Specs: 
    * CPU: AMD Ryzen 2700X
    * GPU: GeForce RTX 2070
* The decision to go with a settings file rather than command line flags was made because the settings wouldn't change often and it was annoying to keep typing out all command arguments.






## To Do
### Must Haves:
- Cross platform compatibility (need to test macOS and WSL)
- Filter handwarmers/short games
- Make recursive through folders and updates names accordingly
- Command line prompt for settings if they don't exist, then set them
- Create installer script


### Nice to Haves:
- Widescreen record
- Option to record all then convert all as opposed to record, convert, repeat.
- More error handling/checking
- Better Progress Bar
- Upload to YouTube


### Next Level:
- Specify config on command line for Dolphin so we dont have to create and keep track of which dolphin directory it's going in
- May not be possible due to slippi-desktop-app opening dolphin and Slippi r18 dolphin doesnt support command line config
  - Cut out Slippi Desktop App


### Credits
* [Inspiration and ground work](https://www.reddit.com/r/SSBM/comments/d0y0ag/send_slippi_a_proof_of_concept_for_massrecording/)
