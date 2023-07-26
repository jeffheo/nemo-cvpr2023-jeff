#!/bin/bash
set -e  # Exit on any error
export PATH="$PATH:."

eval "$(conda shell.bash hook)"
conda activate vibe-env

# Obtain video names from nemo-config.yml
video_names=($(grep -Po 'names:\s*\K.*' ./nemo-config.yml | tr -d '[]," '))
# # Print the video names one per line
#printf '%s\n' "${video_names[@]}"
# Extract the name of the first video
video=${video_names[0]}
printf '%s\n' "$video"

# Split the name into "action" and "index" parts
IFS='.' read -ra NAME <<< "$video"

# Extract the index value
index=${NAME[1]}

# # Change write permissions for the data folder so that the docker container can write to it
script_dir=$(cd "$(dirname "$0")" && pwd)
data_dir="${script_dir}/data"
#chmod -R 777 "$data_dir"

cd ./VIBE_custom
# Iterate over video names
for name in "${video_names[@]}"; do
     python ./demo.py --vid_file "${data_dir}/videos/${name}.mp4" --output_folder "${data_dir}/exps/"
done

cd ..

# Deactivate the environment
eval "$(conda shell.bash hook)"

conda deactivate

# Create conda environment through custom_env.yml


eval "$(conda shell.bash hook)"
# Activate the environment
conda activate nemo_jeff

# #pip install --force-reinstall pyopengl==3.1.5

# Get the number of videos
#num_elements=${#video_names[@]}
#count="$num_elements"
video_name_with_extension=${video_names[0]}

# Remove the extension and the number
video_name="${video_name_with_extension%%.*}"
echo "$video_name"
echo "$index"
#echo "$count"

python ./video_to_frames_custom.py --action "$video_name" --index "$index"
# Iterate over video names
for name in "${video_names[@]}"; do
    docker run --gpus 1 --rm -v "${data_dir}/exps:/mnt" cwaffles/openpose ./build/examples/openpose/openpose.bin --image_dir /mnt/"${name%.mp4}.frames" --write_json /mnt/"${name%.mp4}.op" --display 0 --model_pose BODY_25 --number_people_max 1 --render_pose 0
done

cp -r ./data/exps/${video}.frames ../../nemo-cvpr2023-jeff-old/data/exps/moving_tennis_swing/
cp -r ./data/exps/${video}.op ../../nemo-cvpr2023-jeff-old/data/exps/moving_tennis_swing/
cp -r ./data/exps/${video}.vibe ../../nemo-cvpr2023-jeff-old/data/exps/moving_tennis_swing/

cp -r ./data/exps/${video}.frames ../../slahmr/images/


cd ../../slahmr/

eval "$(conda shell.bash hook)"
conda deactivate

eval "$(conda shell.bash hook)"
conda activate slahmr
cd slahmr/preproc/

python launch_slam.py --type custom --root /pasteur/u/jeffheo/projects/slahmr --gpus 1
cd ../cameras/${video}.frames
mv ./frame_cameras.json ../../../../nemo-cvpr2023-jeff-old/droidslam/moving_vid/${video}.json

rm -r ../../../images/*

# Now run the NeMo script
#bash custom_video/nemo-run.sh 0
