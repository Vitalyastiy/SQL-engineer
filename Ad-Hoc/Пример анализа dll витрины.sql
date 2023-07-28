
--Необходимые оптимизатору статистики, в случае их отсутствия, можно проверить выполнив команду EXPLAIN, предварительно запустив диагностику в текущем сеансе
diagnostic helpstats on for session;



--==Шаг 1 Данные о витринах EDW

Основную информацию о существующих таблицах в EDW и содержащихся в них полях, можно непосредственно в системе, выполнив следующие SQL-запросы:

select * from prd2_tmd_v.tables_info;
select * from prd2_tmd_v.columns_info;

https://t2ru-alation-prod-app

В витринах содержится следующая информация:
 Краткое описание содержащихся данных в витрине
 Владелец витрины или ее заказчик
 Подразделение, которое заказало разработку данной витрины
 Глубина хранения данных
 Частота и регламент обновления, включая пересчеты прошлых периодов
 Размер таблицы в GB
 Для полей-идентификаторов ссылка на таблицу-справочник с расшифровкой поля

--формат полей по умолчанию
Для слоев DDS/BDS/MDS/RDS в соответсвие с моделью EDW для определенного набора полей определены стандарты размерностей и правила
преобразования названий. Эта информация содержится в таблицес размерностями и правилами преобразований в соответсвие с моделью EDW:

select top 100 * from PRD2_TMD_V.DEFAULT_FIELD_FORMAT;



--==Шаг 2 Метрики витрины

Каждый тип перекоса может по разному влиять на план запроса, который может быть выбран оптимизатором
    Rows per value
    Rows per hash bucket
    Rows per AMP
    Rows per row partition
    Rows per row partition per AMP
    Rows per row partition per hash bucket
    Rows per row partition per value


--Запрос показывает неравномерность распределения таблицы. Отклонение должно быть менее 5%
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
 and lower(t1.databasename) = 'uat_ca'                  --имя схемы
-- and t1.tablekind = 't'
where 1=1
 and lower(a.databasename) = 'uat_ca'                   --имя схемы
 and lower(a.tablename) = 'mc_nps_hwe'                  --имя витрины
group by 1,2,3,4
;


--Запрос показывает распределение строк таблицы по AMP. Отклонение от среднего для минимального или максимального значения должно быть меньше 15%
select
 t1.amp_no,
 t1.row_cnt,
 ((t1.row_cnt/t2.row_avr_amp) - 1.0)*100 as deviation
from
(select
 hashamp(hashbucket(hashrow(subs_id))) as amp_no,       --primary index
 cast(count(*) as float) as row_cnt
from uat_ca.mc_nps_hwe                                  --имя схемы/витрины
group by 1
) as t1,
(select cast(count(*) as float)/(hashamp()+1) as row_avr_amp from uat_ca.mc_nps_hwe) as t2          --имя схемы/витрины
order by 2 desc
;


--dll витрины
show table uat_ca.mc_nps_hwe;
PRIMARY INDEX ( subs_id )
PARTITION BY RANGE_N(create_date  BETWEEN DATE '2020-01-09' AND DATE '2022-12-31' EACH INTERVAL '1' DAY );



--Запрос показывает количество конфликтов хэша строк для указанного индекса или столбца
/*ситуация, в которой значение rowhash для разных строк идентично, что затрудняет для системы
  различение хеш-синонимов, когда одна уникальная строка запрашивается для извлечения
  https://www.docs.teradata.com/r/w4DJnG9u9GdDlXzsTXyItA/XfRpR9T7fWZfF_1IZWuwRg
*/

select
 hashrow(subs_id) as row_hash,                      --primary index
 count(*) as row_cnt
from uat_ca.mc_nps_hwe
group by 1
order by 1
having row_cnt > 3
;



--==Выбор первичного индекса

--Распределение строк таблицы по AMP в текущей витрине
Sel HASHAMP(HASHBUCKET(HASHROW(subs_id))) AS AMP_NO,COUNT(*)
from uat_ca.mc_nps_hwe
group by 1
order by 2;


--Распределение строк таблицы по AMP в создаваемой витрине
в запросах создания/вставки данных в таблицы с использованием left, right, full join когда заранее сложно спрогнозировать уникальность значений первичного индекса,
для select запроса рекомендуется заранее посмотреть распределение при помощи функций  hashamp(hashbucket(hashrow(pi_candidate)))
например:

