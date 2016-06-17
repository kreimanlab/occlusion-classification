#!/bin/bash

case "$1" in
"classification" | "identification")
  queue="parallel -n 8"
  fnc="run('$1')"
  ;;
"features")
  queue=long
  fnc="computeFeatures()"
  ;;
"features-hoptime")
  queue=long
  fnc="computeHopTimeFeatures($2)"
  ;;
"feature-diffs")
  queue=priority
  fnc="computeHopDiffs($2)"
  ;;
*)
  echo "Usage: ./run.sh <classification|identification|features|features-hoptime|feature-diffs>"
  exit 1
  ;;
esac
bsub -J $1-${PWD##*/} \
  -R "rusage[mem=16000]" \
  -W 96:0 \
  -q $queue \
  -o $(date +%Y-%m-%d_%H:%M:%S).out -e $(date +%Y-%m-%d_%H:%M:%S).err \
  matlab -nodisplay -r "$fnc;exit"
