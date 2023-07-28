

diagnostic helpstats on for session;


In:
select top 100 * from uat_ca.v_nps_bu;                  --опросы nps
select top 100 * from uat_ca.vi_mi_call_ds_rtk;         --данные от коллег по обзвону группы абонентов по МИ с ответами 1-6
select top 100 * from uat_ca.v_poll_459;                --опрос удовлетворенности


select 
 create_date,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1
order by 1 desc;


Out:
select top 100 * from uat_ca.v_call_ds;
--uat_ca.mi_call_fin


--Статистика
COLLECT SUMMARY STATISTICS ON uat_ca.vi_mi_call_ds_rtk;


--==Проверка

select * from uat_ca.vi_mi_call_ds_rtk sample 0.10;


replace view uat_ca.v_call_ds as
lock row for access
select
 create_date,
 coalesce(call_date, date '2000-01-01') as call_date,
 case when call_status is not null then 1 else 0 end as call_flg,
 point_name,
 msisdn,
 coalesce(offer_flg,0) as offer_flg,
 coalesce(offer_type,'Не предложен') as offer_type,
 coalesce(rtk_voice_flg,0) as rtk_voice_flg,
 coalesce(rtk_voice_reason,'Другая РТК') as rtk_voice_reason,
 coalesce(rtk_mi_flg,0) as rtk_mi_flg,
 coalesce(rtk_mi_reason,'Другая РТК') as rtk_mi_reason,
 coalesce(rtk_ds_flg,0) as rtk_ds_flg,
 coalesce(rtk_ds_reason,'Другая РТК') as rtk_ds_reason,
 coalesce(rtk_monobrand_flg,0) as rtk_monobrand_flg,
 coalesce(rtk_monobrand_reason,'Другая РТК') as rtk_monobrand_reason,
 coalesce(rtk_roaming_flg,0) as rtk_roaming_flg,
 coalesce(rtk_roaming_reason,'Другая РТК') as rtk_roaming_reason,
 coalesce(rtk_dishonesty_flg,0) as rtk_dishonesty_flg,
 coalesce(rtk_dishonesty_reason,'Другая РТК') as rtk_dishonesty_reason,
 coalesce(rtk_lk_flg,0) as rtk_lk_flg,
 coalesce(rtk_lk_reason,'Другая РТК') as rtk_lk_reason,
 coalesce(rtk_annoying_flg,0) as rtk_annoying_flg,
 coalesce(rtk_annoying_reason,'Другая РТК') as rtk_annoying_reason,
 coalesce(rtk_tarif_flg,0) as rtk_tarif_flg,
 coalesce(rtk_tarif_reason,'Другая РТК') as rtk_tarif_reason,
 coalesce(error_detract,0) as error_detract,
 case when (rtk_voice_flg + rtk_mi_flg + rtk_ds_flg + rtk_monobrand_flg + rtk_roaming_flg + rtk_dishonesty_flg + rtk_lk_flg + rtk_annoying_flg + rtk_tarif_flg) > 0 then 1 else 0 end rtk_flg
from uat_ca.vi_mi_call_ds_rtk1
where 1=1
 and (point_name = 'Контакт-центр'
 or point_name = 'Мобильный интернет'
 )
;

--select distinct(point_name) from uat_ca.v_call_ds

--select * from uat_ca.v_call_ds where sum1 > 0 КЕЙС ПО КАЧЕСТВУ ДАННЫХ


--==Динамика

--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_call_ds
group by 1,2
order by 2 desc;

select
 weeknumber_of_year (call_date, 'ISO') as "неделя",
 trunc (call_date,'iw') as first_day_week,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_call_ds
group by 1,2
order by 2 desc;


--2 месячная динамика
select
 trunc (call_date,'mm') as "Месяц",
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_call_ds
group by 1
order by 1 desc;

--3 дневная динамика
select 
 call_date,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_call_ds
group by 1
order by 1 desc;

select
 create_date,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_call_ds
group by 1
order by 1 desc;



--==Пример выбора дублей
select * from uat_ca.v_call_ds
where 1=1
qualify count(*) over (partition by msisdn) > 1
;

