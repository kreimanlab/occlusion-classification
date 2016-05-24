bsub -J classification -R "rusage[mem=16000]" -W 96:0 -q priority -o $(date +%Y-%m-%d_%H:%M:%S).out -e $(date +%Y-%m-%d_%H:%M:%S).err matlab -nojvm -nodisplay -r "runClassification('dataMin', 1, 'dataMax', 13000, 'hopSize', 1000);exit"

