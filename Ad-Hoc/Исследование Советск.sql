
diagnostic helpstats on for session;


--==Справочник по секторам для Советска

create multiset table uat_ca.mc_sector (
 rec_date date format 'yy/mm/dd',
 acell varchar(25) character set unicode not casespecific,
 location varchar(50) character set unicode not casespecific,
 master_site varchar(25) character set unicode not casespecific,
 vcell varchar(25) character set unicode not casespecific,
 band varchar(25) character set unicode not casespecific,
 ran_std varchar(5) character set unicode not casespecific
) primary index (vcell)
;

--delete uat_ca.mc_sector;

select * from uat_ca.mc_sector;


COLLECT STATISTICS COLUMN (VCELL) ON uat_ca.mc_sector;


--==
show table prd2_dds.usage_billing;
PRIMARY INDEX ( SUBS_ID )
PARTITION BY RANGE_N(START_DATE  BETWEEN DATE '2022-05-09' AND DATE '2022-12-31' EACH INTERVAL '1' DAY );

--=================================================================================================


REPLACE PROCEDURE uat_ca.adhoc_usage (in r_date date, in dt1 date, in dt2 date, in branch_id int)
SQL SECURITY INVOKER
BEGIN

-- объявление переменных
DECLARE dt date;
DECLARE proc varchar(50);
DECLARE LOAD_ID int;
DECLARE ERR_MSG VARCHAR(4000) DEFAULT '';
DECLARE ERR_SQLCODE INT;
DECLARE ERR_SQLSTATE INT;
DECLARE ROW_CNT INT;
DECLARE TOTAL_ROW_CNT INT;


-- Ошибка на этапе запуска SQL кода
DECLARE EXIT HANDLER FOR SqlException
BEGIN
SET ERR_SQLCODE = Cast(SqlCode AS INTEGER);
SET ERR_SQLSTATE = Cast(SqlState AS INTEGER);
SELECT ErrorText INTO :ERR_MSG FROM dbc.errormsgs WHERE Errorcode = :ERR_SQLCODE;
CALL uat_ca.prc_debug (:proc, :load_id, session, 0, 'An error occured during execution: ' || :ERR_MSG);
END;


SET dt = DT1;
SET proc = 'adhoc_usage';           -- наименование расчета
SET TOTAL_ROW_CNT = 0;

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;


-- логирование начала расчета данных
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START: ' || to_char(branch_id));



--==01 Выборка абонентов - Калининград (branch_id 22, region_id 25)

--show table subs;
--drop table subs;