--== дубли, где абонент давал комментарий
select * from (
select 
 msisdn, call_date, create_date
from uat_ca.v_call_ds
where 1=1
 and rtk_flg = 1) a
 qualify count(*) over (partition by msisdn) > 1
;


select top 100* from uat_ca.v_call_ds;

select * from (
select
 create_date,
 msisdn,
 count(*) as row_cnt
from uat_ca.v_call_ds
where 1=1
 and create_date = date '2022-07-27'
group by 1,2
) a
where 1=1
 and row_cnt > 1
;


--Кейсы по качеству данных

1. Две или более попыток дозвона до абонента с одним признаком дозвона                               -- оставляем запись с фагом call_flg = 1
2. Две или более попыток дозвона до абонента с признаками дозвона более чем в одном случае           -- формируем данные, задаем вопрос коллегам (брать по последней дате дозвона)
3. Две или более попыток дозвона до абонента с отсутствием признака дозвона                          -- берем по последней дате дозвона
4. В выгрузке данных присутствуют все точки контакта? 


--дубли
select
 msisdn,
 max(call_date) as last_call,
 count(*) call_cnt,
 sum(call_flg) as try_cnt
from (
select * from uat_ca.v_call_ds
--where 1=1
 --and create_date >= date '2022-07-18'
 --and create_date < date '2022-07-25'
qualify count(*) over (partition by msisdn) > 1
) a
group by 1
;



--Пример абонента с 3 попытками дозвона
select * from uat_ca.v_call_ds
where 1=1
-- and create_date >= date '2022-07-18'
 --and create_date < date '2022-07-25'
 and msisdn = '79507220725'
 
 
 select * from uat_ca.v_call_ds
where 1=1
-- and create_date >= date '2022-07-18'
 --and create_date < date '2022-07-25'
 and msisdn = '79006795447'
 
 
 
 
 select top 100 * from uat_ca.v_call_ds
 
 --Пример с комментарием и 2-мя дозвонами
 select * from uat_ca.v_call_ds
where 1=1
 and msisdn = '79000797657'

79507220725

;

select * from uat_ca.vi_mi_call_ds_rtk
where 1=1
 and create_date >= date '2022-07-18'
 and create_date < date '2022-07-25'
 and msisdn = '79771424285'
;


select
 msisdn,
 max(call_date) as last_call,
 count(*) call_cnt,
 sum(call_flg) as try_cnt
from (
select * from uat_ca.v_call_ds
where 1=1
 and create_date >= date '2022-07-18'
 and create_date < date '2022-07-25'
qualify count(*) over (partition by msisdn) > 1
) a
group by 1
;

select * from uat_ca.v_call_ds where msisdn = '79002559618';

select
 msisdn,
 max(case when call_flg = 0 then call_date end) as date_null,
 max(case when call_flg = 1 then call_date end) as date_one,
 case when date_null = date_one then 0
      when date_null < date_one then 1
      when date_null > date_one then -1
      else 99 end as quality_flg
from uat_ca.v_call_ds
where msisdn = '79002559618'
group by 1
;


--=================================================================================================
--=================================================================================================
--=================================================================================================

select * from uat_ca.vi_mi_call_ds_rtk

--==01 Шаг 1 Выбор корректных абонентов из дублей

--drop table tg;

--==при рассчете меняем диапазон дат
create multiset volatile table tg, no log as (
select * from (
select
 msisdn,
 min(create_date) as min_create_date,
 max(call_date) as last_call,
 count(*) call_cnt,
 sum(call_flg) as try_cnt
from (
select * from uat_ca.v_call_ds
where 1=1
-- and create_date >= date '2022-08-08'
 and create_date < date '2022-08-16'
qualify count(*) over (partition by msisdn) > 1
) a
group by 1
) a
where 1=1
 and try_cnt = 1
) with data
primary index (msisdn)
on commit preserve rows
;

select top 100 * from tg;
select count(*) from tg;        35



--drop table tg_2;

