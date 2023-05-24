Диапазон от 30 дней и до после даты из первой таблицы, используя функции ADD_MONTHS и INTERVAL для вычисления конкретных дат. 
Затем мы сравниваем даты из второй таблицы с этим диапазоном при помощи оператора BETWEEN.

select top 100  create_date, ADD_MONTHS(t1.create_date, -1)  , ADD_MONTHS(t1.create_date, 0) - INTERVAL '30'DAY from uat_ca.v3_nps_bu t1 


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
on commit preserve rows -- необходимо явно прописывать
--ON COMMIT DELETE ROWS по умолчанию



--------------------------------Пример таблицы -------------------------------

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
	 a.create_date - cast(t1.event_date_instal as date) as diff_day
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
