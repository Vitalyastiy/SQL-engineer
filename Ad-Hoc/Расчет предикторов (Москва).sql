
diagnostic helpstats on for session;

select top 100 * from uat_ca.sample_from_gprs_hadoop_2022_06;

rename table
uat_ca.sample_from_gprs_hadoop_2022_06
as
uat_ca.sample_26_hadoop
;

--=================================================================================================

select top 100 * from uat_ca.sample_26_hadoop;


COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (SUBS_ID),
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN),
 COLUMN (SUBS_ID ,CREATE_DATE)
ON uat_ca.sample_26_hadoop;


COLLECT STATISTICS
 COLUMN (START_DTTM),
 COLUMN (NE_ID)
ON uat_ca.sample_26_hadoop;



select
 trunc(create_date,'mm') as create_month,
 branch_id,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.sample_26_hadoop
group by 1,2
order by 2,1 desc;


--==Объем/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('sample_26_hadoop')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          SAMPLE_26_HADOOP        SERGEY.V.ALEKSEEV   2022-09-05 11:33:14     2022-09-06 11:03:22     0,025           86,248          --один месяц, Тула
UAT_CA          SAMPLE_26_HADOOP        SERGEY.V.ALEKSEEV   2022-09-05 11:33:14     2022-09-08 15:39:27     0,217           74,546


--=================================================================================================
--=================================================================================================
--=================================================================================================


REPLACE PROCEDURE uat_ca.mc_grps_tg_msk_hadoop (in rep_date date, in c_sdate date, in c_edate date)
SQL SECURITY INVOKER
BEGIN

--==01 Целевая группа + окончание интервала + трафик + скорость + технология ne_id + регин ne_id + flg_session

--show table subs;
--drop table subs;

