#!/usr/bin/env bash

IN_DIR="/data/wiki/en_articles"
TMP_DIR="tmp_dir"
OUT_DIR="out_dir"
NUM_REDUCERS=8

hadoop fs -rm -r -skipTrash $TMP_DIR* >/dev/null
hadoop fs -rm -r -skipTrash $OUT_DIR* >/dev/null

yarn jar /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -D mapreduce.job.name="naive_wordcount" \
    -D stream.num.map.output.key.fields=3 \
    -D mapreduce.job.output.key.comparator.class=org.apache.hadoop.mapreduce.lib.partition.KeyFieldBasedComparator \
    -D mapreduce.partition.keycomparator.options='-k1 -k2' \
    -D mapreduce.job.reduces=${NUM_REDUCERS} \
    -files mapper.py,reducer.py \
    -mapper mapper.py \
    -reducer reducer.py \
    -input $IN_DIR \
    -output $TMP_DIR >/dev/null

yarn jar /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -D mapreduce.job.name="sort_output" \
    -D stream.num.map.output.key.fields=3 \
    -D mapreduce.job.reduces=1 \
    -D mapreduce.job.output.key.comparator.class=org.apache.hadoop.mapreduce.lib.partition.KeyFieldBasedComparator \
    -D mapreduce.partition.keycomparator.options='-k2,2nr -k1' \
    -mapper cat \
    -reducer cat \
    -input $TMP_DIR \
    -output $OUT_DIR >/dev/null

hdfs dfs -cat ${OUT_DIR}/part-00000 2>>/dev/null | head -10

