diagnostic helpstats on for session;

--PS для Тулы--

  -----------------------------------------------------------------
  --таблица с флагом Аcела 
  -----------------------------------------------------------------
 
  --drop table abnt
 create multiset volatile table abnt ,no log (

 acell varchar(50) character set unicode not casespecific,
 mastersite varchar(30) character set unicode not casespecific,
 sector_name varchar(25) character set unicode not casespecific
)
no primary index 
on commit preserve rows
;
select * from abnt
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
------------------------------------------------
--создаем справочник - маппинг асел - всел 

select top 100 * from uat_ca.fv_tula_acell;
------------------------------------------------
-- drop table uat_ca.fv_tula_acell
  create multiset table uat_ca.fv_tula_acell  as(
  select t1.acell
	   , t1.mastersite
	   , t1.sector_name
	   , t2.ne_id
	   , t2.bs_name
	   , t2.standart
	   , t2.stechnology
	   , t2.edw_sdate
	   , t2.edw_edate
	   , t2.comments
	 
    from abnt t1  
   inner join prd2_dic_v.network_element t2 on t1.sector_name = t2.sector_name
 qualify row_number() over(partition by t1.sector_name order by t2.edw_sdate desc) =1 

)
	with data 
 primary index (sector_name);

--------------------------------------------------------------------------------------
---exam
 select top 100 *
 from prd2_dic_v.network_element where ne_id = 15101021731


 
 
--------------------------------------------------------------------------------------
  select t1.acell
	   , t1.mastersite
	   , t1.sector_name
	   , t2.bs_name
	   , t2.standart
	   , t2.stechnology
	   , t2.edw_sdate
	   , t2.edw_edate
	   , t2.comments
	   , row_number() over(partition by t1.sector_name order by t2.edw_sdate desc) ro
    from abnt t1  
   inner join prd2_dic_v.network_element t2 on t1.sector_name = t2.sector_name
--------------------------------------------------------------------------------------
--Подгружаем флаги асела
--------------------------------------------------------------------------------------
 
   
create multiset volatile table acell_flg ,no log (
	RECDATE varchar(30) character set unicode not casespecific,
	acell VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
	macroregion varchar(30) character set unicode not casespecific,
	rcode2 varchar(30) character set unicode not casespecific,
	region varchar(30) character set unicode not casespecific,
	flag_psi varchar(30) character set unicode not casespecific
)
primary index (acell)
on commit preserve rows
;


--drop table acell_flg
--delete acell_flg

sel top 100 * from acell_flg;

select * from acell_flg where flag_psi > 0;

select * from (
select
 cast(cast(recdate as varchar(13))||':00:00' as timestamp(0)) as recdate,
 acell,
 flag_psi
from acell_flg
where 1=1
 and acell = 'TL000509_O'
) a
where 1=1
 and recdate >= timestamp '2022-06-18 00:00:00'
 and recdate < timestamp '2022-06-19 00:00:00'
;

select * from uat_ca.fv_tula_acell where acell = 'TL000509_O';


-------------------------------------------------   
--Создаем волатилку со всеми флагами по часам
-------------------------------------------------
--select top 100 * from uat_ca.fv_tula_acell

select top 100 * from acell_vcell_flg

--drop table acell_vcell_flg
create multiset volatile table acell_vcell_flg , no log as (

select cast(cast(t1.recdate as varchar(13))||':00:00' as timestamp(0)) as recdate
     , t1.acell
     , t1.macroregion
     , t1.rcode2
	 , t1.region
	 , t1.flag_psi
	 , t2.ne_id
	 , t2.mastersite
	 , t2.sector_name
	 , t2.bs_name
	 , t2.standart
	 , t2.stechnology
	 
  from acell_flg t1 
 inner join uat_ca.fv_tula_acell t2 on t1.acell = t2.acell
 
)
with data
primary index (sector_name)
on commit preserve rows;


