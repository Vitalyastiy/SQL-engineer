
select max_report_date from prd2_tmd_v.bds_load_status where table_name='subs_clr_d';



/*week 5*/  call uat_ca.mc_nps_187 (timestamp '2023-02-03 00:00:00', timestamp '2023-02-06 00:00:00', date '2023-02-03', date '2023-02-06');
/*week 6*/  call uat_ca.mc_nps_187 (timestamp '2023-02-06 00:00:00', timestamp '2023-02-13 00:00:00', date '2023-02-06', date '2023-02-13');
/*week 7*/  call uat_ca.mc_nps_187 (timestamp '2023-02-13 00:00:00', timestamp '2023-02-20 00:00:00', date '2023-02-13', date '2023-02-20');
/*week 8*/  call uat_ca.mc_nps_187 (timestamp '2023-02-20 00:00:00', timestamp '2023-02-27 00:00:00', date '2023-02-20', date '2023-02-27');



--==Логи
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_187'
;

--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_nps2_6_nsp2
group by 1,2
order by 2 desc;

--2 месячная динамика
select
 trunc (create_date,'mm') as "Месяц",
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_nps2_6_nsp2
group by 1
order by 1 desc;

--3 дневная динамика
select
 create_date,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_nps2_6_nsp2
group by 1
order by 1 desc;


--Дубли
select * from uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date >= date '2023-02-01'
 and create_date < date '2023-03-01'
qualify count(*) over (partition by subs_id) >1;


update uat_ca.mc_nps2_6_nsp2
set problem_point = 54,
    cluster_name = 'Обслуживание в салоне связи Tele2'
where 1=1
 and subs_id = 59892812
 and create_date = date '2023-02-09'
;

delete uat_ca.mc_nps2_6_nsp2
where 1=1
 and subs_id = 59892812
 and create_date = date '2023-02-09'
;


/*
update uat_ca.mc_nps2_6_nsp2
set branch_id = 54,
    cluster_name = 'Defender',
    macroregion = 'Черноземье',
    region = 'Воронеж'
where 1=1
 and subs_id = 52208063
 and create_date = date '2023-01-28'
;


update uat_ca.mc_nps2_6_nsp2
set branch_id = 53,
    cluster_name = 'Challenger',
    macroregion = 'Волга',
    region = 'Чувашия'
where 1=1
 and subs_id = 200103777244
 and create_date = date '2023-01-28'
;
*/

--==================================================================================================

insert into tele2_uat.mc_nps_b2b2
select
 create_month,
 create_date,
 activation_dttm,
 week_num,
 month_num,
 year_num,
 branch_id,
 cluster_name,
 macroregion,
 region,
 subs_id,
 msisdn,
 bsegment,
 subs_segm_name,
 lt_day,
 lt_gr,
 nps,
 detractor,
 passive,
 promoter,
 nps_category,
 case when problem_point = 'Качество голосовой связи' then 'Голос и СМС'
      when problem_point = 'Телефонную линию поддержки клиентов' then 'Колл-центр'
      when problem_point = 'Качество мобильного интернета' then 'Мобильный интернет'
      when problem_point = 'Обслуживание в салоне связи Tele2' then 'Монобренд'
      else problem_point end as problem_point,
 price_1,
 price_2,
 mb_1,
 mb_2,
 cc_1,
 cc_2,
 voice_1,
 voice_2,
 internet_1,
 internet_2,
 lk_1,
 lk_2,
 address,
 nps_mark,
 problem_point_mark,
 price_1_mark,
 price_2_mark,
 mb_1_mark,
 mb_2_mark,
 cc_1_mark,
 cc_2_mark,
 voice_1_mark,
 voice_2_mark,
 internet_1_mark,
 internet_2_mark,
 lk_1_mark,
 lk_2_mark,
 nps_key,
 first_day_week
from uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date >= date '2023-02-20'
 and create_date < date '2023-02-27'
;


--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from tele2_uat.v2_nps_b2b
group by 1,2
order by 2 desc;

--2 месячная динамика
select
 trunc (create_date,'mm') as "Месяц",
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,s
 dis_msisdn - row_cnt as diff_msisdn
from tele2_uat.v2_nps_b2b
group by 1
order by 1 desc;

--3 дневная динамика
select 
 create_date,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from tele2_uat.v2_nps_b2b
group by 1
order by 1 desc;





--==Update
select * from tele2_uat.v2_nps_b2b
where 1=1
 and branch_id is null
;

show view tele2_uat.v2_nps_b2b;             --tele2_uat.mc_nps_b2b2;

select * from prd2_dds_v.phone_number_2 where subs_id = 52208063;
select * from prd2_dds_v.phone_number_2 where subs_id = 200103777244;

subs_id         52208063
branch_id       54
"cluster"       Defender
macroregion     Черноземье
region          Воронеж

subs_id         200103777244
branch_id       53
"cluster"       Challenger
macroregion     Волга
region          Чувашия



select * from prd2_dic_v.branch where branch_id in (53, 54);
select * from prd2_dic_v.region where region_id in (15, 74);
select * from prd2_dic_v.macroregion where macroregion_id in (, );


update tele2_uat.mc_nps_b2b2
set branch_id = 54,
    cluster_name = 'Defender',
    macroregion = 'Черноземье',
    region = 'Воронеж'
where 1=1
 and subs_id = 52208063
 and create_date = date '2023-01-28'
;


update tele2_uat.mc_nps_b2b2
set branch_id = 53,
    cluster_name = 'Challenger',
    macroregion = 'Волга',
    region = 'Чувашия'
where 1=1
 and subs_id = 200103777244
 and create_date = date '2023-01-28'
;



--==================================================================================================


REPLACE PROCEDURE uat_ca.mc_nps_187 (in stime timestamp, in etime timestamp, in sdate date, in edate date)
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


SET proc = 'nps_187';           -- наименование расчета

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;


-- логирование начала расчета данных
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START');

--BT;


--drop table soa;

create multiset volatile table soa, no log (
 created_date timestamp(0),
 replay_date timestamp(0),
 current_communication_id bigint,
 sub_list_id varchar(64) character set unicode not casespecific,
 short_number smallint,
 poll_id smallint,
 treatment_code varchar(9) character set unicode not casespecific,
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 q_step byteint,
 content_id smallint,
 q_text_id smallint,
 q_text varchar(800) character set unicode not casespecific,
 nps byteint,
 mark varchar(255) character set unicode not casespecific,
 mark_text varchar(25) character set unicode not casespecific,
 addition varchar(255) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa
select
 created_dttm as created_date,
 replay_dttm as replay_date,
-- cast(created_dttm as date) as created_date,
-- cast(replay_dttm as date) as replay_date,
 current_communication_id,
 sub_list_id,
 short_number,
 poll_id,
 treatment_code,
 msisdn,
 subs_id,
 q_step,
 content_id,
 q_text_id,
 q_text,
 nps,
 mark,
 mark_text,
 addition,
 load_id
from (
--select a.* from uat_ca.knime_v11 a
select a.* from prd2_DDS_V.SMSPOLL_DETAIL a
inner join (
--select distinct msisdn from uat_ca.knime_v11
select distinct msisdn from prd2_DDS_V.SMSPOLL_DETAIL
where 1=1
 and poll_id = 187
 and nps = 1
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2021-03-15 00:00:00'
-- and created_dttm < timestamp '2021-03-22 00:00:00'
) b on a.msisdn = b.msisdn
where 1=1
 and a.poll_id = 187
 and a.created_dttm >= :stime
 and a.created_dttm < :etime
-- and a.created_dttm >= timestamp '2021-03-15 00:00:00'
-- and a.created_dttm < timestamp '2021-03-22 00:00:00'
-- and a.msisdn = '79515538864'
) a
;

--select top 100 * from prd2_DDS_V.SMSPOLL_DETAIL;

--delete soa;
--delete soa where msisdn in ('79510990442', '79507234624', '79217030315', '79087211323');


-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'INTERVAL_DATE '|| to_char(sdate,'DD.MM.YYYY') || '_' ||to_char(edate,'DD.MM.YYYY') || ' Всего строк: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--select top 100 * from soa;
--select top 100 * from prd2_DDS_V.SMSPOLL_DETAIL;
--select top 100 * from uat_ca.knime_v11;             --опросы по точке контакта B2B начинаются с 11.01.2021
--select top 100 * from uat_ca.knime_v2;              --опросы по точке контакта B2B начинаются с 19.05.2020
--delete soa;

--select cast(created_date as date), count(distinct msisdn) as msisdn_cnt, count(*) as row_cnt from soa group by 1 order by 1 desc;
--
--select * from soa where msisdn = '79018028278';
--select * from prd2_DDS_V.SMSPOLL_DETAIL where msisdn = '79018028278';

/*
select * from soa where msisdn = '79503401200';


select
 cast(created_dttm as date) as created_date,
 sum(case when nps = 1 then 1 end) as nps_cnt,
 count(*)
from prd2_DDS_V.SMSPOLL_DETAIL
where 1=1
 and poll_id = 66
 and created_dttm >= timestamp '2021-01-11 00:00:00'
 and created_dttm < timestamp '2021-01-25 00:00:00'
group by 1
order by 1;

select * from prd2_DDS_V.SMSPOLL_DETAIL
where 1=1
 and poll_id = 66
 and created_dttm >= timestamp '2021-01-11 00:00:00'
 and created_dttm < timestamp '2021-01-25 00:00:00'
 and msisdn = '79048381204'
;


select * from uat_ca.knime_v11
where 1=1
 and poll_id = 66
 and msisdn = '79048381204'
;

select
 cast(created_date as date) as created_date,
 sum(case when nps = 1 then 1 end) as nps_cnt,
 count(*)
from uat_ca.knime_v11
where 1=1
 and poll_id = 66
group by 1
order by 1;


select top 100 * from PRD2_TMD.CM_LOGS where loadid = 1305800047;
select top 100 * from PRD2_TMD.CM_LOGS where processname = 'LOAD_SMSPOLL_DETAIL';
*/


/*


--B2B_TD_2023
select * from prd2_odw_v.smspoll_polls
where 1=1
 and poll_id = 187;

--==Step
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 187;

--1
Спасибо, что вы с Tele2!
Мы хотим, чтобы вам было хорошо с нами. Пожалуйста, ответьте на несколько вопросов.
Оцените готовность рекомендовать Tele2 по шкале от 1 до 10, где 1- «точно не порекомендую», 10- «точно порекомендую".
Все SMS на этот номер бесплатны.


--2
Как вы считаете, что требуется улучшить в первую очередь?
1- Тарифы
2- Обслуживание в салоне связи Tele2
3- Телефонная линия поддержки (636)
4- Качество голосовой связи
5- Качество мобильного интернета
6- Личный кабинет
7- Все устраивает


--3
Насколько вы довольны соотношением цены и объема оказываемых услуг по шкале от 1 до 10, где 1- не довольны, 10- очень довольны? Отправьте цифру в ответ

--4
Оцените, насколько вам понятны списания за услуги по шкале от 1 до 10, где 1- «не понятны», 10- «полностью понятны»? Отправьте цифру в ответ

--5
Был ли решен вопрос, по которому вы обращались в салон связи? 
1- Да, с первого визита
2- Да, но после нескольких посещений. обращений в салон
3-Вопрос не решили. 
Отправьте цифру в ответ

--6 - Корректировка
Что первым делом требуется улучшить в салонах связи? 
1- Профессиональные знания сотрудников
2- Готовность сотрудников помочь
3- Скорость в решении вопросов
4- Удобство размещения офисов
5- Комфорт ожидания в очереди

--7
Был ли решен вопрос, по которому вы обращались в службу поддержки клиентов? 
1 - Да, с первого звонка
2 - Да, но не с первого звонка
3 - Нет
Отправьте цифру в ответ

--8 - Корректировка
Что первым делом требуется улучшить в телефонной службе поддержки (636)?
1- Профессиональные знания операторов
2- Готовность операторов помочь
3- Дружелюбие операторов
4- Скорость в решении вопросов
5- Время ожидания соединения с оператором

--9 - Корректировка
Где чаще всего вы испытываете проблемы с качеством голосовой связи или SMS? Укажите один вариант ответа:
1- Проблем не наблюдаю
2- Регулярно дома
3- Регулярно на работе
4- Регулярно по маршруту передвижения
5- Регулярно за городом
6- В местах проведения досуга                    
Отправьте цифру в ответ

--10 - Корректировка
С какими проблемами вы сталкиваетесь чаще всего?
1- Сеть недоступна
2- Плохая слышимость/помехи/эхо
3- Обрыв звонка
4- Недоставленные или долгое время доставки SMS

--11 - Корректировка
Где вы испытываете проблемы с качеством мобильного интернета?
1.- Проблем не наблюдаю
2.- Регулярно дома
3.- Регулярно на работе
4.- Регулярно по маршруту передвижения 
5.- Регулярно за городом
6.- Регулярно в местах проведения досуга
Отправьте цифру в ответ

--12 - Корректировка
Выберите ситуацию, с которой вы чаще всего сталкиваетесь при использовании интернета:
1.- Интернет недоступен
2.- Низкая скорость или обрывы соединения

--13
Был ли решен вопрос, по которому вы обращались в  личный кабинет? 
1- Да
2- Нет, вопрос решил в телефонной  службе поддержки (636)
3- Нет, вопрос решил в салоне связи Tele2
4- Нет, вопрос не решил.

--14
Что требуется улучшить в  личном кабинете?
1- Функциональность
2- Интерфейс
3- Сервисную поддержку
Отправьте цифру в ответ

--15
Спасибо за участие в опросе. 
Ваше мнение помогает повышать качество услуг и обслуживания. 
Если у вас наблюдаются проблемы со связью, в ответ на это SMS, пожалуйста, сообщите город, улицу и дом, где они возникают. Хорошего вам дня!

*/

--=================================================================================================

--02 транспонирование

--diagnostic helpstats on for session;

COLLECT STATISTICS
 COLUMN (CREATED_DATE ,TREATMENT_CODE ,MSISDN ,SUBS_ID),
 COLUMN (CREATED_DATE ,REPLAY_DATE ,CURRENT_COMMUNICATION_ID ,SUB_LIST_ID ,SHORT_NUMBER ,POLL_ID ,TREATMENT_CODE ,MSISDN ,SUBS_ID ,CONTENT_ID ,Q_TEXT_ID ,Q_TEXT ,NPS ,MARK_TEXT ,ADDITION ,LOAD_ID),
 COLUMN (LOAD_ID),
 COLUMN (ADDITION),
 COLUMN (MARK_TEXT),
 COLUMN (NPS),
 COLUMN (Q_TEXT),
 COLUMN (Q_TEXT_ID),
 COLUMN (CONTENT_ID),
 COLUMN (SUBS_ID),
 COLUMN (TREATMENT_CODE),
 COLUMN (POLL_ID),
 COLUMN (SHORT_NUMBER),
 COLUMN (SUB_LIST_ID)
ON soa;

--drop table spss_soa2_3;

create multiset volatile table spss_soa2_3, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 create_date date format 'yy/mm/dd',
 treatment_code varchar(9) character set unicode not casespecific,
 step_1 varchar(255) character set unicode not casespecific,
 step_2 varchar(255) character set unicode not casespecific,
 step_3 varchar(255) character set unicode not casespecific,
 step_4 varchar(255) character set unicode not casespecific,
 step_5 varchar(255) character set unicode not casespecific,
 step_6 varchar(255) character set unicode not casespecific,
 step_7 varchar(255) character set unicode not casespecific,
 step_8 varchar(255) character set unicode not casespecific,
 step_9 varchar(255) character set unicode not casespecific,
 step_10 varchar(255) character set unicode not casespecific,
 step_11 varchar(255) character set unicode not casespecific,
 step_12 varchar(255) character set unicode not casespecific,
 step_13 varchar(255) character set unicode not casespecific,
 step_14 varchar(255) character set unicode not casespecific,
 step_15 varchar(255) character set unicode not casespecific
)
primary index (msisdn)
on commit preserve rows;