--Пример "большого" запроса
lock row for access
select hashamp(hashbucket(hashrow(a.msisdn, a.created_date))) as amp_no, count(*)
from (
select
 pr.created_date,                   -- Дата создания записи/Дата получения вопроса
 pr.replay_date,                    -- Дата получения ответа
 pr.current_communication_id,       -- Идентификатор рассылки                                                         - не уникальный в poll_reports (поскольку step), уникальный в current_communications
 cc.sub_list_id,                    -- Идентификатор списка абонентов опроса                                          - уникальный
 cc.short_number,                   -- Короткий номер, с которого проходит опрос
 cc.poll_id,                        -- Идентификатор опроса из таблицы POLLS (NPS Мобильный интернет, NPS_B2B и т.д.)
 cl.treatment_code,                 -- Идентификатор списка рассылки во внешней системе
 pr.msisdn,                         -- Мобильный номер абонента
 pr.q_step,                         -- Номер вопроса
 pc.content_id,                     -- Идентификатор записи
 pc.q_text_id,                      -- Идентификатор вопроса для отчетности
 pc.q_text,                         -- Формулировка вопроса
 pc.nps,                            -- Признак nps - 1. Не nps - 0
 pr.mark,                           -- Ответ абонента (оригинальный)
 pr.mark_text,                      -- Соответствие ответа
 cl.addition                        -- Дополнительные данные от клиента системы
from uat_ca.knime_poll_reports pr
--
left join uat_ca.knime_current_communications cc on pr.current_communication_id = cc.current_communication_id
--
left join uat_ca.knime_communication_lists cl on pr.msisdn = cl.msisdn
 and cc.sub_list_id = cl.sub_list_id
--Справочники
left join uat_ca.knime_dic_poll_contents pc on cc.poll_id = pc.poll_id
 and pr.q_step = pc.q_step
--
where 1=1
 and cc.poll_id in (8,9,2,3,14,11,1,22,23,309,310,311,312,313,52,53,417)
 and pr.created_date >= timestamp '2021-10-01 00:00:00'
 and pr.created_date < timestamp '2022-01-01 00:00:00'
) a
group by 1
order by 2 desc;

/*
Если какие-либо выборки с фильтрацией данных из таблицы не планируются (например, таблица используется в промежуточном слое, и данные из нее
всегда выбираются и вставляются полностью, после чего также полностью удаляются), то рекомендуется создавать такую таблицу без PRIMARY INDEX.
Для создания такой таблицы в DDL необходимо явно указать "NO PRIMARY INDEX". Если этого не сделать, а просто не указать PRIMARY INDEX, то в
качестве PRIMARY INDEX автоматически будет использован первый столбец создаваемой таблицы. В таблицах без PRIMARY INDEX (таблицах NoPI) данные
распределяются по AMP'ам случайным образом, что обеспечивает равномерность этого распределения. Соответственно, даже при записи одних и тех же
строк в таблицу распределение их по AMP'ам каждый раз будет новым (исключение - если данные вставляются из другой таблицы Teradata. Тогда они
будут распределены на те же AMP'ы, на которых они находятся в таблице-источнике).
*/



--Размер витрины и SkewFactor

--show view show_table_size;


--(100 - (Avg(s.CurrentPerm)/Max(s.CurrentPerm)*100)) as SkewFactor

select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('mc_nps_hwe')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          MC_NPS_HWE              MIKHAIL.CHUPIS      2021-07-05 05:04:22     2021-12-27 16:46:15     46,895          14,624
UAT_CA          MC_NPS_HWE              MIKHAIL.CHUPIS      2022-05-27 13:40:08     2022-07-04 15:46:21     0,441           9,114



--==Шаг 3 Актуальность витрин и глубина хранения данных

select top 100 * from prd2_tmd_v.bds_load_status where table_name='SUBS_CLR_D';       --Слой бизнес-данных EDW TERADATA
select top 100 * from prd2_tmd_v.dds_load_status where table_name='SUBSCRIPTION';       --Слой детальных данных EDW TERADATA

