#!/bin/bash
#PBS -N pgd_ember1
#PBS -P CSCI1142
#PBS -q serial
#PBS -l select=1:ncpus=8:mem=20gb
#PBS -l walltime=24:00:00
#PBS -J 0-4

set -x
set -o pipefail
echo "==== JOB START ===="
date
env | grep PBS


cd $PBS_O_WORKDIR || exit 1

module load python/3.9.6
#module purge
#module load anaconda3
#source activate base
#module load cuda/11.8
source ~/venv/bin/activate

mkdir -p logs results

# PBS array index
TASK_ID=${PBS_ARRAY_INDEX:-0}
echo "TASK_ID=$TASK_ID"

# Read experiment parameters
PARAMS=$(sed -n "$((TASK_ID+1))p" experiments.txt)
set -- $PARAMS

EPS=$1
ALPHA=$2
ITERS=$3
SEED=$4

RUN_ID="eps${EPS}_alpha${ALPHA}_it${ITERS}_seed${SEED}"

echo "Starting run $RUN_ID on task $TASK_ID"
echo "Running on host: $(hostname)"
echo "Working directory: $(pwd)"
echo "Array index: $PBS_ARRAY_INDEX"

echo "Checking EMBER data"
ls -lh ember_output || exit 2

python malware_detection_ember_mlp_adversarial_pgd.py \
  --eps $EPS \
  --alpha $ALPHA \
  --iters $ITERS \
  --seed $SEED \
  --run_id $RUN_ID \
  --outdir results
