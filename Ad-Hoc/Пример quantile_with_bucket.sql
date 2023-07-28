
diagnostic helpstats on for session;


--QUANTILE - Computes the quantile scores for the values in a group
/*https://docs.teradata.com/r/kmuOwjp1zEYg98JsB8fu_A/LXJdYcQJxgVAV2shA5tFoQ*/

--WIDTH_BUCKET - Returns the number of the partition to which value_expression is assigned
/*https://docs.teradata.com/r/kmuOwjp1zEYg98JsB8fu_A/Wa8vw69cGzoRyNULHZeudg*/


--==Quantile выравнивает количество строк, а width_bucket - интервал заданной переменной (макс - мин) / количество buckets


--=================================================================================================
--=================================================================================================
--=================================================================================================

/*В качестве примера данные по NPS опросам по точке контакта Мобильный интернет*/

select top 100 * from uat_ca.v_nps_bu;

lrt - Likelihood to Recommend, оценку которую ставит абонент
nps - преобразованная оценка (1-6) это "-1", (7-8) это "0", (9-10) это 10, avr(nps) - значение NPS


--drop table subs;
--delete subs;

create multiset volatile table subs, no log as (
--insert into subs
select
 weeknumber_of_year (create_date, 'ISO') as week_num,
 subs_id,
 ltr,
 nps,
 coalesce(mb_last_30,0) as data_mb
from uat_ca.v_nps_bu
where 1=1
 and create_date between date '2022-07-25' and date '2022-07-31'
-- and point_name = 'Мобильный интернет'
) with data
primary index (subs_id)
on commit preserve rows
;

select top 100 * from subs;


--статистика
COLLECT STATISTICS COLUMN (DATA_MB) ON subs;


--0, 969 938,32
select min(data_mb), max(data_mb) from subs;

select top 10 * from subs order by data_mb desc;
--топ 5
subs_id         data_mb
100067973245    969 938,32
100069719736    445 247,842
56199036        437 113,834
200057635366    392 935,095
200084763042    353 990,717


--==QUANTILE
with t1 as (
select
 data_mb,
 subs_id,
--
 quantile(10, data_mb) as bucket_num
from subs
)
select
 bucket_num,
 count(subs_id) as subs_cnt,
 round(min(data_mb), 1) as min_data,
 round(max(data_mb), 1) as max_data,
 round(sum(data_mb),1) as bucket_data,
 sum(bucket_data) over () as total_data,
 cast(bucket_data as float)/total_data as share_bucket
from t1
group by 1
order by 1
;


--==WIDTH_BUCKET
with t1 as (
select
 data_mb,
 subs_id,
--min, max, N интервалов
 width_bucket(data_mb, 0, 969939, 10) as bucket_num
from subs
)
select
 bucket_num,
 count(subs_id) as subs_cnt,
 round(min(data_mb), 1) as min_data,
 round(max(data_mb), 1) as max_data,
 round(sum(data_mb),1) as bucket_data,
 sum(bucket_data) over () as total_data,
 cast(bucket_data as float)/total_data as share_bucket
from t1
group by 1
order by 1
;



--==================================================================================================
--==================================================================================================
--==================================================================================================

--==усложнение 1

with t2 as (
select
 bucket_num,
 count(subs_id) as subs_cnt,
 round(min(data_mb), 1) as min_data,
 round(max(data_mb), 1) as max_data,
 round(sum(data_mb),1) as bucket_data,
 sum(bucket_data) over () as total_data,
 cast(bucket_data as float)/total_data as share_bucket,
--
 row_number() over (order by bucket_num) as bucket_rn
from t1
group by 1
),
t1 as (
select
 data_mb,
 subs_id,
--min, max, N интервалов
 width_bucket(data_mb, 0, 969939, 10) as bucket_num
from subs
)
select
 bucket_num as t1,
 bucket_rn as bucket_num,
 subs_cnt,
 min_data,
 max_data,
 bucket_data,
 total_data,
 share_bucket
from t2
order by 1
;



--==усложнение 2

with t2 as (
select
 bucket_num,
 count(subs_id) as subs_cnt,
 round(min(data_mb), 1) as min_data,
 round(max(data_mb), 1) as max_data,
 round(sum(data_mb),1) as bucket_data,
 sum(bucket_data) over () as total_data,
 cast(bucket_data as float)/total_data as share_bucket,
--
 row_number() over (order by bucket_num) as bucket_rn
from t1
group by 1
),
t1 as (
select
 data_mb,
 subs_id,
--
 case when data_mb = 0 then 0
      when data_mb >150000 then 99
      else width_bucket(data_mb, 0, 150000, 10) + 1
      end as bucket_num
from subs
)
select
 bucket_num as t1,
 bucket_rn as bucket_num,
 subs_cnt,
 min_data,
 max_data,
 bucket_data,
 total_data,
 share_bucket
from t2
order by 1
;



--==усложнение 3

with t2 as (
select
 bucket_num,
 count(subs_id) as subs_cnt,
 round(min(data_mb), 1) as min_data,
 round(max(data_mb), 1) as max_data,
 round(sum(data_mb),1) as bucket_data,
 sum(bucket_data) over () as total_data,
 cast(bucket_data as float)/total_data as share_bucket,
 sum(subs_cnt) over () as total_cnt,
 cast(subs_cnt as float)/total_cnt as share_subs,
--
 row_number() over (order by bucket_num) as bucket_rn
from t1
group by 1
),
t1 as (
select
 data_mb,
 subs_id,
--min, max, N интервалов
 case when data_mb = 0 then 0
      when data_mb >150000 then 99
      else width_bucket(data_mb, 0, 150000, 5) + 1
      end as bucket_num
from subs
)
select
 bucket_rn as bucket_num,
 subs_cnt,
 min_data,
 max_data,
 bucket_data,
 total_data,
 100*share_bucket (format 'zz.z%') (varchar(10)) as share_bucket,
 100*share_subs (format 'zz.zz%') (varchar(10)) as share_subs
from t2
order by 1
;



