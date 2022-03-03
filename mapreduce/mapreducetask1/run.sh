#!/usr/bin/env bash

IN_DIR="/data/ids"
OUT_DIR="tmp_dir"
NUM_REDUCERS=2

#hadoop fs -mkdir $OUT_DIR >/dev/null
hadoop fs -rm -r -skipTrash $OUT_DIR* >/dev/null

yarn jar /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -D mapreduce.job.name="print_random_ids" \
    -D mapreduce.job.reduces=${NUM_REDUCERS} \
    -files mapper.py,reducer.py \
    -mapper mapper.py \
    -reducer reducer.py \
    -input $IN_DIR \
    -output $OUT_DIR >/dev/null

for num in `seq 0 $(($NUM_REDUCERS - 1))`
do
    hdfs dfs -cat ${OUT_DIR}/part-0000$num | head -25
done
