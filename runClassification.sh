bsub -J classification-${PWD##*/} -R "rusage[mem=16000]" -W 96:0 -q priority -o $(date +%Y-%m-%d_%H:%M:%S).out -e $(date +%Y-%m-%d_%H:%M:%S).err matlab -nojvm -nodisplay -r "runClassification();exit"
