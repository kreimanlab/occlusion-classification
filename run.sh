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
    -o $(date +%Y-%m-%d_%H:%M:%S)-rnn.out \
    -e $(date +%Y-%m-%d_%H:%M:%S)-rnn.err \
    $program $fnc
  exit 0
fi

# Matlab
program="matlab -nodisplay -r"
fnc_prefix="addpath(genpath(pwd)); "
fnc_suffix="; exit"
mem_usage=16000

case "$1" in
"classification" | "features" | "features-imagenet" | "features-less_occlusion" \
| "features-hop" | "features-hop-imagenet" | "features-hop-masked")
#  queue="parallel -n 8"
  queue="long"
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
  echo "Usage: ./run.sh <classification|features|features-imagenet|features-hop|feature-diffs>"
  exit 1
  ;;
esac
bsub -J $1-${PWD##*/} \
  -R "rusage[mem=$mem_usage]" \
  -W 96:0 \
  -q $queue \
  -o $(date +%Y-%m-%d_%H:%M:%S)-$1.out \
  -e $(date +%Y-%m-%d_%H:%M:%S)-$1.err \
  $program "$fnc_prefix$fnc$fnc_suffix"