select distinct ne_id from acell_vcell_flg;


------------------------------------------------------------------------
--Таблица с абонентами Тулы хадуп
-----------------------------------------------------------------------

--select top 100 * 
--from uat_ca.sample_26_hadoop
--drop table nps_tula

create multiset volatile table nps_tula , no log as (
select subs_id
     , cast(cast(start_dttm as varchar(13))||':00:00' as timestamp(0)) as start_dttm
     , rating_group_id
     , apn_id
     , duration
     , in_volume
     , out_volume 
     , ne_id
     , cause4term
     , sgsn_ip
     , udt
     , branch_id
     , create_date
     , msisdn      
  from uat_ca.sample_26_hadoop t1 
  where 1=1
   and branch_id = 26
 )
with data
primary index (subs_id)
on commit preserve rows;

select top 100 * from nps_tula;

select count(distinct subs_id) from nps_tula;


-----------------------------------------------------------------
-- витрина subs+flag
-----------------------------------------------------------------
sel top 100 * from 
--uat_ca.fv_psi_tula
acell_vcell_flg

--drop table sum_flg 
create multiset table uat_ca.fv_psi_tula  as(
select t1.subs_id
     , t1.start_dttm
     , t1.rating_group_id
     , t1.apn_id
     , t1.duration
     , t1.in_volume
     , t1.out_volume 
     , t1.ne_id
     , t1.cause4term
     , t1.sgsn_ip
     , t1.udt
     , t1.branch_id
     , t1.create_date
     , t1.msisdn 
     --, t2.recdate
     , t2.acell
     , t2.macroregion
     --, t2.rcode2
    -- , t2.region
     , t2.flag_psi
    -- , t2.NE_ID
     , t2.mastersite
     , t2.sector_name
     , t2.BS_NAME
     , t2.STANDART
     , t2.STECHNOLOGY 
        
  from nps_tula t1
 inner join acell_vcell_flg t2 on t1.ne_id= t2.ne_id and t1.start_dttm = t2.recdate  ---данные уже отфильтрованы(дата к дате)
 )
with data 
 primary index (subs_id);


--drop table fv_psi_tula;

create multiset volatile table fv_psi_tula, no log as (
select t1.subs_id
     , t1.start_dttm
     , t1.rating_group_id
     , t1.apn_id
     , t1.duration
     , t1.in_volume
     , t1.out_volume 
     , t1.ne_id
     , t1.cause4term
     , t1.sgsn_ip
     , t1.udt
     , t1.branch_id
     , t1.create_date
     , t1.msisdn 
     --, t2.recdate
     , t2.acell
     , t2.macroregion
     --, t2.rcode2
    -- , t2.region
     , t2.flag_psi
    -- , t2.NE_ID
     , t2.mastersite
     , t2.sector_name
     , t2.BS_NAME
     , t2.STANDART
     , t2.STECHNOLOGY 
        
  from nps_tula t1
 inner join acell_vcell_flg t2 on t1.ne_id= t2.ne_id and t1.start_dttm = t2.recdate
 )
with data 
 primary index (subs_id)
 on commit preserve rows
;


select top 100 * from fv_psi_tula;
select * from fv_psi_tula where flag_psi > 0 and stechnology = '4G';

select *
from fv_psi_tula
where 1=1
 and start_dttm >= timestamp '2022-06-29 22:00:00'
 and start_dttm < timestamp '2022-06-29 23:00:00'
 and acell = 'TL000093_C'
;

select * from (
select
 cast(cast(recdate as varchar(13))||':00:00' as timestamp(0)) as recdate,
 acell,
 flag_psi
from acell_flg
where 1=1
 and acell = 'TL000093_C'
) a
where 1=1
 and recdate >= timestamp '2022-06-29 22:00:00'
 and recdate < timestamp '2022-06-29 23:00:00'
;

select * from uat_ca.fv_tula_acell where acell = 'TL000093_C' and stechnology = '4G';

