
--Шаг 1. Временная таблица, для справочника
--drop table analysts.uat_ca_vf_dic_acell
CREATE TABLE analysts.uat_ca_vf_dic_acell
                   
(report_date  string,
 acell string,
 macroregion string,
 region string,
 sector_name string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ";"
TBLPROPERTIES("skip.header.line.count"="1"); 
--
select * from analysts.uat_ca_vf_dic_acell;
--
--Шаг 1.2 загрузка из csv в таблицу
LOAD DATA INPATH '/user/hive/warehouse/analysts.db/table_import/NN_2022_dic.csv'  INTO TABLE analysts.uat_ca_vf_dic_acell;

--Шаг 1.3 Формирование постоянной таблицы
--drop table analysts.uat_ca_vf_acell_dic_NN
CREATE TABLE analysts.uat_ca_vf_acell_dic_NN
(
 report_date  date,
 acell VARCHAR(25) ,
 macroregion VARCHAR(50),
 region VARCHAR(50) ,
 ector_name VARCHAR(25)
)
stored as orc; 
--
select * from analysts.uat_ca_vf_acell_dic_NN;

--Шаг 1.4 Вставка данных в постоянную таблицу(Справочник)
INSERT INTO analysts.uat_ca_vf_acell_dic_NN
SELECT
  cast(report_date as date),
  cast(acell as VARCHAR(25)) ,
  cast(macroregion as VARCHAR(50)),
  cast(region as VARCHAR(50)) ,
  cast(sector_name as VARCHAR(25))
from analysts.uat_ca_vf_dic_acell;
--
select count(*) from analysts.uat_ca_vf_acell_dic_NN
select * from analysts.uat_ca_vf_acell_dic_NN limit 50
-------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------
--- Мапп с ne_id

SELECT t1.report_date
     , t1.macroregion 
     , t1.region 
     , t1.acell 
     , t1.ector_name as sector_name
     , t2.ne_id
     , t2.edw_sdate
     , t2.edw_edate
 FROM analysts.uat_ca_vf_acell_dic_nn  t1 
INNER JOIN (
            select ne_id
                 , sector_name
                 , edw_sdate
                 , edw_edate
                 , row_number() over (partition by sector_name order by edw_sdate desc) as row_filt
              FROM prd2_dic_v.network_element
             where 1=1
               and mastersite is not null
               and district_name is not null
            )t2 on t1.ector_name = t2.sector_name and row_filt = 1 
where 1=1


and to_date(trunc(t2.edw_sdate, 'MM')) < t1.report_date 
and to_date(trunc(t2.edw_edate, 'MM')) > t1.report_date



---------------------------------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Шаг 2. Временная таблица, для флагов региона
--drop table analysts.uat_ca_vf_flg_acell
CREATE TABLE analysts.uat_ca_vf_flg_acell
                   
(     rec_dttm string,
      acell string,
      region string,
      pi_share string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ","
TBLPROPERTIES("skip.header.line.count"="1"); 

--Шаг 2.2 загрузка из csv в таблицу
LOAD DATA INPATH '/user/hive/warehouse/analysts.db/table_import/nn_flg.csv'  INTO TABLE analysts.uat_ca_vf_flg_acell;
---
select * from analysts.uat_ca_vf_flg_acell
select count(*) from analysts.uat_ca_vf_flg_acell
-----------------------------------------------------

--Шаг 2.3 Формирование постоянной таблицы
--drop table analysts.uat_ca_vf_acell_flg_nn
CREATE TABLE analysts.uat_ca_vf_acell_flg_nn
(     rec_dttm TIMESTAMP,
      region VARCHAR(50),
      acell VARCHAR(25),
      pi_share decimal(16,0),
      pi_flg decimal(16,0)
)
stored as orc; 


--Шаг 2.4 Вставка данных в постоянную таблицу
INSERT INTO analysts.uat_ca_vf_acell_flg_nn
SELECT
  cast(cast(rec_dttm as varchar(13))||':00:00' as timestamp),
  cast(region as VARCHAR(50)) ,
  cast(acell as VARCHAR(25)) ,
  cast(pi_share as decimal(16,0)),
  case when pi_share > 0 then 1
       else 0
   end as pi_flg
  from analysts.uat_ca_vf_flg_acell;

-----------------------------------------------------------------------------------------------------------------------------------------
select * from analysts.uat_ca_vf_acell_flg_nn 
select * from analysts.uat_ca_vf_acell_dic_NN
select * from analysts.uat_ca_vf_acell_all_nn
-------------------------------------------------------------------------------------------------------------------------------------------

-----------
--Шаг 3. Объедененная таблица (фрейм через питон)
--drop table analysts.uat_ca_vf_acell_all_nn
CREATE TABLE analysts.uat_ca_vf_acell_all_nn
                   
(     rec_dttm string,
      acell string,
      region string,
      pi_share string,
      reg_date string,
      sector_name string,
      ne_id string
)

ROW FORMAT DELIMITED FIELDS TERMINATED BY ","
TBLPROPERTIES("skip.header.line.count"="1"); 

--Шаг 3.2 загрузка из csv в таблицу
LOAD DATA INPATH '/user/hive/warehouse/analysts.db/table_import/full.csv'  INTO TABLE analysts.uat_ca_vf_acell_all_nn;
---
select * from analysts.uat_ca_vf_acell_all_nn where LIMIT 100
select count(*) from analysts.uat_ca_vf_acell_all_nn
-----------------------------------------------------

--Шаг 3.3 Формирование постоянной таблицы(удалитъ версию один)
--drop table analysts.uat_ca_vf_acell_all_fl_nn_2
CREATE TABLE analysts.uat_ca_vf_acell_all_fl_nn_2
(     rec_dttm TIMESTAMP,
      acell VARCHAR(25),
      region VARCHAR(50),
      pi_share decimal(16,0),
      reg_date date,
      sector_name VARCHAR(25),
      ne_id decimal(22,0),
      pi_flg decimal(2,0)
)
stored as orc; 


--Шаг 3.4 Вставка данных в постоянную таблицу
INSERT INTO analysts.uat_ca_vf_acell_all_fl_nn_2
SELECT
  cast(cast(rec_dttm as varchar(13))||':00:00' as timestamp) as rec_dttm,
  cast(acell as VARCHAR(25)) ,
  cast(region as VARCHAR(50)) ,
  cast(pi_share as decimal(16,0)),
  cast(reg_date as date),
  cast(sector_name as VARCHAR(25)),
  cast(ne_id as decimal(22,0)),
  case when pi_share > 0 then 1
       else 0
   end as pi_flg
  from analysts.uat_ca_vf_acell_all_nn
--LIMIT 100

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
select * from analysts.uat_ca_vf_acell_all_fl_nn where pi_flg is null and reg_date ='2022-08-01' LIMIT 100
select count(*) from analysts.uat_ca_vf_acell_all_fl_nn
---------------------------------------------------------- 
----тест
select 
ne_id, 
rec_dttm, 
count(distinct(sector_name)) as n_sectors 
from analysts.uat_ca_vf_acell_all_fl_nn_2
group by ne_id, rec_dttm 
having n_sectors > 1;
---------------------------------------------------------------------------------------------------------------------------------

 
 
 
 
 --пример партиций 
-------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--drop table analysts.uat_ca_vf_acell_all_nn
CREATE TABLE analysts.uat_ca_vf_acell_all_nn
                   
(     rec_dttm TIMESTAMP,
      reg_date date,
      region VARCHAR(50),
      acell VARCHAR(25),
      sector_name VARCHAR(25),
      pi_share decimal(16,0),
      pi_flg decimal(16,0)
)
--partitioned by (reg_date smallint, month_id tinyint)
stored as orc;
-----------------------
insert into analysts.fct_mail_kqi_week_v2_orc
partition(year_id, month_id) -- поле должно быть последним в select
select ....
------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

  
  


--Попытки сформироватъ датафрейм
-----------------------------------------------------------------
CREATE TABLE analysts.uat_ca_vf_acell_fin
--drop table analysts.uat_ca_vf_acell_fin                 
(     rec_dttm TIMESTAMP,
      reg_date date,
      region VARCHAR(50),
      acell VARCHAR(25),
      sector_name VARCHAR(25),
      ne_id VARCHAR(25),
      pi_flg decimal(16,0), 
      start_time_r TIMESTAMP,
      hours decimal(16,0),
      events decimal(16,0)
)
--partitioned by (reg_date smallint, month_id tinyint)
stored as orc;
------------------------------------------------------

--подход 1
select t1.reg_date
     , t1.rec_dttm
     , t1.region 
     , t1.acell 
     , t1.sector_name 
     , t1.ne_id
  -- , t1.pi_share 
     , t1.pi_flg
     , count(distinct subs_id) as hours 
     , count(subs_id) as events
  from analysts.uat_ca_vf_acell_all_fl_nn t1 
 inner join (select cast(cast(start_time as varchar(13))||':00:00' as timestamp) as start_time_r
                 ,  start_time
                 ,  ne_id
                 ,  subs_id
              from  gprs.usage_gprs
             where 1=1
               and udt >= '2022-02-01' and udt < '2022-03-01' 
           ) t2 on t1.ne_id = t2.ne_id
               and t1.rec_dttm  = t2.start_time_r
 where 1=1
   and t1.reg_date = '2022-02-01'
 group by t1.reg_date, t1.rec_dttm, t1.region, t1.acell, t1.sector_name, t1.ne_id, t1.pi_flg
 -------------------------------------------

--подход 2

with t1 as ( 
select *
  from analysts.uat_ca_vf_acell_all_fl_nn 
 where reg_date = '2022-02-01'
), t2  as (select ne_id
     from t1 group by ne_id), t3 as(   
select  a.start_time
,  a.ne_id
,  a.subs_id
,  cast(cast(a.start_time as varchar(13))||':00:00' as timestamp) as start_time_r
from  gprs.usage_gprs a join t2 on  a.ne_id=t2.ne_id
where 1=1
and udt >= '2022-02-01' and udt < '2022-03-01' )

select t1.reg_date
     , t1.rec_dttm
     , t1.region 
     , t1.acell 
     , t1.sector_name 
     , t1.ne_id
  -- , t1.pi_share 
     , t1.pi_flg
     , t3.start_time_r
     , count(t3.subs_id) as hours 
     , count(distinct t3.subs_id) as events
     from t1 inner join t3 on t3.start_time_r = t1.rec_dttm
                          and t1.ne_id = t3.ne_id
     group by t1.reg_date
     , t1.rec_dttm
     , t1.region 
     , t1.acell 
     , t1.sector_name 
     , t1.ne_id
  -- , t1.pi_share 
     , t1.pi_flg
     , t3.start_time_r
     
     
--хз 
-----------------------------------------------------------------------------------------------------------------------------------------------
SELECT t1.report_date
     , t3.rec_dttm
     , t1.macroregion 
     , t1.region 
     , t1.acell 
     , t1.ector_name as sector_name
     , t2.ne_id
     , t3.pi_share 
     , t3.pi_flg
 FROM analysts.uat_ca_vf_acell_dic_nn  t1 
INNER JOIN (
            select ne_id
                 , sector_name
                 , row_number() over (partition by sector_name order by edw_sdate desc) as row_filt
              FROM prd2_dic_v.network_element
             where 1=1
               and mastersite is not null
               and district_name is not null
            )t2 on t1.ector_name = t2.sector_name and row_filt = 1
INNER JOIN analysts.uat_ca_vf_acell_fl2_nn t3 on t1.acell = t3.acell
  						  		             and trunc(t3.rec_dttm,'MM') = t1.report_date            
where 1=1;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 
