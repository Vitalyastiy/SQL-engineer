
diagnostic helpstats on for session;

--==2023

--delete uat_ca.poll_id_193 where create_date >= date '2023-04-01';

/*week 14*/   call uat_ca.mc_nps_bu_193 (timestamp'2023-04-06 00:00:00', timestamp'2023-04-10 00:00:00');
/*week 15*/   call uat_ca.mc_nps_bu_193 (timestamp'2023-04-10 00:00:00', timestamp'2023-04-17 00:00:00');
/*week 16*/   call uat_ca.mc_nps_bu_193 (timestamp'2023-04-17 00:00:00', timestamp'2023-04-24 00:00:00');
/*week 17*/   call uat_ca.mc_nps_bu_193 (timestamp'2023-04-24 00:00:00', timestamp'2023-05-01 00:00:00');
/*week 18*/   call uat_ca.mc_nps_bu_193 (timestamp'2023-05-01 00:00:00', timestamp'2023-05-08 00:00:00');
/*week 19*/   call uat_ca.mc_nps_bu_193 (timestamp'2023-05-08 00:00:00', timestamp'2023-05-15 00:00:00');

/*week 22*/   call uat_ca.mc_nps_bu_193 (timestamp'2023-06-01 00:00:00', timestamp'2023-06-05 00:00:00');
/*week 23*/   call uat_ca.mc_nps_bu_193 (timestamp'2023-06-05 00:00:00', timestamp'2023-06-12 00:00:00');

call uat_ca.mc_nps_bu_193 (timestamp'2023-07-12 00:00:00', timestamp'2023-07-13 00:00:00');

-- Просмотр витрин
select top 100 * from uat_ca.poll_id_193;
select top 100 * from uat_ca.poll_id_193 where create_date >= date '2022-01-10';


--EDW
select
 cast(created_dttm as date) as created_date,
 poll_id,
 count(distinct subs_id),
 count(*)
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id in (193)
 and created_dttm >= timestamp '2023-07-01 00:00:00'
 and created_dttm < timestamp '2023-07-06 00:00:00'
group by 1,2
;

--SOA
select
 weeknumber_of_year (a.created_date, 'ISO') as "неделя",
 trunc (a.created_date,'iw') as first_day_week,
 count(distinct msisdn)
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2023-07-01 00:00:00'
 and b.created_date < timestamp '2023-07-06 00:00:00'
 and b.poll_id = 193
where 1=1
 and a.created_date >= timestamp '2023-07-01 00:00:00'
 and a.created_date < timestamp '2023-07-06 00:00:00'
group by 1,2
order by 2
;


--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.poll_id_193
group by 1,2
order by 2 desc;

--2 месячная динамика
select
 trunc (create_date,'mm') as "Месяц",
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.poll_id_193
group by 1
order by 1 desc;

--3 дневная динамика
select
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.poll_id_193
group by 1
order by 1 desc;



select top 100 * from uat_ca.poll_id_193;       --витрина по точке контакта Наш NPS TD
select top 100 * from uat_ca.mc_base_main_td;   --метрики абонентов

select point_name, count(*) from uat_ca.mc_base_main_td group by 1;

--==View для работы - аналитика/BI

replace view uat_ca.v3_nps_main_td as
lock table uat_ca.poll_id_193 for access                        --витрина по точке контакта Наш NPS TD
lock table uat_ca.mc_base_main_td for access                    --метрики абонентов

