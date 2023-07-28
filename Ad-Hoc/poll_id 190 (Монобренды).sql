
diagnostic helpstats on for session;


--2023
/*week 07*/ call uat_ca.mc_nps_bu_190 (timestamp '2023-02-13 00:00:00', timestamp '2023-02-16 00:00:00');   -- 4 мин. 34 сек.
            call uat_ca.mc_nps_bu_190 (timestamp '2023-02-16 00:00:00', timestamp '2023-02-17 00:00:00');

--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Для просмотра рассчитанных дней в момент работы процедуры, либо по ее завершению используйте запрос по таблице логов:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_190'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


select top 100 * from uat_ca.poll_id_190;
select top 100 * from uat_ca.v_poll_190;

--delete uat_ca.poll_id_190;


--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_190
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
from uat_ca.v_poll_190
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
from uat_ca.v_poll_190
group by 1
order by 1 desc;


--=================================================================================================

/*
2023-02-10
*/

--190   NPS_Монобренды_2023
select * from prd2_odw_v.smspoll_polls
where 1=1
 and poll_id in (190);

--уникальные q_text
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 190
order by 3, 1;


--==417
--1
Спасибо, что вы с Tele2! Мы хотим, чтобы вам было хорошо в наших офисах. Оцените нас, ответив на несколько вопросов. Был ли решен вопрос, по которому вы обращались в офис? 
1 - Да, с первого визита
2 - Да, но после нескольких визитов
3 - Вопрос не решили
Отправьте цифру в ответ
SMS на этот номер бесплатны

--2
Что первым делом нам требуется улучшить в офисах?
1- Профессиональные знания сотрудников 
2- Готовность сотрудников помочь
3- Расположение офиса и график работы
4- Время ожидания в очереди
5- Ассортимент (телефоны, смартфоны, аксессуары и т.д.)
6- Прочие услуги (кредиты, страхование и т.д.)
7- Все устраивает

--3
И последний вопрос. Оцените готовность рекомендовать компанию Tele2 родным и близким от 1 до 10, где 1 - точно не порекомендую, 10 - точно порекомендую.

--4
Спасибо за участие! Будем благодарны, если в ответ на данное сообщение вы поделитесь, почему поставили именно такую оценку. Хорошего вам дня!


--==190
--1 NPS
Спасибо, что Вы пользуетесь Tele2! 
Учитывая Ваш опыт посещения офиса обслуживания, оцените, готовность рекомендовать Tele2 от 1 до 10, 
где 1 - точно не порекомендую, 10 - точно порекомендую. 
Отправьте цифру в ответ. SMS на этот номер бесплатны.

--2 Для оценок 1-8
Пожалуйста, выберите причину, по которой Вы НЕ можете поставить более высокую оценку? Отправьте одну цифру в ответ
1.Мало офисов/далеко находится
2.Очередь в офисе/долгое ожидание
3.Сотрудник не смог решить вопрос, с которым Вы обратились
4.Невежливые сотрудники
5.Подключили/порекомендовали невыгодный для Вас тариф или услугу
6.Ассортимент (телефоны, смартфоны, аксессуары и т.д.)
7.Другое (причина, не связанная с действиями сотрудника офиса)

--3 Решение вопроса
Был ли решен вопрос, по которому Вы обращались в офис обслуживания Tele2? Отправьте одну цифру в ответ 
1.Да, с первого обращения
2.Да, но после нескольких обращений
3.Нет

--4 Для оценок 9-10
Спасибо за высокую оценку! Пожалуйста, укажите, что из нижеперечисленного Вам понравилось больше всего? Отправьте одну цифру в ответ
1.Много офисов/близкое расположение
2.Быстрое обслуживание/нет очередей в офисе
3.Сотрудник помог решить вопрос, с которым Вы обратились
4.Вежливые сотрудники 
5.Подключили/порекомендовали выгодный для Вас тариф или услугу
6.Ассортимент (телефоны, смартфоны, аксессуары и т.д.)
7.Другое (причина, не связанная с действиями сотрудника офиса)

--5
Спасибо за участие! Будем благодарны, если в ответ на данное сообщение вы поделитесь, почему вы выбрали данную причину.
Хорошего Вам дня!


--уникальные q_text
select q_step, length(q_text) from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 190
order by 1;

--417
1       306
2       309
3       152
4       141

--190
1       250
2       452
3       174
4       480
5       138


--==Список абонентов на опрос

