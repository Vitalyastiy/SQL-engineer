
diagnostic helpstats on for session;

/*
2022-11-17
Привет, запустил 2 опроса:
NPS_MIXX, Poll_ID=184
Чат-бот, Poll_ID=126

*/

--=================================================================================================

--точка контакта NPS_MIXX
select * from prd2_odw_v.smspoll_polls
where 1=1
 and poll_id in (184);

--уникальные q_text
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 184
order by 3, 1;


--1
Спасибо, что Вы пользуетесь подпиской Mixx от Tele2! Учитывая Ваш опыт использования подписки, оцените готовность рекомендовать Mixx от 1 до 10,
где 1 - точно не порекомендую, 10 - точно порекомендую. Отправьте цифру в ответ.

--2
Пожалуйста, выберите причину, по которой Вы НЕ можете поставить более высокую оценку? Отправьте одну цифру в ответ:
1. Неудобно активировать сервисы внутри подписки
2. Не хватает интересных мне сервисов 
3. Дороже, чем другие подписки
4. Не устраивает соотношение цена/качество
5. Непонятно, как пользоваться сервисами внутри подписки
6. Свой вариант ответа

--3
Будем благодарны, если поделитесь, какие сервисы Вы дополнительно хотели бы видеть в составе подписки?

--4
Спасибо за участие, хорошего Вам дня!

--5
Будем благодарны, если в ответ на данное сообщение Вы поделитесь, что нам нужно изменить в подписке Mixx, чтобы она стала лучше?

--6
Спасибо за высокую оценку! Пожалуйста, укажите, что из нижеперечисленного Вам понравилось больше всего? Отправьте одну цифру в ответ:
1. Возможность настраивать состав подписки 
2. Есть все нужные мне сервисы
3. Дешевле, чем другие подписки
4. Возможность пользовать подпиской, не являясь абонентом Tele2
5. Соотношение цена/качество
6. Понятно, как пользоваться сервисами внутри подписки
7. Свой вариант ответа

--7
Спасибо за участие! Будем благодарны, если в ответ на данное сообщение Вы поделитесь, почему вы выбрали данную причину.
Хорошего вам дня!



--уникальные q_text
lock row for access
select q_step, length(q_text) from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 184
order by 1;

1       225
2       363
3       102
4       37
5       128
6       418
7       138


--==Список абонентов на опрос
select
 weeknumber_of_year (a.created_date, 'ISO') as "неделя",
 trunc (a.created_date,'iw') as first_day_week,
 cast(a.created_date as date) as create_date,
 count(distinct msisdn)
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2022-12-01 00:00:00'
 and b.created_date < timestamp '2023-01-01 00:00:00'
 and b.poll_id = 184
where 1=1
 and a.created_date >= timestamp '2022-12-01 00:00:00'
 and a.created_date < timestamp '2023-01-01 00:00:00'
group by 1,2,3
order by 3;

45  2022-11-07,2022-11-09       10

46  2022-11-14,2022-11-16       8
46  2022-11-14,2022-11-17       33 815

49  2022-12-05,2022-12-07       13 322


--=================================================================================================
--=================================================================================================
--=================================================================================================

REPLACE PROCEDURE uat_ca.mc_nps_bu_184 (in stime timestamp, in etime timestamp)
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

SET proc = 'nps_184';           -- наименование расчета

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
 and poll_id = 184
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2022-11-21 00:00:00'
-- and created_dttm < timestamp '2022-11-28 00:00:00'
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
 mark_7 varchar(1024) character set unicode not casespecific,
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
 max (step_7) as mark_7,
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


--03 Step 1 NPS
/*
Спасибо, что Вы пользуетесь подпиской Mixx от Tele2! Учитывая Ваш опыт использования подписки, оцените готовность
рекомендовать Mixx от 1 до 10, где 1 - точно не порекомендую, 10 - точно порекомендую. Отправьте цифру в ответ.
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


--04 Step 2 Почему вы не можете поставить более высокую оценку
/*
Пожалуйста, выберите причину, по которой Вы НЕ можете поставить более высокую оценку? Отправьте одну цифру в ответ:
1. Неудобно активировать сервисы внутри подписки
2. Не хватает интересных мне сервисов 
3. Дороже, чем другие подписки
4. Не устраивает соотношение цена/качество
5. Непонятно, как пользоваться сервисами внутри подписки
6. Свой вариант ответа
*/
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
      when a.ans_2 = 1 then 'Неудобно активировать сервисы внутри подписки'
      when a.ans_2 = 2 then 'Не хватает интересных мне сервисов'
      when a.ans_2 = 3 then 'Дороже, чем другие подписки'
      when a.ans_2 = 4 then 'Не устраивает соотношение цена/качество'
      when a.ans_2 = 5 then 'Непонятно, как пользоваться сервисами внутри подписки'
      when a.ans_2 = 6 then 'Свой вариант ответа'
      when a.ans_2 = -1 then 'Свой вариант ответа'
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
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from soa_2
) a
;

