select * from uat_ca.vf_alladin_250523
select * from uat_ca.mc_alladin_subs
-----------------------------------------------------------
--drop table uat_ca.vf_alladin_250523
create multiset table uat_ca.vf_alladin_250523 as (

select 
a.create_date,
	 a.cluster_actual as cluster_name,
	 a.macroregion as macroregion,
	 a.region as region,
	 a.branch_id,
	 a.cust_id,
	 a.subs_id,
	 a.msisdn,
	 a.point_name,
	 a.ltr as nps,
	 a.nps as nps_key,
	-- a.lt_day,
	 case when a.lt_day is null or a.lt_day = - 1 then 'null'
	      when a.lt_day < 91 then '3'
	      when a.lt_day < 181  then '4-6'
	      when a.lt_day < 361 then '7-12'
	      when a.lt_day < 721 then '13-24'
	      else '25+' end as lt_gr,
	-- a.age,
	 case when a.age is null or a.age = -1 then 'n/a'
	      when a.age < 21 then '16-20'
	      when a.age < 36 then '21-35'
	      when a.age < 46 then '36-45'
	      when a.age < 56 then '46-55'
	      else '56 +' end as age_gr,
	-- a.gender,
	 case when a.gender is null or a.gender = -1 then 'n/a'
	      when a.gender = 0 then 'М'
	      when a.gender = 1 then 'Ж'
	      end as gender,
	 a.data_gb,
	 case when data_gb is null then '0'
	      when data_gb = 0 then '0'
	      when data_gb <= 10 then '10'
	      when data_gb <= 30 then 'от 10-30'
	      when data_gb <= 50 then 'от 30-50'
	      when data_gb <= 100 then 'от 50-100'
	      else '100+'
	 end as data_gr,
	--
	-- t1.report_month,
	 t1.create_dttm,
	 t1.event_date_to_rtk,
	 t1.event_date_instal,
	 t1.alladin_system,
	 t1.last_status_name,
	 t1.reason,
	 a.create_date - cast(t1.event_date_instal as date) as diff_day,
	 case when t1.event_date_instal is not null then 1 else 0 end as flg_conv 
	from uat_ca.v3_nps_bu a
	--
	left join uat_ca.mc_alladin_subs t1 on a.subs_id = t1.subs_id
	

							  AND trunc(t1.event_date_instal, 'rm') 
							  BETWEEN ADD_MONTHS(a.create_date, -1) - INTERVAL '31' DAY 
							  AND a.create_date	
							  
where  create_date > date '2022-01-01' 
--and event_date_instal is not null


--проверка на несовпадения
-- and a.subs_id not in (select subs_id from uat_ca.mc_nps_alladin where event_date_instal is not null )
) with data 
primary index (subs_id)

-------------------------------------------------------






--шаг 1 создаем пустую таблицу со структурой
--шаг 2 пишем макрос
--шаг 3 добавляем значения

--drop table subs_all;
-- delete from subs_all

