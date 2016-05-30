if [ "$#" -ne 1 ]; then
    echo "Usage: ./run.sh <classification|identification>"
    exit 1
fi
bsub -J $1-${PWD##*/} -R "rusage[mem=16000]" -W 96:0 -q parallel -n 12 -o $(date +%Y-%m-%d_%H:%M:%S).out -e $(date +%Y-%m-%d_%H:%M:%S).err matlab -nodisplay -r "run('$1');exit"
