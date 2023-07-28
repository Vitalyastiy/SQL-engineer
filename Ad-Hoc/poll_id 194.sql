
diagnostic helpstats on for session;



--=================================================================================================
--=================================================================================================
--=================================================================================================

--имя точки контакта

select * from prd2_odw_v.smspoll_polls where update_date >= timestamp '2023-06-01 00:00:00';


select * from prd2_odw_v.smspoll_polls
where 1=1
 and poll_id in (194);

select count(*) from prd2_odw_v.smspoll_polls;

194     Навяз_зв_ШПД_Тариф


--уникальные q_text
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 194
order by 3, 1;


--step 1
/*
Спасибо, что вы пользуетесь Tele2! Нам важно ваше мнение. Пожалуйста, оцените готовность рекомендовать Tele2 по шкале от 1 до 10, где 1 - точно НЕ порекомендую, 10 - точно порекомендую.
Все SMS на этот номер бесплатны.
*/

--step 2 - оценки 1-8
/*
Что нам необходимо улучшить в первую очередь, чтобы вы точно смогли рекомендовать Tele2 в будущем? Отправьте в ответ одну цифру:
0. Зона покрытия
1. Качество связи
2. Тарифы 
3. Роуминг в поездках по России и за границу
4. Честность (Понятность и прозрачность списаний денег со счета Tele2)
5. Качество мобильного интернета
6. Работу абонентской службы
7. Мобильное приложение Tele2
8. Звонки от оператора с предложением сменить тариф\подключить дополнительную услугу
9. Другое
*/

--step 3
/*
Пожалуйста, опишите, что по вашему мнению нужно улучшить в первую очередь?
*/

--step 4 - оценки 9-10
/*
Спасибо за высокую оценку! Скажите пожалуйста, что повлияло на вашу оценку в первую очередь?
Отправьте в ответ одну цифру:
0. Широкая зона приема
1. Хорошее качество связи
2. Тарифы
3. Роуминг в поездках по России и за границу
4. Честность  (Понятность и прозрачность списаний денег со счета Tele2)
5. Хорошее качество мобильного интернета
6. Работа абонентской службы (вежливые, решают вопросы, легко дозвониться)
7. Мобильное приложение Tele2 (удобно пользоваться)
8. Отсутствие навязчивых звонков от оператора с предложением сменить тариф\подключить услугу
9. Другое
*/

--step 5
/*
Пожалуйста, опишите, что вам понравилось больше всего?
*/

--step 6
/*
Спасибо за участие в опросе.
*/


--==EDW
select
 cast(created_dttm as date) as created_date,
 count(distinct subs_id),
 count(*)
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id in (194)
 and created_dttm >= timestamp '2023-07-01 00:00:00'
 and created_dttm < timestamp '2023-07-17 00:00:00'
group by 1
;

2023-07-03      3           8
2023-07-05      1 148       1 903
2023-07-06      12          19
2023-07-11      1 685       2 739



--==SOA
select
 cast(a.created_date as date) as create_date,
 count(distinct msisdn)
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2023-07-01 00:00:00'
 and b.created_date < timestamp '2023-07-17 00:00:00'
 and b.poll_id in (194)
where 1=1
 and a.created_date >= timestamp '2023-07-01 00:00:00'
 and a.created_date < timestamp '2023-07-17 00:00:00'
group by 1
order by 1
;

2023-07-03      3
2023-07-04      3
2023-07-05      50 493
2023-07-11      59 507


--=================================================================================================
--=================================================================================================
--=================================================================================================

--==шаг 1 - формирование списка идентификаторов опроса - sub_list_id (sub_list_id + poll_id)

--show table sub_list;
--drop table sub_list;
--delete sub_list;

create multiset volatile table sub_list ,no log (
 create_dttm timestamp(0),
 poll_id bigint,
 sub_list_id varchar(64) character set unicode not casespecific)
primary index (sub_list_id)
on commit preserve rows;


insert into sub_list
select
 created_date as create_dttm,
 poll_id,
 sub_list_id
from prd2_odw_v.smspoll_poll_lists
where 1=1
 and created_date >= timestamp '2023-07-10 00:00:00'
 and created_date < timestamp '2023-07-17 00:00:00'
 and poll_id in (194)
;

select * from sub_list;
select cast(create_dttm as date), count(*) from sub_list group by 1 order by 1;



--==шаг 2 - формирование списка абонентов для смс рассылки (sub_list_id + treatment_code + msisdn)

COLLECT STATISTICS
 COLUMN (SUB_LIST_ID)
ON sub_list;


--show table subs;
--drop table subs;
--delete subs;