insert into spss_soa2_3
select
 msisdn,
 subs_id,
 cast(created_date as date) as create_date,
-- replay_date,
 treatment_code,
-- q_text_id,
 max (step_1) as step_1,
 max (step_2) as step_2,
 max (step_3) as step_3,
 max (step_4) as step_4,
 max (step_5) as step_5,
 max (step_6) as step_6,
 max (step_7) as step_7,
 max (step_8) as step_8,
 max (step_9) as step_9,
 max (step_10) as step_10,
 max (step_11) as step_11,
 max (step_12) as step_12,
 max (step_13) as step_13,
 max (step_14) as step_14,
 max (step_15) as step_15
from (
select * from soa pivot (max(mark) for q_step in (
 '1' as step_1,
 '2' as step_2,
 '3' as step_3,
 '4' as step_4,
 '5' as step_5,
 '6' as step_6,
 '7' as step_7,
 '8' as step_8,
 '9' as step_9,
 '10' as step_10,
 '11' as step_11,
 '12' as step_12,
 '13' as step_13,
 '14' as step_14,
 '15' as step_15
)) t2
) a
group by 1,2,3,4
;


--delete spss_soa2_3;
--select create_date, count(distinct subs_id), count(distinct msisdn), count (*) from spss_soa2_3 group by 1 order by 1;

--select * from spss_soa2_3 sample 500;
--select step_1, count(*) from spss_soa2_3 group by 1 order by 1;
--select step_2, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_3, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_4, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_5, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_6, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_7, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_8, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_9, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_10, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_11, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_12, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_13, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_14, count(*) from spss_soa2_3 group by 1 order by 2 desc;
--select step_15, count(*) from spss_soa2_3 group by 1 order by 2 desc;


--03 Расчет NPS
/*
Спасибо, что вы с Tele2!
Мы хотим, чтобы вам было хорошо с нами. Пожалуйста, ответьте на несколько вопросов.
Оцените готовность рекомендовать Tele2 по шкале от 1 до 10, где 1- «точно не порекомендую», 10- «точно порекомендую".
Все SMS на этот номер бесплатны.
**/

create multiset volatile table spss_soa_nps, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_1 varchar(200) character set unicode casespecific,
 nps_1 varchar(255) character set unicode casespecific,
 nps_2 varchar(255) character set unicode casespecific,
 nps_3 varchar(255) character set unicode casespecific,
 nps_4 varchar(255) character set unicode casespecific,
 nps_5 varchar(255) character set unicode casespecific,
 nps_6 varchar(255) character set unicode casespecific,
 nps_7 varchar(255) character set unicode casespecific,
 nps_8 varchar(255) character set unicode casespecific,
 nps_9 varchar(255) character set unicode casespecific,
 nps_10 varchar(255) character set unicode not casespecific,
 nps_11 varchar(255) character set unicode not casespecific,
 nps_12 varchar(255) character set unicode not casespecific,
 nps_13 varchar(255) character set unicode not casespecific,
 nps_14 varchar(255) character set unicode not casespecific)
primary index ( msisdn )
on commit preserve rows;


create multiset volatile table spss_soa_nps2, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_1 varchar(200) character set unicode casespecific,
 nps number,
 nps_text varchar(200) character set unicode casespecific)
primary index (msisdn)
on commit preserve rows;


insert into spss_soa_nps
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_1,
 oreplace(a.step_1,'.00','') as nps_1,                                                                                                     -- исключаем .00
 trim (nps_1) as nps_2,                                                                                                                    -- исключаем пробелы в начале, конце
 trim (both ',' from nps_2) as nps_3,                                                                                                      -- исключаем ','
 trim (both '.' from nps_3) as nps_4,                                                                                                      -- исключаем '.'
 trim (both '*' from nps_4) as nps_5,                                                                                                      -- исключаем '*'
 regexp_replace (nps_5, '687', '', 1, 1) as nps_6,                                                                                         -- заменяем первое вхождение 687
 trim (nps_6) as nps_7,                                                                                                                    -- исключаем пробелы в начале, конце
 otranslate(nps_7,'1234567890','') as nps_8,                                                                                               -- оставляем только текст
 trim(otranslate(nps_7,otranslate(nps_7,'1234567890',''),'')) as nps_9,                                                                    -- оставляем только цифры
 case when length (nps_9) > 0 and length (nps_8) = 0 then cast (nps_7 as varchar (100)) else cast ('-' as varchar(10)) end as nps_10,      -- выбираем ответы только где есть цифры
 case when nps_10 is not null then cast(otranslate(nps_10,' ','') as varchar(100)) end as nps_11,                                          -- исключаем любые пробелы
 cast (case when nps_11 = '-' then oreplace (nps_7, regexp_replace(nps_7, '[[:alnum:]]'),'')
             else '-' end as varchar (50))as nps_12,                                                                                       -- 
 case when nps_12 in ('1','2','3','4','5','6','7','8','9','10') then nps_12 else '-' end as nps_13,                                        -- 
 case when nps_11 = '-' then nps_13 else nps_11 end as nps_14                                                                              -- итоговый ответ nps
from spss_soa2_3 a
;


--delete spss_soa_nps2;

insert into spss_soa_nps2
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_1,
 to_number (case when upper (a.step_1) like '%ДЕСЯТ%' then '10'
                 when upper (a.step_1) like '%ДЕВЯТ%' then '9'
                 when upper (a.step_1) like '%ВОСЕМ%' then '8'
                 when a.nps_14 in ('1','2','3','4','5','6','7','8','9','10') then a.nps_14 else '-1' end) as nps,                                       -- итоговая оценка
 case when nps = '-1' then a.step_1 end as nps_text
from spss_soa_nps a
;


--select top 100 * from spss_soa_nps;
--select top 100 * from spss_soa_nps2;
--select count(*) from spss_soa_nps2;
--select * from spss_soa_nps2;
--
--select * from spss_soa_nps where msisdn = '79018028278';
--select * from spss_soa_nps2 where msisdn = '79018028278';


--04 Расчет step 2 PROBLEM_POINT
/*
Как вы считаете, что требуется улучшить в первую очередь?
1- Тарифы
2- Обслуживание в салоне связи Tele2
3- Телефонная линия поддержки (636)
4- Качество голосовой связи
5- Качество мобильного интернета
6- Личный кабинет
7- Все устраивает
*/

--drop table spss_soa_step2;

create multiset volatile table spss_soa_step2 ,no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_2 varchar(200) character set unicode casespecific,
-- step_text_2 varchar(100) character set unicode casespecific,
 ans_2 varchar(255) character set unicode casespecific)
primary index (msisdn)
on commit preserve rows;

--delete spss_soa_step2;

insert into spss_soa_step2
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_2,
-- case when a.ans_2 = -1 then step_2 end as step_text_2,
 case when a.ans_2 is null then null
      when a.ans_2 = 1 then 'Тарифы'
      when a.ans_2 = 2 then 'Обслуживание в салоне связи Tele2'
      when a.ans_2 = 3 then 'Телефонная линия поддержки (636)'
      when a.ans_2 = 4 then 'Качество голосовой связи'
      when a.ans_2 = 5 then 'Качество мобильного интернета'
      when a.ans_2 = 6 then 'Личный кабинет'
      when a.ans_2 = 7 then 'Все устраивает'
      else 'Другое' end as ans_2
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_2,
-- a.step_text_2,
 length (oreplace(oreplace(oreplace(upper(step_2),' ',''),',',''),'.','')) length_step_2,
 case when step_2 is null then null
      when length_step_2 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6', '7')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from spss_soa2_3 a
) a
;

--select top 100 * from spss_soa_step2;
--select * from spss_soa_step2;

--select * from spss_soa_step2 where msisdn = '79503401200';


--05 Расчет step 3 PRICE_1
/*
Насколько вы довольны соотношением цены и объема оказываемых услуг по шкале от 1 до 10, где 1- не довольны, 10- очень довольны? Отправьте цифру в ответ
*/

create multiset volatile table spss_soa_step3, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_3 varchar(200) character set unicode casespecific,
-- step_text_3 varchar(100) character set unicode casespecific,
 ans_3 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


create multiset volatile table spss_soa_step3_1, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_3 varchar(200) character set unicode casespecific,
-- step_text_3 varchar(100) character set unicode casespecific,
 ans_3 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into spss_soa_step3
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_3,
-- a.step_text_3,
 case when a.ans_3_1 = '-' then a.ans_3_3 else a.ans_3_1 end as ans_3
from (
select
 a.*,
 case when a.ans_3_2 in ('0','1','2','3','4','5','6','7','8','9','10') then a.ans_3_2 else '-' end as ans_3_3
from ( 
select
 a.*,
 case when a.ans_3_new is not null
      then cast(otranslate(a.ans_3_new,' ','') as varchar(1000)) end as ans_3_1,
 cast (case when ans_3_1 = '-'
      then oreplace (a.ans_3, regexp_replace(a.ans_3, '[[:alnum:]]'),'') else '-' end as varchar (50))as ans_3_2
from (
select
 a.*,
 length(trim(otranslate(a.ans_3,otranslate(a.ans_3,'1234567890',''),''))) ans_3_single,
 length(trim(otranslate(a.ans_3,'1234567890',''))) ans_3_text,
 case when ans_3_single>0 and ans_3_text=0 then cast(a.ans_3 as varchar(1000)) else cast('-' as varchar(1000)) end ans_3_new
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_3,
-- a.step_text_3,
 trim (regexp_replace(trim (both ',' from trim (both '.' from trim(oreplace(a.step_3,'.00','')))),'687','',1,1)) ans_3
from spss_soa2_3 a
) a
) a
) a
) a
;

--delete spss_soa_step3_1;

insert into spss_soa_step3_1
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_3,
-- a.step_text_3,
 case when a.step_3 is null then null
      when a.ans_3 in ('1','2','3','4','5','6','7','8','9','10') then a.ans_3
      else '-1' end as ans_3
from spss_soa_step3 a
;


--select top 100 * from spss_soa_step3_1;
--select * from spss_soa_step3_1;


--06 Расчет step 4 PRICE_2
/*
Оцените, насколько вам понятны списания за услуги по шкале от 1 до 10, где 1- «не понятны», 10- «полностью понятны»? Отправьте цифру в ответ
*/

create multiset volatile table spss_soa_step4, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_4 varchar(200) character set unicode casespecific,
-- step_text_4 varchar(100) character set unicode casespecific,
 ans_4 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


create multiset volatile table spss_soa_step4_1, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_4 varchar(200) character set unicode casespecific,
-- step_text_4 varchar(100) character set unicode casespecific,
 ans_4 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into spss_soa_step4
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_4,
-- a.step_text_4,
 case when a.ans_4_1 = '-' then a.ans_4_3 else a.ans_4_1 end as ans_4
from (
select
 a.*,
 case when a.ans_4_2 in ('0','1','2','3','4','5','6','7','8','9','10') then a.ans_4_2 else '-' end as ans_4_3
from ( 
select
 a.*,
 case when a.ans_4_new is not null
      then cast(otranslate(a.ans_4_new,' ','') as varchar(100)) end as ans_4_1,
 cast (case when ans_4_1 = '-'
      then oreplace (a.ans_4, regexp_replace(a.ans_4, '[[:alnum:]]'),'') else '-' end as varchar (50))as ans_4_2
from (
select
 a.*,
 length(trim(otranslate(a.ans_4,otranslate(a.ans_4,'1234567890',''),''))) ans_4_single,
 length(trim(otranslate(a.ans_4,'1234567890',''))) ans_4_text,
 case when ans_4_single>0 and ans_4_text=0 then cast(a.ans_4 as varchar(100)) else cast('-' as varchar(10)) end ans_4_new
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_4,
-- a.step_text_4,
 trim (regexp_replace(trim (both ',' from trim (both '.' from trim(oreplace(a.step_4,'.00','')))),'687','',1,1)) ans_4
from spss_soa2_3 a
) a
) a
) a
) a
;

--delete spss_soa_step4_1;

insert into spss_soa_step4_1
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_4,
-- a.step_text_4,
 case when a.step_4 is null then null
      when a.ans_4 in ('1','2','3','4','5','6','7','8','9','10') then a.ans_4
      else '-1' end as ans_4
from spss_soa_step4 a
;


--select top 100 * from spss_soa_step4_1;
--select * from spss_soa_step4_1;


--07 Расчет step 5 MB_1
/*
Был ли решен вопрос, по которому вы обращались в салон связи? 
1- Да, с первого визита
2- Да, но после нескольких посещений. обращений в салон
3-Вопрос не решили. 
Отправьте цифру в ответ
*/

create multiset volatile table spss_soa_step5, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_5 varchar(200) character set unicode casespecific,
-- step_text_5 varchar(100) character set unicode casespecific,
 ans_5 varchar(255) character set unicode casespecific)
primary index (msisdn)
on commit preserve rows;

--delete spss_soa_step5;

insert into spss_soa_step5
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_5,
-- a.step_text_5,
 case when a.ans_5 is null then null
      when a.ans_5 = 1 then 'Да, с первого визита'
      when a.ans_5 = 2 then 'Да, после нескольких посещений/обращений в салон'
      when a.ans_5 = 3 then 'Вопрос не решили'
      else 'Другое' end as ans_5
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_5,
-- a.step_text_5,
 length (oreplace(oreplace(oreplace(upper(step_5),' ',''),',',''),'.','')) length_step_5,
 case when step_5 is null then null
      when length_step_5 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_5),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_5),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_5
from spss_soa2_3 a
) a
;


--select top 100 * from spss_soa_step5;
--select * from spss_soa_step5;


--08 Расчет step 6 MB_2
/*
Что первым делом требуется улучшить в салонах связи? 
1- Профессиональные знания сотрудников
2- Готовность сотрудников помочь
3- Скорость в решении вопросов
4- Удобство размещения офисов
5- Комфорт ожидания в очереди
*/