create multiset volatile table tg_2, no log as (
select
 msisdn,
 min(create_date) as create_date,
 max(case when call_flg = 0 then call_date end) as date_null,
 max(case when call_flg = 1 then call_date end) as date_one,
 case when date_null = date_one then 0
      when date_null < date_one then 1
      when date_null > date_one then -1
      else 99 end as quality_flg
from (
select a.* from uat_ca.v_call_ds a
inner join tg t1 on a.msisdn = t1.msisdn
 and a.create_date = t1.min_create_date
where 1=1
-- and a.create_date >= date '2022-08-08'
 and a.create_date < date '2022-08-16'
) a
group by 1
) with data
primary index (msisdn)
on commit preserve rows
;

select top 100 * from tg_2;
select count(*) from tg_2;        35

/*
select * from uat_ca.v_call_ds where msisdn = '79002559618';
select * from uat_ca.v_call_ds where msisdn = '79586493298';

select * from uat_ca.v_call_ds where msisdn = '79514240966';

select * from tg_2 where quality_flg = 1;

select * from uat_ca.v_call_ds where msisdn = '79514240966';
*/


--Абоненты соответствующие криетрию "качество данных"


--drop table tg_quality;

create multiset volatile table tg_quality, no log as (
select a.* from uat_ca.v_call_ds a
inner join tg_2 t1 on a.msisdn = t1.msisdn
 and a.create_date = t1.create_date
 and a.call_date = t1.date_one
 and t1.quality_flg = 1
where 1=1
-- and a.create_date >= date '2022-07-18'
 and a.create_date < date '2022-08-16'
) with data
primary index (msisdn)
on commit preserve rows
;


select top 100 * from tg_quality;
select count(*) from tg_quality;        35


--Абоненты без дублей

--2 131
select count(*) from uat_ca.v_call_ds
where 1=1
 and create_date >= date '2022-07-18'
 and create_date < date '2022-07-25'
;

--18 - уникальных, не уникальных 36
select count(*) from tg;

--2 114


--==02 Шаг 2 Абоненты без дублей + корректные абоненты с шага 1

--drop table subs_fin;

create multiset volatile table subs_fin, no log as (
--абоненты без дублей
select a.* from uat_ca.v_call_ds a
left join tg t1 on a.msisdn = t1.msisdn
 and a.create_date = t1.min_create_date
where 1=1
-- and a.create_date >= date '2022-08-08'
 and a.create_date < date '2022-08-16'
 and t1.msisdn is null
--абоенты соответствующие критерию "качество данных"
qualify row_number() over (partition by a.msisdn order by a.call_date desc) = 1
union all
select * from tg_quality
) with data
primary index (msisdn)
on commit preserve rows
;

select top 100 * from subs_fin;
select count(*) from subs_fin;      --4 391

select * from subs_fin
qualify count(*) over (partition by msisdn) > 1
;

--Контроль по абоненту: Корректные абоненты с двумя успешными попытками дозвона
select * from subs_fin where msisdn = '79000266529';



--drop table close_inhouse_with_DS_2;

create multiset volatile table close_inhouse_with_DS_2, no log as (
select
 a.create_date,
 t1.cluster_actual as cluster_name,
 t1.macroregion,
 t1.region,
 a.call_date,
 a.call_flg,
 a.point_name,
 t1.cust_id,
 t1.subs_id,
 a.msisdn,
 t1.lt_day,
 t1.lt_gr,
 t1.age,
 t1.gender,
 t1.mark_6,
 t1.class_mark_6,
 t1.micro_class_mark_6,
 t1.cluster_mark_6_pr_2,
 t1.servelat,
 t1.servelat_gr,
 t1.ltr as nps,
 t1.nps as nps_key,
 t1.tp_id,
 t1.tp_name,
 t1.tac,
 t1.arpu_segment,
 t1.segment_value,
 t1.mb_last_30 as data_mb,
 t1.gsb_bronze,
 t1.eralash,
 a.offer_flg,
 a.offer_type,
 a.rtk_voice_flg,
 a.rtk_voice_reason,
 a.rtk_mi_flg,
 a.rtk_mi_reason,
 a.rtk_ds_flg,
 a.rtk_ds_reason,
 a.rtk_monobrand_flg,
 a.rtk_monobrand_reason,
 a.rtk_roaming_flg,
 a.rtk_roaming_reason,
 a.rtk_dishonesty_flg,
 a.rtk_dishonesty_reason,
 a.rtk_lk_flg,
 a.rtk_lk_reason,
 a.rtk_annoying_flg,
 a.rtk_annoying_reason,
 a.rtk_tarif_flg,
 a.rtk_tarif_reason,
 a.error_detract,
--данные удовлетворенности, 459
 t2.mark_1,
 t2.mark_2,
 t2.mark_3,
 t2.mark_4,
 t2.ans_1,
 t2.ans_2,
 t2.ans_3,
 nvl2(t2.msisdn,1,0) as flg_459,
 a.rtk_flg
from subs_fin a
--
inner join uat_ca.v_nps_bu t1 on a.msisdn = t1.msisdn
 and t1.create_date >= date '2022-04-27'
 and t1.create_date < date '2022-08-16'
 and a.create_date = t1.create_date
--
left join uat_ca.v_poll_459 t2 on a.msisdn = t2.msisdn
 and t2.create_date >= date '2022-04-27'
 and t2.create_date < date '2022-08-16'
-- and a.create_date = t2.create_date
) with data
primary index (subs_id)
on commit preserve rows
;