create multiset volatile table subs ,no log (
 report_date date format 'yy/mm/dd',
 branch_id decimal(4,0),
 cust_id decimal(12,0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set unicode casespecific,
 tp_id decimal(12,0),
 tac varchar(8) character set unicode casespecific,
 sim_lte_flg decimal(1,0))
primary index ( subs_id )
on commit preserve rows;


insert into subs
select
 a.report_date,
 a.branch_id,
 a.cust_id,
 a.subs_id,
 a.msisdn,
 a.tp_id,
 a.tac,
--
 t1.is_lte as sim_lte_flg
from uat_ca.mc_base_db a
--
left join prd2_dds_v.subscription t1 on a.subs_id = t1.subs_id
 and t1.report_date = :r_date
-- and t1.report_date = date '2022-10-31'
where 1=1
 and a.report_date = :r_date
 and a.branch_id = :branch_id
-- and a.report_date = date '2022-10-31'
-- and a.branch_id = 22
;


--select top 100 * from subs;


--==
COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (SIM_LTE_FLG)
ON subs;



--==02 Usage GPRS

--show table subs_usage;
--drop table subs_usage;

create multiset volatile table subs_usage ,no log (
 edw_usage varchar(10) character set unicode not casespecific,
 branch_id decimal(4,0),
 cust_id decimal(12,0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set unicode casespecific,
 call_id decimal(15,0),
 call_tp_id decimal(12,0),
 start_dttm timestamp(0),
 ne_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 cause4term varchar(5) character set latin not casespecific,
 rating_group_id decimal(11,0),
 ip_address varchar(20) character set latin not casespecific,
 apn_id varchar(64) character set latin not casespecific,
 duration decimal(9,0),
 in_volume decimal(18,0),
 out_volume decimal(18,0),
 all_volume decimal(18,0),
 rated_amount decimal(16,4),
 charge_amount decimal(16,4),
 discount_amount decimal(16,6),
 usage_type_id decimal(2,0),
 call_type_id decimal(4,0),
 cost_band_id decimal(12,0),
 roaming_type_id decimal(15,0),
 tech_roaming_type_id decimal(15,0),
 service_generation_code varchar(32) character set unicode casespecific,
 imsi varchar(20) character set latin not casespecific,
 imei varchar(20) character set latin not casespecific)
primary index ( subs_id )
on commit preserve rows;



BT;

-- цикл по датам
WHILE (dt < DT2) DO


insert into subs_usage
select
 'usage_gprs' as edw_usage,
--
 t1.branch_id,
 t1.cust_id,
 t1.subs_id,
 t1.msisdn,
--
 a.call_id,
 a.call_tp_id,
 cast(start_date as timestamp(0)) + ((start_time - time '00:00:00') hour to second(0)) as start_dttm,
 a.ne_id,
 t2.sector_name,
 a.cause4term,
 a.rating_group_id,
 a.ip_address,
 a.apn_id,
 a.duration,
 a.in_volume,
 a.out_volume,
 a.in_volume + a.out_volume as all_volume,
 cast(0 as decimal(16, 4)) as rated_amount,
 cast(0 as decimal(16, 4)) as charge_amount,
 cast(0 as decimal(16, 6)) as discount_amount,
 cast(1 as decimal(2, 0)) as usage_type_id,
 cast(-1001 as decimal(4, 0)) as call_type_id,
 a.cost_band_id,
 cast(null as decimal(15, 0)) as roaming_type_id,
 cast(null as decimal(15, 0)) as tech_roaming_type_id,
 t2.stechnology as service_generation_code,
 a.imsi,
 a.imei
from prd2_dds_v2.usage_gprs a
--
inner join subs t1 on a.subs_id = t1.subs_id
 and t1.sim_lte_flg = 1
--
left join prd2_dic_v.network_element t2 on a.ne_id = t2.ne_id
--
inner join uat_ca.mc_sector t3 on t2.sector_name = t3.vcell
--
where 1=1
 and a.start_date >= dt
 and a.start_date < dt + interval '1' day
-- and a.start_date >= date '2022-08-29'
-- and a.start_date < date '2022-08-30'
;


--==03 Usage Bulling

insert into subs_usage
select
 'usage_billing' as edw_usage,
--
 t1.branch_id,
 t1.cust_id,
 t1.subs_id,
 t1.msisdn,
--
 a.call_id,
 a.call_tp_id,
 a.start_dttm,
 a.ne_id,
 t2.sector_name,
 a.cause4term,
 a.rating_group_id,
 a.ip_address,
 a.apn_id,
 a.duration,
 a.in_volume,
 a.out_volume,
 a.in_volume + a.out_volume as all_volume,
 a.rated_amount,
 a.charge_amount,
 a.discount_amount,
 a.usage_type_id,
 a.call_type_id,
 a.cost_band_id,
 a.roaming_type_id,
 a.tech_roaming_type_id,
 t2.stechnology as service_generation_code,
 a.imsi,
 a.imei
from prd2_dds_v2.usage_billing a
--
inner join subs t1 on a.subs_id = t1.subs_id
 and t1.sim_lte_flg = 1
--
left join prd2_dic_v.network_element t2 on a.ne_id = t2.ne_id
--
inner join uat_ca.mc_sector t3 on t2.sector_name = t3.vcell
--
where 1=1
 and a.start_date >= dt
 and a.start_date < dt + interval '1' day
-- and a.start_date >= date '2022-08-29'
-- and a.start_date < date '2022-08-30'
 and a.traffic_type_id = 4
;


-- Увеличиваем дату dt
SET dt = dt + INTERVAL '1' DAY;
get diagnostics ROW_CNT = row_count;


SET TOTAL_ROW_CNT = TOTAL_ROW_CNT + ROW_CNT;
END WHILE;

ET;


--==04 Справочник CPE

--show table subs_cpe;
--drop table subs_cpe;

create multiset volatile table subs_cpe ,no log (
  imei varchar(20) character set latin not casespecific,
  usg_tac varchar(8) character set latin not casespecific,
  vendor_name varchar(100) character set unicode not casespecific,
  model_name varchar(100) character set unicode not casespecific,
  multisim byteint,
  esim byteint,
  device_type varchar(50) character set unicode not casespecific,
  os_group varchar(30) character set unicode not casespecific,
  gen_3g byteint,
  gen_4g byteint,
  lte_fdd_450 byteint,
  lte_fdd_800 byteint,
  lte_fdd_1800 byteint,
  lte_fdd_2100 byteint,
  lte_tdd_2300 byteint,
  lte_fdd_2600 byteint,
  lte_tdd_2600 byteint)
primary index ( imei )
on commit preserve rows;


insert into subs_cpe
select
 distinct
 a.imei,
 substr(a.imei,1,8) as usg_tac,
--
 t1.cpe_manufacturer_name as vendor_name,
 t1.cpe_model_name as model_name,
 case when coalesce(t1.sim_count,0) > 1 then 1 else 0 end as multisim,
 case when coalesce(t1.esim,0) > 1 then 1 else 0 end as esim,
 t1.cpe_type_name as device_type,
 t1.os_group_name as os_group,
 
 case when (coalesce(t1.g_3,0) + coalesce(t1.g_3_900,0) + coalesce(t1.g_3_2100,0) ) > 1 then 1 else 0 end as gen_3g,
 case when (coalesce(t1.g_4,0) + coalesce(t1.lte_fdd_450,0) + coalesce(t1.lte_fdd_800,0) + coalesce(t1.lte_fdd_1800,0) +
            coalesce(t1.lte_fdd_2100,0) + coalesce(t1.lte_fdd_2600,0) + coalesce(t1.lte_tdd_2300,0) +
            coalesce(t1.lte_tdd_2600,0) ) > 1 then 1 else 0 end as gen_4g,
 coalesce(t1.lte_fdd_450,0) as lte_fdd_450,
 coalesce(t1.lte_fdd_800,0) as lte_fdd_800,
 coalesce(t1.lte_fdd_1800,0) as lte_fdd_1800,
 coalesce(t1.lte_fdd_2100,0) as lte_fdd_2100,
 coalesce(t1.lte_tdd_2300,0) as lte_tdd_2300,
 coalesce(t1.lte_fdd_2600,0) as lte_fdd_2600,
 coalesce(t1.lte_tdd_2600,0) as lte_tdd_2600
from subs_usage a
--
inner join prd2_dic_v.cpe_model t1 on usg_tac = t1.tac
;


--select top 100 * from subs_cpe;
--select device_type, count(*) from subs_cpe where gen_4g = 1 group by 1;


--==
COLLECT STATISTICS
 COLUMN (IMEI)
ON subs_usage;

COLLECT STATISTICS
 COLUMN (GEN_4G),
 COLUMN (IMEI),
 COLUMN (DEVICE_TYPE)
ON subs_cpe;



--==05 Вставка на схему

insert into uat_ca.mc_sector_adhoc
select
 a.edw_usage,
 cast(a.start_dttm as date) as report_date,
 a.branch_id,
 a.cust_id,
 a.subs_id,
 a.msisdn,
 a.call_id,
 a.call_tp_id,
 a.start_dttm,
 a.ne_id,
 a.sector_name,
 a.cause4term,
 a.rating_group_id,
 a.ip_address,
 a.apn_id,
 a.duration,
 a.in_volume,
 a.out_volume,
 a.all_volume,
 a.rated_amount,
 a.charge_amount,
 a.discount_amount,
 a.usage_type_id,
 a.call_type_id,
 a.cost_band_id,
 a.roaming_type_id,
 a.tech_roaming_type_id,
 a.service_generation_code,
 a.imsi,
 a.imei,
--
 t1.usg_tac as tac,
 t1.vendor_name,
 t1.model_name,
 t1.multisim,
 t1.esim,
 t1.os_group,
 t1.lte_fdd_450,
 t1.lte_fdd_800,
 t1.lte_fdd_1800,
 t1.lte_fdd_2100,
 t1.lte_tdd_2300,
 t1.lte_fdd_2600,
 t1.lte_tdd_2600
from subs_usage a
--
inner join subs_cpe t1 on a.imei = t1.imei
 and t1.gen_4g = 1
 and t1.device_type = 'SMARTPHONE'
;


-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Всего транзакций: '|| to_char(branch_id) || ' - ' ||trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


drop table subs;
drop table subs_usage;
drop table subs_cpe;


-- логирование окончания расчета данных
CALL uat_ca.prc_debug (proc,:load_id,session,1,'END: ' || to_char(branch_id));

END;



select top 100 * from uat_ca.mc_sector_adhoc;
select count(*) from uat_ca.mc_sector_adhoc;        --18 687 741


--delete uat_ca.mc_sector_adhoc;

--==
/*
1. 29.08 - 11.09
2. 10.10 - 23.10
3. 01.11 - 06.11
*/

call uat_ca.adhoc_usage (date '2022-10-31', date '2022-08-29', date '2022-09-11', 22);      --4 мин. 21 сек.
call uat_ca.adhoc_usage (date '2022-10-31', date '2022-10-10', date '2022-10-23', 22);
call uat_ca.adhoc_usage (date '2022-10-31', date '2022-11-01', date '2022-11-06', 22);


-- Для просмотра рассчитанных дней в момент работы процедуры, либо по ее завершению используйте запрос по таблице логов:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'adhoc_usage'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


--=================================================================================================

--== Объем/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('mc_sector_adhoc')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          MC_SECTOR_ADHOC         MIKHAIL.CHUPIS      2022-11-09 13:45:57     2022-11-09 14:17:17     1,21            3,357


--=================================================================================================
--=================================================================================================
--=================================================================================================

show table uat_ca.mc_sector_adhoc;
--drop table uat_ca.mc_sector_adhoc;

create multiset table uat_ca.mc_sector_adhoc (
  edw_usage varchar(10) character set unicode not casespecific,
  report_date date format 'yy/mm/dd',
  branch_id decimal(4,0),
  cust_id decimal(12,0),
  subs_id decimal(12,0),
  msisdn varchar(20) character set unicode casespecific,
  call_id decimal(15,0),
  call_tp_id decimal(12,0),
  start_dttm timestamp(0),
  ne_id decimal(12,0),
  sector_name varchar(25) character set unicode not casespecific,
  cause4term varchar(5) character set latin not casespecific,
  rating_group_id decimal(11,0),
  ip_address varchar(20) character set latin not casespecific,
  apn_id varchar(64) character set latin not casespecific,
  duration decimal(9,0),
  in_volume decimal(18,0),
  out_volume decimal(18,0),
  all_volume decimal(18,0),
  rated_amount decimal(16,4),
  charge_amount decimal(16,4),
  discount_amount decimal(16,6),
  usage_type_id decimal(2,0),
  call_type_id decimal(4,0),
  cost_band_id decimal(12,0),
  roaming_type_id decimal(15,0),
  tech_roaming_type_id decimal(15,0),
  service_generation_code varchar(32) character set unicode casespecific,
  imsi varchar(20) character set latin not casespecific,
  imei varchar(20) character set latin not casespecific,
  tac varchar(8) character set latin not casespecific,
  vendor_name varchar(100) character set unicode not casespecific,
  model_name varchar(100) character set unicode not casespecific,
  multisim byteint,
  esim byteint,
  os_group varchar(30) character set unicode not casespecific,
  lte_fdd_450 byteint,
  lte_fdd_800 byteint,
  lte_fdd_1800 byteint,
  lte_fdd_2100 byteint,
  lte_tdd_2300 byteint,
  lte_fdd_2600 byteint,
  lte_tdd_2600 byteint)
primary index ( call_id )
index ( subs_id );


--==
/*
1. 29.08 - 11.09
2. 10.10 - 23.10
3. 01.11 - 06.11
*/

select a.traffic_type_id, count(*) from prd2_dds_v2.usage_billing a
inner join subs t1 on a.subs_id = t1.subs_id
where 1=1
 and a.start_date >= date '2022-08-29'
 and a.start_date < date '2022-09-11'
group by 1
;