create multiset volatile table spss_soa_step6, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_6 varchar(200) character set unicode casespecific,
-- step_text_6 varchar(100) character set unicode casespecific,
 ans_6 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

--delete spss_soa_step6;

insert into spss_soa_step6
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_6,
-- a.step_text_6,
 case when a.ans_6 is null then null
      when a.ans_6 = 1 then 'Профессиональные знания сотрудников'
      when a.ans_6 = 2 then 'Готовность сотрудников помочь'
      when a.ans_6 = 3 then 'Скорость в решении вопросов'
      when a.ans_6 = 4 then 'Удобство размещения офисов'
      when a.ans_6 = 5 then 'Комфорт ожидания в очереди'
      else 'Другое' end as ans_6
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_6,
-- a.step_text_6,
 length (oreplace(oreplace(oreplace(upper(step_6),' ',''),',',''),'.','')) length_step_6,
 case when step_6 is null then null
      when length_step_6 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_6),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1','2','3','4','5')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_6),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_6
from spss_soa2_3 a
) a
;

--select top 100 * from spss_soa_step6;
--select * from spss_soa_step6;


--09 Расчет step 7 CC_1
/*
Был ли решен вопрос, по которому вы обращались в службу поддержки клиентов? 
1 - Да, с первого звонка
2 - Да, но не с первого звонка
3 - Нет
Отправьте цифру в ответ
*/

create multiset volatile table spss_soa_step7, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_7 varchar(200) character set unicode casespecific,
-- step_text_7 varchar(100) character set unicode casespecific,
 ans_7 varchar(255) character set unicode casespecific)
primary index (msisdn)
on commit preserve rows;


--delete spss_soa_step7;

insert into spss_soa_step7
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_7,
-- a.step_text_7,
 case when a.ans_7 is null then null
      when a.ans_7 = 1 then 'Да, с первого звонка'
      when a.ans_7 = 2 then 'Да, но не с первого звонка'
      when a.ans_7 = 3 then 'Нет'
      else 'Другое' end as ans_7
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_7,
-- a.step_text_7,
 length (oreplace(oreplace(oreplace(upper(step_7),' ',''),',',''),'.','')) length_step_7,
 case when step_7 is null then null
      when length_step_7 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_7),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_7),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_7
from spss_soa2_3 a
) a
;

--select top 100 * from spss_soa_step7;
--select * from spss_soa_step7;


--10 Расчет step 8 CC_2
/*
Что первым делом требуется улучшить в телефонной службе поддержки (636)?
1- Профессиональные знания операторов
2- Готовность операторов помочь
3- Дружелюбие операторов
4- Скорость в решении вопросов
5- Время ожидания соединения с оператором
*/

create multiset volatile table spss_soa_step8, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_8 varchar(200) character set unicode casespecific,
-- step_text_8 varchar(100) character set unicode casespecific,
 ans_8 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


--delete spss_soa_step8;

insert into spss_soa_step8
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_8,
-- a.step_text_8,
 case when a.ans_8 is null then null
      when a.ans_8 = 1 then 'Профессиональные знания операторов'
      when a.ans_8 = 2 then 'Готовность операторов помочь'
      when a.ans_8 = 3 then 'Дружелюбие операторов'
      when a.ans_8 = 4 then 'Скорость в решении вопросов'
      when a.ans_8 = 5 then 'Время ожидания соединения с оператором'
      else 'Другое' end as ans_8
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_8,
-- a.step_text_8,
 length (oreplace(oreplace(oreplace(upper(step_8),' ',''),',',''),'.','')) length_step_8,
 case when step_8 is null then null
      when length_step_8 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_8),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1','2','3','4','5')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_8),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_8
from spss_soa2_3 a
) a
;


--select top 100 * from spss_soa_step8;
--select * from spss_soa_step8;


--11 Расчет step 9 VOICE_1
/*
Где чаще всего вы испытываете проблемы с качеством голосовой связи или SMS? Укажите один вариант ответа:
1- Проблем не наблюдаю
2- Регулярно дома
3- Регулярно на работе
4- Регулярно по маршруту передвижения
5- Регулярно за городом
6- В местах проведения досуга
Отправьте цифру в ответ
*/

create multiset volatile table spss_soa_step9, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_9 varchar(200) character set unicode casespecific,
-- step_text_9 varchar(100) character set unicode casespecific,
 ans_9 varchar(255) character set unicode casespecific)
primary index (msisdn)
on commit preserve rows;


--delete spss_soa_step9;

insert into spss_soa_step9
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_9,
-- a.step_text_9,
 case when a.ans_9 is null then null
      when a.ans_9 = 1 then 'Проблем не наблюдаю'
      when a.ans_9 = 2 then 'Регулярно дома'
      when a.ans_9 = 3 then 'Регулярно на работе'
      when a.ans_9 = 4 then 'Регулярно по маршруту передвижения'
      when a.ans_9 = 5 then 'Регулярно за городом'
      when a.ans_9 = 6 then 'В местах проведения досуга'
      else 'Другое' end as ans_9
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_9,
-- a.step_text_9,
 length (oreplace(oreplace(oreplace(upper(step_9),' ',''),',',''),'.','')) length_step_9,
 case when step_9 is null then null
      when length_step_9 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_9),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3','4', '5', '6')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_9),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_9
from spss_soa2_3 a
) a
;

--select top 100 * from spss_soa_step9;
--select * from spss_soa_step9;


--12 Расчет step 10 VOICE_2
/*
С какими проблемами вы сталкиваетесь чаще всего?
1- Сеть недоступна
2- Плохая слышимость/помехи/эхо
3- Обрыв звонка
4- Недоставленные или долгое время доставки SMS
*/

create multiset volatile table spss_soa_step10, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_10 varchar(200) character set unicode casespecific,
-- step_text_10 varchar(100) character set unicode casespecific,
 ans_10 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

--delete spss_soa_step10;

insert into spss_soa_step10
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_10,
-- a.step_text_10,
 case when a.ans_10 is null then null
      when a.ans_10 = 1 then 'Сеть недоступна'
      when a.ans_10 = 2 then 'Плохая слышимость/ помехи/ эхо'
      when a.ans_10 = 3 then 'Обрыв звонка'
      when a.ans_10 = 4 then 'Недоставленные или долгое время доставки SMS'
      else 'Другое' end as ans_10
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_10,
-- a.step_text_10,
 length (oreplace(oreplace(oreplace(upper(step_10),' ',''),',',''),'.','')) length_step_10,
 case when step_10 is null then null
      when length_step_10 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_10),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1','2','3','4')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_10),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_10
from spss_soa2_3 a
) a
;

--select top 100 * from spss_soa_step10;
--select * from spss_soa_step10;


--13 Расчет step 11 INTERNET_1
/*
Где вы испытываете проблемы с качеством мобильного интернета?
1.- Проблем не наблюдаю
2.- Регулярно дома
3.- Регулярно на работе
4.- Регулярно по маршруту передвижения 
5.- Регулярно за городом
6.- Регулярно в местах проведения досуга
Отправьте цифру в ответ
*/

create multiset volatile table spss_soa_step11, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_11 varchar(200) character set unicode casespecific,
-- step_text_11 varchar(100) character set unicode casespecific,
 ans_11 varchar(255) character set unicode casespecific)
primary index (msisdn)
on commit preserve rows;

--delete spss_soa_step11;

insert into spss_soa_step11
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_11,
-- a.step_text_11,
 case when a.ans_11 is null then null
      when a.ans_11 = 1 then 'Проблем не наблюдаю'
      when a.ans_11 = 2 then 'Регулярно дома'
      when a.ans_11 = 3 then 'Регулярно на работе'
      when a.ans_11 = 4 then 'Регулярно по маршруту передвижения'
      when a.ans_11 = 5 then 'Регулярно за городом'
      when a.ans_11 = 6 then 'Регулярно в местах проведения досуга'
      else 'Другое' end as ans_11
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_11,
-- a.step_text_11,
 length (oreplace(oreplace(oreplace(upper(step_11),' ',''),',',''),'.','')) length_step_11,
 case when step_11 is null then null
      when length_step_11 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_11),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3','4', '5', '6')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_11),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_11
from spss_soa2_3 a
) a
;

--select top 100 * from spss_soa_step11;
--select * from spss_soa_step11;


--14 Расчет step 12 INTERNET_2
/*
Выберите ситуацию, с которой вы чаще всего сталкиваетесь при использовании интернета:
1.- Интернет недоступен
2.- Низкая скорость или обрывы соединения
*/

create multiset volatile table spss_soa_step12, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_12 varchar(200) character set unicode casespecific,
-- step_text_12 varchar(100) character set unicode casespecific,
 ans_12 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


--delete spss_soa_step12;

insert into spss_soa_step12
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_12,
-- a.step_text_12,
 case when a.ans_12 is null then null
      when a.ans_12 = 1 then 'Интернет недоступен'
      when a.ans_12 = 2 then 'Низкая скорость или обрывы соединения'
      else 'Другое' end as ans_12
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_12,
-- a.step_text_12,
 length (oreplace(oreplace(oreplace(upper(step_12),' ',''),',',''),'.','')) length_step_12,
 case when step_12 is null then null
      when length_step_12 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_12),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1','2')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_12),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_12
from spss_soa2_3 a
) a
;

--select top 100 * from spss_soa_step12;
--select * from spss_soa_step12;


--15 Расчет step 13 LK (ранее - INTERNET_3)
/*
Был ли решен вопрос, по которому вы обращались в  личный кабинет? 
1- Да
2- Нет, вопрос решил в телефонной  службе поддержки (636)
3- Нет, вопрос решил в салоне связи Tele2
4- Нет, вопрос не решил.
*/

--drop table spss_soa_step13;

create multiset volatile table spss_soa_step13, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_13 varchar(200) character set unicode casespecific,
-- step_text_13 varchar(100) character set unicode casespecific,
 ans_13 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

--delete spss_soa_step13;

insert into spss_soa_step13
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_13,
-- a.step_text_13,
 case when a.ans_13 is null then null
      when a.ans_13 = 1 then 'Да'
      when a.ans_13 = 2 then 'Нет, вопрос решил в телефонной  службе поддержки (636)'
      when a.ans_13 = 3 then 'Нет, вопрос решил в салоне связи Tele2'
      when a.ans_13 = 4 then 'Нет, вопрос не решил'
      else 'Другое' end as ans_13
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_13,
-- a.step_text_13,
 length (oreplace(oreplace(oreplace(upper(step_13),' ',''),',',''),'.','')) length_step_13,
 case when step_13 is null then null
      when length_step_13 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_13),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1','2','3','4')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_13),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_13
from spss_soa2_3 a
) a
;

--select top 100 * from spss_soa_step13;
--select * from spss_soa_step13;


--16 Расчет step 14 LK2
/*
Что требуется улучшить в  личном кабинете?
1- Функциональность
2- Интерфейс
3- Сервисную поддержку
Отправьте цифру в ответ
*/

create multiset volatile table spss_soa_step14, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
-- branch_id decimal(4,0),
 create_date date format 'yy/mm/dd',
 step_14 varchar(200) character set unicode casespecific,
-- step_text_13 varchar(100) character set unicode casespecific,
 ans_14 varchar(255) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

--delete spss_soa_step14;

insert into spss_soa_step14
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_14,
-- a.step_text_14,
 case when a.ans_14 is null then null
      when a.ans_14 = 1 then 'Функциональность'
      when a.ans_14 = 2 then 'Интерфейс'
      when a.ans_14 = 3 then 'Сервисную поддержку'
      else 'Другое' end as ans_14
