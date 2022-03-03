#!/bin/bash

hive -f not_part_logs.hql
hive -f part_logs.hql
hive -f users.hql
hive -f ipregions.hql
hive -f subnets.hql
