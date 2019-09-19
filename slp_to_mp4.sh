#!/bin/bash
COLOR_BLUE='\033[0;34m'
COLOR_BLACK='\033[30m'
COLOR_CYAN='\033[0;36m'
COLOR_DARK_GRAY='\033[0;90m'
COLOR_GREEN='\033[0;32m'
COLOR_LIGHT_BLUE='\033[1;34m'
COLOR_LIGHT_CYAN='\033[1;36m'
COLOR_LIGHT_GRAY='\033[0;37m'
COLOR_LIGHT_GREEN='\033[1;32m'
COLOR_LIGHT_MAGENTA='\033[1;35m'
COLOR_LIGHT_RED='\033[1;31m'
COLOR_LIGHT_YELLOW='\033[1;33m'
COLOR_MAGENTA='\033[0;35m'
COLOR_RED='\033[0;31m'
COLOR_WHITE='\033[1;37m'
COLOR_YELLOW='\033[0;33m'
COLOR_NONE='\033[0m'


function validate_and_set_settings {
    path_to_slp_files=$(jq -r .path_to_slp_files $(pwd)/settings/settings.json)
    if [[ $path_to_slp_files = null ]]; then
        echo -e "\t[${COLOR_RED}Setting Missing${COLOR_NONE}]: Setting not found (check settings.json - path_to_slp_files)"
        exit 1
    fi

    output_dir=$(jq -r .output_dir $(pwd)/settings/settings.json)
    if [[ $output_dir = null ]]; then
        echo -e "\t[${COLOR_RED}Setting Missing${COLOR_NONE}]: Setting not found (check settings.json - output_dir)"
        exit 1
    fi
    export output_dir=$output_dir

    path_to_dolphin_base=$(jq -r .path_to_dolphin_base $(pwd)/settings/settings.json)
    if [[ $path_to_dolphin_base = null ]]; then
        echo -e "\t[${COLOR_RED}Setting Missing${COLOR_NONE}]: Setting not found (check settings.json - path_to_dolphin_base)"
        exit 1
    fi

    path_to_dolphin_temp=$(jq -r .path_to_dolphin_temp $(pwd)/settings/settings.json)
    if [[ $path_to_dolphin_temp = null ]]; then
        echo -e "\t[${COLOR_RED}Setting Missing${COLOR_NONE}]: Setting not found (check settings.json - path_to_dolphin_temp)"
        exit
    fi
    export path_to_dolphin_temp=$path_to_dolphin_temp

    path_to_slippi_desktop_app=$(jq -r .path_to_slippi_desktop_app $(pwd)/settings/settings.json)
    if [[ $path_to_slippi_desktop_app = null ]]; then
        echo -e "\t[${COLOR_RED}Setting Missing${COLOR_NONE}]: Setting not found (check settings.json - path_to_slippi_desktop_app)"
        exit 1
    fi
    export path_to_slippi_desktop_app=$path_to_slippi_desktop_app

    path_to_slippi_desktop_app_data_dir=$(jq -r .path_to_slippi_desktop_app_data_dir $(pwd)/settings/settings.json)
    if [[ $path_to_slippi_desktop_app_data_dir = null ]]; then
        echo -e "\t[${COLOR_RED}Setting Missing${COLOR_NONE}]: Setting not found (check settings.json - path_to_slippi_desktop_app_data_dir)"
        exit 1
    fi
    export path_to_slippi_desktop_app_data_dir=$path_to_slippi_desktop_app_data_dir

    parallelism=$(jq -r .parallelism $(pwd)/settings/settings.json)
    if [[ $parallelism = null ]]; then
        echo -e "\t[${COLOR_YELLOW}Setting Missing${COLOR_NONE}]: Setting not found (check settings.json - parallelism, defaulting to ${COLOR_BLUE}1${COLOR_NONE})"
        parallelism="1"
    fi
    export parallelism=$parallelism

    resolution_scale_factor=$(jq -r .resolution_scale_factor $(pwd)/settings/settings.json)
    if [[ $resolution_scale_factor = null ]]; then
        echo -e "\t[${COLOR_YELLOW}Setting Missing${COLOR_NONE}]: Setting not found (check settings.json - resolution_scale_factor), defaulting to ${COLOR_BLUE}2${COLOR_NONE}"
        resolution_scale_factor="2"
    fi

    _log_level=$(jq -r .log_level $(pwd)/settings/settings.json)
    if [[ $_log_level = null ]]; then
        echo -e "\t[${COLOR_YELLOW}Setting Missing${COLOR_NONE}]: Setting not found (check settings.json - log_level), defaulting to ${COLOR_BLUE}warn${COLOR_NONE}"
        _log_level="warn"
    fi

    if [[ ! -f "$(pwd)/settings/ini_templates/dolphin_settings.ini" ]]; then
        echo -e "\t[${COLOR_RED}File Missing${COLOR_NONE}]: ini_templates/dolphin_settings.ini"
        exit 1
    fi

    if [[ ! -f "$(pwd)/settings/ini_templates/dolphin_gfx_settings.ini" ]]; then
        echo -e "\t[${COLOR_RED}File Missing${COLOR_NONE}]: ini_templates/dolphin_gfx_settings.ini"
        exit 1
    fi

    if [[ ! -f "$(pwd)/settings/slippi_desktop_app_settings.json" ]]; then
        echo -e "\t[${COLOR_RED}File Missing${COLOR_NONE}]: slippi_desktop_app_settings.json"
        exit 1
    else
        dolphin_bin=$(jq -r .settings.playbackDolphinPath $(pwd)/settings/slippi_desktop_app_settings.json)/dolphin-emu
        if [[ $dolphin_bin = null ]]; then
            echo -e "\t[${COLOR_RED}Setting Missing${COLOR_NONE}] Setting not found (check slippi_desktop_app_settings.json - settings.playbackDolphinPath)"
            exit 1
        else
            if [[ ! -f ${dolphin_bin} ]]; then
                echo -e "\t[${COLOR_RED}File Missing${COLOR_NONE}]: Dolphin Binary not found (check your settings in: slippi_desktop_app_settings.json)"
                exit 1
            fi
        fi

        melee_iso=$(jq -r .settings.isoPath $(pwd)/settings/slippi_desktop_app_settings.json)
        if [[ $melee_iso = null ]]; then
            echo -e "\t[${COLOR_RED}Setting Missing${COLOR_NONE}] in: slippi_desktop_app_settings.json - settings.isoPath"
            exit 1
        else
            if [[ ! -f ${melee_iso} ]]; then
                echo -e "\t[${COLOR_RED}File Missing${COLOR_NONE}]: ${melee_iso}"
                exit 1
            fi
        fi
        
    fi

    echo -e "\t[${COLOR_GREEN}Settings Validated${COLOR_NONE}]: $(pwd)/settings/settings.json"
}

