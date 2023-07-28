
diagnostic helpstats on for session;


--==Текущая динамика
select create_date, count(distinct msisdn), count(*) from uat_ca.poll_id_126 group by 1 order by 1 desc;


--==Вызов процедуры (условие не строгое/ строгое)

--2022
/*week 29*/ call uat_ca.mc_nps_126 (date '2022-07-18', date '2022-07-25');   -- 58 сек.
/*week 33*/ call uat_ca.mc_nps_126 (date '2022-08-15', date '2022-08-22');   -- 2 мин 1 сек.
/*week 38*/ call uat_ca.mc_nps_126 (date '2022-09-19', date '2022-09-26');   -- 2 мин 1 сек.
/*week 42*/ call uat_ca.mc_nps_126 (date '2022-10-17', date '2022-10-24');

/*week 46*/ call uat_ca.mc_nps_126 (date '2022-11-14', date '2022-11-21');
/*week 51*/ call uat_ca.mc_nps_126 (date '2022-12-19', date '2022-12-26');      --1 мин. 53 сек.


--==2023
/*week 05*/ call uat_ca.mc_nps_126 (date '2023-01-30', date '2023-02-06');      --1 мин. 53 сек.
/*week 14*/ call uat_ca.mc_nps_126 (date '2023-04-01', date '2023-04-09');
/*week 19*/ call uat_ca.mc_nps_126 (date '2023-05-08', date '2023-05-14');		--17 мин. 9 сек.


--==Витрина для работы

select top 100 * from uat_ca.v_chat_bot_v2 where create_date >= date '2022-02-03';

select
 report_month,
 point_name,
 100*nps (format '-zz.zz%') (varchar(10)) as nps,
 subs_cnt,
 100*(1.96*stddev/sqrt(subs_cnt)) (format '-zz.zz%') (varchar(10)) as st_error,
-- 1.96*stddev/sqrt(subs_cnt) as st_error,
 100*(nps - (1.96*stddev/sqrt(subs_cnt))) (format '-zz.zz%') (varchar(10)) as lower_threshold,
 100*(nps + (1.96*stddev/sqrt(subs_cnt))) (format '-zz.zz%') (varchar(10)) as upper_threshold
from (
select
 trunc (create_date,'mm') as report_month,
 'Чат-бот' as point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v_chat_bot_v2
where 1=1
-- and create_date >= date '2022-09-05'
-- and create_date < date '2022-09-13'
 and nps_key in (-1,0,1)
group by 1,2
) a
order by 1
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
from uat_ca.v_chat_bot_v2
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
from uat_ca.v_chat_bot_v2
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
from uat_ca.v_chat_bot_v2
group by 1
order by 1 desc;



--==Плюс поля тарифного плана

--drop table subs;

