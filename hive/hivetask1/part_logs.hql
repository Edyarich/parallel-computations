ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;

SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.max.dynamic.partitions.pernode=300;

USE vladimiroved;
DROP TABLE IF EXISTS Logs;

CREATE EXTERNAL TABLE Logs (
    ip STRING,
    http_req STRING, 
    page_size SMALLINT, 
    status SMALLINT, 
    info STRING
)
PARTITIONED BY (query_time INT)
STORED AS TEXTFILE;

INSERT INTO Logs PARTITION (query_time)
SELECT ip, http_req, page_size, status, info, query_time 
FROM NotPartLogs;