select top 100 * from close_inhouse

select distinct(point_name) from close_inhouse_with_DS

select * from close_inhouse_with_DS
where point_name = 'Контакт-центр'

select top 100 * from close_inhouse;
select count(*) from close_inhouse;     --4 329

select * from close_inhouse
qualify count(*) over (partition by subs_id) > 1
;

delete close_inhouse
where 1=1
 and msisdn = '79229588662'
 and create_date =  date '2022-07-06'
 and ans_1 = 'Решен'
;


/*
select * from tmp
qualify count(*) over (partition by msisdn) > 1
;

select * from uat_ca.v_nps_bu
where 1=1
 and create_date >= date '2022-07-18'
 and create_date < date '2022-07-25'
 and msisdn = '79000949145';


select * from uat_ca.v_poll_459
where 1=1
 and create_date >= date '2022-07-18'
 and create_date < date '2022-07-25'
qualify count(*) over (partition by msisdn) > 1
;
*/


select top 100 * from close_inhouse;
select * from close_inhouse where msisdn = '79251450252';

select flg_459, count(*) from close_inhouse group by 1;
select * from close_inhouse where msisdn in ('79883862707', '79087176622', '79500361913', '79518285744', '79924267484');


--Для проверки
79883862707 79087176622 79500361913 79518285744 79924267484



select top 100 * from uat_ca.v_nps_bu where msisdn = '79251450252';
select top 100 * from uat_ca.vi_mi_call_ds_rtk where msisdn = '79251450252';
select top 100 * from uat_ca.v_poll_459 where msisdn = '79251450252';

select count(*) from uat_ca.vi_close_inhouse
select count(*) from uat_ca.vi_close_inhouse2

select top 100 * from uat_ca.vi_close_inhouse2
--==Финальная витрина на схеме

--drop table uat_ca.vi_close_inhouse2;
--drop table uat_ca.close_inhouse_with_DS_2

create multiset table uat_ca.close_inhouse_with_DS_2 as (
select * from close_inhouse_with_DS_2
) with data
primary index (subs_id)
;

create multiset table uat_ca.vi_close_inhouse2 as (
select * from close_inhouse
) with data
primary index (subs_id)
;

create multiset table uat_ca.vi_close_inhouse3 as (
select * from close_inhouse3
) with data
primary index (subs_id)
;


select top 100 * from uat_ca.vi_close_inhouse2;
select count(*) from uat_ca.vi_close_inhouse2;      --16 363

select top 100 * from uat_ca.vi_close_inhouse3;
select count(*) from uat_ca.vi_close_inhouse3;      --16 364


--================================================================================


--drop table vi_mi_call_ds_rtk;

