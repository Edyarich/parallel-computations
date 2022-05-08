add jar /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
add jar /opt/cloudera/parcels/CDH/lib/hive/lib/hive-serde.jar;
add file ./udf.sh;
USE vladimiroved;

select transform(age)
using './udf.sh' as age_transformer 
from Users
limit 10;