select top 100 * from prd2_odw_v.smspoll_communication_lists;
select top 100 * from prd2_odw_v.smspoll_poll_lists;

--
select
 weeknumber_of_year (a.created_date, 'ISO') as "неделя",
 trunc (a.created_date,'iw') as first_day_week,
 count(distinct msisdn)
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2023-02-01 00:00:00'
 and b.created_date < timestamp '2023-03-01 00:00:00'
 and b.poll_id = 190
where 1=1
 and a.created_date >= timestamp '2023-02-01 00:00:00'
 and a.created_date < timestamp '2023-03-01 00:00:00'
group by 1,2
order by 2
;

--week 06   --3
--week 07   --36 731



--=================================================================================================
--=================================================================================================
--=================================================================================================

REPLACE PROCEDURE uat_ca.mc_nps_bu_190 (in stime timestamp, in etime timestamp)
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

SET proc = 'nps_190';           -- наименование расчета

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
 and poll_id = 190
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2023-02-13 00:00:00'
-- and created_dttm < timestamp '2023-02-20 00:00:00'
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
 load_id
from (
select * from soa pivot (max(mark) for q_step in (
 '1' as step_1,
 '2' as step_2,
 '3' as step_3,
 '4' as step_4,
 '5' as step_5
)) t2
) a
group by 1,2,3,4,10
;

--select * from soa_2;


--03 Step 1 NPS
/*
Спасибо, что Вы пользуетесь Tele2! 
Учитывая Ваш опыт посещения офиса обслуживания, оцените, готовность рекомендовать Tele2 от 1 до 10, 
где 1 - точно не порекомендую, 10 - точно порекомендую. 
Отправьте цифру в ответ. SMS на этот номер бесплатны.
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


--04 Step 2 Для оценок 1-8
/*
Пожалуйста, выберите причину, по которой Вы НЕ можете поставить более высокую оценку? Отправьте одну цифру в ответ
1.Мало офисов/далеко находится
2.Очередь в офисе/долгое ожидание
3.Сотрудник не смог решить вопрос, с которым Вы обратились
4.Невежливые сотрудники
5.Подключили/порекомендовали невыгодный для Вас тариф или услугу
6.Ассортимент (телефоны, смартфоны, аксессуары и т.д.)
7.Другое (причина, не связанная с действиями сотрудника офиса)
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
      when a.ans_2 = 1 then 'Мало офисов/далеко находится'
      when a.ans_2 = 2 then 'Очередь в офисе/долгое ожидание'
      when a.ans_2 = 3 then 'Сотрудник не смог решить вопрос, с которым Вы обратились'
      when a.ans_2 = 4 then 'Невежливые сотрудники'
      when a.ans_2 = 5 then 'Подключили/порекомендовали невыгодный для Вас тариф или услугу'
      when a.ans_2 = 6 then 'Ассортимент (телефоны, смартфоны, аксессуары и т.д.)'
      when a.ans_2 = 7 then 'Причина, не связанная с действиями сотрудника офиса'
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
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6', '7')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from soa_2
) a
;

--select * from soa_step2;


--05 Step 3 Решение вопроса
/*
Был ли решен вопрос, по которому Вы обращались в офис обслуживания Tele2? Отправьте одну цифру в ответ 
1.Да, с первого обращения
2.Да, но после нескольких обращений
3.Нет
*/
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
      when a.ans_3 = 1 then 'Да, с первого визита'
      when a.ans_3 = 2 then 'Да, но после нескольких визитов'
      when a.ans_3 = 3 then 'Вопрос не решили'
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


--06 Step 44 Для оценок 9-10
/*
Спасибо за высокую оценку! Пожалуйста, укажите, что из нижеперечисленного Вам понравилось больше всего? Отправьте одну цифру в ответ
1.Много офисов/близкое расположение
2.Быстрое обслуживание/нет очередей в офисе
3.Сотрудник помог решить вопрос, с которым Вы обратились
4.Вежливые сотрудники 
5.Подключили/порекомендовали выгодный для Вас тариф или услугу
6.Ассортимент (телефоны, смартфоны, аксессуары и т.д.)
7.Другое (причина, не связанная с действиями сотрудника офиса)
*/
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
      when a.ans_4 = 1 then 'Мало офисов/далеко находится'
      when a.ans_4 = 2 then 'Очередь в офисе/долгое ожидание'
      when a.ans_4 = 3 then 'Сотрудник не смог решить вопрос, с которым Вы обратились'
      when a.ans_4 = 4 then 'Невежливые сотрудники'
      when a.ans_4 = 5 then 'Подключили/порекомендовали невыгодный для Вас тариф или услугу'
      when a.ans_4 = 6 then 'Ассортимент (телефоны, смартфоны, аксессуары и т.д.)'
      when a.ans_4 = 7 then 'Причина, не связанная с действиями сотрудника офиса'
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
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6', '7')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_4
from soa_2
) a
;