select
 trunc (a.create_date,'mm') as create_month,
 weeknumber_of_year (a.create_date, 'ISO') as week_num,
 trunc (a.create_date,'iw') as first_day_week,
 a.create_date,
 t1.cluster_name,
 t1.macroregion,
 t1.region,
 t1.branch_id,
 a.subs_id,
 t1.msisdn,
 t1.lt_day,
 t1.lt_gr,
 t1.age,
 t1.age_gr,                                                         --когорты соответствуют маркетинговым
 t1.gender,
 t1.point_name,
 a.nps,
 case when t1.nps_key = -1 then 'Detractor'
      when t1.nps_key = 0 then 'Passive'
      when t1.nps_key = 1 then 'Promoter'
      end nps_category,
 t1.nps_key,
 case when a.ans_2 = 'Другое' then a.mark_2 end as mark_2,          --Что нам необходимо улучшить в первую очередь
 a.mark_3,                                                          --Будем признательны, если в ответ вы напишите, что именно повлияло на вашу оценку
 a.mark_4,                                                          --Что по вашему мнению нужно улучшить в первую очередь
 case when a.ans_5 = 'Другое' then a.mark_5 end as mark_5,          --Что вам нравится больше всего
 a.mark_6,                                                          --Пожалуйста, опишите, что вам понравилось больше всего
 a.mark_7,                                                          --Комментарий/пожелания/предложения/адрес из опроса poll_id 5 (проводился до 01.04.2023)
 a.ans_2,                                                           --Что нам необходимо улучшить в первую очередь
 a.ans_5                                                            --Что вам нравится больше всего
from uat_ca.poll_id_193 a
--
left join uat_ca.mc_base_main_td t1 on a.subs_id = t1.subs_id
 and a.create_date = t1.create_date
--
where 1=1
 and a.create_date >= date '2022-01-01'
 and a.nps in (1,2,3,4,5,6,7,8,9,10)
;

select top 100 * from uat_ca.v3_nps_main_td;
select count(*) from uat_ca.v3_nps_main_td;             --66 662



--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs
from uat_ca.v3_nps_main_td
group by 1,2
order by 2 desc;

--1 дневная динамика
select
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v3_nps_main_td
group by 1
order by 1 desc;

select * from uat_ca.v3_nps_main_td where msisdn is null;       --2023-05-17

--==Результат NPS

select
 report_month,
 point_name,
 100*nps (format 'zz.zz%') (varchar(10)) as nps_main,
 subs_cnt,
 1.96*stddev/sqrt(subs_cnt) as st_error,
 100*(nps - st_error) (format 'zz.zz%') (varchar(10)) as lower_threshold,
 100*(nps + st_error) (format 'zz.zz%') (varchar(10)) as upper_threshold
from (
select
 trunc (create_date,'mm') as report_month,
 point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v3_nps_main_td
group by 1,2
) a
;



select
 report_date,
 point_name,
 100*nps (format 'zz.zz%') (varchar(10)) as nps_main,
 subs_cnt,
 1.96*stddev/sqrt(subs_cnt) as st_error,
 100*(nps - st_error) (format 'zz.zz%') (varchar(10)) as lower_threshold,
 100*(nps + st_error) (format 'zz.zz%') (varchar(10)) as upper_threshold
from (
select
 ((cast(extract(month from create_date) as int)-1)/3)+1 || 'q ' || cast (extract(year from create_date) as varchar(4)) as report_date,
 point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v3_nps_main_td
group by 1,2
) a
;



select
 report_year,
 point_name,
 100*nps (format 'zz.zz%') (varchar(10)) as nps_main,
 subs_cnt,
 1.96*stddev/sqrt(subs_cnt) as st_error,
 100*(nps - st_error) (format 'zz.zz%') (varchar(10)) as lower_threshold,
 100*(nps + st_error) (format 'zz.zz%') (varchar(10)) as upper_threshold
from (
select
 trunc (create_date,'yy') as report_year,
 point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v3_nps_main_td
where 1=1
 and create_date >= date '2022-04-01'
 and create_date < date '2023-01-01'
 and nps_key in (-1,0,1)
group by 1,2
) a
;

-- месячная динамика
select
 trunc (create_date,'mm') as "Месяц",
 count (distinct subs_id) dis_subs,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs
from uat_ca.v3_nps_main_td
where 1=1
-- and create_date <= date '2023-02-19'
 and nps_key in (-1,0,1)
group by 1
order by 1 desc;


select
 trunc (create_date,'mm') as "Месяц",
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_base_main_td
where 1=1
-- and create_date <= date '2023-02-19'
 and nps_key in (-1,0,1)