function init {
    echo -e "[${COLOR_GREEN}Script Init - Start${COLOR_NONE}]"
    #Kill running Slippi Desktop App and Dolphin instances
    ps axf | grep slippi-desktop-app | grep -v grep | awk '{print "kill -9 " $1}' | sh | at now &> /dev/null
    ps axf | grep dolphin-emu | grep -v grep | awk '{print "kill -9 " $1}' | sh | at now &> /dev/null

    #Validate settings and set variables
    validate_and_set_settings

    #Copy Slippi Desktop App script settings to Slippi Desktop App
    cp "$(pwd)/settings/slippi_desktop_app_settings.json" "${path_to_slippi_desktop_app_data_dir}/Settings"
    echo -e "\t[${COLOR_GREEN}Settings Copied${COLOR_NONE}]: Copy settings/slippi_desktop_app_settings.json to Slippi Desktop App directory"

    #Copy Dolphin playback script settings to Dolphin
    cp "$(pwd)/settings/ini_templates/dolphin_settings.ini" "${path_to_dolphin_base}/User/Config/Dolphin.ini"
    echo -e "\t[${COLOR_GREEN}Settings Copied${COLOR_NONE}]: Copy settings/ini_templates/dolphin_settings.ini to Dolphin"



    #Copy Dolphin playback GFX settings to Dolphin
    local efb_scale=$(($resolution_scale_factor * 2))
    cp "$(pwd)/settings/ini_templates/dolphin_gfx_settings.ini" "${path_to_dolphin_base}/User/Config/GFX.ini"
    sed -i".bak" "s@EFBScale = .*@EFBScale = $efb_scale@" "${path_to_dolphin_base}/User/Config/GFX.ini"
    echo -e "\t[${COLOR_GREEN}Settings Copied${COLOR_NONE}]: Copy GFX settings/ini_templates/dolphin_gfx_settings.ini to Dolphin"

    rm -rf temp
    mkdir temp

    find ${path_to_slp_files} -name *.slp > temp/recording_jobs.txt
    echo -e "\t[${COLOR_GREEN}Recording List Created${COLOR_NONE}]: Created temp/recording_jobs.txt (a list of slp files to record):"
    sed "s:^:\t\t:" temp/recording_jobs.txt

    export -f validate_and_set_settings
    export -f clean_dump_dir
    export -f set_slippi_desktop_app_parallel_dolphin_bin
    export -f set_frames_in_slippi_file
    export -f record_file
    export -f set_video_filter
    export -f ini_replace
    export -f set_path_to_parallel_dolphin
    export -f convert_wav_and_avi_to_mp4

    set_video_filter
 
    echo -e "[${COLOR_GREEN}Script Init - Complete${COLOR_NONE}]\n"
    
}

