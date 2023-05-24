-- drop table qwe 

create multiset volatile table qwe as(
--------------------


select t1.subs_id,
t1.create_date - cast(t2.event_date_instal as date) as diff_day,
t1.create_date, t2.event_date_instal, 
last_status_name
from uat_ca.v3_nps_bu t1 
join uat_ca.mc_alladin_subs t2 on t1.subs_id =  t2.subs_id
							  AND trunc(t2.event_date_instal, 'rm') 
							  BETWEEN ADD_MONTHS(t1.create_date, 0) - INTERVAL '61' DAY 
							  AND t1.create_date	
							  
where  create_date > date '2022-01-01' 

-----and  t1.subs_id = 100080784263

-----------------
) with data 
on commit preserve rows
--ON COMMIT DELETE ROWS по умолчанию