from (
select
 a.msisdn,
 a.subs_id,
-- a.branch_id,
 a.create_date,
 a.step_14,
-- a.step_text_14,
 length (oreplace(oreplace(oreplace(upper(step_14),' ',''),',',''),'.','')) length_step_14,
 case when step_14 is null then null
      when length_step_14 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(step_14),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1','2','3')
                           then regexp_substr(oreplace(oreplace(oreplace(upper(step_14),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_14
from spss_soa2_3 a
) a
;

--select top 100 * from spss_soa_step14;
--select * from spss_soa_step14;


--16 Статистика

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step3_1;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step4_1;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step5;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step6;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step7;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step8;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step9;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step10;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step11;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step12;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step13;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_step14;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa2_3;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (MSISDN ,CREATE_DATE)
ON spss_soa_nps2;


--17 Финальная сборка

--drop table spss_soa_fin_2;

create multiset volatile table spss_soa_fin_2, no log (
 create_date date format 'yy/mm/dd',
 branch_id decimal(4,0),
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 nps byteint,
 problem_point varchar(255) character set unicode casespecific,
 price_1 byteint,
 price_2 byteint,
 mb_1 varchar(255) character set unicode casespecific,
 mb_2 varchar(255) character set unicode not casespecific,
 cc_1 varchar(255) character set unicode casespecific,
 cc_2 varchar(255) character set unicode not casespecific,
 voice_1 varchar(255) character set unicode casespecific,
 voice_2 varchar(255) character set unicode not casespecific,
 internet_1 varchar(255) character set unicode casespecific,
 internet_2 varchar(255) character set unicode not casespecific,
 lk_1 varchar(255) character set unicode not casespecific,
 lk_2 varchar(255) character set unicode not casespecific,
 address varchar(255) character set unicode casespecific,
 nps_mark varchar(255) character set unicode casespecific,
 problem_point_mark varchar(255) character set unicode casespecific,
 price_1_mark varchar(255) character set unicode casespecific,
 price_2_mark varchar(255) character set unicode casespecific,
 mb_1_mark varchar(255) character set unicode casespecific,
 mb_2_mark varchar(255) character set unicode not casespecific,
 cc_1_mark varchar(255) character set unicode casespecific,
 cc_2_mark varchar(255) character set unicode not casespecific,
 voice_1_mark varchar(255) character set unicode casespecific,
 voice_2_mark varchar(255) character set unicode not casespecific,
 internet_1_mark varchar(255) character set unicode casespecific,
 internet_2_mark varchar(255) character set unicode not casespecific,
 lk_1_mark varchar(255) character set unicode not casespecific,
 lk_2_mark varchar(255) character set unicode not casespecific,
 load_id integer)
primary index (subs_id)
on commit preserve rows;


--diagnostic helpstats on for session;

--delete spss_soa_fin_2;

insert into spss_soa_fin_2
select
 a.create_date,
 t15.branch_id,
 a.msisdn,
 a.subs_id,
 cast(t1.nps as byteint) as nps,
 t2.ans_2 as problem_point,
 cast(t3.ans_3 as byteint) as price_1,
 cast(t4.ans_4 as byteint) as price_2,
 t5.ans_5 as mb_1,
 t6.ans_6 as mb_2,
 t7.ans_7 as cc_1,
 t8.ans_8 as cc_2,
 t9.ans_9 as voice_1,
 t10.ans_10 as voice_2,
 t11.ans_11 as internet_1,
 t12.ans_12 as internet_2,
 t13.ans_13 as lk_1,
 t14.ans_14 as lk_2,
 case when a.step_15 is null then null
      when length (a.step_15) > 10 then a.step_15
      end as address,
 case when coalesce(t1.nps,99) = -1 then t1.step_1 end as nps_mark,
 case when coalesce(t2.ans_2,'na') = 'Другое' then t2.step_2 end as problem_point_mark,
 case when coalesce(t3.ans_3,99) = -1 then t3.step_3 end as price_1_mark,
 case when coalesce(t4.ans_4,99) = -1 then t4.step_4 end as price_2_mark,
 case when coalesce(t5.ans_5,'na') = 'Другое' then t5.step_5 end as mb_1_mark,
 case when coalesce(t6.ans_6,'na') = 'Другое' then t6.step_6 end as mb_2_mark,
 case when coalesce(t7.ans_7,'na') = 'Другое' then t7.step_7 end as cc_1_mark1,
 case when coalesce(t8.ans_8,'na') = 'Другое' then t8.step_8 end as cc_2_mark,
 case when coalesce(t9.ans_9,'na') = 'Другое' then t9.step_9 end as voice_1_mark,
 case when coalesce(t10.ans_10,'na') = 'Другое' then t10.step_10 end as voice_2_mark,
 case when coalesce(t11.ans_11,'na') = 'Другое' then t11.step_11 end as internet_1_mark,
 case when coalesce(t12.ans_12,'na') = 'Другое' then t12.step_12 end as internet_2_mark,
 case when coalesce(t13.ans_13,'na') = 'Другое' then t13.step_13 end as lk_1_mark,
 case when coalesce(t14.ans_14,'na') = 'Другое' then t14.step_14 end as lk_2_mark,
 : load_id
from spss_soa2_3 a
left join spss_soa_nps2 t1 on a.msisdn = t1.msisdn and a.create_date = t1.create_date
left join spss_soa_step2 t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date
left join spss_soa_step3_1 t3 on a.msisdn = t3.msisdn and a.create_date = t3.create_date
left join spss_soa_step4_1 t4 on a.msisdn = t4.msisdn and a.create_date = t4.create_date
left join spss_soa_step5 t5 on a.msisdn = t5.msisdn and a.create_date = t5.create_date
left join spss_soa_step6 t6 on a.msisdn = t6.msisdn and a.create_date = t6.create_date
left join spss_soa_step7 t7 on a.msisdn = t7.msisdn and a.create_date = t7.create_date
left join spss_soa_step8 t8 on a.msisdn = t8.msisdn and a.create_date = t8.create_date
left join spss_soa_step9 t9 on a.msisdn = t9.msisdn and a.create_date = t9.create_date
left join spss_soa_step10 t10 on a.msisdn = t10.msisdn and a.create_date = t10.create_date
left join spss_soa_step11 t11 on a.msisdn = t11.msisdn and a.create_date = t11.create_date
left join spss_soa_step12 t12 on a.msisdn = t12.msisdn and a.create_date = t12.create_date
left join spss_soa_step13 t13 on a.msisdn = t13.msisdn and a.create_date = t13.create_date
left join spss_soa_step14 t14 on a.msisdn = t14.msisdn and a.create_date = t14.create_date
--
left join prd2_bds_v2.subs_clr_d t15 on a.msisdn = t15.msisdn
 and a.create_date = t15.report_date
 and t15.report_date >= :sdate
 and t15.report_date < :edate
-- and t15.report_date >= date '2021-03-15'
-- and t15.report_date < date '2021-03-22'
;



-- вставка на схему uat_ca
insert into uat_ca.mc_nps2_6_nsp2
select
 a.create_month,
 a.create_date,
 a.activation_dttm,
 a.week_num,
 a.month_num,
 a.year_num,
 a.branch_id,
 a.cluster_name,
 a.macroregion,
 a.region,
 a.subs_id,
 a.msisdn,
 a.bsegment,
 a.subs_segm_name,
 a.lt_day,
 case when a.lt_day is null then 'null' 
      when a.lt_day >=0 and a.lt_day <= 30 then '1'
      when a.lt_day >30 and a.lt_day <= 60 then '2'
      when a.lt_day >60 and a.lt_day <= 90 then '3'
      when a.lt_day >90 and a.lt_day <= 180  then '4-6'
      when a.lt_day >180 and a.lt_day <= 360 then '7-12'
      when a.lt_day >360 and a.lt_day <= 720 then '13-24'
      when a.lt_day >720 and a.lt_day <= 1080 then '25-36'
      else '36+' end as lt_gr,
-- определение nps
 a.nps,
 a.detractor,
 a.passive,
 a.promoter,
 a.nps_category,
-- определение step 2-14
 a.problem_point,
 a.price_1,
 a.price_2,
 a.mb_1,
 a.mb_2,
 a.cc_1,
 a.cc_2,
 a.voice_1,
 a.voice_2,
 a.internet_1,
 a.internet_2,
 a.lk_1,
 a.lk_2,
 a.address,
--
 a.nps_mark,
 a.problem_point_mark,
 a.price_1_mark,
 a.price_2_mark,
 a.mb_1_mark,
 a.mb_2_mark,
 a.cc_1_mark,
 a.cc_2_mark,
 a.voice_1_mark,
 a.voice_2_mark,
 a.internet_1_mark,
 a.internet_2_mark,
 a.lk_1_mark,
 a.lk_2_mark,
--
 case when a.nps is null then null
      when a.nps = -1 then null
      when a.detractor = 1 then -1
      when a.passive = 1 then 0
      when a.promoter = 1 then 1
      end as nps_key,
 trunc (a.create_date,'iw') as first_day_week,
 a.load_id
--
from (
select
 trunc (a.create_date, 'mm') as create_month,
 a.create_date,
 t4.activation_dttm as activation_dttm,
 weeknumber_of_year(a.create_date, 'iso') as week_num,
 case when extract(month from a.create_date) = 1 then '01 январь'
      when extract(month from a.create_date) = 2 then '02 февраль'
      when extract(month from a.create_date) = 3 then '03 март'
      when extract(month from a.create_date) = 4 then '04 апрель'
      when extract(month from a.create_date) = 5 then '05 май'
      when extract(month from a.create_date) = 6 then '06 июнь'
      when extract(month from a.create_date) = 7 then '07 июль'
      when extract(month from a.create_date) = 8 then '08 август'
      when extract(month from a.create_date) = 9 then '09 сентябрь'
      when extract(month from a.create_date) = 10 then '10 октябрь'
      when extract(month from a.create_date) = 11 then '11 ноябрь'
      when extract(month from a.create_date) = 12 then '12 декабрь' else '' end as month_num,
 extract(year from a.create_date) as year_num,
 a.branch_id,
 t1.cluster_name,
 t3.macroregion_name as macroregion,
 t2.region_name as region,
 a.subs_id,
 a.msisdn,
 t4.bsegment as bsegment,
 t5.subscription_segment_name as subs_segm_name,
 a.create_date - cast (t4.activation_dttm as date) lt_day,
-- определение nps
 a.nps,
 cast(case when nps = '-1' then null
           when a.nps between 1 and 6 then 1 else 0 end as integer) as detractor,
 cast(case when a.nps = '-1' then null
           when a.nps between 7 and 8 then 1 else 0 end as integer) as passive,
 cast(case when a.nps = '-1' then null
           when a.nps between 9 and 10 then 1 else 0 end as integer) as promoter,
 case when detractor = 1 then 'Detractor'
      when passive = 1 then 'Passive'
      when promoter = 1 then 'Promoter'
      end nps_category,
-- step 2-14
 a.problem_point,
 a.price_1,
 a.price_2,
 a.mb_1,
 a.mb_2,
 a.cc_1,
 a.cc_2,
 a.voice_1,
 a.voice_2,
 a.internet_1,
 a.internet_2,
 a.lk_1,
 a.lk_2,
 a.address,
--
 a.nps_mark,
 a.problem_point_mark,
 a.price_1_mark,
 a.price_2_mark,
 a.mb_1_mark,
 a.mb_2_mark,
 a.cc_1_mark,
 a.cc_2_mark,
 a.voice_1_mark,
 a.voice_2_mark,
 a.internet_1_mark,
 a.internet_2_mark,
 a.lk_1_mark,
 a.lk_2_mark,
--
 case when a.create_date > (select max_report_date from prd2_tmd_v.dds_load_status where table_name='subscription')
      then (select max_report_date from prd2_tmd_v.dds_load_status where table_name='subscription')
      else a.create_date end as create_date2,
 a.load_id
from spss_soa_fin_2 a
--определение даты активации и сегмента
inner join prd2_dds_v.subscription t4 on a.subs_id = t4.subs_id
 and create_date2 = t4.report_date
 and t4.report_date >= :sdate
 and t4.report_date < :edate
-- and t4.report_date >= date '2021-03-15'
-- and t4.report_date < date '2021-03-22'
--
left join prd2_dic_v.branch t1 on a.branch_id = t1.branch_id
left join prd2_dic_v.region t2 on t1.region_id = t2.region_id
left join prd2_dic_v.macroregion t3 on t2.macroregion_id = t3.macroregion_id
left join prd2_dic_v.subscription_segment t5 on t4.subs_segm_id = t5.subscription_segment_id
) a
;


-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Всего строк uat_ca.knime_poll_187: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


drop table soa;
drop table spss_soa2_3;
drop table spss_soa_nps;
drop table spss_soa_nps2;
drop table spss_soa_step2;
drop table spss_soa_step3;
drop table spss_soa_step3_1;
drop table spss_soa_step4;
drop table spss_soa_step4_1;
drop table spss_soa_step5;
drop table spss_soa_step6;
drop table spss_soa_step7;
drop table spss_soa_step8;
drop table spss_soa_step9;
drop table spss_soa_step10;
drop table spss_soa_step11;
drop table spss_soa_step12;
drop table spss_soa_step13;
drop table spss_soa_step14;
drop table spss_soa_fin_2;

--ET;


-- логирование окончания расчета данных
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,1,'END');


END;


--=================================================================================================

-- Комментарий
COMMENT ON PROCEDURE uat_ca.mc_nps_66 AS
'Процедура формирования витрины с опросами NPS из нового источника SOA 2.0, точка контакта Мобильный интернет. Результирующая таблица: uat_ca.mc_nps2_6_nsp2';


--=================================================================================================

-- Вызов процедуры

--2021
/*week 09*/ call uat_ca.mc_nps_66 (timestamp '2021-03-01 00:00:00', timestamp '2021-03-08 00:00:00', date '2021-03-01', date '2021-03-08');   --5 мин. 36 сек.
/*week 10*/ call uat_ca.mc_nps_66 (timestamp '2021-03-08 00:00:00', timestamp '2021-03-15 00:00:00', date '2021-03-08', date '2021-03-15');   --6 мин. 02 сек.
/*week 11*/ call uat_ca.mc_nps_66 (timestamp '2021-03-15 00:00:00', timestamp '2021-03-22 00:00:00', date '2021-03-15', date '2021-03-22');   --5 мин. 18 сек.
/*week 12*/ call uat_ca.mc_nps_66 (timestamp '2021-03-22 00:00:00', timestamp '2021-03-29 00:00:00', date '2021-03-22', date '2021-03-29');   --3 мин. 20 сек.
/*week 13*/ call uat_ca.mc_nps_66 (timestamp '2021-03-29 00:00:00', timestamp '2021-04-05 00:00:00', date '2021-03-29', date '2021-04-05');   --7 мин. 46 сек.
/*week 14*/ call uat_ca.mc_nps_66 (timestamp '2021-04-05 00:00:00', timestamp '2021-04-12 00:00:00', date '2021-04-05', date '2021-04-12');   --
/*week 15*/ call uat_ca.mc_nps_66 (timestamp '2021-04-12 00:00:00', timestamp '2021-04-19 00:00:00', date '2021-04-12', date '2021-04-19');   --
/*week 16*/ call uat_ca.mc_nps_66 (timestamp '2021-04-19 00:00:00', timestamp '2021-04-26 00:00:00', date '2021-04-19', date '2021-04-26');   --
/*week 17*/ call uat_ca.mc_nps_66 (timestamp '2021-04-26 00:00:00', timestamp '2021-05-03 00:00:00', date '2021-04-26', date '2021-05-03');   --
/*week 18*/ call uat_ca.mc_nps_66 (timestamp '2021-05-03 00:00:00', timestamp '2021-05-10 00:00:00', date '2021-05-03', date '2021-05-10');   --1 мин. 14 сек.
/*week 19*/ call uat_ca.mc_nps_66 (timestamp '2021-05-10 00:00:00', timestamp '2021-05-17 00:00:00', date '2021-05-10', date '2021-05-17');   --4 мин. 18 сек.
/*week 20*/ call uat_ca.mc_nps_66 (timestamp '2021-05-17 00:00:00', timestamp '2021-05-24 00:00:00', date '2021-05-17', date '2021-05-24');   --4 мин. 18 сек.
/*week 21*/ call uat_ca.mc_nps_66 (timestamp '2021-05-24 00:00:00', timestamp '2021-06-01 00:00:00', date '2021-05-24', date '2021-06-01');   --20 мин. 59 сек.
/*week 22*/ call uat_ca.mc_nps_66 (timestamp '2021-06-01 00:00:00', timestamp '2021-06-07 00:00:00', date '2021-06-01', date '2021-06-07');   --4 мин. 52 сек.
/*week 23*/ call uat_ca.mc_nps_66 (timestamp '2021-06-07 00:00:00', timestamp '2021-06-14 00:00:00', date '2021-06-07', date '2021-06-14');   --4 мин. 52 сек.
/*week 24*/ call uat_ca.mc_nps_66 (timestamp '2021-06-14 00:00:00', timestamp '2021-06-21 00:00:00', date '2021-06-14', date '2021-06-21');   --4 мин. 52 сек.
/*week 25*/ call uat_ca.mc_nps_66 (timestamp '2021-06-21 00:00:00', timestamp '2021-06-28 00:00:00', date '2021-06-21', date '2021-06-28');   --14 мин. 58 сек.
/*week 26*/ call uat_ca.mc_nps_66 (timestamp '2021-06-28 00:00:00', timestamp '2021-07-05 00:00:00', date '2021-06-28', date '2021-07-05');   --
/*week 27*/ call uat_ca.mc_nps_66 (timestamp '2021-07-05 00:00:00', timestamp '2021-07-12 00:00:00', date '2021-07-05', date '2021-07-12');   --
/*week 28*/ call uat_ca.mc_nps_66 (timestamp '2021-07-12 00:00:00', timestamp '2021-07-19 00:00:00', date '2021-07-12', date '2021-07-19');   --57 мин. 46 сек.
/*week 29*/ call uat_ca.mc_nps_66 (timestamp '2021-07-19 00:00:00', timestamp '2021-07-26 00:00:00', date '2021-07-19', date '2021-07-26');   --10 мин. 45 сек.
/*week 30*/ call uat_ca.mc_nps_66 (timestamp '2021-07-26 00:00:00', timestamp '2021-08-02 00:00:00', date '2021-07-26', date '2021-08-02');   --8 мин. 28 сек.
/*week 31*/ call uat_ca.mc_nps_66 (timestamp '2021-08-02 00:00:00', timestamp '2021-08-09 00:00:00', date '2021-08-02', date '2021-08-09');   --
/*week 32*/ call uat_ca.mc_nps_66 (timestamp '2021-08-09 00:00:00', timestamp '2021-08-16 00:00:00', date '2021-08-09', date '2021-08-16');   --3 мин. 25 сек.
/*week 33*/ call uat_ca.mc_nps_66 (timestamp '2021-08-16 00:00:00', timestamp '2021-08-23 00:00:00', date '2021-08-16', date '2021-08-23');   --2 мин. 31 сек.
/*week 34*/ call uat_ca.mc_nps_66 (timestamp '2021-08-23 00:00:00', timestamp '2021-08-30 00:00:00', date '2021-08-23', date '2021-08-30');   --3 мин. 04 сек.
/*week 35*/ call uat_ca.mc_nps_66 (timestamp '2021-08-30 00:00:00', timestamp '2021-09-06 00:00:00', date '2021-08-30', date '2021-09-06');   --3 мин. 10 сек.

/*week 36*/ call uat_ca.mc_nps_66 (timestamp '2021-09-06 00:00:00', timestamp '2021-09-13 00:00:00', date '2021-09-06', date '2021-09-13');   --11 мин. 40 сек.
/*week 37*/ call uat_ca.mc_nps_66 (timestamp '2021-09-13 00:00:00', timestamp '2021-09-20 00:00:00', date '2021-09-13', date '2021-09-20');   --
/*week 38*/ call uat_ca.mc_nps_66 (timestamp '2021-09-20 00:00:00', timestamp '2021-09-27 00:00:00', date '2021-09-20', date '2021-09-27');   --08 мин. 47 сек.

/*week 39*/ call uat_ca.mc_nps_66 (timestamp '2021-09-27 00:00:00', timestamp '2021-10-04 00:00:00', date '2021-09-27', date '2021-10-04');   --01 мин. 31 сек.
/*week 40*/ call uat_ca.mc_nps_66 (timestamp '2021-10-04 00:00:00', timestamp '2021-10-11 00:00:00', date '2021-10-04', date '2021-10-11');   --03 мин. 49 сек.
/*week 41*/ call uat_ca.mc_nps_66 (timestamp '2021-10-11 00:00:00', timestamp '2021-10-18 00:00:00', date '2021-10-11', date '2021-10-18');   --02 мин. 31 сек.

/*week 42*/ call uat_ca.mc_nps_66 (timestamp '2021-10-18 00:00:00', timestamp '2021-10-25 00:00:00', date '2021-10-18', date '2021-10-25');   --12 мин. 25 сек.
/*week 43*/ call uat_ca.mc_nps_66 (timestamp '2021-10-25 00:00:00', timestamp '2021-11-01 00:00:00', date '2021-10-25', date '2021-11-01');   --11 мин. 12 сек.
/*week 44*/ call uat_ca.mc_nps_66 (timestamp '2021-11-01 00:00:00', timestamp '2021-11-08 00:00:00', date '2021-11-01', date '2021-11-08');   --02 мин. 31 сек.
/*week 45*/ call uat_ca.mc_nps_66 (timestamp '2021-11-08 00:00:00', timestamp '2021-11-15 00:00:00', date '2021-11-08', date '2021-11-15');   --06 мин. 45 сек.
/*week 46*/ call uat_ca.mc_nps_66 (timestamp '2021-11-15 00:00:00', timestamp '2021-11-22 00:00:00', date '2021-11-15', date '2021-11-22');   --05 мин. 17 сек.
/*week 47*/ call uat_ca.mc_nps_66 (timestamp '2021-11-22 00:00:00', timestamp '2021-11-29 00:00:00', date '2021-11-22', date '2021-11-29');   --
/*week 48*/ call uat_ca.mc_nps_66 (timestamp '2021-11-29 00:00:00', timestamp '2021-12-06 00:00:00', date '2021-11-29', date '2021-12-06');   --

/*week 49*/ call uat_ca.mc_nps_66 (timestamp '2021-12-06 00:00:00', timestamp '2021-12-13 00:00:00', date '2021-12-06', date '2021-12-13');   --05 мин. 53 сек.
/*week 50*/ call uat_ca.mc_nps_66 (timestamp '2021-12-13 00:00:00', timestamp '2021-12-20 00:00:00', date '2021-12-13', date '2021-12-20');   --04 мин. 26 сек.

/*week 51*/ call uat_ca.mc_nps_66 (timestamp '2021-12-20 00:00:00', timestamp '2021-12-27 00:00:00', date '2021-12-20', date '2021-12-27');   --04 мин. 55 сек.
/*week 52*/ call uat_ca.mc_nps_66 (timestamp '2021-12-27 00:00:00', timestamp '2022-01-01 00:00:00', date '2021-12-27', date '2022-01-01');   --04 мин. 26 сек.


--2022
/*week 02*/ call uat_ca.mc_nps_66 (timestamp '2022-01-10 00:00:00', timestamp '2022-01-17 00:00:00', date '2022-01-10', date '2022-01-17');   --01 мин. 34 сек.
/*week 03*/ call uat_ca.mc_nps_66 (timestamp '2022-01-17 00:00:00', timestamp '2022-01-24 00:00:00', date '2022-01-17', date '2022-01-24');   --01 мин. 32 сек.
/*week 04*/ call uat_ca.mc_nps_66 (timestamp '2022-01-24 00:00:00', timestamp '2022-01-31 00:00:00', date '2022-01-24', date '2022-01-31');   --01 мин. 36 сек.
/*week 05*/ call uat_ca.mc_nps_66 (timestamp '2022-01-31 00:00:00', timestamp '2022-02-07 00:00:00', date '2022-01-31', date '2022-02-07');   --01 мин. 36 сек.
/*week 06*/ call uat_ca.mc_nps_66 (timestamp '2022-02-07 00:00:00', timestamp '2022-02-14 00:00:00', date '2022-02-07', date '2022-02-14');   --01 мин. 19 сек.
/*week 07*/ call uat_ca.mc_nps_66 (timestamp '2022-02-14 00:00:00', timestamp '2022-02-21 00:00:00', date '2022-02-14', date '2022-02-21');   --02 мин. 28 сек.
/*week 08*/ call uat_ca.mc_nps_66 (timestamp '2022-02-21 00:00:00', timestamp '2022-02-28 00:00:00', date '2022-02-21', date '2022-02-28');
/*week 09*/ call uat_ca.mc_nps_66 (timestamp '2022-02-28 00:00:00', timestamp '2022-03-07 00:00:00', date '2022-02-28', date '2022-03-07');
/*week 10*/ call uat_ca.mc_nps_66 (timestamp '2022-03-07 00:00:00', timestamp '2022-03-14 00:00:00', date '2022-03-07', date '2022-03-14');
/*week 11*/ call uat_ca.mc_nps_66 (timestamp '2022-03-14 00:00:00', timestamp '2022-03-21 00:00:00', date '2022-03-14', date '2022-03-21');
/*week 12*/ call uat_ca.mc_nps_66 (timestamp '2022-03-21 00:00:00', timestamp '2022-03-28 00:00:00', date '2022-03-21', date '2022-03-28');
/*week 13*/ call uat_ca.mc_nps_66 (timestamp '2022-03-28 00:00:00', timestamp '2022-04-04 00:00:00', date '2022-03-28', date '2022-04-04');
/*week 14*/ call uat_ca.mc_nps_66 (timestamp '2022-04-04 00:00:00', timestamp '2022-04-11 00:00:00', date '2022-04-04', date '2022-04-11');
/*week 15*/ call uat_ca.mc_nps_66 (timestamp '2022-04-11 00:00:00', timestamp '2022-04-18 00:00:00', date '2022-04-11', date '2022-04-18');
/*week 16*/ call uat_ca.mc_nps_66 (timestamp '2022-04-18 00:00:00', timestamp '2022-04-25 00:00:00', date '2022-04-18', date '2022-04-25');   --02 мин. 28 сек.
/*week 17*/ call uat_ca.mc_nps_66 (timestamp '2022-04-25 00:00:00', timestamp '2022-05-02 00:00:00', date '2022-04-25', date '2022-05-02');
/*week 18*/ call uat_ca.mc_nps_66 (timestamp '2022-05-02 00:00:00', timestamp '2022-05-09 00:00:00', date '2022-05-02', date '2022-05-09');
/*week 19*/ call uat_ca.mc_nps_66 (timestamp '2022-05-09 00:00:00', timestamp '2022-05-16 00:00:00', date '2022-05-09', date '2022-05-16');   --03 мин. 41 сек.
/*week 20*/ call uat_ca.mc_nps_66 (timestamp '2022-05-16 00:00:00', timestamp '2022-05-23 00:00:00', date '2022-05-16', date '2022-05-23');
/*week 21*/ call uat_ca.mc_nps_66 (timestamp '2022-05-23 00:00:00', timestamp '2022-05-30 00:00:00', date '2022-05-23', date '2022-05-30');
/*week 22*/ call uat_ca.mc_nps_66 (timestamp '2022-05-30 00:00:00', timestamp '2022-06-06 00:00:00', date '2022-05-30', date '2022-06-06');
/*week 23*/ call uat_ca.mc_nps_66 (timestamp '2022-06-06 00:00:00', timestamp '2022-06-13 00:00:00', date '2022-06-06', date '2022-06-13');   --01 мин. 34 сек.
/*week 24*/ call uat_ca.mc_nps_66 (timestamp '2022-06-13 00:00:00', timestamp '2022-06-20 00:00:00', date '2022-06-13', date '2022-06-20');
/*week 25*/ call uat_ca.mc_nps_66 (timestamp '2022-06-20 00:00:00', timestamp '2022-06-27 00:00:00', date '2022-06-20', date '2022-06-27');   --01 мин. 34 сек.
/*week 26*/ call uat_ca.mc_nps_66 (timestamp '2022-06-27 00:00:00', timestamp '2022-07-04 00:00:00', date '2022-06-27', date '2022-07-04');   --03 мин. 56 сек.
/*week 27*/ call uat_ca.mc_nps_66 (timestamp '2022-07-04 00:00:00', timestamp '2022-07-11 00:00:00', date '2022-07-04', date '2022-07-11');   --12 мин. 48 сек.
/*week 28*/ call uat_ca.mc_nps_66 (timestamp '2022-07-11 00:00:00', timestamp '2022-07-18 00:00:00', date '2022-07-11', date '2022-07-18');
/*week 29*/ call uat_ca.mc_nps_66 (timestamp '2022-07-18 00:00:00', timestamp '2022-07-25 00:00:00', date '2022-07-18', date '2022-07-25');
/*week 30*/ call uat_ca.mc_nps_66 (timestamp '2022-07-25 00:00:00', timestamp '2022-08-01 00:00:00', date '2022-07-25', date '2022-08-01');

/*week 31*/ call uat_ca.mc_nps_66 (timestamp '2022-08-01 00:00:00', timestamp '2022-08-08 00:00:00', date '2022-08-01', date '2022-08-08');     --17 мин. 04 мин.
/*week 32*/ call uat_ca.mc_nps_66 (timestamp '2022-08-08 00:00:00', timestamp '2022-08-15 00:00:00', date '2022-08-08', date '2022-08-15');     --5 мин. 33 сек.
/*week 33*/ call uat_ca.mc_nps_66 (timestamp '2022-08-15 00:00:00', timestamp '2022-08-22 00:00:00', date '2022-08-15', date '2022-08-22');
/*week 34*/ call uat_ca.mc_nps_66 (timestamp '2022-08-22 00:00:00', timestamp '2022-08-29 00:00:00', date '2022-08-22', date '2022-08-29');     --12 мин. 06 сек.

/*week 35*/ call uat_ca.mc_nps_66 (timestamp '2022-08-29 00:00:00', timestamp '2022-09-05 00:00:00', date '2022-08-29', date '2022-09-05');
/*week 36*/ call uat_ca.mc_nps_66 (timestamp '2022-09-05 00:00:00', timestamp '2022-09-12 00:00:00', date '2022-09-05', date '2022-09-12');
/*week 37*/ call uat_ca.mc_nps_66 (timestamp '2022-09-12 00:00:00', timestamp '2022-09-19 00:00:00', date '2022-09-12', date '2022-09-19');
/*week 38*/ call uat_ca.mc_nps_66 (timestamp '2022-09-19 00:00:00', timestamp '2022-09-26 00:00:00', date '2022-09-19', date '2022-09-26');
/*week 39*/ call uat_ca.mc_nps_66 (timestamp '2022-09-26 00:00:00', timestamp '2022-10-03 00:00:00', date '2022-09-26', date '2022-10-03');

/*week 40*/ call uat_ca.mc_nps_66 (timestamp '2022-10-03 00:00:00', timestamp '2022-10-10 00:00:00', date '2022-10-03', date '2022-10-10');
/*week 41*/ call uat_ca.mc_nps_66 (timestamp '2022-10-10 00:00:00', timestamp '2022-10-17 00:00:00', date '2022-10-10', date '2022-10-17');
/*week 42*/ call uat_ca.mc_nps_66 (timestamp '2022-10-17 00:00:00', timestamp '2022-10-24 00:00:00', date '2022-10-17', date '2022-10-24');
/*week 43*/ call uat_ca.mc_nps_66 (timestamp '2022-10-24 00:00:00', timestamp '2022-10-31 00:00:00', date '2022-10-24', date '2022-10-31');
            call uat_ca.mc_nps_66 (timestamp '2022-10-29 00:00:00', timestamp '2022-10-31 00:00:00', date '2022-10-29', date '2022-10-31');

/*week 44*/ call uat_ca.mc_nps_66 (timestamp '2022-10-31 00:00:00', timestamp '2022-11-07 00:00:00', date '2022-10-31', date '2022-11-07');
/*week 45*/ call uat_ca.mc_nps_66 (timestamp '2022-11-07 00:00:00', timestamp '2022-11-14 00:00:00', date '2022-11-07', date '2022-11-14');
/*week 46*/ call uat_ca.mc_nps_66 (timestamp '2022-11-14 00:00:00', timestamp '2022-11-21 00:00:00', date '2022-11-14', date '2022-11-21');
/*week 47*/ call uat_ca.mc_nps_66 (timestamp '2022-11-21 00:00:00', timestamp '2022-11-28 00:00:00', date '2022-11-21', date '2022-11-28');
/*week 48*/ call uat_ca.mc_nps_66 (timestamp '2022-11-28 00:00:00', timestamp '2022-12-05 00:00:00', date '2022-11-28', date '2022-12-05');
/*week 49*/ call uat_ca.mc_nps_66 (timestamp '2022-12-05 00:00:00', timestamp '2022-12-12 00:00:00', date '2022-12-05', date '2022-12-12');     --
/*week 50*/ call uat_ca.mc_nps_66 (timestamp '2022-12-12 00:00:00', timestamp '2022-12-19 00:00:00', date '2022-12-12', date '2022-12-19');
/*week 51*/ call uat_ca.mc_nps_66 (timestamp '2022-12-19 00:00:00', timestamp '2022-12-26 00:00:00', date '2022-12-19', date '2022-12-26');
/*week 52*/ call uat_ca.mc_nps_66 (timestamp '2022-12-26 00:00:00', timestamp '2023-01-02 00:00:00', date '2022-12-26', date '2023-01-02');


--==2023
/*week 2*/  call uat_ca.mc_nps_66 (timestamp '2023-01-09 00:00:00', timestamp '2023-01-16 00:00:00', date '2023-01-09', date '2023-01-16');
/*week 3*/  call uat_ca.mc_nps_66 (timestamp '2023-01-16 00:00:00', timestamp '2023-01-23 00:00:00', date '2023-01-16', date '2023-01-23');
/*week 4*/  call uat_ca.mc_nps_66 (timestamp '2023-01-23 00:00:00', timestamp '2023-01-30 00:00:00', date '2023-01-23', date '2023-01-30');
/*week 5*/  call uat_ca.mc_nps_66 (timestamp '2023-01-30 00:00:00', timestamp '2023-02-06 00:00:00', date '2023-01-30', date '2023-02-06');

--=================================================================================================

-- Комментарии доступны в витринах метаданных EDW:
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablekind = 'Procedure' order by "Дата последнего изменения" desc;
select * from prd2_tmd_v.columns_info;


-- Для просмотра рассчитанных дней в момент работы процедуры, либо по ее завершению используйте запрос по таблице логов:
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_187'
-- and t1.logdate > current_timestamp(0) - interval '1' month
 and t1.logdate >= timestamp '2022-06-19 00:00:00'
 and t1.logdate < timestamp '2022-06-20 00:00:00'
order by logdate desc;


-- Просмотр логов
select * from uat_ca.mc_logs order by 1;
--delete uat_ca.mc_logs where loadid = 52;


-- Просмотр витрин
select top 100 * from uat_ca.mc_nps2_6_nsp2;
select top 100 * from uat_ca.mc_nps2_6_nsp2 where branch_id is null;

--delete uat_ca.mc_nps2_6_nsp2 where create_date = date '2022-07-23';

delete uat_ca.mc_nps2_6_nsp2 where subs_id = 100059614232 and create_date = date '2021-10-02';
delete uat_ca.mc_nps2_6_nsp2 where subs_id = 100076045863 and create_date = date '2021-10-09';
delete uat_ca.mc_nps2_6_nsp2 where subs_id = 200092046828 and create_date = date '2022-02-05';

select top 100 * from uat_ca.mc_nps2_6_nsp2 where create_date >= date '2021-08-30';
--delete uat_ca.mc_nps2_6_nsp2 where create_date >= date '2021-12-13' and create_date < date '2021-12-20';

--delete uat_ca.mc_nps2_6_nsp2 where branch_id is null;

select create_date, count(distinct msisdn), count(*) from uat_ca.mc_nps2_6_nsp2 group by 1 order by 1 desc;


--==================================================================================================
--==================================================================================================
--==================================================================================================

--==Пересчет некорректных дней
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 create_date,
 count(*)
from uat_ca.mc_nps2_6_nsp2
where 1=1
 and branch_id is null
group by 1,2,3
;

delete uat_ca.mc_nps2_6_nsp2 where create_date = date '2022-05-21';
delete uat_ca.mc_nps2_6_nsp2 where create_date = date '2022-06-17';

call uat_ca.mc_nps_66 (timestamp '2022-05-21 00:00:00', timestamp '2022-05-22 00:00:00', date '2022-05-21', date '2022-05-22');     --15 мин. 19 сек.
call uat_ca.mc_nps_66 (timestamp '2022-06-17 00:00:00', timestamp '2022-06-18 00:00:00', date '2022-06-17', date '2022-06-18');     --19 мин. 59 сек.

20      2022-05-16      2022-05-21      1       --
24      2022-06-13      2022-06-17      196     --


select create_date, count(*) from uat_ca.mc_nps2_6_nsp2 where create_date in (date '2022-05-21', date '2022-06-17') group by 1;


--витрина b2b
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 create_date,
 count(*)
from tele2_uat.v2_nps_b2b
where 1=1
 and branch_id is null
group by 1,2,3
;

delete tele2_uat.mc_nps_b2b2 where create_date = date '2022-05-21';
delete tele2_uat.mc_nps_b2b2 where create_date = date '2022-06-17';



insert into tele2_uat.mc_nps_b2b2
select
 create_month,
 create_date,
 activation_dttm,
 week_num,
 month_num,
 year_num,
 branch_id,
 cluster_name,
 macroregion,
 region,
 subs_id,
 msisdn,
 bsegment,
 subs_segm_name,
 lt_day,
 lt_gr,
 nps,
 detractor,
 passive,
 promoter,
 nps_category,
 case when problem_point = 'Качество голосовой связи' then 'Голос и СМС'
      when problem_point = 'Телефонную линию поддержки клиентов' then 'Колл-центр'
      when problem_point = 'Качество мобильного интернета' then 'Мобильный интернет'
      when problem_point = 'Обслуживание в салоне связи Tele2' then 'Монобренд'
      else problem_point end as problem_point,
 price_1,
 price_2,
 mb_1,
 mb_2,
 cc_1,
 cc_2,
 voice_1,
 voice_2,
 internet_1,
 internet_2,
 lk_1,
 lk_2,
 address,
 nps_mark,
 problem_point_mark,
 price_1_mark,
 price_2_mark,
 mb_1_mark,
 mb_2_mark,
 cc_1_mark,
 cc_2_mark,
 voice_1_mark,
 voice_2_mark,
 internet_1_mark,
 internet_2_mark,
 lk_1_mark,
 lk_2_mark,
 nps_key,
 first_day_week
from uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date >= date '2022-06-17'
 and create_date < date '2022-06-18'
;



--==================================================================================================
--==================================================================================================
--==================================================================================================

select top 100 * from uat_ca.mc_nps2_6_nsp2 where branch_id is null;

--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_nps2_6_nsp2
group by 1,2
order by 2 desc;

--2 месячная динамика
select
 trunc (create_date,'mm') as "Месяц",
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_nps2_6_nsp2
group by 1
order by 1 desc;

--3 дневная динамика
select
 create_date,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_nps2_6_nsp2
group by 1
order by 1 desc;


--Дубли
select * from uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date >= date '2023-01-01'
 and create_date < date '2023-02-01'
qualify count(*) over (partition by subs_id) >1;


delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79005999310' and create_date = date '2022-08-31';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79003042460' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79533934018' and create_date = date '2022-09-02';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79068607535' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79500688384' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79517941511' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79514647125' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79535880793' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79000220466' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79045861561' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79000167939' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79531668006' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79200159048' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79046555557' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79062057193' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79020468316' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79500340779' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79535009487' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79637731224' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79967468507' and create_date = date '2022-09-02';
--delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79999052646' and create_date = date '2022-09-03';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79777592779' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79015824042' and create_date = date '2022-09-02';
delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79999243522' and create_date = date '2022-09-02';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79191259010' and create_date = date '2022-09-02';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79919541214' and create_date = date '2022-09-24';



delete uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date = date '2022-10-29'
 and msisdn in ('79047788896', '79010041979', '79537353240', '79021266587', '79021397500',
                '79046310171', '79027061630', '79226693839', '79009957429', '79373996959',
                '79509002099', '79046524579', '79803037179', '79057115455', '79916263024',
                '79585000280', '79778485844')
;

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79015132613' and create_date = date '2022-12-29';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79519936925' and create_date = date '2023-01-27';


create multiset volatile table subs2, no log as (
select distinct * from uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date >= date '2022-10-24'
 and create_date < date '2022-10-31'
qualify count(*) over (partition by subs_id) >1
) with data
primary index (subs_id)
on commit preserve rows
;

select * from subs2;

delete uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date = date '2022-10-26'
 and msisdn in ('79006977773', '79309884533')
;

insert into uat_ca.mc_nps2_6_nsp2
select * from subs2;




--update
/*
create multiset volatile table tmp, no log as (
select * from uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date >= date '2022-03-28'
 and create_date < date '2022-04-04'
-- and msisdn = '79773319915'
qualify count(*) over (partition by subs_id) >1
) with data
primary index (subs_id)
on commit preserve rows;


UPDATE tmp
SET address = 'Москва. Ул. Лазо дом 10'
WHERE 1=1
 AND msisdn = '79773319915'
 AND create_date = date '2021-04-02'
;

select top 100 * from tmp;
*/


--Март 2021
UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Тарифы',
    price_1 = 7
WHERE 1=1
 AND msisdn = '79510990442'
 AND create_date = date '2021-03-16';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79510990442' AND create_date = date '2021-03-17';


UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Качество мобильного интернета',
    internet_1 = 'Регулярно на работе',
    internet_2 = 'Низкая скорость или обрывы соединения'
WHERE 1=1
 AND msisdn = '79087211323'
 AND create_date = date '2021-03-19';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79087211323' AND create_date = date '2021-03-20';


--Апрель 2021
UPDATE uat_ca.mc_nps2_6_nsp2
SET address = 'Москва. Ул. Лазо дом 10'
WHERE 1=1
 AND msisdn = '79773319915'
 AND create_date = date '2021-04-02';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79773319915' AND create_date = date '2021-04-03';


--Май 2021
create multiset volatile table tmp, no log as (
select distinct a.* from uat_ca.mc_nps2_6_nsp2 a
where 1=1
 and subs_id in (56462002, 200072113837)
 and create_month = date '2021-05-01'
)with data
primary index (subs_id)
on commit preserve rows
;

select * from tmp;

delete uat_ca.mc_nps2_6_nsp2
where 1=1
 and subs_id in (56462002, 200072113837)
 and create_month = date '2021-05-01'
;

insert into uat_ca.mc_nps2_6_nsp2
select * from tmp
;


UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Все устраивает'
WHERE 1=1
 AND msisdn = '79106352603'
 AND create_date = date '2021-05-14';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79106352603' AND create_date = date '2021-05-15';

UPDATE uat_ca.mc_nps2_6_nsp2
SET internet_2 = 'Низкая скорость или обрывы соединения'
WHERE 1=1
 AND msisdn = '79771224051'
 AND create_date = date '2021-05-27';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79771224051' AND create_date = date '2021-05-28';

UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Все устраивает'
WHERE 1=1
 AND msisdn = '79916363441'
 AND create_date = date '2021-05-25';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79916363441' AND create_date = date '2021-05-28';

UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Все устраивает'
WHERE 1=1
 AND msisdn = '79771224051'
 AND create_date = date '2021-05-27';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79771224051' AND create_date = date '2021-05-28';


UPDATE uat_ca.mc_nps2_6_nsp2
SET internet_1 = 'Регулярно в местах проведения досуга',
    internet_2 = 'Интернет недоступен'
WHERE 1=1
 AND msisdn = '79779351046'
 AND create_date = date '2021-06-21';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79779351046' AND create_date = date '2021-06-22';



--Июнь 2021
UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Все устраивает'
WHERE 1=1
 AND msisdn = '79015789481'
 AND create_date = date '2021-07-14';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79015789481' AND create_date = date '2021-07-15';


--Август 2021
UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Все устраивает'
WHERE 1=1
 AND msisdn = '79533038718'
 AND create_date = date '2021-08-05';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79533038718' AND create_date = date '2021-08-06';

--Сентябрь 2021
UPDATE uat_ca.mc_nps2_6_nsp2
SET cc_2 = 'Время ожидания соединения с оператором'
WHERE 1=1
 AND msisdn = '79085160790'
 AND create_date = date '2021-09-22';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79085160790' AND create_date = date '2021-09-23';

UPDATE uat_ca.mc_nps2_6_nsp2
SET price_2 = 7
WHERE 1=1
 AND msisdn = '79503632612'
 AND create_date = date '2021-09-22';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79503632612' AND create_date = date '2021-09-23';


--Октябрь 2021
UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Все устраивает'
WHERE 1=1
 AND msisdn = '79040779367'
 AND create_date = date '2021-10-11';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79040779367' AND create_date = date '2021-10-12';

--Декабрь 2021
UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Качество мобильного интернета'
WHERE 1=1
 AND msisdn = '79003329890'
 AND create_date = date '2021-12-22';

UPDATE uat_ca.mc_nps2_6_nsp2
SET internet_1 = 'Регулярно за городом'
WHERE 1=1
 AND msisdn = '79003329890'
 AND create_date = date '2021-12-22';

UPDATE uat_ca.mc_nps2_6_nsp2
SET internet_2 = 'Низкая скорость или обрывы соединения'
WHERE 1=1
 AND msisdn = '79003329890'
 AND create_date = date '2021-12-22';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79003329890' AND create_date = date '2021-12-23';


--Январь
UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Качество мобильного интернета',
    internet_1 = 'Регулярно дома',
    internet_2 = 'Низкая скорость или обрывы соединения',
    address = 'Город Котельниково, улица Навасёлова дом 11 квартира 1'
WHERE 1=1
 AND msisdn = '79047575471'
 AND create_date = date '2022-01-17';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79047575471' AND create_date = date '2022-01-18';

--март
UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Качество голосовой связи'
WHERE 1=1
 AND msisdn = '79522696117'
 AND create_date = date '2022-03-02';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79522696117' AND create_date = date '2022-03-03';

UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Другое',
    problem_point_mark = 'Все устраивает'
WHERE 1=1
 AND msisdn = '79919609193'
 AND create_date = date '2022-03-31';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79919609193' AND create_date = date '2022-04-01';


--Август
UPDATE uat_ca.mc_nps2_6_nsp2
SET problem_point = 'Качество мобильного интернета',
    internet_1 = 'Регулярно дома',
    internet_2 = 'Интернет недоступен'
WHERE 1=1
 AND msisdn = '79531120972'
 AND create_date = date '2022-08-02';

delete uat_ca.mc_nps2_6_nsp2 where msisdn = '79531120972' AND create_date = date '2022-08-03';


--=================================================================================================
--=================================================================================================
--=================================================================================================

--delete uat_ca.mc_nps2_6_nsp2 where create_date = date '2022-10-29';
--delete tele2_uat.v2_nps_b2b where create_date = date '2022-10-29';

select top 100 * from tele2_uat.v2_nps_b2b where branch_id is null;

delete tele2_uat.v2_nps_b2b where branch_id is null;
delete uat_ca.mc_nps2_6_nsp2 where branch_id is null;

--витрина на схеме tele2_uat

--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from tele2_uat.v2_nps_b2b
group by 1,2
order by 2 desc;

--2 месячная динамика
select
 trunc (create_date,'mm') as "Месяц",
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,s
 dis_msisdn - row_cnt as diff_msisdn
from tele2_uat.v2_nps_b2b
group by 1
order by 1 desc;

--3 дневная динамика
select 
 create_date,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from tele2_uat.v2_nps_b2b
group by 1
order by 1 desc;


create multiset table uat_ca.mc_nps2_6_nsp2_tmp as (
select * from tele2_uat.mc_nps_b2b2
where 1=1
 and create_date >= date '2021-03-01'
) with data
primary index (subs_id);

select count(*) from uat_ca.mc_nps2_6_nsp2_tmp;     --3 759

--delete tele2_uat.mc_nps_b2b2 where create_date >= date '2021-07-12';


insert into tele2_uat.mc_nps_b2b2
select
 create_month,
 create_date,
 activation_dttm,
 week_num,
 month_num,
 year_num,
 branch_id,
 cluster_name,
 macroregion,
 region,
 subs_id,
 msisdn,
 bsegment,
 subs_segm_name,
 lt_day,
 lt_gr,
 nps,
 detractor,
 passive,
 promoter,
 nps_category,
 case when problem_point = 'Качество голосовой связи' then 'Голос и СМС'
      when problem_point = 'Телефонную линию поддержки клиентов' then 'Колл-центр'
      when problem_point = 'Качество мобильного интернета' then 'Мобильный интернет'
      when problem_point = 'Обслуживание в салоне связи Tele2' then 'Монобренд'
      else problem_point end as problem_point,
 price_1,
 price_2,
 mb_1,
 mb_2,
 cc_1,
 cc_2,
 voice_1,
 voice_2,
 internet_1,
 internet_2,
 lk_1,
 lk_2,
 address,
 nps_mark,
 problem_point_mark,
 price_1_mark,
 price_2_mark,
 mb_1_mark,
 mb_2_mark,
 cc_1_mark,
 cc_2_mark,
 voice_1_mark,
 voice_2_mark,
 internet_1_mark,
 internet_2_mark,
 lk_1_mark,
 lk_2_mark,
 nps_key,
 first_day_week
from uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date >= date '2023-01-30'
 and create_date < date '2023-02-06'
;


select * from tele2_uat.mc_nps_b2b2 where branch_id is null;


select * from tele2_uat.mc_nps_b2b2
where 1=1
 and create_date >= date '2021-01-01'
 and create_date < date '2022-01-01'
;








/*



















select top 100 * from spss_soa_fin_2;
select * from spss_soa_fin_2 where branch_id is null;
select count(distinct msisdn), count(*) from spss_soa_fin_2;
select create_date, count(*) from spss_soa_fin_2 group by 1;
select count(*) from spss_soa2_3;

select * from spss_soa_fin_2 where create_date = date '2021-03-17';
select msisdn, count(*) from spss_soa_fin_2 group by 1 order by 1;
select * from spss_soa2_3 where msisdn = '79217030315';
select * from spss_soa2_3 where msisdn = '79507234624';
select * from spss_soa2_3 where msisdn = '79510990442';
select * from spss_soa2_3 where msisdn = '79087211323';

79510990442
79217030315
79507234624
79087211323


select * from prd2_bds_v2.subs_clr_d
where 1=1
 and report_date >= date '2021-03-15'
 and report_date < date '2021-03-22'
 and msisdn = '79507234624'
;

select count(distinct msisdn), count(*) from spss_soa2_3;
select * from spss_soa2_3 where msisdn = '79507234624';

select msisdn, count(*) from spss_soa2_3 group by 1 order by 2 desc;

select count(*) from spss_soa2_3 where msisdn = '79507234624';
select count(*) from spss_soa_nps2 where msisdn = '79507234624';
select count(*) from spss_soa_step2 where msisdn = '79507234624';
select count(*) from spss_soa_step3 where msisdn = '79507234624';
select count(*) from spss_soa_step4 where msisdn = '79507234624';
select count(*) from spss_soa_step5 where msisdn = '79507234624';
select count(*) from spss_soa_step6 where msisdn = '79507234624';
select count(*) from spss_soa_step7 where msisdn = '79507234624';
select count(*) from spss_soa_step8 where msisdn = '79507234624';
select count(*) from spss_soa_step9 where msisdn = '79507234624';
select count(*) from spss_soa_step10 where msisdn = '79507234624';
select count(*) from spss_soa_step11 where msisdn = '79507234624';
select count(*) from spss_soa_step12 where msisdn = '79507234624';
select count(*) from spss_soa_step13 where msisdn = '79507234624';
select count(*) from spss_soa_step14 where msisdn = '79507234624';















select * from prd2_dds_v.phone_number_2 where subs_id = 200088427142;


select * from spss_soa2_3;
select create_date, count(distinct subs_id), count(*) from spss_soa2_3 group by 1 order by 1;

select * from spss_soa2_3
where create_date = date '2021-02-01'
qualify count(*) over (partition by msisdn) > 1;

select * from spss_soa2_3
where create_date = date '2021-02-01'
;

delete spss_soa2_3
where 1=1
 and create_date = date '2021-02-01'
 and msisdn = '79821135779'
 and treatment_code is null
;


select count(*) from spss_soa_nps2;
select count(*) from spss_soa_step2;
select count(*) from spss_soa_step3_1;
select count(*) from spss_soa_step4_1;
select count(*) from spss_soa_step5;
select count(*) from spss_soa_step6;
select count(*) from spss_soa_step7;
select count(*) from spss_soa_step8;
select count(*) from spss_soa_step9;
select count(*) from spss_soa_step10;
select count(*) from spss_soa_step11;
select count(*) from spss_soa_step12;
select count(*) from spss_soa_step13;
select count(*) from spss_soa_step14;


--delete spss_soa_fin_2;

select top 100 * from spss_soa_fin_2;
select * from spss_soa_fin_2 where subs_id is null;
--delete spss_soa_fin_2 where subs_id is null;
select * from spss_soa_fin_2 where branch_id is null;


--18 Вставка на схему uat_ca

COLLECT STATISTICS
 COLUMN (BRANCH_ID),
 COLUMN (SUBS_ID),
 COLUMN (CREATE_DATE ,SUBS_ID)
ON spss_soa_fin_2;

select create_date, count(*) from uat_ca.mc_nps2_6_nsp where create_date >= date '2020-11-02' group by 1 order by 1;
select create_date, count(*) from spss_soa_fin_2 where create_date >= date '2020-05-01' group by 1 order by 1;

show table uat_ca.mc_nps2_6_nsp2;

--drop table uat_ca.mc_nps2_6_nsp2;

CREATE MULTISET TABLE uat_ca.mc_nps2_6_nsp2 ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO (
 create_month DATE FORMAT 'yy/mm/dd',
 create_date DATE FORMAT 'yy/mm/dd',
 activation_dttm TIMESTAMP(0),
 week_num byteint,
 month_num VARCHAR(11) CHARACTER SET UNICODE NOT CASESPECIFIC,
 year_num INTEGER,
 branch_id DECIMAL(4,0),
 cluster_name VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 macroregion VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 region VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 subs_id DECIMAL(12,0),
 msisdn VARCHAR(20) CHARACTER SET UNICODE NOT CASESPECIFIC,
 bsegment VARCHAR(20) CHARACTER SET UNICODE CASESPECIFIC,
 subs_segm_name VARCHAR(20) CHARACTER SET UNICODE CASESPECIFIC,
 lt_day NUMBER,
 lt_gr VARCHAR(5) CHARACTER SET UNICODE NOT CASESPECIFIC,
 nps byteint,
 detractor byteint,
 passive byteint,
 promoter byteint,
 nps_category VARCHAR(9) CHARACTER SET UNICODE NOT CASESPECIFIC,
 problem_point VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 price_1 byteint,
 price_2 byteint,
 mb_1 VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 mb_2 VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
 cc_1 VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 cc_2 VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
 voice_1 VARCHAR(100) CHARACTER SET UNICODE CASESPECIFIC,
 voice_2 VARCHAR(100) CHARACTER SET UNICODE NOT CASESPECIFIC,
 internet_1 VARCHAR(100) CHARACTER SET UNICODE CASESPECIFIC,
 internet_2 VARCHAR(100) CHARACTER SET UNICODE NOT CASESPECIFIC,
 lk_1 VARCHAR(100) CHARACTER SET UNICODE NOT CASESPECIFIC,
 lk_2 VARCHAR(100) CHARACTER SET UNICODE NOT CASESPECIFIC,
 address VARCHAR(200) CHARACTER SET UNICODE CASESPECIFIC,
 nps_mark varchar(255) character set unicode casespecific,
 problem_point_mark varchar(255) character set unicode casespecific,
 price_1_mark varchar(255) character set unicode casespecific,
 price_2_mark varchar(255) character set unicode casespecific,
 mb_1_mark varchar(255) character set unicode casespecific,
 mb_2_mark varchar(255) character set unicode not casespecific,
 cc_1_mark varchar(255) character set unicode casespecific,
 cc_2_mark varchar(255) character set unicode not casespecific,
 voice_1_mark varchar(255) character set unicode casespecific,
 voice_2_mark varchar(255) character set unicode not casespecific,
 internet_1_mark varchar(255) character set unicode casespecific,
 internet_2_mark varchar(255) character set unicode not casespecific,
 lk_1_mark varchar(255) character set unicode not casespecific,
 lk_2_mark varchar(255) character set unicode not casespecific,
 nps_key BYTEINT,
 first_day_week DATE FORMAT 'yy/mm/dd',
 load_id INTEGER)
PRIMARY INDEX ( subs_id );

select top 100 * from uat_ca.mc_nps2_6_nsp2;

delete uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date >= date '2021-03-15'
 and create_date < date '2021-03-22'
;


insert into uat_ca.mc_nps2_6_nsp2
select
 a.create_month,
 a.create_date,
 a.activation_dttm,
 a.week_num,
 a.month_num,
 a.year_num,
 a.branch_id,
 a.cluster_name,
 a.macroregion,
 a.region,
 a.subs_id,
 a.msisdn,
 a.bsegment,
 a.subs_segm_name,
 a.lt_day,
 case when a.lt_day is null then 'null' 
      when a.lt_day >=0 and a.lt_day <= 30 then '1'
      when a.lt_day >30 and a.lt_day <= 60 then '2'
      when a.lt_day >60 and a.lt_day <= 90 then '3'
      when a.lt_day >90 and a.lt_day <= 180  then '4-6'
      when a.lt_day >180 and a.lt_day <= 360 then '7-12'
      when a.lt_day >360 and a.lt_day <= 720 then '13-24'
      when a.lt_day >720 and a.lt_day <= 1080 then '25-36'
      else '36+' end as lt_gr,
-- определение nps
 a.nps,
 a.detractor,
 a.passive,
 a.promoter,
 a.nps_category,
-- определение step 2-14
 a.problem_point,
 a.price_1,
 a.price_2,
 a.mb_1,
 a.mb_2,
 a.cc_1,
 a.cc_2,
 a.voice_1,
 a.voice_2,
 a.internet_1,
 a.internet_2,
 a.lk_1,
 a.lk_2,
 a.address,
--
 a.nps_mark,
 a.problem_point_mark,
 a.price_1_mark,
 a.price_2_mark,
 a.mb_1_mark,
 a.mb_2_mark,
 a.cc_1_mark,
 a.cc_2_mark,
 a.voice_1_mark,
 a.voice_2_mark,
 a.internet_1_mark,
 a.internet_2_mark,
 a.lk_1_mark,
 a.lk_2_mark,
--
 case when a.nps is null then null
      when a.nps = -1 then null
      when a.detractor = 1 then -1
      when a.passive = 1 then 0
      when a.promoter = 1 then 1
      end as nps_key,
 trunc (a.create_date,'iw') as first_day_week,
 a.load_id
--
from (
select
 trunc (a.create_date, 'mm') as create_month,
 a.create_date,
 t4.activation_dttm as activation_dttm,
 weeknumber_of_year(a.create_date, 'iso') as week_num,
 case when extract(month from a.create_date) = 1 then '01 январь'
      when extract(month from a.create_date) = 2 then '02 февраль'
      when extract(month from a.create_date) = 3 then '03 март'
      when extract(month from a.create_date) = 4 then '04 апрель'
      when extract(month from a.create_date) = 5 then '05 май'
      when extract(month from a.create_date) = 6 then '06 июнь'
      when extract(month from a.create_date) = 7 then '07 июль'
      when extract(month from a.create_date) = 8 then '08 август'
      when extract(month from a.create_date) = 9 then '09 сентябрь'
      when extract(month from a.create_date) = 10 then '10 октябрь'
      when extract(month from a.create_date) = 11 then '11 ноябрь'
      when extract(month from a.create_date) = 12 then '12 декабрь' else '' end as month_num,
 extract(year from a.create_date) as year_num,
 a.branch_id,
 t1.cluster_name,
 t3.macroregion_name as macroregion,
 t2.region_name as region,
 a.subs_id,
 a.msisdn,
 t4.bsegment as bsegment,
 t5.subscription_segment_name as subs_segm_name,
 a.create_date - cast (t4.activation_dttm as date) lt_day,
-- определение nps
 a.nps,
 cast(case when nps = '-1' then null
           when a.nps between 1 and 6 then 1 else 0 end as integer) as detractor,
 cast(case when a.nps = '-1' then null
           when a.nps between 7 and 8 then 1 else 0 end as integer) as passive,
 cast(case when a.nps = '-1' then null
           when a.nps between 9 and 10 then 1 else 0 end as integer) as promoter,
 case when detractor = 1 then 'Detractor'
      when passive = 1 then 'Passive'
      when promoter = 1 then 'Promoter'
      end nps_category,
-- step 2-14
 a.problem_point,
 a.price_1,
 a.price_2,
 a.mb_1,
 a.mb_2,
 a.cc_1,
 a.cc_2,
 a.voice_1,
 a.voice_2,
 a.internet_1,
 a.internet_2,
 a.lk_1,
 a.lk_2,
 a.address,
--
 a.nps_mark,
 a.problem_point_mark,
 a.price_1_mark,
 a.price_2_mark,
 a.mb_1_mark,
 a.mb_2_mark,
 a.cc_1_mark,
 a.cc_2_mark,
 a.voice_1_mark,
 a.voice_2_mark,
 a.internet_1_mark,
 a.internet_2_mark,
 a.lk_1_mark,
 a.lk_2_mark,
--
 case when a.create_date > (select max_report_date from prd2_tmd_v.dds_load_status where table_name='subscription')
      then (select max_report_date from prd2_tmd_v.dds_load_status where table_name='subscription')
      else a.create_date end as create_date2,
 a.load_id
from spss_soa_fin_2 a
--определение даты активации и сегмента
inner join prd2_dds_v.subscription t4 on a.subs_id = t4.subs_id
 and create_date2 = t4.report_date
 and t4.report_date >= date '2021-03-15'
 and t4.report_date < date '2021-03-22'
--
left join prd2_dic_v.branch t1 on a.branch_id = t1.branch_id
left join prd2_dic_v.region t2 on t1.region_id = t2.region_id
left join prd2_dic_v.macroregion t3 on t2.macroregion_id = t3.macroregion_id
left join prd2_dic_v.subscription_segment t5 on t4.subs_segm_id = t5.subscription_segment_id
) a
;


--delete uat_ca.mc_nps2_6_nsp2 where create_date >= date '2021-02-01';


select top 100 * from uat_ca.mc_nps2_6_nsp2 where create_date >= date '2021-01-01';
select trunc (create_date,'iw'), count(*) from uat_ca.mc_nps2_6_nsp2 where create_date >= date '2021-01-01' group by 1 order by 1;

select trunc (create_date,'iw'), count(*) from uat_ca.mc_nps2_6_nsp2 group by 1 order by 1;

select top 100 * from uat_ca.mc_nps2_6_nsp2;
select top 100 * from uat_ca.mc_nps2_6_nsp2 where address is not null;
select top 100 * from uat_ca.mc_nps2_6_nsp2 where branch_id is null;


--19 Вставка на схему tele2_uat

show table tele2_uat.mc_nps_b2b2;

--drop table tele2_uat.mc_nps_b2b2;

CREATE MULTISET TABLE tele2_uat.mc_nps_b2b2 ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO (
 create_month DATE FORMAT 'yy/mm/dd',
 create_date DATE FORMAT 'yy/mm/dd',
 activation_dttm TIMESTAMP(0),
 week_num byteint,
 month_num VARCHAR(11) CHARACTER SET UNICODE NOT CASESPECIFIC,
 year_num INTEGER,
 branch_id DECIMAL(4,0),
 cluster_name VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 macroregion VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 region VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 subs_id DECIMAL(12,0),
 msisdn VARCHAR(20) CHARACTER SET UNICODE NOT CASESPECIFIC,
 bsegment VARCHAR(20) CHARACTER SET UNICODE CASESPECIFIC,
 subs_segm_name VARCHAR(20) CHARACTER SET UNICODE CASESPECIFIC,
 lt_day NUMBER,
 lt_gr VARCHAR(5) CHARACTER SET UNICODE NOT CASESPECIFIC,
 nps byteint,
 detractor byteint,
 passive byteint,
 promoter byteint,
 nps_category VARCHAR(9) CHARACTER SET UNICODE NOT CASESPECIFIC,
 problem_point VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 price_1 byteint,
 price_2 byteint,
 mb_1 VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 mb_2 VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
 cc_1 VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
 cc_2 VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
 voice_1 VARCHAR(100) CHARACTER SET UNICODE CASESPECIFIC,
 voice_2 VARCHAR(100) CHARACTER SET UNICODE NOT CASESPECIFIC,
 internet_1 VARCHAR(100) CHARACTER SET UNICODE CASESPECIFIC,
 internet_2 VARCHAR(100) CHARACTER SET UNICODE NOT CASESPECIFIC,
 lk_1 VARCHAR(100) CHARACTER SET UNICODE NOT CASESPECIFIC,
 lk_2 VARCHAR(100) CHARACTER SET UNICODE NOT CASESPECIFIC,
 address VARCHAR(200) CHARACTER SET UNICODE CASESPECIFIC,
 nps_mark varchar(255) character set unicode casespecific,
 problem_point_mark varchar(255) character set unicode casespecific,
 price_1_mark varchar(255) character set unicode casespecific,
 price_2_mark varchar(255) character set unicode casespecific,
 mb_1_mark varchar(255) character set unicode casespecific,
 mb_2_mark varchar(255) character set unicode not casespecific,
 cc_1_mark varchar(255) character set unicode casespecific,
 cc_2_mark varchar(255) character set unicode not casespecific,
 voice_1_mark varchar(255) character set unicode casespecific,
 voice_2_mark varchar(255) character set unicode not casespecific,
 internet_1_mark varchar(255) character set unicode casespecific,
 internet_2_mark varchar(255) character set unicode not casespecific,
 lk_1_mark varchar(255) character set unicode not casespecific,
 lk_2_mark varchar(255) character set unicode not casespecific,
 nps_key BYTEINT,
 first_day_week DATE FORMAT 'yy/mm/dd')
PRIMARY INDEX ( subs_id );


delete tele2_uat.mc_nps_b2b2
where 1=1
 and create_date >= date '2021-03-15'
 and create_date < date '2021-03-22'
;


insert into tele2_uat.mc_nps_b2b2
select
 create_month,
 create_date,
 activation_dttm,
 week_num,
 month_num,
 year_num,
 branch_id,
 cluster_name,
 macroregion,
 region,
 subs_id,
 msisdn,
 bsegment,
 subs_segm_name,
 lt_day,
 lt_gr,
 nps,
 detractor,
 passive,
 promoter,
 nps_category,
 case when problem_point = 'Качество голосовой связи' then 'Голос и СМС'
      when problem_point = 'Телефонную линию поддержки клиентов' then 'Колл-центр'
      when problem_point = 'Качество мобильного интернета' then 'Мобильный интернет'
      when problem_point = 'Обслуживание в салоне связи Tele2' then 'Монобренд'
      else problem_point end as problem_point,
 price_1,
 price_2,
 mb_1,
 mb_2,
 cc_1,
 cc_2,
 voice_1,
 voice_2,
 internet_1,
 internet_2,
 lk_1,
 lk_2,
 address,
 nps_mark,
 problem_point_mark,
 price_1_mark,
 price_2_mark,
 mb_1_mark,
 mb_2_mark,
 cc_1_mark,
 cc_2_mark,
 voice_1_mark,
 voice_2_mark,
 internet_1_mark,
 internet_2_mark,
 lk_1_mark,
 lk_2_mark,
 nps_key,
 first_day_week
from uat_ca.mc_nps2_6_nsp2
where 1=1
 and create_date >= date '2021-03-15'
 and create_date < date '2021-03-22'
;

select top 100 * from tele2_uat.mc_nps_b2b2 where branch_id is null;


--insert into tele2_uat.mc_nps_b2b2
--select
-- create_month,
-- create_date,
-- activation_dttm,
-- "week",
-- "month",
-- "year",
-- branch_id,
-- "cluster",
-- macroregion,
-- region,
-- subs_id,
-- msisdn,
-- bsegment,
-- subs_segm_name,
-- "lt",
-- lt_gr,
-- nps,
-- Detractor,
-- Passive,
-- Promoter,
-- nps_category,
-- case when problem_point = 'Качество голосовой связи' then 'Голос и СМС'
--      when problem_point = 'Телефонную линию поддержки клиентов' then 'Колл-центр'
--      when problem_point = 'Качество мобильного интернета' then 'Мобильный интернет'
--      when problem_point = 'Обслуживание в салоне связи Tele2' then 'Монобренд'
--      else problem_point end as problem_point,
-- price_1,
-- price_2,
-- mb_1,
-- mb_2,
-- cc_1,
-- cc_2,
-- voice_1,
-- voice_2,
-- internet_1,
-- internet_2,
-- internet_3,
-- lk,
-- address,
-- nps_key,
-- first_day_week
--from uat_ca.mc_nps2_6_nsp2
--where 1=1
-- and create_date >= date '2021-01-11'
-- and create_date < date '2021-02-08'
--;

replace view tele2_uat.v2_nps_b2b as lock row for access 
select
 create_month,
 create_date,
 activation_dttm,
 week_num as "week",
 month_num as "month",
 year_num as "year",
 branch_id,
 cluster_name as "cluster",
 macroregion,
 region,
 subs_id,
 msisdn,
 bsegment,
 subs_segm_name,
 lt_day as "lt",
 lt_gr,
 nps,
 detractor,
 passive,
 promoter,
 nps_category,
 problem_point,
 price_1,
 price_2,
 mb_1,
 mb_2,
 cc_1,
 cc_2,
 voice_1,
 voice_2,
 internet_1,
 internet_2,
 lk_1,
 lk_2,
 address,
 nps_mark,
 problem_point_mark,
 price_1_mark,
 price_2_mark,
 mb_1_mark,
 mb_2_mark,
 cc_1_mark,
 cc_2_mark,
 voice_1_mark,
 voice_2_mark,
 internet_1_mark,
 internet_2_mark,
 lk_1_mark,
 lk_2_mark,
 nps_key,
 first_day_week
from tele2_uat.mc_nps_b2b2
;


diagnostic helpstats on for session;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (SUBS_ID)
ON tele2_uat.mc_nps_b2b2;

select trunc (create_date,'iw'), count(distinct msisdn) as msisdn_cnt, count(*) as row_cnt, msisdn_cnt - row_cnt as diff from tele2_uat.mc_nps_b2b2 group by 1 order by 1;
select create_date, count(distinct msisdn) as msisdn_cnt, count(*) as row_cnt, msisdn_cnt - row_cnt as diff from tele2_uat.mc_nps_b2b2 group by 1 order by 1;

select * from tele2_uat.mc_nps_b2b2 where address is not null;


--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (*) as msisdn_cnt
from tele2_uat.v2_nps_b2b
group by 1,2
order by 2 desc;

--2 месячная динамика
select
 trunc (create_date,'mm') as "Месяц",
 count (*) as msisdn_cnt
from tele2_uat.v2_nps_b2b
group by 1
order by 1 desc;

--3 дневная динамика
select 
 create_date,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_msisdn - row_cnt as diff_msisdn
from tele2_uat.v2_nps_b2b
group by 1
order by 1 desc;






delete tele2_uat.mc_nps_b2b
where create_date >= date '2020-11-09'
 and create_date < date '2020-11-16';

select trunc (create_date,'iw'), count(*) from tele2_uat.mc_nps_b2b2 where create_date >= date '2020-01-01' group by 1 order by 1;

select trunc (create_date,'iw'), count(*) from tele2_uat.mc_nps_b2b2 group by 1 order by 1;

select
 trunc (create_date,'iw') as report_month,
 cast(count(*) as int) as uat_ca_cnt,
 b.tele2_uat_cnt,
 uat_ca_cnt - coalesce(b.tele2_uat_cnt,0) as diff
from uat_ca.mc_nps2_6_nsp
left join (
select trunc (create_date,'iw') as report_m, cast(count(*) as int) as tele2_uat_cnt from tele2_uat.mc_nps_b2b where create_date >= date '2020-01-01' group by 1
) b on report_month = b.report_m
where create_date >= date '2020-01-01'
group by 1,3 order by 1
;

select
 trunc (create_date,'iw') as report_month,
 cast(count(*) as int) as uat_ca_cnt,
 b.tele2_uat_cnt,
 uat_ca_cnt - coalesce(b.tele2_uat_cnt,0) as diff
from uat_ca.mc_nps2_6_nsp
left join (
select
 weeknumber_of_year (create_date, 'ISO') as "Неделя",
 trunc (create_date,'iw') as report_m,
 count (*) as tele2_uat_cnt
from tele2_uat.v_nps_b2b
where create_date >= date '2020-01-01'
group by 1,2
) b on report_month = b.report_m
where create_date >= date '2020-01-01'
group by 1,3 order by 1
;


-- Временные для uat_ca.mc_nps2_6_soa_ans
drop table soa;

--В ременные для uat_ca.mc_nps2_6_nsp
drop table spss_soa2_3;
drop table spss_soa_nps;
drop table spss_soa_nps2;
drop table spss_soa_step2;
drop table spss_soa_step3;
drop table spss_soa_step3_1;
drop table spss_soa_step4;
drop table spss_soa_step4_1;
drop table spss_soa_step5;
drop table spss_soa_step6;
drop table spss_soa_step7;
drop table spss_soa_step8;
drop table spss_soa_step9;
drop table spss_soa_step10;
drop table spss_soa_step11;
drop table spss_soa_step12;
drop table spss_soa_step13;
drop table spss_soa_step14;
drop table spss_soa_fin_2;

COLLECT STATISTICS COLUMN ("YEAR") ON tele2_uat.mc_nps_b2b;




--View для отчета
replace view tele2_uat.v_nps_b2b as lock row for access 
select * from tele2_uat.mc_nps_b2b
;

replace view tele2_uat.v2_nps_b2b as lock row for access 
select * from tele2_uat.mc_nps_b2b2
;

select * from tele2_uat.v2_nps_b2b;


select top 100 * from uat_ca.v2_nps_b2b where 1=1
 and create_date >= date '2021-02-22'
 and create_date < date '2021-03-01'
;

--1 недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (*) as msisdn_cnt
from uat_ca.v2_nps_b2b
group by 1,2
order by 2 desc;

--2 месячная динамика
select
 trunc (create_date,'mm') as "месяц",
 count (*) as msisdn_cnt
from uat_ca.v2_nps_b2b
group by 1
order by 1 desc;


replace view uat_ca.v2_nps_b2b as lock row for access 
select
 create_month,
 create_date,
 activation_dttm,
 week_num as "week",
 month_num as "month",
 year_num as "year",
 branch_id,
 cluster_name as "cluster",
 macroregion,
 region,
 subs_id,
 msisdn,
 bsegment,
 subs_segm_name,
 lt_day as "lt",
 lt_gr,
 nps,
 detractor,
 passive,
 promoter,
 nps_category,
 problem_point,
 price_1,
 price_2,
 mb_1,
 mb_2,
 cc_1,
 cc_2,
 voice_1,
 voice_2,
 internet_1,
 internet_2,
 lk_1,
 lk_2,
 address,
 nps_mark,
 problem_point_mark,
 price_1_mark,
 price_2_mark,
 mb_1_mark,
 mb_2_mark,
 cc_1_mark,
 cc_2_mark,
 voice_1_mark,
 voice_2_mark,
 internet_1_mark,
 internet_2_mark,
 lk_1_mark,
 lk_2_mark,
 nps_key,
 first_day_week
from uat_ca.mc_nps2_6_nsp2
;

show view tele2_uat.v2_nps_b2b
show table tele2_uat.mc_nps_b2b2;


diagnostic helpstats on for session;

COLLECT STATISTICS
 USING MAXVALUELENGTH 5 COLUMN (NPS,CREATE_DATE),
 COLUMN (PROBLEM_POINT)
ON tele2_uat.mc_nps_b2b2;
 



select
 EXTRACT(MONTH FROM create_date) as mnth,
 msisdn,
 nps,
 problem_point,
 mb_1,
 mb_2,
 voice_1,
 voice_2,
 internet_1,
 internet_2,
 address,
 create_date,
 region,
 macroregion
from tele2_uat.v2_nps_b2b
where 1=1
 and create_date >= date '2021-06-01'
 and create_date < date '2021-07-01'
 and nps in (1,2,3,4,5,6)
 and problem_point in ('Мобильный интернет','Качество мобильного интернета', 'Голос и СМС','Качество голосовой связи', 'Телефонная линия поддержки (636)')
sample 500
;