create multiset volatile table subs_all ,no log (
 create_date date format 'yy/mm/dd',
 cluster_name varchar(50) character set unicode casespecific,
 macroregion varchar(50) character set unicode casespecific,
 region varchar(50) character set unicode casespecific,
 branch_id decimal(4,0),
 cust_id decimal(12,0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set unicode not casespecific,
 point_name varchar(100) character set unicode not casespecific,
 nps byteint,
 nps_key byteint,
 lt_gr varchar(5) character set unicode not casespecific,
 age_gr varchar(5) character set unicode not casespecific,
 gender varchar(3) character set unicode not casespecific,
 data_gb float,
 data_gr varchar(9) character set unicode not casespecific,
 create_dttm timestamp(0),
 event_date_to_rtk varchar(150) character set unicode casespecific,
 event_date_instal timestamp(0),
 alladin_system varchar(50) character set unicode casespecific,
 last_status_name varchar(100) character set unicode casespecific,
 reason varchar(50) character set unicode casespecific,
 diff_day integer)
primary index (subs_id)
on commit preserve rows;

--drop table subs_all;
-- delete from subs_all
replace macro nps_all (s_nps date, e_nps date, sdate date, edate date) as (
--create multiset volatile table subs_all, no log as (
insert into subs_all
select * from (
	select
	 a.create_date,
	 a.cluster_actual as cluster_name,
	 a.macroregion as macroregion,
	 a.region as region,
	 a.branch_id,
	 a.cust_id,
	 a.subs_id,
	 a.msisdn,
	 a.point_name,
	 a.ltr as nps,
	 a.nps as nps_key,
	-- a.lt_day,
	 case when a.lt_day is null or a.lt_day = - 1 then 'null'
	      when a.lt_day < 91 then '3'
	      when a.lt_day < 181  then '4-6'
	      when a.lt_day < 361 then '7-12'
	      when a.lt_day < 721 then '13-24'
	      else '25+' end as lt_gr,
	-- a.age,
	 case when a.age is null or a.age = -1 then 'n/a'
	      when a.age < 21 then '16-20'
	      when a.age < 36 then '21-35'
	      when a.age < 46 then '36-45'
	      when a.age < 56 then '46-55'
	      else '56 +' end as age_gr,
	-- a.gender,
	 case when a.gender is null or a.gender = -1 then 'n/a'
	      when a.gender = 0 then 'М'
	      when a.gender = 1 then 'Ж'
	      end as gender,
	 a.data_gb,
	 case when data_gb is null then '0'
	      when data_gb = 0 then '0'
	      when data_gb <= 10 then '10'
	      when data_gb <= 30 then 'от 10-30'
	      when data_gb <= 50 then 'от 30-50'
	      when data_gb <= 100 then 'от 50-100'
	      else '100+'
	 end as data_gr,
	--
	-- t1.report_month,
	 t1.create_dttm,
	 t1.event_date_to_rtk,
	 t1.event_date_instal,
	 t1.alladin_system,
	 t1.last_status_name,
	 t1.reason,
	 a.create_date - cast(t1.event_date_instal as date) as diff_day
	from uat_ca.v3_nps_bu a
	--
	inner join uat_ca.mc_alladin_subs t1 on a.subs_id = t1.subs_id
	 --and t1.event_date_instal >= date '2022-06-01'
	 --and t1.event_date_instal < date '2022-08-01'
	 and t1.event_date_instal >= :sdate
	 and t1.event_date_instal < :edate
	where 1=1
	-- and a.create_date >= date '2022-07-01'
	-- and a.create_date < date '2022-08-01'
	 and a.create_date >= :s_nps
	 and a.create_date < :e_nps
) a

where 1=1 
;
--where 1=0 
--)with data
--on commit preserve rows;
);



--2022
/*Январь*/     Execute nps_all (date '2022-01-01', date '2022-02-01', date '2021-12-01', date '2022-02-01');
/*Февраль*/    Execute nps_all (date '2022-02-01', date '2022-03-01', date '2022-01-01', date '2022-03-01');
/*Март*/       Execute nps_all (date '2022-03-01', date '2022-04-01', date '2022-02-01', date '2022-04-01');
/*Апрель*/     Execute nps_all (date '2022-04-01', date '2022-05-01', date '2022-03-01', date '2022-05-01');
/*Май*/        Execute nps_all (date '2022-05-01', date '2022-06-01', date '2022-04-01', date '2022-06-01');
/*Июнь*/       Execute nps_all (date '2022-06-01', date '2022-07-01', date '2022-05-01', date '2022-07-01');
/*Июль*/       Execute nps_all (date '2022-07-01', date '2022-08-01', date '2022-06-01', date '2022-08-01');
/*Август*/     Execute nps_all (date '2022-08-01', date '2022-09-01', date '2022-07-01', date '2022-09-01');
/*Сентябрь*/   Execute nps_all (date '2022-09-01', date '2022-10-01', date '2022-08-01', date '2022-10-01');
/*Октябрь*/    Execute nps_all (date '2022-10-01', date '2022-11-01', date '2022-09-01', date '2022-11-01');
/*Ноябрь*/     Execute nps_all (date '2022-11-01', date '2022-12-01', date '2022-10-01', date '2022-12-01');
/*Декабрь*/    Execute nps_all (date '2022-12-01', date '2023-01-01', date '2022-11-01', date '2023-01-01');


--2023
/*Январь*/     Execute nps_all (date '2023-01-01', date '2023-02-01', date '2022-12-01', date '2023-02-01');
/*Февраль*/    Execute nps_all (date '2023-02-01', date '2023-03-01', date '2023-01-01', date '2023-03-01');
/*Март*/       Execute nps_all (date '2023-03-01', date '2023-04-01', date '2023-02-01', date '2023-04-01');
/*Апрель*/     Execute nps_all (date '2023-04-01', date '2023-05-01', date '2023-03-01', date '2023-05-01');
-------------------------------------------------
select * from subs_all
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------





----------------------------------------------------------
SELECT TOP 100 *
FROM uat_ca.v3_nps_bu t1
LEFT JOIN uat_ca.mc_alladin_subs t2
ON t1.subs_id = t2.subs_id
AND t2.create_date BETWEEN ADD_MONTHS(t1.create_date, -1) - INTERVAL '30' DAY AND ADD_MONTHS(t1.create_date, 1) + INTERVAL '30' DAY;

В этом примере мы задаем диапазон дат от 30 дней до 30 дней после даты из первой таблицы, используя функции 
ADD_MONTHS и INTERVAL для вычисления конкретных дат. Затем мы сравниваем даты из второй таблицы 
с этим диапазоном при помощи оператора BETWEEN.

select top 100  create_date, ADD_MONTHS(t1.create_date, -1)  , ADD_MONTHS(t1.create_date, 0) - INTERVAL '30'DAY from uat_ca.v3_nps_bu t1 


-------------------------------------------------------------

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

----------------------------------------------------------
select subs_id,
create_date - cast(event_date_instal as date) as diff_day,
create_date, event_date_instal 
from uat_ca.mc_nps_alladin
where event_date_instal is not null 

------------------------------------------------------------






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


select * from qwe where subs_id not in ( select subs_id 
										from uat_ca.mc_nps_alladin
										where event_date_instal is not null   )	
-----------------------------------------------------------
select subs_id,
create_date - cast(event_date_instal as date) as diff_day,
create_date, event_date_instal 
from uat_ca.mc_nps_alladin
where event_date_instal is not null 
------------------------------------------------------------