group by 1
order by 1 desc;



select top 100 * from uat_ca.v3_nps_main_td;


--=================================================================================================

select * from prd2_odw_v.smspoll_polls
where 1=1
 and poll_id in (193);

193     --NPS_TopDown

--уникальные q_text
lock row for access
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 193
order by 3, 1;


--step 1
/*
Спасибо, что вы пользуетесь Tele2! Нам важно ваше мнение. Пожалуйста, оцените готовность рекомендовать Tele2 по шкале от 1 до 10, где 1 - точно НЕ порекомендую, 10 - точно порекомендую
Все SMS на этот номер бесплатны.
*/

--step 2
/*
Что нам необходимо улучшить в первую очередь, чтобы вы могли поставить более высокую оценку в будущем? Отправьте в ответ одну цифру:
1. Качество связи
2. Тарифы 
3. Роуминг в поездках по России и за границу
4. Честность (Понятность и прозрачность списаний денег со счета Tele2)
5. Качество мобильного интернета
6. Работу абонентской службы
7. Мобильное приложение Tele2
8. Звонки от оператора с предложением сменить тариф/подключить услугу
9. Другое

Что нам необходимо улучшить в первую очередь, чтобы вы могли поставить более высокую оценку в будущем? Отправьте в ответ одну цифру:
0. Зону покрытия
1. Качество связи
2. Тарифы 
3. Роуминг в поездках по России и за границу
4. Честность (Понятность и прозрачность списаний денег со счета Tele2)
5. Качество мобильного интернета
6. Работу абонентской службы
7. Мобильное приложение Tele2
8. Звонки от оператора с предложением сменить тариф/подключить услугу
9. Другое
*/

--step 3
/*
Спасибо за участие в опросе. Будем признательны, если в ответ вы напишите, что именно повлияло на вашу оценку.
*/

--step 4
/*
Спасибо за участие в опросе! Пожалуйста, опишите, что по вашему мнению нужно улучшить в первую очередь?
*/

--step 5
/*
Спасибо за высокую оценку! Расскажите, что вам нравится больше всего? Отправьте в ответ одну цифру:
1. Качество связи
2. Тарифы
3. Роуминг в поездках по России и за границу
4. Честность (Понятность и прозрачность списаний денег со счета Tele2)
5. Качество мобильного интернета
6. Работа абонентской службы
7. Мобильное приложение Tele2
8. Звонки от оператора с предложением сменить тариф/подключить услугу
9. Другое

Спасибо за высокую оценку! Расскажите, что вам нравится больше всего? Отправьте в ответ одну цифру:
0. Зона покрытия
1. Качество связи
2. Тарифы
3. Роуминг в поездках по России и за границу
4. Честность (Понятность и прозрачность списаний денег со счета Tele2)
5. Качество мобильного интернета
6. Работа абонентской службы
7. Мобильное приложение Tele2
8. Звонки от оператора с предложением сменить тариф/подключить услугу
9. Другое
*/

--step 6
/*
Спасибо за участие в опросе! Пожалуйста, опишите, что вам понравилось больше всего?
*/

--==================================================================================================
--==================================================================================================
--==================================================================================================

show table step_1;
--drop table step_1;

create multiset volatile table step_1 ,no log (
 create_month date format 'yy/mm/dd',
 week_num integer,
 first_day_week date format 'yy/mm/dd',
 create_date date format 'yy/mm/dd',
 branch_id smallint,
 poll_id bigint,
 poll_name varchar(24) character set unicode not casespecific,
 point_name varchar(24) character set unicode not casespecific,
 msisdn varchar(11) character set unicode not casespecific)
primary index ( msisdn )
on commit preserve rows;