create multiset volatile table subs, no log as(
--insert into subs
select
 a.type_poll,
 a.create_date,
 a.cluster_name,
 a.macroregion,
 a.region,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 a.mark_2,
 a.mark_3,
 a.mark_4,
 a.mark_5,
 a.mark_6,
 a.mark_7,
 a.ans_2,
 a.ans_3,
 a.ans_4,
 a.nps,
 a.detractor,
 a.passive,
 a.promoter,
 a.nps_category,
 a.nps_key,
--
 t1.tp_id,
 t2.tp_name,
 t2.name_commercial,
 t2.name_report,
 t2.concept
from uat_ca.v_chat_bot_v2 a
--
left join prd2_dds_v.subscription t1 on a.msisdn = t1.msisdn
 and t1.report_date = date '2023-04-01'
-- and t1.report_date = :rdate
left join prd2_dic_v.price_plan t2 on t1.tp_id = t2.tp_id
--
where 1=1
 and a.create_date = date '2023-04-01'
 with no data
primary index (msisdn)
on commit preserve rows
;


select * from subs;

select top 100 * from subs;
select * from subs where tp_id is null;
select create_date, count(*) from subs group by 1;

select * from subs;

--даты
2022-08-18
2022-08-19

2022-09-22
2022-09-23

2022-10-20
2022-10-21

2022-11-17
2022-11-18

2022-12-19      1 781
2022-12-20      37


select top 100 * from uat_ca.v_chat_bot_v2;

select create_date, count(*) from uat_ca.v_chat_bot_v2 group by 1 order by 1;

UPDATE uat_ca.poll_id_126
SET create_date = date '2023-04-01'
WHERE 1=1
 AND create_date >= date '2023-05-10'
 AND create_date < date '2023-05-12'
;

select distinct create_date from uat_ca.poll_id_126 where create_date > date '2023-05-01';
--=================================================================================================
--=================================================================================================
--=================================================================================================

--EEE_Чат-бот_032822      (poll_id = 126)

lock row for access
select * from prd2_odw_v.smspoll_polls
where 1=1
 and poll_id in (126);



--Первый этап
126     2022-03-28      5
126     2022-04-07      4833
126     2022-04-08      425

--Второй этап
126     2022-04-21      3469
126     2022-04-22      80

--Третий этап
126     2022-05-24      3513
126     2022-05-25      322

--Четвертый этап
126     2022-06-16      3 237
126     2022-06-17      17


--03.2022 - по текущий момент
select
 cast (created_dttm as date) as created_date,
 count(*)
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id = 126
group by 1
order by 1
;


--=================================================================================================
--уникальные q_text
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 126
order by 3, 1;


--126

--1 NPS
Спасибо, что Вы с Tele2! Мы будем благодарны, если Вы поможете нам стать лучше, ответив на несколько вопросов.
Учитывая Ваш опыт взаимодействия с виртуальным помощником (чат-бот), оцените готовность рекомендовать компанию Tele2 родным и близким от 1 до 10, где 1 - точно не порекомендую, 10 - точно порекомендую

--2 Решение вопроса 1-9
Решил ли виртуальный помощник (чат-бот) Ваш вопрос во время последнего обращения в Tele2?
1 - Решил с первого раза.
2 - Решил, но потребовалось задать тот же вопрос в чат несколько раз.
3 - Не смог решить вопрос.
SMS на этот номер бесплатны.

--3 Решение вопроса 10
Решил ли виртуальный помощник (чат-бот) Ваш вопрос во время последнего обращения в Tele2?
1 - Решил с первого раза.
2 - Решил, но потребовалось задать тот же вопрос в чат несколько раз.
3 - Не смог решить вопрос.
SMS на этот номер бесплатны.

--4 Решение вопроса Не разобрали ответ
Решил ли виртуальный помощник (чат-бот) Ваш вопрос во время последнего обращения в Tele2?
1 - Решил с первого раза.
2 - Решил, но потребовалось задать тот же вопрос в чат несколько раз.
3 - Не смог решить вопрос.
SMS на этот номер бесплатны.

--5 Что требуется улучшить
Спасибо за участие! Мы будем признательны, если Вы расскажете, что нужно улучшить в первую очередь в работе виртуального помощника (чат-бот), чтобы Вы ТОЧНО могли нас рекомендовать. 

--6 Что требуется улучшить
Спасибо за Вашу оценку! В ответ на это SMS напишите, что в работе виртуального помощника (чат-бот) Вам нравится больше всего. Хорошего дня!

--7 Что требуется улучшить
Спасибо за участие! В ответ на это SMS напишите, что стоит улучшить в работе виртуального помощника (чат-бот). Хорошего дня!

--
select
 weeknumber_of_year (a.created_date, 'ISO') as "неделя",
 trunc (a.created_date,'iw') as first_day_week,
 count(distinct msisdn)
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2023-03-01 00:00:00'
 and b.created_date < timestamp '2023-04-01 00:00:00'
 and b.poll_id = 126
where 1=1
 and a.created_date >= timestamp '2023-03-01 00:00:00'
 and a.created_date < timestamp '2023-04-01 00:00:00'
group by 1,2
order by 1
;

13      2022-03-28      38 900
14      2022-04-04      42 090

21      2022-05-23      41 871

24      2022-06-13      43 837

29      2022-07-18      43 398, прошли опрос 459, 1.6%

33      2022-08-15      44 719

38      2022-09-19      54 703

42      2022-10-17      52 764

46      2022-11-14      17 979

51      2022-12-19      25 927

5       2023-01-30      23 420

14		2023-04-03		26 637



--=================================================================================================
--=================================================================================================
--=================================================================================================

REPLACE PROCEDURE uat_ca.mc_nps_126 (in stime timestamp, in etime timestamp)
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

SET proc = 'nps_126';           -- наименование расчета

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;

-- логирование начала расчета данных
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START');

--=================================================================================================

--01 целевая группа
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
 and poll_id = 126
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2022-06-13 00:00:00'
-- and created_dttm < timestamp '2022-06-20 00:00:00'
;

--select top 100 * from soa;


-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'INTERVAL_DATE '|| to_char(cast(stime as date),'DD.MM.YYYY') || '_' ||to_char(cast(etime as date),'DD.MM.YYYY') || ' Всего строк: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--02 транспонирование

COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (MSISDN),
 COLUMN (TREATMENT_CODE),
 COLUMN (CREATED_DATE ,TREATMENT_CODE ,MSISDN ,SUBS_ID ,LOAD_ID),
 COLUMN (LOAD_ID)
ON soa;

--drop table soa_2;

create multiset volatile table soa_2, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- create_date timestamp(0),
 create_date date format 'yy/mm/dd',
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 mark_7 varchar(1024) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa_2
select
 msisdn,
 subs_id,
 cast(created_date as date) as create_date,
-- created_date as create_date,
 treatment_code,
 max (step_1) as step_1,
 max (step_2) as step_2,
 max (step_3) as step_3,
 max (step_4) as step_4,
 max (step_5) as step_5,
 max (step_6) as step_6,
 max (step_7) as step_7,
 load_id
from (
select * from soa pivot (max(mark) for q_step in (
 '1' as step_1,
 '2' as step_2,
 '3' as step_3,
 '4' as step_4,
 '5' as step_5,
 '6' as step_6,
 '7' as step_7
)) t2
) a
group by 1,2,3,4,12
;

--select * from soa_2;



--03 Step_01 NPS
/*
Спасибо, что Вы с Tele2! Мы будем благодарны, если Вы поможете нам стать лучше, ответив на несколько вопросов.
Учитывая Ваш опыт взаимодействия с виртуальным помощником (чат-бот), оцените готовность рекомендовать компанию Tele2 родным и близким от 1 до 10, где 1 - точно не порекомендую, 10 - точно порекомендую

*/

--delete soa_step1;
--delete soa_step1_1;

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


--04 Step_02 Решение вопроса 1-9
/*
Решил ли виртуальный помощник (чат-бот) Ваш вопрос во время последнего обращения в Tele2?
1 - Решил с первого раза.
2 - Решил, но потребовалось задать тот же вопрос в чат несколько раз.
3 - Не смог решить вопрос.
SMS на этот номер бесплатны.
*/

--drop table soa_step2;
--drop table soa_step2_1;

create multiset volatile table soa_step2, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step2
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_2,
 case when a.ans_2 is null then null
      when a.ans_2 = 1 then 'Решил с первого раза'
      when a.ans_2 = 2 then 'Решил, но потребовалось задать тот же вопрос в чат несколько раз'
      when a.ans_2 = 3 then 'Не смог решить вопрос'
      when a.ans_2 = -1 then 'Другое'
      else '-1' end as ans_2
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_2,
 length (oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.','')) length_step_2,
 case when mark_2 is null then null
      when length_step_2 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from soa_2
) a
;

--select * from soa_step2;


--05 Step_03 Решение вопроса 10
/*
Решил ли виртуальный помощник (чат-бот) Ваш вопрос во время последнего обращения в Tele2?
1 - Решил с первого раза.
2 - Решил, но потребовалось задать тот же вопрос в чат несколько раз.
3 - Не смог решить вопрос.
SMS на этот номер бесплатны.
*/

--delete soa_step3;

create multiset volatile table soa_step3, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step3
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_3,
 case when a.ans_3 is null then null
      when a.ans_3 = 1 then 'Решил с первого раза'
      when a.ans_3 = 2 then 'Решил, но потребовалось задать тот же вопрос в чат несколько раз'
      when a.ans_3 = 3 then 'Не смог решить вопрос'
      when a.ans_3 = -1 then 'Другое'
      else '-1' end as ans_3
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_3,
 length (oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.','')) length_step_3,
 case when mark_3 is null then null
      when length_step_3 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_3
from soa_2
) a
;

--select * from soa_step3;


--06 Step_04 Решение вопроса Не разобрали ответ
/*
Решил ли виртуальный помощник (чат-бот) Ваш вопрос во время последнего обращения в Tele2?
1 - Решил с первого раза.
2 - Решил, но потребовалось задать тот же вопрос в чат несколько раз.
3 - Не смог решить вопрос.
SMS на этот номер бесплатны.
*/

--delete soa_step4;

create multiset volatile table soa_step4, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 ans_4 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

insert into soa_step4
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_4,
 case when a.ans_4 is null then null
      when a.ans_4 = 1 then 'Решил с первого раза'
      when a.ans_4 = 2 then 'Решил, но потребовалось задать тот же вопрос в чат несколько раз'
      when a.ans_4 = 3 then 'Не смог решить вопрос'
      when a.ans_4 = -1 then 'Другое'
      else '-1' end as ans_4
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_4,
 length (oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.','')) length_step_4,
 case when mark_4 is null then null
      when length_step_4 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_4
from soa_2
) a
;

--select * from soa_step4;


--07 Step_05 Комментарий/пожелания/предложения/адрес
/*
Спасибо за участие! Мы будем признательны, если Вы расскажете, что нужно улучшить в первую очередь в работе виртуального помощника (чат-бот), чтобы Вы ТОЧНО могли нас рекомендовать. 
Спасибо за Вашу оценку! В ответ на это SMS напишите, что в работе виртуального помощника (чат-бот) Вам нравится больше всего. Хорошего дня!
Спасибо за участие! В ответ на это SMS напишите, что стоит улучшить в работе виртуального помощника (чат-бот). Хорошего дня!
*/


--09 Итоговая сборка
COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_nps2;


COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step3;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step4;



--drop table soa_fin;
--delete soa_fin;

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
 mark_7 varchar(1024) character set unicode not casespecific,
 nps byteint,
 ans_2 varchar(100) character set unicode not casespecific,
 ans_3 varchar(100) character set unicode not casespecific,
 ans_4 varchar(100) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;

insert into soa_fin
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,              --
 a.mark_2,              --
 a.mark_3,              --
 a.mark_4,              --
 a.mark_5,              --Комментарий/пожелания/предложения/адрес
 a.mark_6,              --Комментарий/пожелания/предложения/адрес
 a.mark_7,              --Комментарий/пожелания/предложения/адрес
--
 t1.nps,
 t2.ans_2,
 t3.ans_3,
 t4.ans_4,
 a.load_id
from soa_2 a
--
left join soa_nps2      t1 on a.msisdn = t1.msisdn and a.create_date = t1.create_date                   --NPS
left join soa_step2     t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date
left join soa_step3     t3 on a.msisdn = t3.msisdn and a.create_date = t3.create_date
left join soa_step4     t4 on a.msisdn = t4.msisdn and a.create_date = t4.create_date
;

--select top 100 * from soa_fin;


--10 Исключение долетов
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
insert into uat_ca.poll_id_126
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
 coalesce(a.mark_7,  t1.mark_7) as mark_7,
 coalesce(a.nps,     t1.nps) as nps,
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.ans_3,   t1.ans_3) as ans_3,
 coalesce(a.ans_4,   t1.ans_4) as ans_4,
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

