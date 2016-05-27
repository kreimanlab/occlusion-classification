if [ "$#" -ne 1 ]; then
    echo "Need exactly one parameter to specify the task"
    exit 1
fi
bsub -J $1-${PWD##*/} -R "rusage[mem=16000]" -W 96:0 -q priority -o $(date +%Y-%m-%d_%H:%M:%S).out -e $(date +%Y-%m-%d_%H:%M:%S).err matlab -nojvm -nodisplay -r "run('$1');exit"