--create multiset volatile table step_1, no log as (
insert into step_1
select
 distinct
 trunc (a.created_date,'mm') as create_month,
 weeknumber_of_year (a.created_date, 'ISO') as week_num,
 trunc (a.created_date,'iw') as first_day_week,
 cast(a.created_date as date) as create_date,
 a.branch_id,
 poll_id as poll_id,
 case when poll_id in (193) then 'Наш TopDown'
 end as poll_name,
 poll_name as point_name,
 a.msisdn
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2023-04-06 00:00:00'
 and b.created_date < timestamp '2023-04-10 00:00:00'
 and b.poll_id in (193)
--
left join prd2_dic_v.branch t1 on a.branch_id = t1.branch_id
left join prd2_dic_v.region t2 on t1.region_id = t2.region_id
left join prd2_dic_v.macroregion t3 on t2.macroregion_id = t3.macroregion_id
--
where 1=1
 and a.created_date >= timestamp '2023-04-06 00:00:00'
 and a.created_date < timestamp '2023-04-10 00:00:00'
--) with no data
--primary index (msisdn)
--on commit preserve rows
;


select
 cast (created_dttm as date) as created_date,
 count(*)
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id = 193
group by 1
order by 1
;

--=================================================================================================
--=================================================================================================
--=================================================================================================

--show procedure uat_ca.mc_nps_bu_193;


REPLACE PROCEDURE uat_ca.mc_nps_bu_193 (in stime timestamp, in etime timestamp)
SQL SECURITY INVOKER
BEGIN

-- объявление переменных
DECLARE proc varchar(50);
DECLARE LOAD_ID int;
DECLARE ERR_MSG VARCHAR(4000) DEFAULT '';
DECLARE ERR_SQLCODE INT;
DECLARE ERR_SQLSTATE INT;
DECLARE ROW_CNT INT;

-- Ошибка на этапе запуска SQL кода
DECLARE EXIT HANDLER FOR SqlException
BEGIN
SET ERR_SQLCODE = Cast(SqlCode AS INTEGER);
SET ERR_SQLSTATE = Cast(SqlState AS INTEGER);
SELECT ErrorText INTO :ERR_MSG FROM dbc.errormsgs WHERE Errorcode = :ERR_SQLCODE;
CALL uat_ca.prc_debug (:proc, :load_id, session, 0, 'An error occured during execution: ' || :ERR_MSG);
END;

SET proc = 'nps_193';           -- наименование расчета

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;

-- логирование начала расчета данных
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START');


--=================================================================================================

--==01 целевая группа

create multiset volatile table soa, no log (
 created_date timestamp(0),
 treatment_code varchar(9) character set unicode not casespecific,
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 q_step byteint,
 mark varchar(1024) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa
select
 created_dttm as created_date,
 treatment_code,
 msisdn,
 subs_id,
 q_step,
 mark,
-- load_id
 :load_id
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id = 193
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2023-06-01 00:00:00'
-- and created_dttm < timestamp '2023-06-05 00:00:00'
;

--select top 100 * from soa;


-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'INTERVAL_DATE '|| to_char(cast(stime as date),'DD.MM.YYYY') || '_' ||to_char(cast(etime as date),'DD.MM.YYYY') || ' Всего строк: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--==02 транспонирование

COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (MSISDN),
 COLUMN (TREATMENT_CODE),
 COLUMN (CREATED_DATE ,TREATMENT_CODE ,MSISDN ,SUBS_ID ,LOAD_ID),
 COLUMN (LOAD_ID)
ON soa;


create multiset volatile table soa_2, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 create_date date format 'yy/mm/dd',
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa_2
select
 msisdn,
 subs_id,
 cast(created_date as date) as create_date,
 treatment_code,
 max (step_1) as mark_1,
 max (step_2) as mark_2,
 max (step_3) as mark_3,
 max (step_4) as mark_4,
 max (step_5) as mark_5,
 max (step_6) as mark_6,
 load_id
from (
select * from soa pivot (max(mark) for q_step in (
 '1' as step_1,
 '2' as step_2,
 '3' as step_3,
 '4' as step_4,
 '5' as step_5,
 '6' as step_6
)) t2
) a
group by 1,2,3,4,11
;

--select * from soa_2;


--==03 Step 1 NPS
/*
Спасибо, что вы пользуетесь Tele2! Нам важно ваше мнение. Пожалуйста, оцените готовность рекомендовать Tele2 по шкале от 1 до 10, где 1 - точно НЕ порекомендую, 10 - точно порекомендую
Все SMS на этот номер бесплатны.
*/
create multiset volatile table soa_nps, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 nps_11 varchar(1024) character set unicode not casespecific,
 nps_12 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

create multiset volatile table soa_nps2, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 nps number)
primary index (msisdn)
on commit preserve rows;