--select * from soa_step2;


--05 Step 3 Новые сервисы
/*
Будем благодарны, если поделитесь, какие сервисы Вы дополнительно хотели бы видеть в составе подписки?
*/


--06 Step 4 Комментарий/пожелания/предложения/адрес
/*
Спасибо за участие, хорошего Вам дня!
*/


--06 Step 5 Что необходимо изменить
/*
Будем благодарны, если в ответ на данное сообщение Вы поделитесь, что нам нужно изменить в подписке Mixx, чтобы она стала лучше?
*/


--06 Step 6 Что понравилось больше всего
/*
Спасибо за высокую оценку! Пожалуйста, укажите, что из нижеперечисленного Вам понравилось больше всего? Отправьте одну цифру в ответ:
1. Возможность настраивать состав подписки 
2. Есть все нужные мне сервисы
3. Дешевле, чем другие подписки
4. Возможность пользовать подпиской, не являясь абонентом Tele2
5. Соотношение цена/качество
6. Понятно, как пользоваться сервисами внутри подписки
7. Свой вариант ответа
*/

create multiset volatile table soa_step6, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 ans_6 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step6
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_6,
 case when a.ans_6 is null then null
      when a.ans_6 = 1 then 'Возможность настраивать состав подписки'
      when a.ans_6 = 2 then 'Есть все нужные мне сервисы'
      when a.ans_6 = 3 then 'Дешевле, чем другие подписки'
      when a.ans_6 = 4 then 'Возможность пользовать подпиской, не являясь абонентом Tele2'
      when a.ans_6 = 5 then 'Соотношение цена/качество'
      when a.ans_6 = 6 then 'Понятно, как пользоваться сервисами внутри подписки'
      when a.ans_6 = 7 then 'Свой вариант ответа'
      when a.ans_6 = -1 then 'Свой вариант ответа'
      else '-1' end as ans_6
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_6,
 length (oreplace(oreplace(oreplace(upper(mark_6),' ',''),',',''),'.','')) length_step_6,
 case when mark_6 is null then null
      when length_step_6 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_6),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6', '7')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_6),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_6
from soa_2
) a
;

--select * from soa_step2;


--06 Step 7 Выбор причины
/*
Спасибо за участие! Будем благодарны, если в ответ на данное сообщение Вы поделитесь, почему вы выбрали данную причину.
Хорошего вам дня!
*/



--07 Итоговая сборка
COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step6;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_2;

COLLECT STATISTICS
 COLUMN (MSISDN)
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
 mark_7 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_6 varchar(1024) character set unicode not casespecific,
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
 a.mark_2,              --
 a.mark_3,              --
 a.mark_4,              --
 a.mark_5,              --
 a.mark_6,              --
 a.mark_7,              --
 t2.ans_2,
 t6.ans_6,
 t1.nps,
 a.load_id
from soa_2 a
--
left join soa_nps2  t1 on a.msisdn = t1.msisdn and a.create_date = t1.create_date                   --NPS
left join soa_step2 t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date                   --Почему вы не можете поставить более высокую оценку
left join soa_step6 t6 on a.msisdn = t6.msisdn and a.create_date = t6.create_date                   --Выбор причины
;

--select * from soa_fin;


--07 Исключение долетов

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
insert into uat_ca.poll_id_184
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
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.ans_6,   t1.ans_6) as ans_6,
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

-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Строк по долетам: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));

--абоненты без долетов
insert into uat_ca.poll_id_184
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
 a.ans_2,
 a.ans_6,
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
drop table soa_step2;
drop table soa_step6;
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
COMMENT ON PROCEDURE uat_ca.mc_nps_bu_184 AS
'Процедура формирования витрины с опросами NPS SOA 2.0, тк Mixx. Результирующая таблица: uat_ca.poll_id_184';


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Вызов процедуры (условие строгое/не строгое)

--2022
/*week 46*/ call uat_ca.mc_nps_bu_184 (timestamp '2022-11-14 00:00:00', timestamp '2022-11-21 00:00:00');

/*week 49*/ call uat_ca.mc_nps_bu_184 (timestamp '2022-12-05 00:00:00', timestamp '2022-12-12 00:00:00');

--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Комментарии доступны в витринах метаданных EDW:
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablekind = 'Procedure' order by "Дата последнего изменения" desc;
select * from prd2_tmd_v.columns_info;


-- Для просмотра рассчитанных дней в момент работы процедуры, либо по ее завершению используйте запрос по таблице логов:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_184'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


-- Просмотр логов
select * from uat_ca.mc_logs order by 1;


--Статистика
COLLECT SUMMARY STATISTICS ON uat_ca.poll_id_184;

COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (SUBS_ID),
 COLUMN (MSISDN)
ON uat_ca.poll_id_184;


-- Просмотр витрин
select top 100 * from uat_ca.poll_id_184;
select top 100 * from uat_ca.poll_id_184 where create_date >= date '2022-12-05';

--delete uat_ca.poll_id_184 where trunc (create_date,'iw') = date '2022-11-14';


select create_date, count(distinct msisdn), count(*) from uat_ca.poll_id_184 group by 1 order by 1 desc;
select trunc (create_date,'iw') as week_first_day, weeknumber_of_year (create_date, 'ISO') as week_num, count(distinct msisdn), count(*) from uat_ca.poll_id_184 group by 1,2 order by 1 desc;


--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_184
where 1=1
 and create_date >= date '2022-12-05'
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
from uat_ca.v_poll_184
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
from uat_ca.v_poll_184
group by 1
order by 1 desc;



--View
replace view uat_ca.v_poll_184 as
lock row for access
select
 create_date,
 msisdn,
 subs_id,
-- treatment_code,
 case when nps = -1 then mark_1 end as mark_1,
 case when ans_2 = 'Свой вариант ответа' then mark_2 end as mark_2,
 mark_3,
 mark_4,
 mark_5,
 case when ans_6 = 'Свой вариант ответа' then mark_6 end as mark_6,
 mark_7,
 ans_2,
 ans_6,
 nps,
-- load_id,
--
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
from uat_ca.poll_id_184
;


/*
--show view uat_ca.v_poll_11;
comment on view uat_ca.v_poll_11 as 'NPS Дистанционный сервис';

comment on column uat_ca.v_poll_11.create_date as 'Дата прохождения опроса';
comment on column uat_ca.v_poll_11.mark_1 as 'Ответ как есть на вопрос: Был ли решен вопрос, по которому вы обращались?';
comment on column uat_ca.v_poll_11.mark_2 as 'Ответ как есть на вопрос: Что первым делом нам требуется улучшить в службе поддержки?';
comment on column uat_ca.v_poll_11.mark_3 as 'Ответ как есть на вопрос: NPS';
comment on column uat_ca.v_poll_11.mark_4 as 'Ответ как есть на вопрос: Комментарий/пожелания/предложения/адрес';

comment on column uat_ca.v_poll_11.ans_1 as 'Нормализованный ответ на вопрос: Был ли решен вопрос, по которому вы обращались?';
comment on column uat_ca.v_poll_11.ans_2 as 'Нормализованный ответ на вопрос: Что первым делом нам требуется улучшить в службе поддержки?';
comment on column uat_ca.v_poll_11.nps as 'Нормализованный ответ на вопрос: NPS';
*/

select top 100 * from uat_ca.v_poll_184;
select * from uat_ca.v_poll_184 sample 25;
select * from uat_ca.v_poll_184 where create_date >= date '2022-12-05';


select
 report_month,
 point_name,
 100*nps (format 'zz.z%') (varchar(10)) as nps_bu,
 subs_cnt,
 100*(1.96*stddev/sqrt(subs_cnt)) (format 'zz.zz%') (varchar(10)) as "погрешность",
 100*(nps - (1.96*stddev/sqrt(subs_cnt))) (format 'zz.z%') (varchar(10)) as lower_threshold,
 100*(nps + (1.96*stddev/sqrt(subs_cnt))) (format 'zz.z%') (varchar(10)) as upper_threshold
from (
select
 trunc (create_date,'mm') as report_month,
 'Mixx' as point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v_poll_184
where 1=1
 and create_date >= date '2022-12-05'
 and create_date < date '2022-12-12'
 and nps_key in (-1,0,1)
group by 1,2
) a
;


--Абоненты ответившие на опрос по точке контакта
select
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_11
where 1=1
 and nps is not null
group by 1
order by 1 desc;


--Абоненты ответившие на вопрос NPS от 1 до 10
select
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_184
where 1=1
 and nps_key in (-1,0,1)
group by 1
order by 1 desc;


--=================================================================================================
--=================================================================================================
--=================================================================================================

--show table uat_ca.poll_id_184;

create multiset table uat_ca.poll_id_184 (
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
 ans_6 varchar(1024) character set unicode not casespecific,
 nps byteint,
 load_id integer)
primary index (subs_id)
;

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
 and lower(a.tablename) = 'poll_id_184'
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
from uat_ca.poll_id_184
group by 1
) as t1,
(select cast(count(*) as float)/(hashamp()+1) as row_avr_amp from uat_ca.poll_id_184) as t2
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
from uat_ca.poll_id_184
group by 1
order by 1
having row_cnt > 10
;


--==4 Объем/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('poll_id_184')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          KNIME_POLL_112          MIKHAIL.CHUPIS      2022-01-12 17:44:05     2022-01-12 19:42:04     0,004           38,62