--select * from soa_step4;


/*
step 5
Спасибо за участие! Будем благодарны, если в ответ на данное сообщение вы поделитесь, почему вы выбрали данную причину.
Хорошего Вам дня!
*/


--06 Итоговая сборка
COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_2;

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
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific,
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
 a.mark_1,              --NPS
 a.mark_2,              --Для оценок 1-8
 a.mark_3,              --Решение вопроса
 a.mark_4,              --Для оценок 9-10
 a.mark_5,              --Комментарий/пожелания/предложения/адрес
 t2.ans_2,
 t3.ans_3,
 t4.ans_4,
 t5.nps,
 a.load_id
from soa_2 a
--
left join soa_step2   t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date                   --Для оценок 1-8
left join soa_step3   t3 on a.msisdn = t3.msisdn and a.create_date = t3.create_date                   --Решение вопроса
left join soa_step4   t4 on a.msisdn = t4.msisdn and a.create_date = t4.create_date                   --Для оценок 9-10
left join soa_nps2    t5 on a.msisdn = t5.msisdn and a.create_date = t5.create_date                   --NPS
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
insert into uat_ca.poll_id_190
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
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.ans_3,   t1.ans_3) as ans_3,
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

-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Строк по долетам: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--абоненты без долетов
insert into uat_ca.poll_id_190
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
 a.ans_2,
 a.ans_3,
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
COMMENT ON PROCEDURE uat_ca.mc_nps_bu_190 AS
'Процедура формирования витрины с опросами NPS SOA 2.0, тк Монобренды. Результирующая таблица: uat_ca.poll_id_190';


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Вызов процедуры (условие строгое/не строгое)

--2023
/*week 07*/ call uat_ca.mc_nps_bu_190 (timestamp '2023-02-13 00:00:00', timestamp '2022-04-11 00:00:00');   -- 4 мин. 34 сек.


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Комментарии доступны в витринах метаданных EDW:
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablekind = 'Procedure' order by "Дата последнего изменения" desc;
select * from prd2_tmd_v.columns_info;


-- Для просмотра рассчитанных дней в момент работы процедуры, либо по ее завершению используйте запрос по таблице логов:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_190'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


-- Просмотр логов
select * from uat_ca.mc_logs order by 1;


--Статистика
COLLECT SUMMARY STATISTICS ON uat_ca.poll_id_417;

COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (SUBS_ID),
 COLUMN (MSISDN)
ON uat_ca.poll_id_417;


-- Просмотр витрин
select top 100 * from uat_ca.poll_id_190;
select top 100 * from uat_ca.poll_id_190 where create_date >= date '2023-02-13';

--delete uat_ca.poll_id_190 where trunc (create_date,'iw') = date '2023-02-13';


select create_date, count(distinct msisdn), count(*) from uat_ca.poll_id_190 group by 1 order by 1 desc;
select trunc (create_date,'iw') as week_first_day, weeknumber_of_year (create_date, 'ISO') as week_num, count(distinct msisdn), count(*) from uat_ca.poll_id_190 group by 1,2 order by 1 desc;

/*
select * from uat_ca.poll_id_910
qualify count(*) over (partition by msisdn) > 1;

select * from uat_ca.poll_id_190 where subs_id = 300059703606;
delete uat_ca.poll_id_190 where subs_id = 300059703606 and ans_1 is null;
delete uat_ca.poll_id_190 where subs_id = 300059703606 and ans_2 is null;
delete uat_ca.poll_id_190 where subs_id = 300059703606 and nps is null;

UPDATE uat_ca.poll_id_190
SET ans_2 = 'Все устраивает'
WHERE 1=1
 AND subs_id = 300059703606
 AND create_date = date '2022-01-17';
*/

--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_190
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
from uat_ca.v_poll_190
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
from uat_ca.v_poll_190
group by 1
order by 1 desc;