insert into soa_nps
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 a.nps_11,
 a.nps_12
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_1,
 oreplace(mark_1,'.00','') as nps_1,                                                                                                       -- исключаем .00
 oreplace(oreplace(upper(trim (nps_1)), 'T2', ''), 'Т2', '') as nps_2,                                                                     -- исключаем пробелы в начале, конце и T2
 trim (both ',' from nps_2) as nps_3,                                                                                                      -- исключаем ','
 trim (both '.' from nps_3) as nps_4,                                                                                                      -- исключаем '.'
 trim (both '*' from nps_4) as nps_5,                                                                                                      -- исключаем '*'
 regexp_replace (nps_5, '652', '', 1, 1) as nps_6,                                                                                         -- заменяем первое вхождение 652
 oreplace(oreplace(oreplace(oreplace(upper(trim (nps_6)), 'ТЕЛЕ2', ''), 'TELE2', ''), 'ТЕЛЕ 2', ''), 'TELE 2', '') as nps_7,               -- исключаем пробелы в начале, конце и Теле2
 otranslate(nps_7,'1234567890','') as nps_8,                                                                                               -- оставляем только текст
 trim(otranslate(nps_7,otranslate(nps_7,'1234567890',''),'')) as nps_9,                                                                    -- оставляем только цифры
 case when length (nps_9) > 0 and length (nps_8) = 0 then cast (nps_7 as varchar (255)) else cast ('-' as varchar(255)) end as nps_10,     -- выбираем ответы только где есть цифры
 case when nps_10 is not null then cast(otranslate(nps_10,' ','') as varchar(255)) end as nps_11,                                          -- исключаем любые пробелы
 cast (case when nps_11 = '-' then oreplace (nps_7, regexp_replace(nps_7, '[[:alnum:]]'),'')
            else '-' end as varchar (255))as nps_12
from soa_2
) a
;


insert into soa_nps2
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 to_number (case when a.mark_1 is null then null
                 when a.nps_14 in ('0','1','2','3','4','5','6','7','8','9','10') then a.nps_14 else '-1' end) as nps                       -- итоговая оценка
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_1,
 nps_11,
 nps_12,
 case when nps_12 in ('0','1','2','3','4','5','6','7','8','9','10') then nps_12 else '-' end as nps_13,
 case when nps_11 = '-' then nps_13 else nps_11 end as nps_14                                                                            -- итоговый ответ nps
from soa_nps
) a
;

--select * from soa_nps2;


--==04 Step 2 Что необходимо улучшить
/*
Что нам необходимо улучшить в первую очередь, чтобы вы могли поставить более высокую оценку в будущем? Отправьте в ответ одну цифру:
0. Зону покрытия
1. Качество связи
2. Тарифы 
3. Роуминг в поездках по России и за границу
4. Честность (Понятность и прозрачность списаний денег со счета Tele2)
5. Качество мобильного интернета
6. Работу абонентской службы
7. Мобильное приложение Tele2
8. Звонки от оператора с предложением сменить тариф/подключить услугу
9. Другое
*/
create multiset volatile table soa_step2_1, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 length_step_2 number,
 ans_2 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

