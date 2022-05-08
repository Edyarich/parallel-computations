ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
USE vladimiroved;

SELECT info, COUNT(info) as cnt
FROM Logs
GROUP BY info
ORDER BY cnt DESC