create multiset volatile table subs ,no log (
 report_date date format 'yy/mm/dd',
 region_id decimal(4,0),
 branch_id decimal(15,0),
-- call_id decimal(15,0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set latin not casespecific,
-- imei varchar(20) character set latin not casespecific,
 start_dttm timestamp(0),
 end_dttm timestamp(0),
 duration decimal(9,0),
 uplink_mb float,
 downlink_mb float,
 uplink_megabit_sec float,
 downlink_megabit_sec float,
 rg_id integer,
 cause4term varchar(10) character set latin not casespecific,
 ne_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 tech varchar(25) character set unicode not casespecific,
 flg_session byteint)
primary index ( msisdn )
partition by range_n(start_dttm  between timestamp '2022-01-01 00:00:00+00:00' and timestamp '2022-12-31 23:59:59+00:00' each interval '1' day )
on commit preserve rows;


--время  28 сек.
insert into subs
select
 a.create_date as report_date,
 t1.region_id,
 a.branch_id,
-- a.call_id,
 a.subs_id,
 a.msisdn,
-- a.imei,
 cast(substring(cast(a.start_dttm as char(26)) from 1 for 19) as timestamp(0)) as start_dttm,
 cast(substring(cast(a.start_dttm as char(26)) from 1 for 19) as timestamp(0)) + numtodsinterval(duration, 'second') as end_dttm,
 a.duration,
 cast(a.in_volume as float) / 1024 / 1024 as uplink_mb,
 cast(a.out_volume as float) / 1024 / 1024 as downlink_mb,
 case when a.duration = 0 then -1
      else (cast(a.in_volume as float) * 8 / 1024 / 1024) / a.duration end as uplink_megabit_sec,
 case when a.duration = 0 then -1 
      else (cast(a.out_volume as float) * 8 / 1024 / 1024) / a.duration end as downlink_megabit_sec,
--
 a.rating_group_id as rg_id,
 a.cause4term,
 a.ne_id,
 t1.sector_name as sector_name,
 t1.stechnology as tech,
---
 case when uplink_mb = 0 or downlink_mb = 0 then 1
      else 0 end as flg_session
from uat_ca.sample_26_hadoop a
--
left join prd2_dic_v.network_element t1 on a.ne_id = t1.ne_id
 and t1.edw_sdate <= a.start_dttm
 and t1.edw_edate >= end_dttm
--
where 1=1
-- and a.create_date = date '2022-06-01'
 and a.create_date = :rep_date
 and a.branch_id = 95
;

--select top 100 * from subs;


--==Сбор статистики
--33 сек.
COLLECT STATISTICS
 COLUMN (MSISDN)
ON subs;


--==02 Предиктор 1: cause4term = 2 - плохой опыт, считаем кол-во интервалов

--drop table step_1;
--delete step_1;

--show table step_1;

create multiset volatile table step_1 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_1_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 14 сек.
--create multiset volatile table step_1, no log as (
insert into step_1
select
 a.msisdn,
 sum(a.pr_1_flg) as pr_1_cnt
from (
select
 a.*,
 case when cause4term = 2 then 1 else 0 end as pr_1_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_1;


--==03 Предиктор 2: Длительность < 15 мин. + Трафик > 1МБ + скорость < 1,5 Мб/сек - плохой опыт, считаем кол-во интервалов

--drop table step_2;
--delete step_2;

--show table step_2;

create multiset volatile table step_2 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_2_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 15 сек.
--create multiset volatile table step_2, no log as (
insert into step_2
select
 a.msisdn,
 sum(a.pr_2_flg) as pr_2_cnt
from (
select
 a.*,
 case when (duration <= 900 and downlink_mb > 1 and downlink_megabit_sec <= 1.500) then 1 else 0 end as pr_2_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;

--select top 100 * from step_2;


--==04 Предиктор 3: downlink_mb = 0 + uplink_mb > 0 + tech = 4G - плохой опыт, считаем кол-во интервалов

--drop table step_3;
--delete step_3;

--show table step_3;

create multiset volatile table step_3 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_3_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 20 сек.
--create multiset volatile table step_3, no log as (
insert into step_3
select
 a.msisdn,
 sum(a.pr_3_flg) as pr_3_cnt
from (
select
 a.*,
 case when (downlink_mb = 0 and uplink_mb > 0 and tech = '4G') then 1 else 0 end as pr_3_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;

--select top 100 * from step_3;


--==05 Предиктор 4: Любой интервал 2G маркируем, считаем кол-во интервалов

--drop table step_4;
--delete step_4;

--show table step_4;

create multiset volatile table step_4 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_4_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 19 сек.
--create multiset volatile table step_4, no log as (
insert into step_4
select
 a.msisdn,
 sum(a.pr_4_flg) as pr_4_cnt
from (
select
 a.*,
 case when tech = '2G' then 1 else 0 end as pr_4_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_4;


--==06 Предиктор 5: Длительность < 15 мин. + Трафик < 0,5 МБ + Скорость < 1,5 Мб/сек - определить опыт, считаем кол-во интервалов

--drop table step_5;
--delete step_5;

--show table step_5;

create multiset volatile table step_5 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_5_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 20 сек.
--create multiset volatile table step_5, no log as (
insert into step_5
select
 a.msisdn,
 sum(a.pr_5_flg) as pr_5_cnt
from (
select
 a.*,
 case when (duration <= 900 and downlink_mb < 0.500 and downlink_megabit_sec <= 1.500) then 1 else 0 end as pr_5_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_5;


--==07 Предиктор 6: Длительность < 15 мин. + Трафик > 0,5 МБ + Скорость < 1,5 Мб/сек - плохой опыт, считаем кол-во интервалов

--drop table step_6;
--delete step_6;

--show table step_6;

create multiset volatile table step_6 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_6_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 11 сек.
--create multiset volatile table step_6, no log as (
insert into step_6
select
 a.msisdn,
 sum(a.pr_6_flg) as pr_6_cnt
from (
select
 a.*,
 case when (duration <= 900 and downlink_mb > 0.500 and downlink_megabit_sec <= 1.500) then 1 else 0 end as pr_6_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_6;


--==08 Предиктор 7: Смена tech от интервала к интервалу 4G-->3G с уменьшением скорости - плохой опыт, считаем кол-во интервалов

--drop table step_7;
--delete step_7;

--show table step_7;

create multiset volatile table step_7 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_7_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 1 мин. 35 сек.
--create multiset volatile table step_7, no log as (
insert into step_7
select
 a.msisdn,
 sum(a.pr_7_flg) as pr_7_cnt
from (
select
 a.*,
 case when (a.tech = '4G' and a.tech_post = '3G' and a.downlink_megabit_sec_post < a.downlink_megabit_sec) then 1 else 0 end as pr_7_flg
from (
select
 a.*,
 coalesce(lead (a.tech) over (partition by a.msisdn order by a.start_dttm),a.tech) as tech_post,                                                    --следующая технология в интервале
 coalesce(lead (a.downlink_megabit_sec) over (partition by a.msisdn order by a.start_dttm),a.downlink_megabit_sec) as downlink_megabit_sec_post     --следующая скорость в интервале
from subs a
--where 1=1
-- and msisdn = '73519095588'
) a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_7;


--==09 Предиктор 8: Смена tech от интервала к интервалу 3G-->4G с увеличением скорости - хороший опыт, считаем кол-во интервалов

--drop table step_8;
--delete step_8;

--show table step_8;

create multiset volatile table step_8 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_8_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 44 сек.
--create multiset volatile table step_8, no log as (
insert into step_8
select
 a.msisdn,
 sum(a.pr_8_flg) as pr_8_cnt
from (
select
 a.*,
 case when (a.tech = '3G' and a.tech_post = '4G' and a.downlink_megabit_sec_post > a.downlink_megabit_sec) then 1 else 0 end as pr_8_flg
from (
select
 a.*,
 coalesce(lead (a.tech) over (partition by a.msisdn order by a.start_dttm),a.tech) as tech_post,                                                    --следующая технология в интервале
 coalesce(lead (a.downlink_megabit_sec) over (partition by a.msisdn order by a.start_dttm),a.downlink_megabit_sec) as downlink_megabit_sec_post     --следующая скорость в интервале
from subs a
--where 1=1
-- and msisdn = '73519095588'
) a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_8;

/* Предикторы от Мустафы
--1. Длительность > 14 мин. И Трафик < 1МБ - мусор
--2. РГ = 10829 - мусор
3. cause4term = 2 - плохой опыт
4. Длительность < 15 мин. И Трафик > 1МБ И скорость < 1,5 Мб/сек - плохой опыт
5. downlink_mb = 0, uplink_mb >0 RAT_type =4G - плохой опыт
8. любой интервал 2G маркируем, определяем долю событий на клиента
9. Длительность < 15 мин. И Трафик < 0,5 МБ И скорость < 1,5 Мб/сек - определить опыт
10. Длительность < 15 мин. И Трафик > 0,5 МБ И скорость < 1,5 Мб/сек - плохой опыт
6. смена RAT_type от интервала к интервалу 4G-->3G с уменьшением скорости - плохой опыт
7. смена RAT_type от интервала к интервалу 3G-->4G с увеличением скорости - хороший опыт
*/


--==10 Предиктор 9: Смена tech от интервала к интервалу 4G-->2G - плохой опыт, считаем кол-во интервалов

--drop table step_9;
--delete step_9;

--show table step_9;

create multiset volatile table step_9 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_9_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 37 сек.
--create multiset volatile table step_9, no log as (
insert into step_9
select
 a.msisdn,
 sum(a.pr_9_flg) as pr_9_cnt
from (
select
 a.*,
 case when (a.tech = '4G' and a.tech_post = '2G') then 1 else 0 end as pr_9_flg
from (
select
 a.*,
 coalesce(lead (a.tech) over (partition by a.msisdn order by a.start_dttm),a.tech) as tech_post,                                                    --следующая технология в интервале
 coalesce(lead (a.downlink_megabit_sec) over (partition by a.msisdn order by a.start_dttm),a.downlink_megabit_sec) as downlink_megabit_sec_post     --следующая скорость в интервале
from subs a
--where 1=1
-- and msisdn = '73519095588'
) a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_9;

--==11 Предиктор 10: Смена tech от интервала к интервалу 3G-->2G - плохой опыт, считаем кол-во интервалов

--drop table step_10;
--delete step_10;

--show table step_10;

create multiset volatile table step_10 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_10_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 50 сек.
--create multiset volatile table step_10, no log as (
insert into step_10
select
 a.msisdn,
 sum(a.pr_10_flg) as pr_10_cnt
from (
select
 a.*,
 case when (a.tech = '3G' and a.tech_post = '2G') then 1 else 0 end as pr_10_flg
from (
select
 a.*,
 coalesce(lead (a.tech) over (partition by a.msisdn order by a.start_dttm),a.tech) as tech_post,                                                    --следующая технология в интервале
 coalesce(lead (a.downlink_megabit_sec) over (partition by a.msisdn order by a.start_dttm),a.downlink_megabit_sec) as downlink_megabit_sec_post     --следующая скорость в интервале
from subs a
--where 1=1
-- and msisdn = '73519095588'
) a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_10;


--==12 Кол-во интервалов на абонента

--drop table step_11;
--delete step_11;

--show table step_11;

create multiset volatile table step_11 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 int_cnt integer)
primary index ( msisdn )
on commit preserve rows;

--время 2 сек.
--create multiset volatile table step_11, no log as (
insert into step_11
select
 a.msisdn,
 count(*) as int_cnt
from subs a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_11;


--==13 Общий трафик абонента + трафик по рейтинг группам: MailRu Group Video Services (Видео в ВК и ОК), Youtube, TikTok

--show table step_12;

create multiset volatile table step_12 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 total_mb float,
 mail_mb float,
 youtube_mb float,
 tiktok_mb float)
primary index (msisdn)
on commit preserve rows;


--время 12 сек.
--create multiset volatile table step_12, no log as (
insert into step_12
select
 a.msisdn,
 sum(downlink_mb) as total_mb,
 sum(case when a.rg_id = 10845 then cast(downlink_mb as float) else 0 end) as mail_mb,
 sum(case when a.rg_id = 10823 then cast(downlink_mb as float) else 0 end) as youtube_mb,
 sum(case when a.rg_id = 10847 then cast(downlink_mb as float) else 0 end) as tiktok_mb
from subs a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_12;


--==14 Предиктор 11: uplink_mb = 0 + downlink_mb > 1 +  downlink_megabit_sec < 1.5 - плохой опыт, считаем кол-во интервалов

--drop table step_13;
--delete step_13;

--show table step_13;
create multiset volatile table step_13 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_11_cnt integer)
primary index ( msisdn )
on commit preserve rows;

--время 2 сек.
--create multiset volatile table step_13, no log as (
insert into step_13
select
 a.msisdn,
 sum(a.pr_11_flg) as pr_11_cnt
from (
select
 a.*,
 case when (uplink_mb = 0 and downlink_mb > 1.000 and downlink_megabit_sec <= 1.500) then 1 else 0 end as pr_11_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_13;


--==15 Предиктор 12: Интервал удовлетворяющий условию что трафик приходится на дневное время, считаем кол-во интервалов
/*
ночь - часы с 0 до 8:00 и с 20:00 до 24:00
будни - часы с 8 до 20 в рабочие дни
выходные - часы с 8 до 20 в выходные и праздничные дни
*/

--drop table step_14;
--delete step_14;

--show table step_14;

create multiset volatile table step_14 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_12_cnt integer)
primary index ( msisdn )
on commit preserve rows;

--время 4 сек.
--create multiset volatile table step_14, no log as (
insert into step_14
select
 a.msisdn,
 sum(a.daytime_flg) as pr_12_cnt
from (
select
 a.*,
 cast(cast (a.start_dttm as date) as timestamp(0)) as n,
 n + interval '08:00:00' hour to second as start_time,
 n + interval '20:00:00' hour to second as end_time,
 case when (a.start_dttm >= start_time and a.start_dttm < end_time) then 1 else 0 end as daytime_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_14;


--==16 Предиктор 13: Интервал удовлетворяющий условию что трафик приходится на вечернее время, считаем кол-во интервалов
/*
ночь - часы с 0 до 8:00 и с 20:00 до 24:00
будни - часы с 8 до 20 в рабочие дни
выходные - часы с 8 до 20 в выходные и праздничные дни
*/

--drop table step_15;
--delete step_15;

--show table step_15;

create multiset volatile table step_15 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_13_cnt integer)
primary index ( msisdn )
on commit preserve rows;

--время 3 сек.
--create multiset volatile table step_15, no log as (
insert into step_15
select
 a.msisdn,
 sum(a.night_flg) as pr_13_cnt
from (
select
 a.*,
 cast(cast (a.start_dttm as date) as timestamp(0)) as n,
 cast(cast (a.start_dttm as date) + 1 as timestamp(0)) as n2,
 n + interval '20:00:00' hour to second as start_time,
 n2 + interval '00:00:00' hour to second as end_time,
 case when (a.start_dttm >= start_time and a.start_dttm < end_time) then 1 else 0 end as night_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_15;


--==17 Предиктор 14: Интервал удовлетворяющий условию что трафик приходится на ночное время, считаем кол-во интервалов
/*
ночь - часы с 0 до 8:00 и с 20:00 до 24:00
будни - часы с 8 до 20 в рабочие дни
выходные - часы с 8 до 20 в выходные и праздничные дни
*/

--drop table step_16;
--delete step_16;

--show table step_16;

create multiset volatile table step_16 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_14_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 4 сек.
--create multiset volatile table step_16, no log as (
insert into step_16
select
 a.msisdn,
 sum(a.night2_flg) as pr_14_cnt
from (
select
 a.*,
 cast(cast (a.start_dttm as date) as timestamp(0)) as n,
 n + interval '00:00:00' hour to second as start_time,
 n + interval '08:00:00' hour to second as end_time,
 case when (a.start_dttm >= start_time and a.start_dttm < end_time) then 1 else 0 end as night2_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_16;


--== 18 Объем трафика приходящийся на рабочие/выходные дни дни

--drop table step_17;
--delete step_17;

--show table step_17;

create multiset volatile table step_17 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 work_mb float,
 not_work_mb float)
primary index ( msisdn )
on commit preserve rows;


--Сбор статистики
COLLECT STATISTICS
 COLUMN (START_DTTM)
ON subs;


--время 20 сек.
--create multiset volatile table step_17, no log as (
insert into step_17
select
 a.msisdn,
 sum(case when isBusinessDay = 1 then cast(a.downlink_mb as float) end) as work_mb,
 sum(case when isBusinessDay = 0 then cast(a.downlink_mb as float) end) as not_work_mb
from (
select
 a.*,
 cast(a.start_dttm as date) as start_date,
 t1.isBusinessDay
from subs a
left join sys_calendar.businesscalendar as t1 on start_date = t1.calendar_date
 and t1.calendar_date >= :c_sdate
 and t1.calendar_date < :c_edate
-- and t1.calendar_date >= date '2022-03-23'
-- and t1.calendar_date < date '2022-04-08'
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_17;

/*
2022-01-24 00:00:22,2022-02-08 23:59:37
select
 min(start_dttm) as c_sdate,
 max(start_dttm) as c_edate
from subs
where report_date = date '2022-02-08';
*/



--==19 Предиктор 15: Интервал с технологией 2GБ + downlink_mb > 1 - плохой опыт, считаем кол-во интервалов

--drop table step_18;
--delete step_18;

--show table step_18;

create multiset volatile table step_18 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_15_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 
--create multiset volatile table step_18, no log as (
insert into step_18
select
 a.msisdn,
 sum(a.pr_15_flg) as pr_15_cnt
from (
select
 a.*,
 case when (tech = '2G' and downlink_mb > 1.000) then 1 else 0 end as pr_15_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_18;


--==20 Предиктор 16: Кол-во уникальных секторов, кол-во уникальных секторов 2G

--drop table step_19;
--delete step_19;

--show table step_19;

create multiset volatile table step_19 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 sector_cnt integer,
 sector_2g integer)
primary index ( msisdn )
on commit preserve rows;


--==Сбор статистики
COLLECT STATISTICS
COLUMN (SECTOR_NAME),
 COLUMN (MSISDN ,SECTOR_NAME)
ON subs;


--время 8 сек
--create multiset volatile table step_19, no log as (
insert into step_19
select
 a.msisdn,
 count (distinct a.sector_name) as sector_cnt,
 count(distinct case when a.tech = '2G' then a.sector_name end) as sector_2g
from subs a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--==21 Предиктор 17: Интервал с технологией 4G + downlink_mb < 1.5 - плохой опыт, считаем кол-во интервалов

--drop table step_20;
--delete step_20;

--show table step_20;

create multiset volatile table step_20 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_17_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 
--create multiset volatile table step_20, no log as (
insert into step_20
select
 a.msisdn,
 sum(a.pr_17_flg) as pr_17_cnt
from (
select
 a.*,
 case when (tech = '4G' and downlink_mb < 1.500) then 1 else 0 end as pr_17_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_20;


--==22 Предиктор 18: Интервал с технологией 4G + downlink_megabit_sec <= 1.500 - плохой опыт, считаем кол-во интервалов

--drop table step_20;
--delete step_20;

--show table step_20;

create multiset volatile table step_21 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_18_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 
--create multiset volatile table step_21, no log as (
insert into step_21
select
 a.msisdn,
 sum(a.pr_18_flg) as pr_18_cnt
from (
select
 a.*,
 case when (tech = '4G' and downlink_megabit_sec <= 1.500) then 1 else 0 end as pr_18_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_21;


--==================================================================================================
/*
Дополнительно предлагаю в модель добавить след. комбинации предикторов:
PR_51 - длительность < 15 мин. + трафик > 0,2 Мб + скорость < 0,3 Мб - плохой опыт, считаем интервалы Для уточнения объёма трафика, лучше построить гистограмму распределения.
PR_52 - длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL < 0,3 Мб/сек. + DL < 1,5Мб/сек.  плохой опыт, считаем интервалы
PR_53 - длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL < 0,3 Мб/сек. + DL > 1,5Мб/сек.  хороший опыт, считаем интервалы
PR_54 - длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL > 0,3 Мб/сек. + DL < 1,5Мб/сек.  плохой опыт, считаем интервалы
PR_55 - длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL > 0,3 Мб/сек. + DL > 1,5Мб/сек.  хороший опыт, считаем интервалы 
PR_56 - downlink <> 0 + uplink=0 + технология 4G - строится на том, что по uplink обязательно должен бегать служебный трафик.
*/

--==23 Предиктор 51: Интервал с технологией 4G + длительность < 15 мин. + трафик > 0,2 Мб + скорость < 0,3 Мб - плохой опыт, считаем интервалы

--drop table step_51;
--delete step_51;

--show table step_51;


create multiset volatile table step_51 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_51_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 
--create multiset volatile table step_51, no log as (
insert into step_51
select
 a.msisdn,
 sum(a.pr_51_flg) as pr_51_cnt
from (
select
 a.*,
 extract(hour from start_dttm) as hour_num,
 case when (tech = '4G' and duration <= 905 and uplink_mb > 0.200 and uplink_megabit_sec < 0.300) then 1 else 0 end as pr_51_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_51;


--24 Предиктор 52: Интервал с технологией 4G + длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL < 0,3 Мб/сек. + DL < 1,5Мб/сек.  плохой опыт, считаем интервалы

--drop table step_52;
--delete step_52;

--show table step_52;


create multiset volatile table step_52 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_52_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 
--create multiset volatile table step_52, no log as (
insert into step_52
select
 a.msisdn,
 sum(a.pr_52_flg) as pr_52_cnt
from (
select
 a.*,
 extract(hour from start_dttm) as hour_num,
 case when (tech = '4G' and duration <= 905 and uplink_mb > 0.200 and uplink_megabit_sec < 0.300 and downlink_megabit_sec < 1.500) then 1 else 0 end as pr_52_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_52;


--==25 Предиктор 53: Интервал с технологией 4G + длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL < 0,3 Мб/сек. + DL > 1,5Мб/сек.  плохой опыт, считаем интервалы

--drop table step_53;
--delete step_53;

--show table step_53;


create multiset volatile table step_53 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_53_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 
--create multiset volatile table step_53, no log as (
insert into step_53
select
 a.msisdn,
 sum(a.pr_53_flg) as pr_53_cnt
from (
select
 a.*,
 extract(hour from start_dttm) as hour_num,
 case when (tech = '4G' and duration <= 905 and uplink_mb > 0.200 and uplink_megabit_sec < 0.300 and downlink_megabit_sec > 1.500) then 1 else 0 end as pr_53_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_53;


--==26 Предиктор 54: Интервал с технологией 4G + длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL > 0,3 Мб/сек. + DL < 1,5Мб/сек.  плохой опыт, считаем интервалы

--drop table step_54;
--delete step_54;

--show table step_54;

create multiset volatile table step_54 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_54_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 
--create multiset volatile table step_54, no log as (
insert into step_54
select
 a.msisdn,
 sum(a.pr_54_flg) as pr_54_cnt
from (
select
 a.*,
 extract(hour from start_dttm) as hour_num,
 case when (tech = '4G' and duration <= 905 and uplink_mb > 0.200 and uplink_megabit_sec > 0.300 and downlink_megabit_sec < 1.500) then 1 else 0 end as pr_54_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_54;


--==27 Предиктор 55: Интервал с технологией 4G + длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL > 0,3 Мб/сек. + DL > 1,5Мб/сек.  плохой опыт, считаем интервалы

--drop table step_55;
--delete step_55;

--show table step_55;

create multiset volatile table step_55 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_55_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 
--create multiset volatile table step_55, no log as (
insert into step_55
select
 a.msisdn,
 sum(a.pr_55_flg) as pr_55_cnt
from (
select
 a.*,
 extract(hour from start_dttm) as hour_num,
 case when (tech = '4G' and duration <= 905 and uplink_mb > 0.200 and uplink_megabit_sec > 0.300 and downlink_megabit_sec > 1.500) then 1 else 0 end as pr_55_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_55;


--==28 Предиктор 56: Интервал с технологией 4G + downlink <> 0 + uplink=0 + технология 4G - строится на том, что по uplink обязательно должен бегать служебный трафик

--drop table step_56;
--delete step_56;

--show table step_56;

create multiset volatile table step_56 ,no log (
 msisdn varchar(20) character set latin not casespecific,
 pr_56_cnt integer)
primary index ( msisdn )
on commit preserve rows;


--время 
--create multiset volatile table step_56, no log as (
insert into step_56
select
 a.msisdn,
 sum(a.pr_56_flg) as pr_56_cnt
from (
select
 a.*,
 extract(hour from start_dttm) as hour_num,
 case when (tech = '4G' and downlink_mb <> 0 and uplink_mb = 0) then 1 else 0 end as pr_56_flg
from subs a
) a
group by 1
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


--select top 100 * from step_56;


--=================================================================================================

--==29 Финальная витрина

--delete subs_2;
--drop table subs_2;

--show table subs_2;

create multiset volatile table subs_2 ,no log (
 report_date date format 'yy/mm/dd',
 rep_date date format 'yy/mm/dd',
 min_date date format 'yy/mm/dd',
 branch_id decimal(4,0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set latin not casespecific,
 roam_flg byteint
)
primary index (msisdn)
on commit preserve rows;


insert into subs_2
--select a.* from (
select
 a.report_date,
 a.rep_date,
 a.min_date,
 a.branch_id,
 a.subs_id,
 a.msisdn,
 case when a.branch_id = 95 then 0 else 1 end as roam_flg
from (
select
 distinct a.msisdn,
 a.report_date,
 a.branch_id,
 a.subs_id,
 max(cast(a.start_dttm as date)) as rep_date,
 min(cast(a.start_dttm as date)) as min_date
from subs a
group by 1,2,3,4
) a
--
--left join prd2_dds_v.phone_number_2 t1 on a.msisdn = t1.msisdn
-- and (a.rep_date >= t1.stime and a.rep_date < t1.etime)
--) a
--where 1=1
-- and a.subs_id is not null
;

--select distinct region_id from subs;
--select distinct branch_id from subs;


--select top 100 * from subs_2;





--время 1 мин. 46 сек.
COLLECT STATISTICS COLUMN (MSISDN) ON subs_2;
COLLECT STATISTICS COLUMN (MSISDN) ON step_1;
COLLECT STATISTICS COLUMN (MSISDN) ON step_2;
COLLECT STATISTICS COLUMN (MSISDN) ON step_3;
COLLECT STATISTICS COLUMN (MSISDN) ON step_4;
COLLECT STATISTICS COLUMN (MSISDN) ON step_5;
COLLECT STATISTICS COLUMN (MSISDN) ON step_6;
COLLECT STATISTICS COLUMN (MSISDN) ON step_7;
COLLECT STATISTICS COLUMN (MSISDN) ON step_8;
COLLECT STATISTICS COLUMN (MSISDN) ON step_9;
COLLECT STATISTICS COLUMN (MSISDN) ON step_10;
COLLECT STATISTICS COLUMN (MSISDN) ON step_11;
COLLECT STATISTICS COLUMN (MSISDN) ON step_12;
COLLECT STATISTICS COLUMN (MSISDN) ON step_13;
COLLECT STATISTICS COLUMN (MSISDN) ON step_14;
COLLECT STATISTICS COLUMN (MSISDN) ON step_15;
COLLECT STATISTICS COLUMN (MSISDN) ON step_16;
COLLECT STATISTICS COLUMN (MSISDN) ON step_17;
COLLECT STATISTICS COLUMN (MSISDN) ON step_18;
COLLECT STATISTICS COLUMN (MSISDN) ON step_19;
COLLECT STATISTICS COLUMN (MSISDN) ON step_20;
COLLECT STATISTICS COLUMN (MSISDN) ON step_21;
--
COLLECT STATISTICS COLUMN (MSISDN) ON step_51;
COLLECT STATISTICS COLUMN (MSISDN) ON step_52;
COLLECT STATISTICS COLUMN (MSISDN) ON step_53;
COLLECT STATISTICS COLUMN (MSISDN) ON step_54;
COLLECT STATISTICS COLUMN (MSISDN) ON step_55;
COLLECT STATISTICS COLUMN (MSISDN) ON step_56;


/*
select top 100 * from step_1;       --Предиктор 1: cause4term = 2 - плохой опыт, считаем кол-во интервалов
select top 100 * from step_2;       --Предиктор 2: Длительность < 15 мин. + Трафик > 1МБ + скорость < 1,5 Мб/сек - плохой опыт, считаем кол-во интервалов
select top 100 * from step_3;       --Предиктор 3: downlink_mb = 0 + uplink_mb > 0 + tech = 4G - плохой опыт, считаем кол-во интервалов
select top 100 * from step_4;       --Предиктор 4: Любой интервал 2G маркируем, считаем кол-во интервалов
select top 100 * from step_5;       --Предиктор 5: Длительность < 15 мин. + Трафик < 0,5 МБ + Скорость < 1,5 Мб/сек - определить опыт, считаем кол-во интервалов
select top 100 * from step_6;       --Предиктор 6: Длительность < 15 мин. + Трафик > 0,5 МБ + Скорость < 1,5 Мб/сек - плохой опыт, считаем кол-во интервалов
select top 100 * from step_7;       --Предиктор 7: Смена tech от интервала к интервалу 4G-->3G с уменьшением скорости - плохой опыт, считаем кол-во интервалов
select top 100 * from step_8;       --Предиктор 8: Смена tech от интервала к интервалу 3G-->4G с увеличением скорости - хороший опыт, считаем кол-во интервалов
select top 100 * from step_9;       --Предиктор 9: Смена tech от интервала к интервалу 4G-->2G - плохой опыт, считаем кол-во интервалов
select top 100 * from step_10;      --Предиктор 10: Смена tech от интервала к интервалу 3G-->2G - плохой опыт, считаем кол-во интервалов
select top 100 * from step_11;      --Кол-во интервалов на абонента
select top 100 * from step_12;      --Общий трафик абонента + трафик по рейтинг группам: MailRu Group Video Services (Видео в ВК и ОК), Youtube, TikTok
select top 100 * from step_13;      --Предиктор 11: uplink_mb = 0 + downlink_mb > 1 +  downlink_megabit_sec < 1.5 - плохой опыт, считаем кол-во интервалов
select top 100 * from step_14;      --Предиктор 12: Интервал удовлетворяющий условию что трафик приходится на дневное время, считаем кол-во интервалов
select top 100 * from step_15;      --Предиктор 13: Интервал удовлетворяющий условию что трафик приходится на вечернее время, считаем кол-во интервалов
select top 100 * from step_16;      --Предиктор 14: Интервал удовлетворяющий условию что трафик приходится на ночное время, считаем кол-во интервалов
select top 100 * from step_17;      --Объем трафика приходящийся на рабочие/выходные дни дни
select top 100 * from step_18;      --Предиктор 15: Интервал с технологией 2G + downlink_mb > 1 - плохой опыт, считаем кол-во интервалов
select top 100 * from step_19;      --Предиктор 16: Кол-во уникальных секторов, кол-во уникальных секторов 2G
select top 100 * from step_20;      --Предиктор 17: Интервал с технологией 4G + downlink_mb < 1,5 - плохой опыт, считаем кол-во интервалов
select top 100 * from step_21;      --Предиктор 18: Интервал с технологией 4G + downlink_megabit_sec < 1.5 - плохой опыт, считаем кол-во интервалов
*/


--select top 100 * from uat_ca.mc_gprs_65_hadoop_tg;


--время 
--create multiset table uat_ca.mc_gprs_65_hadoop_tg as (
insert into uat_ca.mc_gprs_40_hadoop_tg
select
 a.report_date,
 a.rep_date,
 a.min_date,
 a.branch_id,
 a.subs_id,
 a.msisdn,
 a.roam_flg,
--
 t11.int_cnt,
 t12.total_mb,
 t12.mail_mb,
 t12.youtube_mb,
 t12.tiktok_mb,
 t17.work_mb,
 t17.not_work_mb,
 t19.sector_cnt,
 t19.sector_2g as sector_2g_cnt,
 t1.pr_1_cnt as pr_1,
 t2.pr_2_cnt as pr_2,
 t3.pr_3_cnt as pr_3,
 t4.pr_4_cnt as pr_4,
 t5.pr_5_cnt as pr_5,
 t6.pr_6_cnt as pr_6,
 t7.pr_7_cnt as pr_7,
 t8.pr_8_cnt as pr_8,
 t9.pr_9_cnt as pr_9,
 t10.pr_10_cnt as pr_10,
 t13.pr_11_cnt as pr_11,
 t14.pr_12_cnt as pr_12,
 t15.pr_13_cnt as pr_13,
 t16.pr_14_cnt as pr_14,
 t18.pr_15_cnt as pr_15,
 t20.pr_17_cnt as pr_16,
 t21.pr_18_cnt as pr_17,
--
 t51.pr_51_cnt as pr_51,
 t52.pr_52_cnt as pr_52,
 t53.pr_53_cnt as pr_53,
 t54.pr_54_cnt as pr_54,
 t55.pr_55_cnt as pr_55,
 t56.pr_56_cnt as pr_56
from subs_2 a
--
left join step_1 t1 on a.msisdn = t1.msisdn       --
left join step_2 t2 on a.msisdn = t2.msisdn       --
left join step_3 t3 on a.msisdn = t3.msisdn       --
left join step_4 t4 on a.msisdn = t4.msisdn       --
left join step_5 t5 on a.msisdn = t5.msisdn       --
left join step_6 t6 on a.msisdn = t6.msisdn       --
left join step_7 t7 on a.msisdn = t7.msisdn       --
left join step_8 t8 on a.msisdn = t8.msisdn       --
left join step_9 t9 on a.msisdn = t9.msisdn       --
left join step_10 t10 on a.msisdn = t10.msisdn     --
left join step_11 t11 on a.msisdn = t11.msisdn     --
left join step_12 t12 on a.msisdn = t12.msisdn     --
left join step_13 t13 on a.msisdn = t13.msisdn     --
left join step_14 t14 on a.msisdn = t14.msisdn     --
left join step_15 t15 on a.msisdn = t15.msisdn     --
left join step_16 t16 on a.msisdn = t16.msisdn     --
left join step_17 t17 on a.msisdn = t17.msisdn     --
left join step_18 t18 on a.msisdn = t18.msisdn     --
left join step_19 t19 on a.msisdn = t19.msisdn     --
left join step_20 t20 on a.msisdn = t20.msisdn     --
left join step_21 t21 on a.msisdn = t21.msisdn     --
--
left join step_51 t51 on a.msisdn = t51.msisdn     --
left join step_52 t52 on a.msisdn = t52.msisdn     --
left join step_53 t53 on a.msisdn = t53.msisdn     --
left join step_54 t54 on a.msisdn = t54.msisdn     --
left join step_55 t55 on a.msisdn = t55.msisdn     --
left join step_56 t56 on a.msisdn = t56.msisdn     --
--) with no data
--primary index (subs_id)
;


drop table subs;
drop table subs_2;
drop table step_1;
drop table step_2;
drop table step_3;
drop table step_4;
drop table step_5;
drop table step_6;
drop table step_7;
drop table step_8;
drop table step_9;
drop table step_10;
drop table step_11;
drop table step_12;
drop table step_13;
drop table step_14;
drop table step_15;
drop table step_16;
drop table step_17;
drop table step_18;
drop table step_19;
drop table step_20;
drop table step_21;
--
drop table step_51;
drop table step_52;
drop table step_53;
drop table step_54;
drop table step_55;
drop table step_56;


END;



--==Даты для процедуры

select
 create_date,
 cast(min(start_dttm) as date) as c_sdate,
 cast(max(start_dttm) as date) + interval '1' day as e_sdate
from uat_ca.sample_26_hadoop
where 1=1
 and branch_id = 95
group by 1
order by 1;


select top 100 * from uat_ca.mc_gprs_65_hadoop_tg;

--==2022
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-04', date'2022-04-20', date'2022-05-04');       --21 мин. 02 сек.

call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-05', date'2022-04-21', date'2022-05-05');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-06', date'2022-04-22', date'2022-05-06');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-09', date'2022-04-25', date'2022-05-09');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-10', date'2022-04-26', date'2022-05-10');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-11', date'2022-04-27', date'2022-05-11');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-12', date'2022-04-28', date'2022-05-12');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-13', date'2022-04-29', date'2022-05-13');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-16', date'2022-05-02', date'2022-05-16');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-18', date'2022-05-04', date'2022-05-18');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-19', date'2022-05-05', date'2022-05-19');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-20', date'2022-05-06', date'2022-05-20');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-23', date'2022-05-09', date'2022-05-23');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-24', date'2022-05-10', date'2022-05-24');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-25', date'2022-05-11', date'2022-05-25');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-26', date'2022-05-12', date'2022-05-26');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-27', date'2022-05-13', date'2022-05-27');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-30', date'2022-05-16', date'2022-05-30');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-05-31', date'2022-05-17', date'2022-05-31');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-01', date'2022-05-18', date'2022-06-01');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-02', date'2022-05-19', date'2022-06-02');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-03', date'2022-05-20', date'2022-06-03');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-04', date'2022-05-21', date'2022-06-04');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-06', date'2022-05-23', date'2022-06-06');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-07', date'2022-05-24', date'2022-06-07');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-08', date'2022-05-25', date'2022-06-08');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-09', date'2022-05-26', date'2022-06-09');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-10', date'2022-05-27', date'2022-06-10');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-11', date'2022-05-28', date'2022-06-11');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-13', date'2022-05-30', date'2022-06-13');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-14', date'2022-05-31', date'2022-06-14');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-15', date'2022-06-01', date'2022-06-15');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-16', date'2022-06-02', date'2022-06-16');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-17', date'2022-06-03', date'2022-06-17');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-20', date'2022-06-06', date'2022-06-20');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-22', date'2022-06-08', date'2022-06-22');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-24', date'2022-06-10', date'2022-06-24');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-25', date'2022-06-11', date'2022-06-25');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-27', date'2022-06-13', date'2022-06-27');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-28', date'2022-06-14', date'2022-06-28');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-29', date'2022-06-15', date'2022-06-29');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-06-30', date'2022-06-16', date'2022-06-30');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-01', date'2022-06-17', date'2022-07-01');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-02', date'2022-06-19', date'2022-07-02');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-04', date'2022-06-20', date'2022-07-04');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-05', date'2022-06-21', date'2022-07-05');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-06', date'2022-06-22', date'2022-07-06');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-07', date'2022-06-23', date'2022-07-07');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-08', date'2022-06-24', date'2022-07-08');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-12', date'2022-06-28', date'2022-07-12');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-13', date'2022-06-29', date'2022-07-13');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-14', date'2022-06-30', date'2022-07-14');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-15', date'2022-07-01', date'2022-07-15');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-18', date'2022-07-04', date'2022-07-18');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-19', date'2022-07-05', date'2022-07-19');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-20', date'2022-07-06', date'2022-07-19');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-21', date'2022-07-07', date'2022-07-21');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-22', date'2022-07-08', date'2022-07-22');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-25', date'2022-07-11', date'2022-07-25');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-26', date'2022-07-12', date'2022-07-26');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-27', date'2022-07-13', date'2022-07-27');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-28', date'2022-07-14', date'2022-07-28');
call uat_ca.mc_grps_tg_msk_hadoop (date'2022-07-29', date'2022-07-15', date'2022-07-29');       --5 час. 05 ми. 59 сек.



--delete uat_ca.mc_gprs_65_hadoop_tg;

select top 100 * from uat_ca.mc_gprs_40_hadoop_tg where report_date = date '2022-07-01';

select count(distinct subs_id), count(distinct msisdn), count(*) from uat_ca.mc_gprs_65_hadoop_tg;

lock row for access
select report_date, count(distinct subs_id), count(distinct msisdn), count(*) from uat_ca.mc_gprs_65_hadoop_tg group by 1 order by 1;


--=================================================================================================
--=================================================================================================
--=================================================================================================


--Абоненты С.Петербург: branch_id 8(88)

int_cnt         --Кол-во интервалов на абонента
total_mb        --Общий трафик абонента
mail_mb         --Трафик по рейтинге группе: MailRu Group Video Services (Видео в ВК и ОК)
youtube_mb      --Трафик по рейтинге группе: Youtube
tiktok_mb       --Трафик по рейтинге группе: TikTok
work_mb         --Объем трафика приходящийся на рабочие дни: Понедельник - пятница
not_work_mb     --Объем трафика приходящийся на выходные: Суббота-воскресенье
sector_cnt      --Уникальные сектора абонента
sector_2g_cnt   --Уникальные сектора абонента

PR_1        --cause4term = 2 - плохой опыт, считаем кол-во интервалов
PR_2        --Длительность < 15 мин. + Трафик > 1МБ + скорость < 1,5 Мб/сек - плохой опыт, считаем кол-во интервалов
PR_3        --downlink_mb = 0 + uplink_mb > 0 + tech = 4G - плохой опыт, считаем кол-во интервалов
PR_4        --Любой интервал 2G маркируем, считаем кол-во интервалов
PR_5        --Длительность < 15 мин. + Трафик < 0,5 МБ + Скорость < 1,5 Мб/сек - определить опыт, считаем кол-во интервалов
PR_6        --Длительность < 15 мин. + Трафик > 0,5 МБ + Скорость < 1,5 Мб/сек - плохой опыт, считаем кол-во интервалов
PR_7        --Смена tech от интервала к интервалу 4G->3G с уменьшением скорости - плохой опыт, считаем кол-во интервалов
PR_8        --Смена tech от интервала к интервалу 3G->4G с увеличением скорости - хороший опыт, считаем кол-во интервалов
PR_9        --Смена tech от интервала к интервалу 4G->2G - плохой опыт, считаем кол-во интервалов
PR_10       --Смена tech от интервала к интервалу 3G->2G - плохой опыт, считаем кол-во интервалов
PR_11       --uplink_mb = 0 + downlink_mb > 1 +  downlink_megabit_sec < 1.5 - плохой опыт, считаем кол-во интервалов
PR_12       --Интервал удовлетворяющий условию что трафик приходится на дневное время, считаем кол-во интервалов
PR_13       --Интервал удовлетворяющий условию что трафик приходится на вечернее время, считаем кол-во интервалов
PR_14       --Интервал удовлетворяющий условию что трафик приходится на ночное время, считаем кол-во интервалов
PR_15       --Интервал с технологией 2G + downlink_mb > 1 - плохой опыт, считаем кол-во интервалов
PR_16       --Кол-во уникальных секторов, кол-во уникальных секторов 2G


Дополнительно предлагаю в модель добавить след. комбинации предикторов:
PR_51       --длительность < 15 мин. + трафик > 0,2 Мб + скорость < 0,3 Мб - плохой опыт, считаем интервалы Для уточнения объёма трафика, лучше построить гистограмму распределения.
PR_52       --длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL < 0,3 Мб/сек. + DL < 1,5Мб/сек.  плохой опыт, считаем интервалы
PR_53       --длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL < 0,3 Мб/сек. + DL > 1,5Мб/сек.  хороший опыт, считаем интервалы
PR_54       --длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL > 0,3 Мб/сек. + DL < 1,5Мб/сек.  плохой опыт, считаем интервалы
PR_55       --длительность < 15 мин. + трафик > 0,2 Мб + скорость: UL > 0,3 Мб/сек. + DL > 1,5Мб/сек.  хороший опыт, считаем интервалы 
PR_56       --downlink <> 0 + uplink=0 + технология 4G - строится на том, что по uplink обязательно должен бегать служебный трафик.

--=================================================================================================
--=================================================================================================
--=================================================================================================


--==Объем/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'tele2_uat'
 and lower(tablename) in ('mc_gprs_25_2022_tg')
order by 1,2;


DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
TELE2_UAT       MC_GPRS_65_2022         MIKHAIL.CHUPIS      2022-02-11 18:33:17     2022-02-15 12:19:09     28,32           15,168


--=================================================================================================
--=================================================================================================
--=================================================================================================

show table uat_ca.mc_gprs_65_hadoop_tg;
--drop table uat_ca.mc_gprs_65_hadoop_tg;

create multiset table uat_ca.mc_gprs_40_hadoop_tg (
 report_date date format 'yy/mm/dd',
 rep_date date format 'yy/mm/dd',
 min_date date format 'yy/mm/dd',
 branch_id decimal(4,0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set latin not casespecific,
 roam_flg byteint,
 int_cnt integer,
 total_mb float,
 mail_mb float,
 youtube_mb float,
 tiktok_mb float,
 work_mb float,
 not_work_mb float,
 sector_cnt integer,
 sector_2g_cnt integer,
 pr_1 integer,
 pr_2 integer,
 pr_3 integer,
 pr_4 integer,
 pr_5 integer,
 pr_6 integer,
 pr_7 integer,
 pr_8 integer,
 pr_9 integer,
 pr_10 integer,
 pr_11 integer,
 pr_12 integer,
 pr_13 integer,
 pr_14 integer,
 pr_15 integer,
 pr_16 integer,
 pr_17 integer,
 pr_51 integer,
 pr_52 integer,
 pr_53 integer,
 pr_54 integer,
 pr_55 integer,
 pr_56 integer)
primary index (subs_id)
;