create multiset volatile table soa_step2, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step2_1
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_2,
 length (oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.','')) length_step_2,
 case when mark_2 is null then null
      when length_step_2 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[0-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[0-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from soa_2
;

insert into soa_step2
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_2,
 case when ans_2 is null then null
      when ans_2 = -1 then 'Другое'
      when ans_2 = 0 then 'Зона покрытия'
      when ans_2 = 1 then 'Качество связи'
      when ans_2 = 2 then 'Тарифы'
      when ans_2 = 3 then 'Роуминг'
      when ans_2 = 4 then 'Честность'
      when ans_2 = 5 then 'Качество мобильного интернета'
      when ans_2 = 6 then 'Работа абонентской службы'
      when ans_2 = 7 then 'Мобильное приложение Tele2'
      when ans_2 = 8 then 'Звонки от оператора'
      when ans_2 = 9 then 'Другое'
      else '-1' end as ans_2
from soa_step2_1
;


--select * from soa_step2;


--==05 Step 3
/*
Спасибо за участие в опросе. Будем признательны, если в ответ вы напишите, что именно повлияло на вашу оценку.
*/

--==06 Step 4
/*
Спасибо за участие в опросе! Пожалуйста, опишите, что по вашему мнению нужно улучшить в первую очередь?
*/


--==07 Step 5 Что вам нравится больше всего
/*
Спасибо за высокую оценку! Расскажите, что вам нравится больше всего? Отправьте в ответ одну цифру:
0. Зона покрытия
1. Качество связи
2. Тарифы
3. Роуминг в поездках по России и за границу
4. Честность (Понятность и прозрачность списаний денег со счета Tele2)
5. Качество мобильного интернета
6. Работа абонентской службы
7. Мобильное приложение Tele2
8. Звонки от оператора с предложением сменить тариф/подключить услугу
9. Другое
*/
create multiset volatile table soa_step5_1, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 length_step_5 number,
 ans_5 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

create multiset volatile table soa_step5, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 ans_5 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step5_1
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_5,
 length (oreplace(oreplace(oreplace(upper(mark_5),' ',''),',',''),'.','')) length_step_5,
 case when mark_5 is null then null
      when length_step_5 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_5),' ',''),',',''),'.',''), '[0-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_5),' ',''),',',''),'.',''), '[0-9]\d{0,2}') else '-1' end
      else '-1' end as ans_5
from soa_2
;

insert into soa_step5
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_5,
 case when ans_5 is null then null
      when ans_5 = -1 then 'Другое'
      when ans_5 = 0 then 'Зона покрытия'
      when ans_5 = 1 then 'Качество связи'
      when ans_5 = 2 then 'Тарифы'
      when ans_5 = 3 then 'Роуминг'
      when ans_5 = 4 then 'Честность'
      when ans_5 = 5 then 'Качество мобильного интернета'
      when ans_5 = 6 then 'Работа абонентской службы'
      when ans_5 = 7 then 'Мобильное приложение Tele2'
      when ans_5 = 8 then 'Звонки от оператора'
      when ans_5 = 9 then 'Другое'
      else '-1' end as ans_5
from soa_step5_1
;

--select * from soa_step5;


--==08 Step 6
/*
Спасибо за участие в опросе! Пожалуйста, опишите, что вам понравилось больше всего?
*/


--==09 Итоговая сборка
COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step5;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_nps2;


create multiset volatile table soa_fin, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_5 varchar(1024) character set unicode not casespecific,
 nps byteint,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa_fin
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,              --NPS
 a.mark_2,              --Что необходимо улучшить в первую очередь
 a.mark_3,              
 a.mark_4,
 a.mark_5,              --Что вам нравится больше всего
 a.mark_6,
 t1.ans_2,
 t2.ans_5,
 t3.nps,
 a.load_id
from soa_2 a
--
left join soa_step2 t1 on a.msisdn = t1.msisdn and a.create_date = t1.create_date                   --Что необходимо улучшить в первую очередь
left join soa_step5 t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date                   --Что вам нравится больше всего
left join soa_nps2  t3 on a.msisdn = t3.msisdn and a.create_date = t3.create_date                   --NPS
;

--select * from soa_fin;


--==10 Исключение долетов

create multiset volatile table subs_tmp ,no log (
 create_date date format 'yy/mm/dd',
 subs_id decimal(12,0),
 msisdn varchar(20) character set unicode not casespecific)
primary index (subs_id)
on commit preserve rows;