Слои:
ODW  - Operational Data Warehouse:   Слой «сырых данных». Содержит все загруженные данные из внешних источников
DDS  - Detail Data Store:            Слой детальных данных EDW TERADATA
BDS  - Business Data Store:          Слой бизнес-данных EDW TERADATA
RDS  - Reports Data Store:           Слой подготовленных отчетов EDW TERADATA
DIC  - Dictionary:                   Общие справочники EDW TERADATA
SEC  - Secure:                       Слой персональных данных EDW TERADATA

MDS  - Marts Data Store:             Слой подготовленных витрин EDW TERADATA (витрины для анализа со стороны Data Science и построения предиктивных моделей)
TMD  - Technical Metadata:           Метаданные EDW TERADATA (таблицы контрольного механизма, логирование)
HIST - History Data Store:           Слой исторических данных EDW TERADATA
DQS  - Data Quality Store:           Слой метрик качества данных EDW TERADATA
SVA  - SAS Visual Analytics:         Cлой подготовленных витрин для отображения в SAS VA TERADATA
SPSS - DM:                           Data Mining (База расчетов скорингов и моделей через SPSS Modeler)

***Отличия баз V от V2 в том, что View в V2 являются "прямыми" представлениями таблиц, а в V происходит дополнительное соединение со справочниками


select max_report_date from prd2_tmd_v.bds_load_status where table_name='SUBS_CLR_D';               --2022-07-02
select max_report_date from prd2_tmd_v.bds_load_status where table_name='SUBS_CHRG_D';              --2021-12-25
select max_report_date from prd2_tmd_v.bds_load_status where table_name='SUBS_USG_D';               --2021-12-25

select max_report_date from prd2_tmd_v.dds_load_status where table_name='SUBSCRIPTION';             --2022-07-02
select max_report_date from prd2_tmd_v.dds_load_status where table_name='PHONE_NUMBER_2';           --2021-12-26
select max_report_date from prd2_tmd_v.dds_load_status where table_name='SMSPOLL_DETAIL';           --2021-12-26

select max_report_date from prd2_tmd_v.dds_load_status where table_name='USAGE_CDR';                --2021-12-25
select max_report_date from prd2_tmd_v.dds_load_status where table_name='USAGE_GPRS';               --2021-12-25
select max_report_date from prd2_tmd_v.dds_load_status where table_name='USAGE_BILLING';            --2021-12-25
select max_report_date from prd2_tmd_v.dds_load_status where table_name='LOAD_DIGITAL_SUITE';       --2021-12-24



--Пример определение актуальности используя абонента
select max(report_date)
from PRD2_BDS_V2.SUBS_CLR_D
where 1=1
 and report_date between current_date-5 and current_date
 and subs_id=300017474518
 and branch_id=95
;



--==Глубина хранения данных в витринах

--Основные абонентские данные

show view prd2_dds_v.subscription;
prd2_dds.subscription        where report_date >=  timestamp'2022-01-11'
prd2_dds_hist.subscription   where report_date <   timestamp'2022-01-11'


prd2_dds_hist.subscription          report_date  date'2020-07-04' - date '2022-01-01'
prd2_dds.subscription               report_date  date'2022-01-02' - date'2022-07-02'

select date '2022-07-13' - interval '183' day;                                                      --2022-01-11

--2022-01-11
select min(report_date) from prd2_dds.subscription
where 1=1
 and report_date >= date '2022-01-05'
 and report_date < date '2022-01-15'
;

--Актуальность данных
select max_report_date from prd2_tmd_v.dds_load_status where table_name='SUBSCRIPTION';             --2022-07-02


--"Холодные" данные, глубина хранения (546 дней)
select date '2022-01-02' - interval '546' day;                                                      --2020-07-05


--prd2_dds_hist.subscription                               --2020-07-04
lock row for access
select min(report_date) from prd2_dds_hist.subscription
where 1=1
 and report_date >= date '2020-07-01'
 and report_date < date '2020-07-05'
;


--prd2_dds_hist.subscription                               --2021-01-01
lock row for access
select max(report_date) from prd2_dds_hist.subscription
where 1=1
 and report_date >= date '2021-12-25'
 and report_date < date '2022-01-02'
;