function clean_dump_dir {
    local dolphin_path=$1
    rm -f "${dolphin_path}/User/Logs/render_time.txt"
    rm -f "${dolphin_path}/User/Dump/Frames/*"
    rm -f "${dolphin_path}/User/Dump/Audio/*"
    rm -f "${dolphin_path}/User/Dump/Audio/dspdump.wav"
    rm -rf ${output_dir}/temp
    mkdir -p "${dolphin_path}/User/Dump/Frames"
    mkdir ${output_dir}/temp
}

function set_slippi_desktop_app_parallel_dolphin_bin {
    local dolphin_path=$1
    cat $(pwd)/settings/slippi_desktop_app_settings.json | jq -r --arg current_parallel_dolphin_path "$dolphin_path" '.settings.playbackDolphinPath = $current_parallel_dolphin_path' > "${path_to_slippi_desktop_app_data_dir}/Settings"
}

function set_frames_in_slippi_file {
    local slp_file=$1
    local _result=$2

    local offset=$(strings -d -t d -n 9 $slp_file | grep -A1 'lastFramel' | grep -v "lastFramel"| cut -d: -f1 | cut -d ' ' -f1)
    offset="$(($offset - 4))"
    if [ "$offset" -eq -4 ]; then
        offset=$(strings -d -t d -n 9 $slp_file | grep -A1 'lastFramel' | grep -v "lastFramel" | cut -d ' ' -f2 | cut -d: -f1 | cut -d ' ' -f1)
        offset="$(($offset - 4))"
    fi
    local a=$(xxd -p -l1 -s $offset $slp_file)
    offset="$(($offset + 1))"
    local b=$(xxd -p -l1 -s $offset $slp_file)
    local frame_count="$((16#$a * 256 + 16#$b))"
    local d="$((10 + $frame_count / 60))"

    current_slippi_file_length=$frame_count
}