insert into subs_tmp
select create_date, subs_id, msisdn from soa_fin
qualify row_number () over (partition by msisdn order by create_date) = 1
;


COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (CREATE_DATE ,SUBS_ID)
ON soa_fin;

COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (CREATE_DATE ,SUBS_ID)
ON subs_tmp;


--абоненты с долетами
insert into uat_ca.poll_id_193
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 coalesce(a.mark_1,  t1.mark_1) as mark_1,
 coalesce(a.mark_2,  t1.mark_2) as mark_2,
 coalesce(a.mark_3,  t1.mark_3) as mark_3,
 coalesce(a.mark_4,  t1.mark_4) as mark_4,
 coalesce(a.mark_5,  t1.mark_5) as mark_5,
 coalesce(a.mark_6,  t1.mark_6) as mark_6,
 null as mark_7,
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.ans_5,   t1.ans_5) as ans_5,
 coalesce(a.nps,     t1.nps) as nps,
 coalesce(a.load_id, t1.load_id) as load_id
from soa_fin a
--
inner join subs_tmp b on a.subs_id = b.subs_id
 and a.create_date = b.create_date
--
inner join (
select a.* from soa_fin a
left join subs_tmp b on a.subs_id = b.subs_id
 and a.create_date = b.create_date
where 1=1
 and b.subs_id is null
) t1 on a.subs_id = t1.subs_id
;

--select top 100 * from uat_ca.poll_id_193;


-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Строк по долетам: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));

--абоненты без долетов
insert into uat_ca.poll_id_193
select
  a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 a.mark_2,
 a.mark_3,
 a.mark_4,
 a.mark_5,
 a.mark_6,
 null as mark_7,
 a.ans_2,
 a.ans_5,
 a.nps,
 a.load_id
from soa_fin a
left join (
select a.* from soa_fin a
left join subs_tmp b on a.subs_id = b.subs_id
 and a.create_date = b.create_date
where 1=1
 and b.subs_id is null
) b on a.subs_id = b.subs_id
where 1=1
 and b.subs_id is null
;


-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Строк без долетов: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


drop table soa;
drop table soa_2;
drop table soa_step2_1;
drop table soa_step2;
drop table soa_step5_1;
drop table soa_step5;
drop table soa_nps;
drop table soa_nps2;
drop table soa_fin;
drop table subs_tmp;


-- логирование окончания расчета данных
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,1,'END');


END;

--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Комментарий
COMMENT ON PROCEDURE uat_ca.mc_nps_bu_193 AS
'Процедура формирования витрины с опросами NPS SOA 2.0, тк Наш NPS TopDown 2023. Результирующая таблица: uat_ca.poll_id_193';


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Вызов процедуры (условие строгое/не строгое)

--==Даты для макроса

select min(created_dttm) from prd2_dds_v.smspoll_detail where poll_id = 193;      --2020-04-07 06:32:26
select top 100 * from sys_calendar.calendar;

select
 weeknumber_of_year(calendar_date, 'ISO') as week_num,
 trunc(calendar_date,'iw') as first_day_week,
 min(calendar_date) as sdate,
 sdate + interval '7' day as edate
from sys_calendar.calendar
where 1=1
 and calendar_date >= date '2023-04-03'
 and calendar_date < date '2023-04-10'
group by 1,2
order by 3;


--==2023
/*week 14*/   call uat_ca.mc_nps_bu_193 (timestamp'2023-04-06 00:00:00', timestamp'2023-04-10 00:00:00');


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Комментарии доступны в витринах метаданных EDW:
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablekind = 'Procedure' order by "Дата последнего изменения" desc;
select * from prd2_tmd_v.columns_info;


-- Для просмотра рассчитанных дней в момент работы процедуры, либо по ее завершению используйте запрос по таблице логов:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_193'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


-- Просмотр логов
select * from uat_ca.mc_logs order by 1;


--Статистика
COLLECT SUMMARY STATISTICS ON uat_ca.poll_id_193;

COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (SUBS_ID),
 COLUMN (MSISDN)
ON uat_ca.poll_id_193;


