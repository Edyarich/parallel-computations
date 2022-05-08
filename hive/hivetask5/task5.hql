add jar /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
add jar /opt/cloudera/parcels/CDH/lib/hive/lib/hive-serde.jar;
add file ./udf.sh;
USE vladimiroved;

select transform(ip, query_time, http_req, page_size, status, info)
using './udf.sh' as (ip, query_time, http_req, page_size, status, info)
from Logs 
limit 10;

