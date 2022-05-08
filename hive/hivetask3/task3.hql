ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
USE vladimiroved;

with status_and_sex as (
    select logs.status, 
        if(users.sex = 'male', 1, 0) as male_cnter, 
        if(Users.sex = 'female', 1, 0) as female_cnter
    from Logs logs
         left join Users users on logs.ip = users.ip
)
select status, sum(male_cnter), sum(female_cnter)
from status_and_sex
group by status;