-- Просмотр витрин
select top 100 * from uat_ca.poll_id_193;
select top 100 * from uat_ca.poll_id_193 where create_date >= date '2022-01-10';


select create_date, count(distinct msisdn), count(*) from uat_ca.poll_id_193 group by 1 order by 1 desc;
select trunc (create_date,'iw') as week_first_day, weeknumber_of_year (create_date, 'ISO') as week_num, count(distinct msisdn), count(*) from uat_ca.poll_id_193 group by 1,2 order by 1 desc;



--==================================================================================================
--==================================================================================================
--==================================================================================================

--==добавление данных poll_id 5

--show table uat_ca.v_poll_5;

create multiset table uat_ca.poll_id_5 (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 nps byteint,
 load_id integer)
primary index (subs_id)
;

--show table uat_ca.v_poll_193;

create multiset table uat_ca.poll_id_193 (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 mark_7 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_5 varchar(1024) character set unicode not casespecific,
 nps byteint,
 load_id integer)
primary index (subs_id);


insert into uat_ca.poll_id_193
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_1,
 mark_2,
 null as mark_3,
 null as mark_4,
 null as mark_5,
 null as mark_6,
 mark_3 as mark_7,
 ans_2,
 null as ans_5,
 nps,
 load_id
from uat_ca.poll_id_5;


select top 100 * from uat_ca.poll_id_193 where create_date >= date '2023-04-06';



--=================================================================================================
--=================================================================================================
--=================================================================================================

--==1 Size

--Запрос показывает неравномерность распределения таблицы. Отклонение должно быть менее 5% (выполнение примерно 1 мин. 32 сек.)
select
 lower(trim(a.databasename)||'.'||a.tablename) as tables_name,
 t1.creatorname as creator_name,
 t1.createtimestamp as create_dttm,
 t1.lastaccesstimestamp as last_access_dttm,
 min(a.currentperm) as min_size_byte,
 max(a.currentperm) as max_size_byte,
 (max(a.currentperm) - min(a.currentperm)) * 100 / cast(nullif(min(a.currentperm),0) as float) as variance_size,
 sum(a.currentperm)/1024**3 as table_size_gb
from dbc.tablesizev a
inner join dbc.tablesv t1 on a.databasename = t1.databasename
 and a.tablename = t1.tablename
 and lower(t1.databasename) = 'uat_ca'
 and t1.tablekind = 't'
where 1=1
 and lower(a.databasename) = 'uat_ca'
 and lower(a.tablename) = 'poll_id_193'
group by 1,2,3,4
;

--==2 Rows/AMP

--Запрос показывает распределение строк таблицы по AMP. Отклонение от среднего для минимального или максимального значения должно быть меньше 15%
select
 t1.amp_no,
 t1.row_cnt,
 ((t1.row_cnt/t2.row_avr_amp) - 1.0)*100 as deviation
from
(select
 hashamp(hashbucket(hashrow(subs_id))) as amp_no,
 cast(count(*) as float) as row_cnt
from uat_ca.poll_id_193
group by 1
) as t1,
(select cast(count(*) as float)/(hashamp()+1) as row_avr_amp from uat_ca.poll_id_193) as t2
order by 2 desc
;


--==3 Hash synonyms

--Запрос показывает количество конфликтов хэша строк для указанного индекса или столбца (выполнение примерно 3 мин. 45 сек.)
/*ситуация, в которой значение rowhash для разных строк идентично, что затрудняет для системы
  различение хеш-синонимов, когда одна уникальная строка запрашивается для извлечения
    https://www.docs.teradata.com/r/w4DJnG9u9GdDlXzsTXyItA/XfRpR9T7fWZfF_1IZWuwRg
*/
select
 hashrow(subs_id) as row_hash,
 count(*) as row_cnt
from uat_ca.poll_id_193
group by 1
order by 1
having row_cnt > 10
;


--==4 Объем/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('poll_id_193')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          POLL_ID_193             MIKHAIL.CHUPIS      2023-05-03 11:01:08     2023-05-05 10:24:10     0,016           0