create multiset volatile table vi_mi_call_ds_rtk, no log(
 msisdn varchar(20) character set unicode not casespecific,
 create_date date format 'yy/mm/dd',
 point_name varchar(25) character set unicode not casespecific,
 offer_flg byteint,
 offer_type varchar(20) character set unicode not casespecific,
 rtk_voice_flg byteint,
 rtk_voice_reason varchar(1024) character set unicode not casespecific,
 rtk_mi_flg byteint,
 rtk_mi_reason varchar(1024) character set unicode not casespecific,
 rtk_ds_flg byteint,
 rtk_ds_reason varchar(1024) character set unicode not casespecific,
 rtk_monobrand_flg byteint,
 rtk_monobrand_reason varchar(1024) character set unicode not casespecific,
 rtk_roaming_flg byteint,
 rtk_roaming_reason varchar(1024) character set unicode not casespecific,
 rtk_dishonesty_flg byteint,
 rtk_dishonesty_reason varchar(1024) character set unicode not casespecific,
 rtk_lk_flg byteint,
 rtk_lk_reason varchar(1024) character set unicode not casespecific,
 rtk_annoying_flg byteint,
 rtk_annoying_reason varchar(1024) character set unicode not casespecific,
 rtk_tarif_flg byteint,
 rtk_tarif_reason varchar(1024) character set unicode not casespecific,
 error_detract byteint,
 call_status varchar(25) character set unicode not casespecific,
 call_date date format 'yy/mm/dd')
primary index (msisdn)
on commit preserve rows
;

--drop table uat_ca.vi_mi_call_ds_rtk;

create multiset table uat_ca.vi_mi_call_ds_rtk1 as (
select * from vi_mi_call_ds_rtk
) with data
primary index (msisdn)
;

select count(*) from vi_mi_call_ds_rtk

select * from vi_mi_call_ds_rtk where call_date < date '2022-05-05'

select count (*) from  vi_mi_call_ds_rtk

select count(*) from vi_mi_call_ds_rtk
--=================================================================================================
--=================================================================================================
--=================================================================================================

--avg(cast(call_status as float))
---% дозвона 58% 
select 
 sum(call_status) as sum_dozv,
 cast(avg(call_status) as decimal(2,2)) as perc
from (
select msisdn,
case when call_status is not null then 1.00 else 0.00 end as call_status
from uat_ca.vi_mi_call_ds_rtk
) as table1


--% по причинам детракторства от общего кол-ва 5532


select
 cast(sum(rtk_voice_flg) as decimal(6,2)) / count(*) as perc_voice,
 cast(sum(rtk_mi_flg) as decimal(6,2)) / count(*) as perc_mi,
 cast(sum(rtk_ds_flg) as decimal(6,2)) / count(*) as perc_ds,
 cast(sum(rtk_monobrand_flg) as decimal(6,2)) / count(*) as perc_monobrand,
 cast(sum(rtk_roaming_flg) as decimal(6,2)) / count(*) as perc_roaming,
 cast(sum(rtk_dishonesty_flg) as decimal(6,2)) / count(*) as perc_dishonesty,
 cast(sum(rtk_lk_flg) as decimal(6,2)) / count(*) as perc_lk,
 cast(sum(rtk_annoying_flg) as decimal(6,2)) / count(*) as perc_annoying,  
 cast(sum(rtk_tarif_flg) as decimal(6,2)) / count(*) as perc_tarif  
 from uat_ca.vi_mi_call_ds_rtk
 where call_status is not null


--select * from uat_ca.vi_mi_call_ds_rtk


--% кол-во давших комментарий 2367 из 5532
create multiset table r_call_status as(
select 
 msisdn, call_date, call_status, create_date
from uat_ca.vi_mi_call_ds_rtk
where 1=1 and
 rtk_voice_reason is not null or
 rtk_mi_reason is not null or
 rtk_ds_reason is not null or
 rtk_monobrand_reason is not null or
 rtk_roaming_reason is not null or
 rtk_dishonesty_reason is not null or
 rtk_lk_reason is not null or
 rtk_annoying_reason is not null or
 rtk_tarif_reason is not null
) with data
primary index(msisdn)
;



--== Данные msisdn с координатами

--drop table vi_mi_cord

create multiset volatile table vi_mi_cord, no log (
 msisdn varchar(20) character set unicode not casespecific,
 call_date date format 'yy/mm/dd',
 offer_type varchar(20) character set unicode not casespecific,
 sd varchar(1024) character set unicode not casespecific,
 Location varchar(1024) character set unicode not casespecific,
 Coordinate1 decimal(8,8),
 Coordinate2 decimal(8,8)
 )
primary index (msisdn)
on commit preserve rows
;

select distinct(point_name) from close_inhouse_with_DS