function record_file {
    global_start_counter=$SECONDS
    set_path_to_parallel_dolphin
    local slp_file=$1
    local base_file_name=$(basename $slp_file)
    local dolphin_path=$current_parallel_dolphin_path
    local frames_file="${dolphin_path}/User/Logs/render_time.txt"
    local dump_folder="${dolphin_path}/User/Dump"

    if [ ! -f $frames_file ]; then
        echo -e "\t[${COLOR_RED}DEBUG${COLOR_NONE}]: Frames File does NOT Exist"
    fi

    echo -e "\t[${COLOR_GREEN}File Recording - Start${COLOR_NONE}]: ${base_file_name}.mp4"

    set_frames_in_slippi_file $slp_file frame_count
    local frame_count=$current_slippi_file_length

    # Launch slippi desktop app so it will launch dolphin, then kill slippi desktop app
    clean_dump_dir $dolphin_path
    set_slippi_desktop_app_parallel_dolphin_bin $dolphin_path
    
    #Done to hide annoying slippi desktop app output
    $path_to_slippi_desktop_app $slp_file > /dev/null 2>&1 & sleep 5
    local slippi_desktop_app_process=$(ps axf --sort time | grep slippi-desktop-app | grep -v grep | awk 'NR==1{print $1}')
    while [ -z $slippi_desktop_app_process ]; do
        sleep 1s
        slippi_desktop_app_process=$(ps axf --sort time | grep slippi-desktop-app | grep -v grep | grep $slp_file | awk 'NR==1{print $1}')
    done
    # kill -9 $slippi_desktop_app_process > /dev/null 2>&1
    kill $!
    wait $! 2>/dev/null

    # Wait for the render_time.txt file to be created by dolphin
    while ! test -f $frames_file; do 
        sleep 1s
        echo "Waiting in job: ${file} for file ${frames_file}"
    done


    local current_frame=$(grep -vc '^$' $frames_file)
    if [ $? -ne 0 ]; then
        echo -e "\t[${COLOR_RED}Error${COLOR_NONE}]: Problem Current Frame: $current_frame"
    fi

    local frame_count="$(($frame_count + 298))"

    if [ -z "$current_frame" ]; then
        echo -e "\t[${COLOR_RED}Error${COLOR_NONE}]: Current Frame is empty: $current_frame"
    fi

    if [ -z "$frame_count" ]; then
        echo -e "\t[${COLOR_RED}Error${COLOR_NONE}]: Frame Count is empty: $current_frame"
    fi

    # Run until the number of frames rendered is the length of the slippi file
    local start_counter=$SECONDS
    local timeout=$((SECONDS+490))
    while [ $current_frame -lt $frame_count ]; do
        if [ ! -f $frames_file ]; then
            echo -e "\t[${COLOR_RED}Error${COLOR_NONE}]: Frames File does NOT Exist"
        fi
        current_frame=$(grep -vc '^$' $frames_file)
        if [ $? -ne 0 ]; then
            echo -e "\t[${COLOR_RED}Error${COLOR_NONE}]: Frames File's current frames are empty"
            cat $frames_file
        fi

        #Timeout loop after 8 minutes
        if [ $SECONDS -gt $timeout ]; then
            break
        fi
    done
    local counter=$(($SECONDS-$start_counter))
    echo -e "\t[${COLOR_GREEN}File Recording - Video Encoding${COLOR_NONE}]: Dumping Slippi file to AVI for: ${COLOR_BLUE}${counter}s${COLOR_NONE}"

    local dolphin_process=$(ps axf --sort time | grep dolphin-emu | grep -v grep | grep $dolphin_path | awk '{print $1}')
    $(kill -9 $dolphin_process > /dev/null 2>&1)

    local current_avi_file="${dump_folder}/Frames/$(ls -t ${dump_folder}/Frames/ | head -1)"
    local current_audio_file_wav="${dump_folder}/Audio/dspdump.wav"

    base_file_name=$(echo $base_file_name | cut -d'.' -f1)
    convert_wav_and_avi_to_mp4 $current_avi_file $current_audio_file_wav $base_file_name
    echo -e "\t[${COLOR_GREEN}File Recording - Finished${COLOR_NONE}]: ${base_file_name}.mp4\n"
    
}