-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Строк по долетам: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--абоненты без долетов
insert into uat_ca.poll_id_126
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
 a.mark_7,
 a.nps,
 a.ans_2,
 a.ans_3,
 a.ans_4,
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
drop table soa_step2;
drop table soa_step3;
drop table soa_step4;
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
COMMENT ON PROCEDURE uat_ca.mc_nps_126 AS
'Процедура формирования витрины с опросами NPS SOA 2.0, тк Чат-бот v3. Результирующая таблица: uat_ca.poll_id_126';


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Комментарии доступны в витринах метаданных EDW:
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablekind = 'Procedure' order by "Дата последнего изменения" desc;
select * from prd2_tmd_v.columns_info;


-- Для просмотра рассчитанных дней в момент работы процедуры, либо по ее завершению используйте запрос по таблице логов:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_126'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


-- Просмотр логов
select * from uat_ca.mc_logs order by 1;


--Статистика
COLLECT SUMMARY STATISTICS ON uat_ca.poll_id_126;

COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (SUBS_ID),
 COLUMN (MSISDN)
ON uat_ca.poll_id_126;


-- Просмотр витрин
select top 100 * from uat_ca.poll_id_126;
select top 100 * from uat_ca.poll_id_126 where create_date >= date '2022-07-18';

select create_date, count(distinct msisdn), count(*) from uat_ca.poll_id_126 group by 1 order by 1 desc;
select trunc (create_date,'iw') as week_first_day, weeknumber_of_year (create_date, 'ISO') as week_num, count(distinct msisdn), count(*) from uat_ca.poll_id_126 group by 1,2 order by 1 desc;