/*
show table prd2_dds.subscription;
PRIMARY INDEX (SUBS_ID)
PARTITION BY RANGE_N(REPORT_DATE  BETWEEN DATE '2021-11-20' AND DATE '2022-12-31' EACH INTERVAL '1' DAY )

show table prd2_dds_hist.subscription;
PRIMARY AMP INDEX ( SUBS_ID )
PARTITION BY ( COLUMN ADD 10,RANGE_N(REPORT_DATE  BETWEEN DATE '2015-01-01' AND DATE '2121-12-31' EACH INTERVAL '1' DAY ) )
*/


--=================================================================================================
--=================================================================================================
--=================================================================================================

Смотрим собираются ли статистики по данному полю:
help stats on prd2_dds.usage_billing;          собранные статистики на таблице
show statistics on prd2_dds.usage_billing;     скрипт сбора статистик по таблице

--=================================================================================================
--=================================================================================================
--=================================================================================================

--== Основные витрины

--1 Связка телефонного номера с SUBS_ID, свойства (историчность: интервал действия index: msisdn partition: no)
--show table PRD2_DDS.PHONE_NUMBER_2;

select * from PRD2_DDS_V.PHONE_NUMBER_2
where 1=1
 and msisdn = '79776991059';


--2 Витрина по клиентам (историчность: снимок на каждый день index: cust_id partition: report_date, branch_id)
--show table PRD2_BDS.CUST_CLR_D;

select * from PRD2_BDS_V.CUST_CLR_D
where 1=1
 and branch_id = 95
 and report_date = date '2020-07-28'
 and cust_id = 300018768796;


--3 Витрина по абонентам (историчность: снимок на каждый день index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_CLR_D;

select * from PRD2_BDS_V.SUBS_CLR_D
 where 1=1
   and branch_id = 95
   and report_date = date '2020-07-28'
   and subs_id = 300017474518;


--4 Значение баланса на конец дня (историчность: снимок на каждый день index: cust_id partition: report_date)
--show table PRD2_BDS.CUST_BAL_D;

select * from PRD2_BDS_V.CUST_BAL_D
where 1=1
 and branch_id = 95
 and report_date = date '2020-07-28'
 and cust_id = 300018768796;


--5 Агрегат по изменениям баланса (историчность: снимок на каждый день index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_BEV_D;

select * from PRD2_BDS_V.SUBS_BEV_D
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;

select top 100 * from PRD2_DDS_V.BALANCE_EVENT
where 1=1
 and cust_id = 300018768796;

select top 100 * from PRD2_DDS_V.BALANCE_HISTORY
where 1=1
 and cust_bal_id in ('300038240449')
 and edttm >= timestamp '2020-07-01 00:00:00';


--6 Агрегат по начислениям (историчность: снимок на каждый день index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_CHRG_D;

select * from PRD2_BDS_V.SUBS_CHRG_D
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;

--7 Состояние услуг на абоненте (историчность: снимок на каждый день index: subs_id partition: branch_id)
--show table PRD2_BDS.SUBS_SERV;

select * from PRD2_BDS_V.SUBS_SERV
where 1=1
 and branch_id = 95
 and subs_id = 300017474518;
;

--8 Состояние услуг на абоненте (историчность: снимок на каждый день)
--show table PRD2_DDS.SERVICE_INSTANCE;

select * from PRD2_BDS_V.SUBS_SERV_D
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;

select top 100 * from PRD2_DDS_V.SERVICE_INSTANCE
 where 1=1
 and subs_id = 300017474518
 and valid_to_date >= timestamp '2020-07-01 00:00:00'
;


--9 Агрегат по звонкам и соединениям (историчность: снимок на каждый день index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_USG_D;

select * from PRD2_BDS_V.SUBS_USG_D
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and report_date < date '2020-08-01'
 and subs_id = 300017474518;


--10 Агрегат по контентным номерам (историчность: снимок на каждый день index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_CONTENT_D_2;

select * from PRD2_BDS_V.SUBS_CONTENT_D_2
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;

--* c 04.06.2020 актуальные доработки ведутся только для  витрины PRD2_BDS.SUBS_CONTENT_D_2


--11 Витрина по смене тарифного плана (историчность: снимок на каждый день)

show view PRD2_BDS_V.SUBS_TP_CHANGE
select * from PRD2_BDS_V.SUBS_TP_CHANGE
where 1=1
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;



