#!/bin/bash

program="matlab -nodisplay -r"
fnc_prefix="addpath(genpath(pwd));"
fnc_suffix=";exit"

case "$1" in
"classification" | "features" | "features-hop")
  queue=long
  if [[ "$1" == "classification" ]]; then
    queue="parallel -n 8"
  fi
  if [ -z "$2" ]; then
    fnc="run('$1')"
  else
    fnc="run('$1', $2)"
  fi
  ;;
"feature-diffs")
  queue=priority
  fnc="computeHopDiffs($2)"
  ;;
"rnn")
  queue="gpu -R rusage[ngpus=1]"
  program=python
  fnc=model/feature_extractors/rnn/RnnFeatures.py
  if [ ! -z "$2" ]; then
    fnc="$fnc $2"
  fi
  fnc_prefix=""
  fnc_suffix=""
  ;;
*)
  echo "Usage: ./run.sh <classification|features|features-hop|feature-diffs>"
  exit 1
  ;;
esac
bsub -J $1-${PWD##*/} \
  -R "rusage[mem=16000]" \
  -W 96:0 \
  -q $queue \
  -o $(date +%Y-%m-%d_%H:%M:%S).out -e $(date +%Y-%m-%d_%H:%M:%S).err \
  $program "$fnc_prefix$fnc$fnc_suffix"