--=================================================================================================
--=================================================================================================
--=================================================================================================


select top 100 * from uat_ca.v_chat_bot_v2;

--View
replace view uat_ca.v_chat_bot_v2 as
lock table uat_ca.poll_id_126 for access
select
 'poll_id_126' as type_poll,
 a.create_date,
 t2.cluster_name as cluster_name,
 t4.macroregion_name as macroregion,
 t3.region_name as region,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 case when a.nps = -1 then a.mark_1 end as mark_1,
 case when a.ans_2 = 'Другое' then a.mark_2 end as mark_2,
 case when a.ans_3 = 'Другое' then a.mark_3 end as mark_3,
 case when a.ans_4 = 'Другое' then a.mark_4 end as mark_4,
 a.mark_5,
 a.mark_6,
 a.mark_7,
 a.ans_2,
 a.ans_3,
 a.ans_4,
 a.nps,
-- a.load_id,
 case when nps between 0 and 6 then 1 else 0 end as detractor,
 case when nps between 7 and 8 then 1 else 0 end as passive,
 case when nps between 9 and 10 then 1 else 0 end as promoter,
 case when detractor = 1 then 'Detractor'
      when passive = 1 then 'Passive'
      when promoter = 1 then 'Promoter'
      end nps_category,
 case when detractor = 1 then -1
      when passive = 1 then 0
      when promoter = 1 then 1
      end as nps_key
from uat_ca.poll_id_126 a
--
left join prd2_dds_v.phone_number_2 t1 on a.msisdn = t1.msisdn
 and (a.create_date >= t1.stime and a.create_date < t1.etime)
left join prd2_dic_v.branch t2 on t1.branch_id = t2.branch_id
left join prd2_dic_v.region t3 on t2.region_id = t3.region_id
left join prd2_dic_v.macroregion t4 on t3.macroregion_id = t4.macroregion_id
;


select top 100 * from uat_ca.v_chat_bot_v2;
select count(*) from uat_ca.v_chat_bot_v2 where region is null;


--=================================================================================================
--=================================================================================================
--=================================================================================================

--show table uat_ca.poll_id_126;
--drop table uat_ca.poll_id_126;

create multiset table uat_ca.poll_id_126 (
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
 nps byteint,
 ans_2 varchar(100) character set unicode not casespecific,
 ans_3 varchar(100) character set unicode not casespecific,
 ans_4 varchar(100) character set unicode not casespecific,
 load_id integer)
primary index (subs_id)
;