--View
replace view uat_ca.v_poll_190 as
lock row for access
select
 a.create_date,
 t2.cluster_name as cluster_name,
 t4.macroregion_name as macroregion,
 t3.region_name as region,
 'Монобренды' as point_name,
 a.msisdn,
 a.subs_id,
-- treatment_code,
 case when a.nps = -1 then a.mark_1 end as mark_1,                  --NPS
 case when a.ans_2 = 'Другое' then a.mark_2 end as mark_2,          --Для оценок 1-8
 case when a.ans_3 = 'Другое' then a.mark_3 end as mark_3,          --Решение вопроса
 case when a.ans_4 = 'Другое' then a.mark_4 end as mark_4,          --Для оценок 9-10
 a.mark_5,                                                          --Комментарий/пожелания/предложения/адрес
 a.ans_2,
 a.ans_3,
 a.ans_4,
 a.nps,
-- load_id,
--
 case when a.nps between 0 and 6 then 1 else 0 end as detractor,
 case when a.nps between 7 and 8 then 1 else 0 end as passive,
 case when a.nps between 9 and 10 then 1 else 0 end as promoter,
 case when detractor = 1 then 'Detractor'
      when passive = 1 then 'Passive'
      when promoter = 1 then 'Promoter'
      end nps_category,
 case when detractor = 1 then -1
      when passive = 1 then 0
      when promoter = 1 then 1
      end as nps_key
from uat_ca.poll_id_190 a
--
left join prd2_dds_v.phone_number_2 t1 on a.msisdn = t1.msisdn
 and (a.create_date >= t1.stime and a.create_date < t1.etime)
left join prd2_dic_v.branch t2 on t1.branch_id = t2.branch_id
left join prd2_dic_v.region t3 on t2.region_id = t3.region_id
left join prd2_dic_v.macroregion t4 on t3.macroregion_id = t4.macroregion_id
;


--show view uat_ca.v_poll_190;
comment on view uat_ca.v_poll_190                   as 'NPS Монобренды';

comment on column uat_ca.v_poll_190.create_date     as 'Дата прохождения опроса';
comment on column uat_ca.v_poll_190.mark_1          as 'Ответ как есть на вопрос: NPS';
comment on column uat_ca.v_poll_190.mark_2          as 'Ответ как есть на вопрос: Для оценок 1-8';
comment on column uat_ca.v_poll_190.mark_3          as 'Ответ как есть на вопрос: Был ли решен вопрос, по которому вы обращались в офис?';
comment on column uat_ca.v_poll_190.mark_4          as 'Ответ как есть на вопрос: Для оценок 9-10';

comment on column uat_ca.v_poll_190.ans_2           as 'Нормализованный ответ на вопрос: Для оценок 1-8';
comment on column uat_ca.v_poll_190.ans_3           as 'Нормализованный ответ на вопрос: Был ли решен вопрос, по которому вы обращались в офис?';
comment on column uat_ca.v_poll_190.ans_4           as 'Нормализованный ответ на вопрос: Для оценок 9-10';
comment on column uat_ca.v_poll_190.nps             as 'Нормализованный ответ на вопрос: NPS';


select top 100 * from uat_ca.v_poll_190;
select * from uat_ca.v_poll_190 sample 25;

--==NPS
select
 report_month,
 point_name,
 nps,
 subs_cnt,
 1.96*stddev/sqrt(subs_cnt) as st_error,
 nps - st_error as lower_threshold,
 nps + st_error as upper_threshold
from (
select
 trunc (create_date,'mm') as report_month,
 'Монобренды' as point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v_poll_190
where 1=1
 and create_date >= date '2023-02-13'
 and create_date < date '2023-03-01'
 and nps_key in (-1,0,1)
group by 1,2
) a
;


select 
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_190
where 1=1
 and nps_key in (-1,0,1)
group by 1
order by 1 desc;



--=================================================================================================
--=================================================================================================
--=================================================================================================

--show table uat_ca.poll_id_190;

create multiset table uat_ca.poll_id_190 (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific,
 ans_4 varchar(1024) character set unicode not casespecific,
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
 and lower(a.tablename) = 'poll_id_190'
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
from uat_ca.poll_id_190
group by 1
) as t1,
(select cast(count(*) as float)/(hashamp()+1) as row_avr_amp from uat_ca.poll_id_190) as t2
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
from uat_ca.poll_id_190
group by 1
order by 1
having row_cnt > 10
;


--==4 Объем/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('poll_id_190')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------




