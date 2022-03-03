ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
USE vladimiroved;

DROP TABLE IF EXISTS NotPartLogs;

CREATE EXTERNAL TABLE NotPartLogs (
    ip STRING,
    query_time INT, 
    http_req STRING, 
    page_size SMALLINT, 
    status SMALLINT, 
    info STRING
)

ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
    "input.regex" = '^(\\S+)\\t{3}(\\d{8})\\d+\\t(\\S+)\\t(\\d+)\\t(\\d+)\\s+(\\S+).*$'
)

STORED AS TEXTFILE
LOCATION '/data/user_logs/user_logs_M';

select * from NotPartLogs limit 10;