select *
from fv_psi_tula
where 1=1
 and start_dttm >= timestamp '2022-06-29 22:00:00'
 and start_dttm < timestamp '2022-06-29 23:00:00'
 and sector_name in (
 'TL0093_023',
 'TL0093_016',
 'TL0093_033',
 'TL0093_036',
 'TL0093_083',
 'TL0093_013'
)
;

select * from fv_psi_tula
where 1=1
 and msisdn = '79520185271'
 and start_dttm >= timestamp '2022-06-29 22:00:00'
 and start_dttm < timestamp '2022-06-29 23:00:00'
;



select 
 a.*,
 t1.sector_name
from uat_ca.sample_26_hadoop a
left join prd2_dic_v.network_element t1 on a.ne_id = t1.ne_id
where 1=1
 and a.msisdn = '79520185271'
 and a.start_dttm >= timestamp '2022-06-29 22:00:00'
 and a.start_dttm < timestamp '2022-06-29 23:00:00'


--Пример абонента
select
 a.*,
 t1.sector_name,
 t1.stechnology
from uat_ca.sample_26_hadoop a
left join prd2_dic_v.network_element t1 on a.ne_id = t1.ne_id
 and start_dttm between t1.edw_sdate and t1.edw_edate
where 1=1
 and a.msisdn = '79520185271'
 and a.start_dttm >= timestamp '2022-06-29 22:00:00'
 and a.start_dttm < timestamp '2022-06-29 23:00:00'
;

select
 t1.create_date,
 t1.subs_id,
 a.amount
from prd2_bds_v.cust_bal_d a
--
inner join (
select
 a.create_date,
 a.cust_id,
 a.subs_id,
 a.branch_id
from uat_ca.mc_nps_tg a
inner join tele2_uat.mc_gprs_25_2022_tg t1 on a.subs_id = t1.subs_id
 and a.create_date = t1.report_date
where 1=1
-- and a.create_date = date '2022-04-07'
 and a.create_date = :rdate
) t1 on a.cust_id = t1.cust_id
 and a.branch_id = t1.branch_id
--
where 1=1
-- and a.report_date = date '2022-04-07'
 and a.report_date = :rdate
 and a.bal_type_id = 1
;








select top 100 * from uat_ca.v_nps_bu
select top 100 * from uat_ca.fv_psi_tula


select t1.subs_id
     , t1.start_dttm
  -- , t1.rating_group_id
     , t1.apn_id
     , t1.ne_id
     , t1.cause4term
 --  , t1.sgsn_ip
     , t1.udt
     , t1.branch_id
     , t1.create_date
     , t1.msisdn 
     , t1.acell
     , t1.macroregion
     , t1.mastersite
     , t1.flag_psi
     , t1.sector_name
     , t1.BS_NAME
     , t1.STANDART
     , t1.STECHNOLOGY   
     , t2.ltr
     , t2.nps
     , t2.ans_1
     , t2.point_name
     , t2.create_date
     , sum(t1.duration)
     , sum(t1.in_volume)
     , sum(t1.out_volume) 
  from uat_ca.fv_psi_tula t1 
 inner join uat_ca.v_nps_bu t2 on t1.subs_id = t2.subs_id and trunc(t2.create_date, 'rm') = '2022-07-01' 
 group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
 
 
 
 
 
 
 
 
select branch_id, trunc(report_date, 'rm'), count(*) from uat_ca.tl_hadoop group by 1,2;

select top 100 *  from uat_ca.tl_hadoop;

select top 100 *  from uat_ca.v_nps_bu



select t1.*, t2.age, t2.gender, t2.create_date, t2.ltr, t2.nps
from uat_ca.tl_hadoop t1 join uat_ca.v_nps_bu t2 on t1.subs_id = t2.subs_id and  t2.create_date = t1.report_date


select top 100 * from uat_ca.sample_hadoop


 