function set_video_filter {
    local log_resolution=""
    case ${resolution_scale_factor} in 
        "1")
            video_filter="scale=584:480,pad=853:480:135"
            log_resolution="853x480 (SD)"
            ;;
        "2")
            video_filter="scale=876:720,pad=1280:720:202"
            log_resolution="1280x720 (HD 720p)"
            ;;
        "3")
            video_filter="scale=1314:1080,pad=1920:1080:303"
            log_resolution="1920x1080 (HD 1080p)"
            ;;
        *)
            echo -e "[${COLOR_GREEN}Error Scaling - File Recording${COLOR_NONE}]: Scale factor must be one of: '1', '2', '3'"
            exit 1
            ;;
    esac
    export video_filter=$video_filter
    echo -e "\t[${COLOR_GREEN}FFmpeg Filter Set${COLOR_NONE}]: to ${COLOR_BLUE}${log_resolution}${COLOR_NONE}"
}

function ini_replace {
    local path_to_instance=$1
    local path_to_instance_dolphin_dump="${path_to_instance}/User/Dump"
    echo -e "\t[${COLOR_GREEN}Settings Replace - Start${COLOR_NONE}]:  ${path_to_instance}/User/Config/Dolphin.ini"
    sed -i".bak" "s@DumpPath = .*@DumpPath = $path_to_instance_dolphin_dump@" "${path_to_instance}/User/Config/Dolphin.ini"
    echo -e "\t[${COLOR_GREEN}Settings Replace - Finish${COLOR_NONE}]: ${path_to_instance}/User/Config/Dolphin.ini"
}

function init_parallelism {
    echo -e "[${COLOR_GREEN}Init Parallelism - Start${COLOR_NONE}]"
    for ((index=1;index<=$parallelism;index++)); do
        rm -rf "${path_to_dolphin_temp}/playback_${index}"
        cp -rf "${path_to_dolphin_base}" "${path_to_dolphin_temp}/playback_${index}"
        ini_replace "${path_to_dolphin_temp}/playback_${index}"
    done

    echo -e "[${COLOR_GREEN}Init Parallelism - Finish${COLOR_NONE}]\n"
}

function set_path_to_parallel_dolphin {
    for ((index=1;index<=${parallelism};index++)); do
        if [ -z "$(ps axf | grep playback_${index}/dolphin-emu | grep -v grep | awk '{print $6}')" ] && [ -z "$(ps axf | grep ffmpeg | grep playback_${index} | grep -v grep | awk '{print $6}')" ]; then
            current_parallel_dolphin_path="${path_to_dolphin_temp}/playback_${index}"
            break
        fi
        current_parallel_dolphin_path=""
    done

    if [ -z $current_parallel_dolphin_path ]; then
        echo -e "\t[${COLOR_RED}Error${COLOR_NONE}]: Could not set current dolphin path"
    fi
    
}

function convert_wav_and_avi_to_mp4 {
    local avi_file=$1
    local wav_file=$2
    local output_file_name=$3

    ffmpeg -loglevel panic -y -i ${avi_file} -i ${wav_file} -filter_complex "[0:v]${video_filter}" "${output_dir}/${output_file_name}.mp4" &
    local ffmpeg_pid=$!
    local start_counter=$SECONDS
    while kill -0 $ffmpeg_pid &> /dev/null; do
        sleep 1s
    done
    local counter=$(($SECONDS-$start_counter))
    echo -e "\t[${COLOR_GREEN}File Recording - Video Encoding${COLOR_NONE}]: Combining AVI and WAV from Dolphin dump for: ${COLOR_BLUE}${counter}s${COLOR_NONE}"
}

function process_slp_files_in_folder {
    parallel --delay 5 --env parallelism --group -k --jobs $parallelism record_file {} < temp/recording_jobs.txt
}


global_counter=$SECONDS

init
init_parallelism
process_slp_files_in_folder
final_counter=$(($SECONDS-$global_counter))
echo -e "[${COLOR_GREEN}Script Complete${COLOR_NONE}]: Exiting Successfully in ${final_counter}s"
exit 0