create multiset volatile table subs ,no log (
 create_dttm timestamp(6),
 sub_list_id varchar(64) character set unicode not casespecific,
 sub_list_name varchar(255) character set unicode not casespecific,
 treatment_code varchar(9) character set unicode not casespecific,
 branch_id smallint,
 msisdn varchar(11) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into subs
select
 a.created_date as create_dttm,
 a.sub_list_id,
 a.sub_list_name,
 a.treatment_code,
 a.branch_id,
 a.msisdn as msisdn
from prd2_odw_v.smspoll_communication_lists a
--
inner join sub_list t1 on a.sub_list_id = t1.sub_list_id
--
where 1=1
 and created_date >= timestamp '2023-07-10 00:00:00'
 and created_date < timestamp '2023-07-17 00:00:00'
;

select * from subs;
select cast(create_dttm as date), count(*) from subs group by 1 order by 1;


--шаг 3 - формирование списка идентификаторов опроса с привязкой к идентификатору коммуникации - current_communication_id (sub_list_id - poll_id + current_communication_id)

COLLECT STATISTICS
 COLUMN (SUB_LIST_ID ,SUB_LIST_NAME),
 COLUMN (SUB_LIST_NAME),
 COLUMN (SUB_LIST_ID)
ON subs;


--show table comm;
--drop table comm;
--delete comm;

create multiset volatile table comm ,no log (
 create_dttm timestamp(0),
 run_dttm timestamp(0),
 short_number smallint,
 poll_id bigint,
 sub_list_id varchar(64) character set unicode not casespecific,
 sub_list_name varchar(255) character set unicode not casespecific,
 current_communication_id bigint,
 activity_status smallint)
primary index (sub_list_id)
on commit preserve rows;


insert into comm
select
 a.created_date as create_dttm,
 a.run_time as run_dttm,
 a.short_number,
 a.poll_id,
 a.sub_list_id,
 t2.sub_list_name,
 a.current_communication_id,
 a.activity_status
from prd2_odw_v.smspoll_current_communications a
--
inner join sub_list t1 on a.sub_list_id = t1.sub_list_id
left join (select distinct sub_list_id, sub_list_name from subs) t2 on t1.sub_list_id = t2.sub_list_id
--
where 1=1
 and created_date >= timestamp '2023-07-10 00:00:00'
 and created_date < timestamp '2023-07-17 00:00:00'
;

select * from comm;
select cast(create_dttm as date), count(*) from comm group by 1 order by 1;


--шаг 4 - формирование cтатусо отправок СМС (current_communication_id + msisdn + q_step)

COLLECT STATISTICS
 COLUMN (BRANCH_ID),
 COLUMN (MSISDN)
ON subs;

COLLECT STATISTICS
 COLUMN (SUB_LIST_ID),
 COLUMN (CURRENT_COMMUNICATION_ID)
ON comm;


--show table sms;
--drop table sms;
--delete sms;


create multiset volatile table sms (
 sub_list_create timestamp(0),
 sub_list_id varchar(64) character set unicode not casespecific,
 sub_list_name varchar(255) character set unicode not casespecific,
 comm_create timestamp(0),
 comm_id bigint,
 poll_id bigint,
 short_number smallint,
 sms_create timestamp(0),
 treatment_id varchar(13) character set unicode not casespecific,
 date_topic timestamp(0),
 date_delivery timestamp(0),
 date_smpp timestamp(0),
 region varchar(50) character set unicode casespecific,
 msisdn varchar(11) character set unicode not casespecific,
 q_step smallint,
 status_delivery smallint,
 status_name varchar(25) character set unicode not casespecific,
 other_sms_flg varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows
;


--create multiset volatile table sms, no log as (
insert into sms
select
 cast(substring(cast(t2.create_dttm as char(26)) from 1 for 19) as timestamp(0)) as sub_list_create,
 t1.sub_list_id,
 t1.sub_list_name,
--
 t1.create_dttm as comm_create,
 a.current_communication_id as comm_id,
 t1.poll_id,
 t1.short_number,
--
 a.created_date as sms_create,
 case when t2.treatment_code = 0 then 'ручной список' else t2.treatment_code end as treatment_id,
 a.date_topic,
 a.date_delivery,
 a.date_smpp,
 t4.region_name as region,
 a.msisdn,
 a.q_step,
 a.status_delivery,
 case when a.status_delivery = 0 then 'взято в работу'
      when a.status_delivery = 1 then 'отправлено'
      when a.status_delivery = 2 then 'доставлено'
      when a.status_delivery = 3 then 'устарело'
      when a.status_delivery = 4 then 'ошибка'
      when a.status_delivery = 5 then 'отвечено'
 end as status_name,
 case when a.another_partaker = 1 then 'участие в другом опросе на момент запуска' else '' end as other_sms_flg
from prd2_odw_v.smspoll_sms_sending_status a
--список идентификаторов опроса с привязкой к идентификатору коммуникации
inner join comm t1 on a.current_communication_id = t1.current_communication_id
--список абонентов для смс рассылки
inner join subs t2 on t1.sub_list_id = t2.sub_list_id
 and a.msisdn = t2.msisdn
--
left join prd2_dic_v.branch t3 on t2.branch_id = t3.branch_id
left join prd2_dic_v.region t4 on t3.region_id = t4.region_id
--
where 1=1
 and a.created_date >= timestamp '2023-07-10 00:00:00'
 and a.created_date < timestamp '2023-07-17 00:00:00'       --на один день больше из-за долетов
--) with no data
--primary index (msisdn)
--on commit preserve rows
;

select * from sms;
select cast(sub_list_create as date), count(*) from sms group by 1 order by 1;



--show table mon;
--drop table mon;
--delete mon;


create multiset volatile table mon ,no log (
  poll_id bigint,
  poll_name varchar(250) character set unicode not casespecific,
  step smallint,
  sub_list_create timestamp(0),
  sms_create timestamp(0),
  date_topic timestamp(0),
  "кол-во на опрос" integer,
  "взято в работу" integer,
  "отправлено" integer,
  "доставлено" integer,
  "устарело" integer,
  "ошибка" integer,
  "отвечено" integer,
  "участие в другом опросе на момент запуска" integer)
primary index ( poll_id )
on commit preserve rows;


--create multiset volatile table mon, no log as (
insert into mon
select
 a.poll_id,
 t1.poll_name as poll_name,
 a.q_step as step,
 min(a.sub_list_create) as sub_list_create,
 min(a.sms_create) as sms_create,
 min(a.date_topic) as date_topic,
 count(distinct a.msisdn) as "кол-во на опрос",
-- count(*) as row_cnt,
 sum(case when a.status_delivery = 0 then 1 else 0 end) as "взято в работу",
 sum(case when a.status_delivery = 1 then 1 else 0 end) as "отправлено",
 sum(case when a.status_delivery = 2 then 1 else 0 end) as "доставлено",
 sum(case when a.status_delivery = 3 then 1 else 0 end) as "устарело",
 sum(case when a.status_delivery = 4 then 1 else 0 end) as "ошибка",
 sum(case when a.status_delivery = 5 then 1 else 0 end) as "отвечено",
 sum(case when a.other_sms_flg = 'участие в другом опросе на момент запуска' then 1 else 0 end) as "участие в другом опросе на момент запуска"
from sms a
--
left join prd2_odw_v.smspoll_polls t1 on a.poll_id = t1.poll_id
--
where 1=1
 and a.poll_id = 194
 and a.sub_list_create >= timestamp '2023-07-10 00:00:00'
 and a.sub_list_create < timestamp '2023-07-17 00:00:00'
 and a.q_step = 1
group by 1,2,3
--) with no data
--primary index (poll_id)
--on commit preserve rows
;


select * from mon;


COLLECT STATISTICS
 COLUMN (CREATE_DTTM)
ON subs;

COLLECT STATISTICS
COLUMN (MSISDN)
ON uat_ca.nps_opros_subs;



--опрос за 2023-07-03
select distinct a.msisdn from subs a
--inner join uat_ca.nps_opros_subs_aladdin t1 on a.msisdn = t1.msisdn
--inner join uat_ca.nps_opros_subs t1 on a.msisdn = t1.msisdn
where 1=1
 and a.create_dttm >= timestamp '2023-07-03 00:00:00'
 and a.create_dttm < timestamp '2023-07-04 00:00:00'
;

79265033309
79777914944
79998880808



--опрос за 2023-07-04   список абонентов Алладин - выборки Саши: Annoying_calls_1_04.07.csv
select distinct a.msisdn from subs a
inner join uat_ca.nps_opros_subs_aladdin t1 on a.msisdn = t1.msisdn
--inner join uat_ca.nps_opros_subs t1 on a.msisdn = t1.msisdn
where 1=1
 and a.create_dttm >= timestamp '2023-07-04 00:00:00'
 and a.create_dttm < timestamp '2023-07-05 00:00:00'
;

79523190047
79501583244
79501159028



--опрос за 2023-07-05   список абонентов Опрос Subs - выборки Саши: выборка Саши: Annoying_calls_2_05.07.csv
select distinct a.msisdn from subs a
--inner join uat_ca.nps_opros_subs_aladdin t1 on a.msisdn = t1.msisdn
inner join uat_ca.nps_opros_subs t1 on a.msisdn = t1.msisdn
where 1=1
 and a.create_dttm >= timestamp '2023-07-05 00:00:00'
 and a.create_dttm < timestamp '2023-07-06 00:00:00'
;



--разбор выборок
select top 100 * from tele2_uat.sr_NPS_opros_subs_aladdin;
select count(*) from tele2_uat.sr_NPS_opros_subs_aladdin;       --73 655        - выборки Саши: Annoying_calls_1_04.07.csv
select top 100 * from uat_ca.nps_opros_subs_aladdin;
select count(*) from uat_ca.nps_opros_subs_aladdin;             --73 655


select top 100 * from tele2_uat.sr_NPS_opros_subs;
select count(*) from tele2_uat.sr_NPS_opros_subs;               --203 213       - выборка Саши: Annoying_calls_2_05.07.csv
select top 100 * from uat_ca.nps_opros_subs;
select count(*) from uat_ca.nps_opros_subs;                     --203 213


--готовый опрос
select top 100 * from uat_ca.v_poll_194;
select * from uat_ca.v_poll_194;


--пересечение с tele2_uat.sr_NPS_opros_subs_aladdin
select a.* from uat_ca.v_poll_194 a
inner join uat_ca.nps_opros_subs_aladdin t1 on a.subs_id = t1.subs_id
;

--пересечение с tele2_uat.sr_NPS_opros_subs     -- 1 159
select a.* from uat_ca.v_poll_194 a
inner join uat_ca.nps_opros_subs t1 on a.subs_id = t1.subs_id
;


--=================================================================================================
--=================================================================================================
--=================================================================================================

--show procedure uat_ca.mc_nps_bu_194;


REPLACE PROCEDURE uat_ca.mc_nps_bu_194 (in stime timestamp, in etime timestamp, point_name varchar(255))
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

SET proc = 'nps_194';           -- наименование расчета

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
 and poll_id = 194
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2023-07-03 00:00:00'
-- and created_dttm < timestamp '2023-07-10 00:00:00'
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
Спасибо, что вы пользуетесь Tele2! Нам важно ваше мнение. Пожалуйста, оцените готовность рекомендовать Tele2 по шкале от 1 до 10, где 1 - точно НЕ порекомендую, 10 - точно порекомендую.
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


--==04 Step 2 - оценки 1-8
/*
Что нам необходимо улучшить в первую очередь, чтобы вы точно смогли рекомендовать Tele2 в будущем? Отправьте в ответ одну цифру:
0. Зона покрытия
1. Качество связи
2. Тарифы 
3. Роуминг в поездках по России и за границу
4. Честность (Понятность и прозрачность списаний денег со счета Tele2)
5. Качество мобильного интернета
6. Работу абонентской службы
7. Мобильное приложение Tele2
8. Звонки от оператора с предложением сменить тариф\подключить дополнительную услугу
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
Пожалуйста, опишите, что по вашему мнению нужно улучшить в первую очередь?
*/

--==06 Step 4 - оценки 9-10
/*
Спасибо за высокую оценку! Скажите пожалуйста, что повлияло на вашу оценку в первую очередь?
Отправьте в ответ одну цифру:
0. Широкая зона приема
1. Хорошее качество связи
2. Тарифы
3. Роуминг в поездках по России и за границу
4. Честность  (Понятность и прозрачность списаний денег со счета Tele2)
5. Хорошее качество мобильного интернета
6. Работа абонентской службы (вежливые, решают вопросы, легко дозвониться)
7. Мобильное приложение Tele2 (удобно пользоваться)
8. Отсутствие навязчивых звонков от оператора с предложением сменить тариф\подключить услугу
9. Другое
*/
create multiset volatile table soa_step4_1, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 length_step_4 number,
 ans_4 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

create multiset volatile table soa_step4, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 ans_4 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step4_1
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_4,
 length (oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.','')) length_step_4,
 case when mark_4 is null then null
      when length_step_4 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.',''), '[0-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.',''), '[0-9]\d{0,2}') else '-1' end
      else '-1' end as ans_4
from soa_2
;

insert into soa_step4
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_4,
 case when ans_4 is null then null
      when ans_4 = -1 then 'Другое'
      when ans_4 = 0 then 'Зона покрытия'
      when ans_4 = 1 then 'Качество связи'
      when ans_4 = 2 then 'Тарифы'
      when ans_4 = 3 then 'Роуминг'
      when ans_4 = 4 then 'Честность'
      when ans_4 = 5 then 'Качество мобильного интернета'
      when ans_4 = 6 then 'Работа абонентской службы'
      when ans_4 = 7 then 'Мобильное приложение Tele2'
      when ans_4 = 8 then 'Звонки от оператора'
      when ans_4 = 9 then 'Другое'
      else '-1' end as ans_4
from soa_step4_1
;

--select * from soa_step4;


--==07 Step 5
/*
Пожалуйста, опишите, что вам понравилось больше всего?
*/


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
ON soa_step4;

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
 point_name varchar(255) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_4 varchar(1024) character set unicode not casespecific,
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
 :point_name as point_name,
 a.mark_1,              --NPS
 a.mark_2,              --Что необходимо улучшить в первую очередь
 a.mark_3,
 a.mark_4,              --Что вам нравится больше всего
 a.mark_5,
 a.mark_6,
 t1.ans_2,
 t2.ans_4,
 t3.nps,
 a.load_id
from soa_2 a
--
left join soa_step2 t1 on a.msisdn = t1.msisdn and a.create_date = t1.create_date                   --Что необходимо улучшить в первую очередь
left join soa_step4 t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date                   --Что вам нравится больше всего
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
insert into uat_ca.poll_id_194
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.point_name,
 coalesce(a.mark_1,  t1.mark_1) as mark_1,
 coalesce(a.mark_2,  t1.mark_2) as mark_2,
 coalesce(a.mark_3,  t1.mark_3) as mark_3,
 coalesce(a.mark_4,  t1.mark_4) as mark_4,
 coalesce(a.mark_5,  t1.mark_5) as mark_5,
 coalesce(a.mark_6,  t1.mark_6) as mark_6,
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.ans_4,   t1.ans_4) as ans_4,
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

--select top 100 * from uat_ca.poll_id_194;


-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Строк по долетам: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--абоненты без долетов
insert into uat_ca.poll_id_194
select
  a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.point_name,
 a.mark_1,
 a.mark_2,
 a.mark_3,
 a.mark_4,
 a.mark_5,
 a.mark_6,
 a.ans_2,
 a.ans_4,
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
drop table soa_step4_1;
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
COMMENT ON PROCEDURE uat_ca.mc_nps_bu_194 AS
'Процедура формирования витрины с опросами NPS SOA 2.0, тк Тарифы, ШПД. Результирующая таблица: uat_ca.poll_id_194';


--=================================================================================================
--=================================================================================================
--=================================================================================================

--Тарифы
call uat_ca.mc_nps_bu_194 (timestamp'2023-07-03 00:00:00', timestamp'2023-07-10 00:00:00', 'Тарифы_203');

--ШПД
call uat_ca.mc_nps_bu_194 (timestamp'2023-07-10 00:00:00', timestamp'2023-07-12 00:00:00', 'ШПД_73');


select top 100 * from uat_ca.poll_id_194;
select top 100 * from uat_ca.v_poll_194;

select create_date, count(*) from uat_ca.poll_id_194 group by 1 order by 1;


-- Для просмотра рассчитанных дней в момент работы процедуры, либо по ее завершению используйте запрос по таблице логов:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_194'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;



select count(*) from uat_ca.v_poll_194;                                 --1 163

select nps_flg, count(*) from uat_ca.v_poll_194 group by 1;
1   1 121
0   42

select group_type, count(*) from uat_ca.v_poll_194 group by 1;


--total результат
select
 first_day_week,
 point_name,
 100*nps (format 'zz.zz%') (varchar(10)) as nps,
 subs_cnt,
 100*1.96*stddev/sqrt(subs_cnt) (format 'zz.zz%') (varchar(10)) as "погрешность",
 100*(nps - 1.96*stddev/sqrt(subs_cnt)) (format 'zz.zz%') (varchar(10)) as lower_threshold,
 100*(nps + 1.96*stddev/sqrt(subs_cnt)) (format 'zz.zz%') (varchar(10)) as upper_threshold
from (
select
-- trunc (create_date,'mm') as report_month,
-- weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v_poll_194
where 1=1
 and create_date >= date '2023-07-03'
 and create_date < date '2023-07-17'
 and nps_flg = 1
group by 1,2
) a
order by 1
;

create_date     point_name                  nps         subs_cnt        погрешность        lower_threshold         upper_threshold
------------    ------------                ------      --------        --------           ---------------         ---------------
2023-07-05      Тарифы_203                  18.74%      1 121           5.33%              13.41%                  24.08%
2023-07-11      ШПД_73                      47.23%      1 626           3.97%              43.25%                  51.20%



--total результат Наш TD
select
 create_date,
 point_name,
 100*nps (format 'zz.zz%') (varchar(10)) as nps,
 subs_cnt,
 100*1.96*stddev/sqrt(subs_cnt) (format 'zz.zz%') (varchar(10)) as "погрешность",
 100*(nps - 1.96*stddev/sqrt(subs_cnt)) (format 'zz.zz%') (varchar(10)) as lower_threshold,
 100*(nps + 1.96*stddev/sqrt(subs_cnt)) (format 'zz.zz%') (varchar(10)) as upper_threshold
from (
select
 create_date,
 point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v3_nps_main_td
where 1=1
 and create_date in (date '2023-07-05', date '2023-07-10')
group by 1,2
) a
;

create_date     point_name                  nps         subs_cnt        погрешность        lower_threshold         upper_threshold
------------    ------------                ------      --------        --------           ---------------         ---------------
2023-07-05      Наш TD                      38.30%      812             5.95%               32.36%                 44.25%
2023-07-10      Наш TD                      39.79%      857             5.73%               34.06%                 45.52%

select top 100 * from uat_ca.v3_nps_main_td;
select nps, count(*) from uat_ca.v3_nps_main_td group by 1;


--результат по ТГ/КГ
select
 first_day_week,
 group_type,
 100*nps (format 'zz.zz%') (varchar(10)) as nps,
 subs_cnt,
 100*1.96*stddev/sqrt(subs_cnt) (format 'zz.zz%') (varchar(10)) as "погрешность",
 100*(nps - 1.96*stddev/sqrt(subs_cnt)) (format 'zz.zz%') (varchar(10)) as lower_threshold,
 100*(nps + 1.96*stddev/sqrt(subs_cnt)) (format 'zz.zz%') (varchar(10)) as upper_threshold
from (
select
-- trunc (create_date,'mm') as report_month,
-- weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 group_type,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v_poll_194
where 1=1
 and create_date >= date '2023-07-03'
 and create_date < date '2023-07-17'
 and nps_flg = 1
 and group_type not in ('n/a')
group by 1,2
) a
order by 1
;

report_month    point_name              nps         subs_cnt        погрешность        lower_threshold         upper_threshold
------------    ------------            ------      --------        --------           ---------------         ---------------
2023-07-05      Целевая группа          18.13%      656             7.03%               11.10%                  25.16%
2023-07-05      Контрольная группа      19.78%      461             8.21%               11.58%                  27.99%

2023-07-11      Целевая группа          47.95%      1 054           4.87%               43.08%                  52.83%
2023-07-11      Контрольная группа      45.69%      570             6.87%               38.83%                  52.56%


--Тарифы
Ген. совокупность CBM       --203 213
Выборка на опрос            --50 493 - 24.8%
Ответившие абоненты         --1 161, респонс от доставленных - 2.5%

--ШПД
Ген. совокупность CBM       --73 655
Выборка на опрос            --59 507 - 80.8%
Ответившие абоненты         --1 686, респонс от доставленных - 3.7%


--==Выборка на опрос
--тарифы
select
 group_type,
 count(*) as subs_cnt,
 sum(subs_cnt) over() as total,
 100*cast(subs_cnt as float)/total (format 'zz.zz%') (varchar(10)) as share_gr
from uat_ca.nps_opros_subs
group by 1
order by 1 desc
;

--шпд
select
 group_type,
 count(*) as subs_cnt,
 sum(subs_cnt) over() as total,
 100*cast(subs_cnt as float)/total (format 'zz.zz%') (varchar(10)) as share_gr
from uat_ca.nps_opros_subs_aladdin
group by 1
order by 1 desc
;



--==Выборка на опрос
--тарифы
select
 group_type,
 count(*) as subs_cnt,
 sum(subs_cnt) over() as total,
 100*cast(subs_cnt as float)/total (format 'zz.zz%') (varchar(10)) as share_gr
from (
select
 distinct a.msisdn,
 coalesce(t1.group_type,'n/a') as group_type
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2023-07-03 00:00:00'
 and b.created_date < timestamp '2023-07-10 00:00:00'
 and b.poll_id in (194)
--
left join uat_ca.nps_opros_subs t1 on a.msisdn = t1.msisdn
--
where 1=1
 and a.created_date >= timestamp '2023-07-03 00:00:00'
 and a.created_date < timestamp '2023-07-10 00:00:00'
) a
group by 1
order by 1 desc
;

--шпд
select
 group_type,
 count(*) as subs_cnt,
 sum(subs_cnt) over() as total,
 100*cast(subs_cnt as float)/total (format 'zz.zz%') (varchar(10)) as share_gr
from (
select
 distinct a.msisdn,
 coalesce(t1.group_type,'n/a') as group_type
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2023-07-10 00:00:00'
 and b.created_date < timestamp '2023-07-17 00:00:00'
 and b.poll_id in (194)
--
left join uat_ca.nps_opros_subs_aladdin t1 on a.msisdn = t1.msisdn
--
where 1=1
 and a.created_date >= timestamp '2023-07-10 00:00:00'
 and a.created_date < timestamp '2023-07-17 00:00:00'
) a
group by 1
order by 1 desc
;



--==Результат опроса
--тарифы
select
 group_type,
 count(*) as subs_cnt,
 sum(subs_cnt) over() as total,
 100*cast(subs_cnt as float)/total (format 'zz.zz%') (varchar(10)) as share_gr
from uat_ca.v_poll_194_tp
group by 1
order by 1 desc
;

--шпд
select
 group_type,
 count(*) as subs_cnt,
 sum(subs_cnt) over() as total,
 100*cast(subs_cnt as float)/total (format 'zz.zz%') (varchar(10)) as share_gr
from uat_ca.v_poll_194_spd
group by 1
order by 1 desc
;



--==Пересечение с опросом FraudResearch

select top 100 * from uat_ca.v_poll_96;

--апрель, май, июнь
select count(distinct msisdn), count(*) from uat_ca.v_poll_96 where create_date >= date '2023-04-01' and create_date < date '2023-07-01';       --165 033, 182 697
select * from uat_ca.v_poll_96 where create_date >= date '2023-04-01' and create_date < date '2023-07-01' qualify count(*) over (partition by msisdn) > 4;


--drop table step_1;

create multiset volatile table step_1, no log as (
select
 create_date,
 msisdn,
 ans_1,
 dense_rank() over (partition by msisdn order by ans_key) as rn_3
from (
select a.*, dense_rank() over (partition by msisdn, create_year order by create_date, ans_key) as rn_2
from (
select
 trunc(create_date,'y') as create_year,
 create_date,
 msisdn,
 ans_1,
 case when ans_1 = 'Навязчивая реклама' then 1
      when ans_1 = 'Другой нежелательный звонок' then 2
      when ans_1 = 'Мошенничество' then 3
      when ans_1 = 'Обычный звонок' then 4
 else 5 end as ans_key,
 dense_rank() over (partition by msisdn, trunc(create_date,'mm') order by ans_key) as rn
from uat_ca.v_poll_96
where 1=1
 and create_date >= date '2023-01-01'
 and create_date < date '2023-07-01'
-- and msisdn = '79000184313'
-- and msisdn = '79000246093'
) a
where 1=1
 and a.rn = 1
) a
where 1=1
 and a.rn_2 = 1
) with data
primary index (msisdn)
on commit preserve rows
;

select count(distinct msisdn), count(*) from step_1;
select * from step_1 qualify count(*) over (partition by msisdn) > 3;

select top 100 * from step_1;


--тарифы
select group_type, ans_1, count(*) from (
select
 a.*,
 t1.ans_1
from uat_ca.v_poll_194_tp a
--
left join step_1 t1 on a.msisdn = t1.msisdn
) a
group by 1,2
order by 1,2
;

целевая     683      - нав+неж+мош - 6, 0.9%
контрольная 476      - нав+неж+мош - 8, 1.7%

--шпд
select group_type, ans_1, count(*) from (
select
 a.*,
 t1.ans_1
from uat_ca.v_poll_194_spd a
--
left join step_1 t1 on a.msisdn = t1.msisdn
) a
group by 1,2
order by 1,2
;

целевая     1089     - нав+неж+мош - 19, 1.7%
контрольная 594      - нав+неж+мош - 13, 2.2%


select * from uat_ca.v_poll_194_tp;
select * from uat_ca.v_poll_194_spd;



/* Скребцов Роман
Дополнил таблицы tele2_uat.sr_NPS_opros_subs, tele2_uat.sr_NPS_opros_subs_aladdin полем group_type:
Целевая группа - абоненты, которым звонили
Контрольная группа - абоненты, которым не звонили

select top 100 * from tele2_uat.sr_NPS_opros_subs_aladdin;
select count(*) from tele2_uat.sr_NPS_opros_subs_aladdin;       --73 655

select top 100 * from tele2_uat.sr_NPS_opros_subs;
select count(*) from tele2_uat.sr_NPS_opros_subs;               --203 213


--1
show table tele2_uat.sr_NPS_opros_subs_aladdin;
--drop table uat_ca.nps_opros_subs_aladdin;

create multiset table uat_ca.nps_opros_subs_aladdin (
 subs_id decimal(12,0),
 msisdn varchar(11) character set unicode not casespecific,
 group_type varchar(200) character set unicode not casespecific)
primary index (subs_id);

insert into uat_ca.nps_opros_subs_aladdin
select
 subs_id,
 substr(cast(msisdn as varchar(20)),1,11) as msisdn,
 group_type
from tele2_uat.sr_NPS_opros_subs_aladdin
;

select top 100 * from uat_ca.nps_opros_subs_aladdin;


--2
show table tele2_uat.sr_NPS_opros_subs;
--drop table uat_ca.nps_opros_subs;

create multiset table uat_ca.nps_opros_subs (
 subs_id decimal(12,0),
 msisdn varchar(11) character set unicode not casespecific,
 group_type varchar(200) character set unicode not casespecific)
primary index (subs_id);

insert into uat_ca.nps_opros_subs
select
 subs_id,
 substr(cast(msisdn as varchar(20)),1,11) as msisdn,
 group_type
from tele2_uat.sr_NPS_opros_subs
;

select top 100 * from uat_ca.nps_opros_subs;

*/



--View тарифы
replace view uat_ca.v_poll_194_tp as
lock row for access
select
 a.create_date,
 t2.cluster_name as cluster_name,
 t4.macroregion_name as macroregion,
 t3.region_name as region,
 point_name,
 a.msisdn,
 a.subs_id,
-- treatment_code,
 case when a.nps = -1 then a.mark_1 end as mark_1,
 case when a.ans_2 = 'Другое' then a.mark_2 end as mark_2,
 a.mark_3,
 case when a.ans_4 = 'Другое' then a.mark_4 end as mark_4,
 a.mark_5,
 a.mark_6,
 a.ans_2,
 a.ans_4,
 a.nps,
 case when a.nps in (1,2,3,4,5,6) then -1
      when a.nps in (7,8) then 0
      when a.nps in (9, 10) then 1
 end as nps_key,
 case when a.nps = -1 then 0 else 1 end as nps_flg,
 coalesce(t5.group_type,'n/a') as group_type
-- load_id,
from uat_ca.poll_id_194 a
--
left join prd2_dds_v.phone_number_2 t1 on a.msisdn = t1.msisdn
 and (a.create_date >= t1.stime and a.create_date < t1.etime)
left join prd2_dic_v.branch t2 on t1.branch_id = t2.branch_id
left join prd2_dic_v.region t3 on t2.region_id = t3.region_id
left join prd2_dic_v.macroregion t4 on t3.macroregion_id = t4.macroregion_id
--
left join uat_ca.nps_opros_subs t5 on a.subs_id = t5.subs_id
--
where 1=1
 and a.create_date >= date '2023-07-03'
 and a.create_date < date '2023-07-10'
;



--View шпд
replace view uat_ca.v_poll_194_spd as
lock row for access
select
 a.create_date,
 t2.cluster_name as cluster_name,
 t4.macroregion_name as macroregion,
 t3.region_name as region,
 point_name,
 a.msisdn,
 a.subs_id,
-- treatment_code,
 case when a.nps = -1 then a.mark_1 end as mark_1,
 case when a.ans_2 = 'Другое' then a.mark_2 end as mark_2,
 a.mark_3,
 case when a.ans_4 = 'Другое' then a.mark_4 end as mark_4,
 a.mark_5,
 a.mark_6,
 a.ans_2,
 a.ans_4,
 a.nps,
 case when a.nps in (1,2,3,4,5,6) then -1
      when a.nps in (7,8) then 0
      when a.nps in (9, 10) then 1
 end as nps_key,
 case when a.nps = -1 then 0 else 1 end as nps_flg,
 coalesce(t5.group_type,'n/a') as group_type
-- load_id,
from uat_ca.poll_id_194 a
--
left join prd2_dds_v.phone_number_2 t1 on a.msisdn = t1.msisdn
 and (a.create_date >= t1.stime and a.create_date < t1.etime)
left join prd2_dic_v.branch t2 on t1.branch_id = t2.branch_id
left join prd2_dic_v.region t3 on t2.region_id = t3.region_id
left join prd2_dic_v.macroregion t4 on t3.macroregion_id = t4.macroregion_id
--
left join uat_ca.nps_opros_subs_aladdin t5 on a.subs_id = t5.subs_id
--
where 1=1
 and a.create_date >= date '2023-07-10'
 and a.create_date < date '2023-07-17'
;


replace view uat_ca.v_poll_194 as
select * from uat_ca.v_poll_194_tp
union all
select * from uat_ca.v_poll_194_spd
;


COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (MSISDN)
ON uat_ca.poll_id_194
;

--==================================================================================================
--==================================================================================================
--==================================================================================================

--show table uat_ca.poll_id_194;

create multiset table uat_ca.poll_id_194 (
 create_date date format 'yy/mm/dd',
 msisdn varchar(11) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 point_name varchar(255) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_4 varchar(1024) character set unicode not casespecific,
 nps byteint,
 load_id integer)
primary index (subs_id);



rename table uat_ca.poll_id_194 as uat_ca.poll_id_194_tmp;


insert into uat_ca.poll_id_194
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 'Тарифы_203' as point_name,
 mark_1,
 mark_2,
 mark_3,
 mark_4,
 mark_5,
 mark_6,
 ans_2,
 ans_4,
 nps,
 load_id
from uat_ca.poll_id_194_tmp
;


select count(*) from uat_ca.poll_id_194;
select count(*) from uat_ca.poll_id_194_tmp;

select * from uat_ca.poll_id_194;
--drop table uat_ca.poll_id_194_tmp;


--==update витрин

Дополнил таблицы tele2_uat.sr_NPS_opros_subs, tele2_uat.sr_NPS_opros_subs_aladdin полем group_type:
Целевая группа - абоненты, которым звонили
Контрольная группа - абоненты, которым не звонили



--==ШПД

select top 100 * from tele2_uat.sr_NPS_opros_subs_aladdin;
select count(*) from tele2_uat.sr_NPS_opros_subs_aladdin;       --73 655

select top 100 * from uat_ca.v_poll_194_spd;
select count(*) from uat_ca.v_poll_194_spd;                     --
select top 100 * from uat_ca.nps_opros_subs_aladdin;



insert into tele2_uat.sr_NPS_opros_subs_aladdin
select
 a.SUBS_ID,
 a.MSISDN,
 a.group_type,
 nvl2(t1.msisdn,1,0) as research
from uat_ca.nps_opros_subs_aladdin a
--
left join uat_ca.v_poll_194_spd t1 on a.msisdn = t1.msisdn
;

select research, count(*) from tele2_uat.sr_NPS_opros_subs_aladdin group by 1;
select * from tele2_uat.sr_NPS_opros_subs_aladdin sample 0.01;



show table tele2_uat.sr_NPS_opros_subs_aladdin;

CREATE MULTISET TABLE tele2_uat.sr_NPS_opros_subs_aladdin ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO,
     MAP = TD_MAP1
     (
      SUBS_ID DECIMAL(12,0),
      MSISDN VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      group_type VARCHAR(200) CHARACTER SET UNICODE NOT CASESPECIFIC,
      research BYTEINT
      )
PRIMARY INDEX ( SUBS_ID );

rename table tele2_uat.sr_NPS_opros_subs_aladdin as tele2_uat.sr_NPS_opros_subs_aladdin_tmp;

--drop table tele2_uat.sr_NPS_opros_subs_aladdin_tmp;



--==Тарифы

select top 100 * from tele2_uat.sr_NPS_opros_subs;
select count(*) from tele2_uat.sr_NPS_opros_subs;               --203 213

select top 100 * from uat_ca.v_poll_194_tp;
select count(*) from uat_ca.v_poll_194_tp;                      -- 1 685
select top 100 * from uat_ca.nps_opros_subs;


insert into tele2_uat.sr_NPS_opros_subs
select
 a.SUBS_ID,
 a.MSISDN,
 a.group_type,
 nvl2(t1.msisdn,1,0) as research
from uat_ca.nps_opros_subs a
--
left join uat_ca.v_poll_194_tp t1  on a.msisdn = t1.msisdn
;

select research, count(*) from tele2_uat.sr_NPS_opros_subs group by 1;


show table tele2_uat.sr_NPS_opros_subs;

CREATE MULTISET TABLE tele2_uat.sr_NPS_opros_subs ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO,
     MAP = TD_MAP1
     (
      SUBS_ID DECIMAL(12,0),
      MSISDN VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      group_type VARCHAR(200) CHARACTER SET UNICODE NOT CASESPECIFIC,
      research BYTEINT
      )
PRIMARY INDEX ( SUBS_ID );

rename table tele2_uat.sr_NPS_opros_subs as tele2_uat.sr_NPS_opros_subs_tmp;

--drop table tele2_uat.sr_NPS_opros_subs_tmp;












