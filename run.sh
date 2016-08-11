#!/bin/bash

# Python
if [ "$1" == "rnn" ]; then
  queue="priority"
  #queue="gpu -R rusage[ngpus=1]"
  program="python -u"
  fnc=model/feature_extractors/rnn/RnnFeatures.py
  if [ ! -z "$2" ]; then
    fnc="$fnc $2"
  fi
  bsub -J $1-${PWD##*/} \
    -R "rusage[mem=64000]" \
    -W 96:0 \
    -q $queue \
    -o $(date +%Y-%m-%d_%H:%M:%S).out -e $(date +%Y-%m-%d_%H:%M:%S).err \
    $program $fnc
  exit 0
fi

# Matlab
program="matlab -nodisplay -r"
#fnc_prefix="addpath(genpath(pwd)); "
fnc_prefix=""
fnc_suffix="; exit"
mem_usage=16000

case "$1" in
"classification" | "features" | "features-hop" | "features-hop-masked")
  queue="parallel -n 8"
  if [ -z "$2" ]; then
    fnc="run('$1')"
  else
    fnc="run('$1', $2)"
  fi
  if [[ "$1" == "features-hop" || "$1" == "features-hop-masked" ]]; then
    mem_usage=64000
  fi
  ;;
"feature-diffs")
  queue=priority
  fnc="computeHopDiffs($2)"
  ;;
"hop-weights")
  queue=priority
  fnc="computeHopWeights($2)"
  ;;
*)
  echo "Usage: ./run.sh <classification|features|features-hop|feature-diffs>"
  exit 1
  ;;
esac
bsub -J $1-${PWD##*/} \
  -R "rusage[mem=$mem_usage]" \
  -W 96:0 \
  -q $queue \
  -o $(date +%Y-%m-%d_%H:%M:%S).out -e $(date +%Y-%m-%d_%H:%M:%S).err \
  $program "$fnc_prefix$fnc$fnc_suffix"

