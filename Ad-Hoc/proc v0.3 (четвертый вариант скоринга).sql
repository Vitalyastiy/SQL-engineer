
diagnostic helpstats on for session;

--In:
select top 100 * from uat_ca.mc_sqm_torus;              --данные по техническим kpi vcell
select top 100 * from uat_ca.mc_sqm_scoring_subs;       --данные по проскоренным абонентам - type_score = 'version_5' (вариант скоринга 2023_07_05)
select top 100 * from uat_ca.mc_rostov_data;            --данные по трафику проскоренных абонентов для четвертого подхода
select top 100 * from uat_ca.mc_sqm_calc_4;             --данные агрегированные + технические kpi - подход 3: потребление трафика больше 100 Мб + вероятность больше 0.7 для второго подхода

--Out:
select top 100 * from uat_ca.mc_mc_sqm_score_4;           --финальная витрина для анализа




--==================================================================================================
--==================================================================================================
--==================================================================================================

--270 762 уникальных абонента - детракторы с вероятностью более 0.7 по скорингу BDO

--Шаг 1
Для абонента определяем ТОП-3 секторов по полю coeff_80
По сектору определяем имя базовой станции, если это разные - берем ту, которая максимальная по потреблению трафика, поле all_col_gb
Наносим на карту

--для пересечения со справочником сетевых элеметров
select top 100 * from prd2_dic_v.network_element;

left join prd2_dic_v.network_element t1 on a.ne_id = t1.ne_id
 and (a.start_dttm >= t1.edw_sdate and a.start_dttm < t1.edw_edate)

берем из network_element все ne_id региона Ростов на Дону (region_id = 52)
сортируем в обратном порядке по edw_sdate
координаты поле bs_position:

select
  bs_position,
  bs_position.st_x() as LON,
  bs_position.st_y() as LAT,
  new st_geometry('ST_Point', bs_position.st_x(), bs_position.st_y()) as ST_POINT
from prd2_dic_v.network_element
where current_timestamp(0) between edw_sdate and edw_edate and ne_id = 693340881
;


--Шаг 2
Определение по данным home_sector из HWE
определяем по home_sector имя базовой станции из network_element
определение имени сектора HWE - /Scripts_2022/HWE/AdHoc МО.sql строка 36
сравниваем с шагом 1


--==================================================================================================

--==01 статистика


--время 2 мин. 32 сек.
COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (SECTOR_NAME),
 COLUMN (STECHNOLOGY),
 COLUMN (STANDART),
 COLUMN (ADDRESS),
 COLUMN (ROAM_SECTOR),
 COLUMN (MEAN_FLAG_INTEGRITY_4G),
 COLUMN (DCSR_2G_BAD_FLG),
 COLUMN (DCSR_3G_BAD_FLG),
 COLUMN (DCSR_4G_FLG),
 COLUMN (LOW_CQI_BAD_FLG),
 COLUMN (MIMO_2_BAD_FLG),
 COLUMN (START_DTTM ,SUBS_ID),
 COLUMN (ROAM_SECTOR ,SUBS_ID),
 COLUMN (START_DTTM ,SUBS_ID ,SECTOR_NAME ,STECHNOLOGY ,STANDART ,ADDRESS ,MEAN_FLAG_INTEGRITY_4G ,
         DCSR_2G_BAD_FLG ,DCSR_3G_BAD_FLG ,DCSR_4G_FLG ,LOW_CQI_BAD_FLG,MIMO_2_BAD_FLG)
ON uat_ca.mc_sqm_calc_4;


--время 2 мин. 06 сек.
COLLECT STATISTICS
 COLUMN (START_DTTM),
 COLUMN (BRANCH_ID),
 COLUMN (VCELL_FLG),
 COLUMN (VCELL_FLG ,ROAM_SECTOR ,SUBS_ID),
 COLUMN (BRANCH_ID ,START_DTTM ,SUBS_ID ,SECTOR_NAME ,STECHNOLOGY ,STANDART ,ADDRESS ,MEAN_FLAG_INTEGRITY_4G ,
         DCSR_2G_BAD_FLG ,DCSR_3G_BAD_FLG ,DCSR_4G_FLG ,LOW_CQI_BAD_FLG ,MIMO_2_BAD_FLG)
ON uat_ca.mc_sqm_calc_4;


--==02

--внутрисетевой роуминг, t1.region_id - регион потребления трафика
case when prd2_dic_v.network_element.region_id = 52 then 0 else 1 end as roam_sector


--ne_flg признак наличия данных в prd2_dic_v.network_element
select ne_flg, count(*) from uat_ca.mc_sqm_calc_4 group by 1;

--четвертый подход
1,247 465 766
0,1 314 177


select count(*) from uat_ca.mc_sqm_calc_4 where sector_name is null;        --1 314 177, 0.5%


--vcell_flg - признак наличия данных в uat_ca.mc_sqm_torus: данные по техническим kpi vcell
nvl2(uat_ca.mc_sqm_torus.vcell,1,0) as vcell_flg

select vcell_flg, count(*) from uat_ca.mc_sqm_calc_4 group by 1;
1   23 644 712
0   1 561 023

--третий подход
1   139 015
0   280 908 378

--четвертый подход
1,241 428 475
0,7 351 468



select vcell_flg, count(*) from uat_ca.mc_sqm_calc_4 where roam_sector = 1 group by 1;
1   16 297
0   1 560 151

--третий подход
0   164 552

--четвертый подход
1,440 999
0,7 340 599



select vcell_flg, count(*) from uat_ca.mc_sqm_calc_4 where roam_sector = 0 group by 1;
1   23 628 415
0   872

--третий подход
1   139 015
0   280 743 826

--четвертый подход
1,240 987 476
0,10 869



select count(*) from uat_ca.mc_sqm_calc_4;      --248 779 943



show table step_1;
--drop table step_1;

create multiset volatile table step_1 ,no log (
 date_dttm timestamp(0),
 branch_id decimal(4,0),
 subs_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 rat varchar(25) character set unicode not casespecific,
 standart varchar(25) character set unicode not casespecific,
-- address varchar(400) character set unicode not casespecific,
 mean_integrity_4g decimal(3,0),
 dcsr_2g_bad decimal(5,2),
 dcsr_3g_bad decimal(5,2),
 dcsr_4g_bad decimal(5,2),
 low_cqi_bad decimal(5,2),
 mimo_2_bad decimal(5,2),
 sector_cnt integer,
 calc_cnt float,
 in_vol decimal(18,0),
 out_vol decimal(18,0),
 all_vol decimal(18,0),
 total_data decimal(18,0),
 calc_data float,
 calc float)
primary index (subs_id)
on commit preserve rows;

--время 34 сек.
COLLECT STATISTICS
 COLUMN (NE_FLG),
 COLUMN (NE_FLG ,VCELL_FLG ,ROAM_SECTOR),
 COLUMN (BRANCH_ID ,START_DTTM ,SUBS_ID ,SECTOR_NAME ,STECHNOLOGY ,STANDART ,MEAN_FLAG_INTEGRITY_4G ,DCSR_2G_BAD_FLG ,
         DCSR_3G_BAD_FLG ,DCSR_4G_FLG ,LOW_CQI_BAD_FLG ,MIMO_2_BAD_FLG)
ON uat_ca.mc_sqm_calc_4;

--время 4 сек.
COLLECT STATISTICS COLUMN (PARTITION) ON uat_ca.mc_sqm_calc_4;


--время 1 мин. 58 сек., - 240 987 188

--create multiset volatile table step_1, no log as (
insert into step_1
select
 start_dttm,
 branch_id,
 subs_id,
 sector_name,
 stechnology as rat,
 standart,
-- address,
--
 coalesce(mean_flag_integrity_4g,0) as mean_integrity_4g,
 coalesce(dcsr_2g_bad_flg,0) as dcsr_2g_bad,
 coalesce(dcsr_3g_bad_flg,0) as dcsr_3g_bad,
 coalesce(dcsr_4g_flg,0) as dcsr_4g_bad,
 coalesce(low_cqi_bad_flg,0) as low_cqi_bad,
 coalesce(mimo_2_bad_flg,0) as mimo_2_bad,
--коэффициент для кол-во секторов
 count(sector_name) over (partition by subs_id, start_dttm order by start_dttm) as sector_cnt,
 1/cast(sector_cnt as float) as calc_cnt,
--коэффициент для объема трафика
 sum(in_volume) as in_vol,
 sum(out_volume) as out_vol,
 in_vol+out_vol as all_vol,
 sum(all_vol) over (partition by subs_id, start_dttm) as total_data,
 cast(all_vol as float)/total_data as calc_data,
--итоговый коэффициент
 (calc_cnt+calc_data)/2 as calc
from uat_ca.mc_sqm_calc_4
--
where 1=1
-- and subs_id = 20416804
 and sector_name is not null
 and roam_sector = 0
 and vcell_flg = 1
 and ne_flg = 1
 and start_dttm >= timestamp '2023-03-01 00:00:00'
 and start_dttm < timestamp '2023-04-01 00:00:00'
qualify case when (in_vol+out_vol) > 0 then 1 else 0 end = 1
group by 1,2,3,4,5,6,7,8,9,10,11,12
--) with no data
--primary index (subs_id)
--on commit preserve rows
;

--delete step_1;


select top 100 * from uat_ca.mc_sqm_calc_4 where subs_id = 20416804;
select top 100 * from step_1;
select * from step_1 where subs_id = 20416804;


--==03

select mean_flag_integrity_4g, count(*) from uat_ca.mc_sqm_calc_4 group by 1;
100,299 960
null,103 445 821
0,145 034 162

select * from step_1 where rat = '2g';      --14 665 263
select top 100 * from uat_ca.mc_sqm_calc_4 where stechnology = '2g' and dcsr_2g_bad_flg is null;


--время 11 сек.
COLLECT STATISTICS
 COLUMN (SECTOR_NAME),
 COLUMN (DATE_DTTM ,SUBS_ID ,SECTOR_NAME)
ON step_1;


show table step_2;
--drop table step_2;

create multiset volatile table step_2 ,no log (
 date_dttm timestamp(0),
 subs_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 rat varchar(25) character set unicode not casespecific,
 standart varchar(25) character set unicode not casespecific,
-- address varchar(400) character set unicode not casespecific,
 mean_integrity_4g_flg byteint,
 dcsr_2g_flg byteint,
 dcsr_3g_flg byteint,
 dcsr_4g_flg byteint,
 low_cqi_flg byteint,
 mimo_2_flg byteint,
 calc_cnt float,
 all_vol decimal(18,0),
 calc_data float,
 calc float,
 dcsr_2g_tr byteint,
 dcsr_2g_flg_2 integer,
 dcsr_4g_flg_2 integer)
primary index (subs_id)
on commit preserve rows;


--время 1 мин. 12 сек., - 240 987 188

--create multiset volatile table step_2, no log as (
insert into step_2
select
 date_dttm,
 subs_id,
 sector_name,
 rat,
 standart,
-- address,
--переход к событиям
 case when mean_integrity_4g is null then 0
      when mean_integrity_4g = 0     then 0
      when mean_integrity_4g = 50    then 1
      when mean_integrity_4g = 100   then 1
      else 0 end
      as mean_integrity_4g_flg,
 case when dcsr_2g_bad is null  then 0
      when dcsr_2g_bad = 0      then 0
      when dcsr_2g_bad < 93     then 1
      else 0 end
      as dcsr_2g_flg,
 case when dcsr_3g_bad is null  then 0
      when dcsr_3g_bad = 0      then 0
      when dcsr_3g_bad < 98     then 1
      else 0 end
      as dcsr_3g_flg,
 case when dcsr_4g_bad is null  then 0
      when dcsr_4g_bad = 0      then 0
      when dcsr_4g_bad < 98     then 1
      else 0 end
      as dcsr_4g_flg,
 case when low_cqi_bad is null  then 0
      when low_cqi_bad = 0      then 0
      when low_cqi_bad > 28     then 1
      else 0 end
      as low_cqi_flg,
 case when mimo_2_bad is null   then 0
      when mimo_2_bad = 0       then 0
      when mimo_2_bad < 20      then 1
      else 0 end
      as mimo_2_flg,
--
-- sector_cnt,
 calc_cnt,
-- in_vol,
-- out_vol,
 all_vol,
-- total_data,
 calc_data,
 calc,
--событие потребления трафика в технологии 2g
 coalesce(case when (rat = '2G' and dcsr_2g_flg = 0 and all_vol > 0) then 1
      else 0 end,0) as dcsr_2g_tr,
 coalesce(case when rat = '2G' then sum(dcsr_2g_flg+dcsr_2g_tr) over (partition by subs_id, date_dttm, sector_name) end,0) as dcsr_2g_flg_2,
--событие для сектора с 4G
 coalesce(case when rat = '4G' then sum(mean_integrity_4g_flg+dcsr_4g_flg+low_cqi_flg+mimo_2_flg) over (partition by subs_id, date_dttm, sector_name) end,0) as dcsr_4g_flg_2
from step_1
--where 1=1
-- and date_dttm >= timestamp '2023-03-01 00:00:00'
-- and date_dttm < timestamp '2023-03-02 00:00:00'
-- and sector_name = 'RO0248_013'
--) with no data
--primary index (subs_id)
--on commit preserve rows
;

--delete step_2;


/*
select * from step_1
where 1=1
 and sector_name = 'RO0248_013'
 and date_dttm >= timestamp '2023-03-01 00:00:00'
 and date_dttm < timestamp '2023-03-02 00:00:00'
;
*/

select top 100 * from step_2;



--==04

--время 32 сек.
COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (RAT),
 COLUMN (STANDART),
-- COLUMN (ADDRESS),
 COLUMN (SUBS_ID ,SECTOR_NAME ,RAT ,STANDART)
ON step_2;


show table step_3;
--drop table step_3;

create multiset volatile table step_3 ,no log (
 report_month date format 'yy/mm/dd',
 subs_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 rat varchar(25) character set unicode not casespecific,
 standart varchar(25) character set unicode not casespecific,
-- address varchar(400) character set unicode not casespecific,
 mean_integrity_4g_flg integer,
 dcsr_2g_flg integer,
 dcsr_3g_flg integer,
 dcsr_4g_flg integer,
 low_cqi_flg integer,
 mimo_2_flg integer,
 bad_2g integer,
 bad_3g integer,
 bad_4g integer,
 bad integer,
 calc_cnt float,
 calc_data float,
 calc float,
 all_vol_gb float
)
primary index (subs_id)
on commit preserve rows;


--время 18 сек. 26 978 252

--create multiset volatile table step_3, no log as (
insert into step_3
select
 trunc(date_dttm,'mm') as report_month,
 subs_id,
 sector_name,
 rat,
 standart,
-- address,
--
 sum(mean_integrity_4g_flg) as mean_integrity_4g_flg,
 sum(dcsr_2g_flg) as dcsr_2g_flg,
 sum(dcsr_3g_flg) as dcsr_3g_flg,
 sum(dcsr_4g_flg) as dcsr_4g_flg,
 sum(low_cqi_flg) as low_cqi_flg,
 sum(mimo_2_flg)  as mimo_2_flg,
--
 sum(dcsr_2g_flg_2)     as bad_2g,
 sum(dcsr_3g_flg)       as bad_3g,
 sum(dcsr_4g_flg_2)     as bad_4g,
 (bad_2g+bad_3g+bad_4g) as bad,     --у Мустафы: SUM bad_flg
--
 sum(calc_cnt) as calc_cnt,
 sum(calc_data) as calc_data,
 sum(calc) as calc,                 --у Мустафы: Total cnt (max:540/564 per Month)
 sum(cast(all_vol as float))/1024/1024/1024 as all_vol_gb
from step_2
group by 1,2,3,4,5
--) with no data
--primary index (subs_id)
--on commit preserve rows
;

--delete step_3;

select * from step_3;
select * from uat_ca.mc_sqm_calc where sector_name = 'RO2934_1' and subs_id = 20416804;



--==05

--время 5 сек.
COLLECT STATISTICS
 COLUMN (REPORT_MONTH ,SUBS_ID)
ON step_3;


show table step_4;
--drop table step_4;

create multiset volatile table step_4 ,no log (
 report_month date format 'yy/mm/dd',
 subs_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 rat varchar(25) character set unicode not casespecific,
 standart varchar(25) character set unicode not casespecific,
-- address varchar(400) character set unicode not casespecific,
 mean_integrity_4g_flg integer,
 dcsr_2g_flg integer,
 dcsr_3g_flg integer,
 dcsr_4g_flg integer,
 low_cqi_flg integer,
 mimo_2_flg integer,
 bad_2g integer,
 bad_3g integer,
 bad_4g integer,
 bad integer,
 calc_cnt float,
 calc_data float,
 calc float,
 all_vol_gb float,
 sum_bad integer,
 bad_share float,
 sum_calc float,
 calc_share float)
primary index ( subs_id )
on commit preserve rows;


--время 12 сек. 26 978 252

--create multiset volatile table step_4, no log as (
insert into step_4
select
 report_month,
 subs_id,
 sector_name,
 rat,
 standart,
-- address,
--
 mean_integrity_4g_flg,
 dcsr_2g_flg,
 dcsr_3g_flg,
 dcsr_4g_flg,
 low_cqi_flg,
 mimo_2_flg,
--
 bad_2g,
 bad_3g,
 bad_4g,
 bad,                    --у Мустафы: SUM bad_flg
--
 calc_cnt,
 calc_data,
 calc,                   --у Мустафы: Total cnt (max:540/564 per Month)
 all_vol_gb,
--
 sum(bad) over (partition by report_month,subs_id) as sum_bad,
 cast(bad as float)/nullifzero(sum_bad) as bad_share,                   --у Мустафы: SUM bad_flg %
 sum(calc) over (partition by report_month,subs_id) as sum_calc,
 cast(calc as float)/sum_calc as calc_share                             --у Мустафы: Total time %
from step_3
--) with no data
--primary index (subs_id)
--on commit preserve rows
;

--delete step_4;

select top 100 * from step_4;

/* -- ошибку исправил, временно убрал адрес базовой станции
select sector_cnt, count(subs_id) as subs_cnt from (
--select a.* from (
select subs_id, count(distinct sector_name) as sector_cnt, count(*) as row_cnt, row_cnt-sector_cnt as diff from step_4 group by 1
) a
--where 1=1
-- and diff > 1
group by 1
;

--дублирующиеся сектора
639 940
638 163

--пример абонента с дублирующимися секторами
select * from step_4 where subs_id = 3863285;
select * from step_4 where subs_id = 3863285 qualify count(*) over (partition by sector_name) > 1;

select * from uat_ca.mc_sqm_calc where subs_id = 3863285 and sector_name = 'RO0840_011';

select top 100 * from uat_ca.mc_sqm_gprs_subs;          --данные по трафику проскоренных абонентов
select top 100 * from uat_ca.mc_sqm_calc;               --данные агрегированные + технические kpi
*/


--==06


--время 3 сек., 26 978 252

--create multiset table uat_ca.mc_mc_sqm_score as (
insert into uat_ca.mc_mc_sqm_score_4
select
 report_month,
 subs_id,
 sector_name,
 rat,
 standart,
-- address,
--
 cast(1 as byteint) as nps_score,
 case when bad = 0 then 0 else 1 end as tech_score,
--
 mean_integrity_4g_flg,
 dcsr_2g_flg,
 dcsr_3g_flg,
 dcsr_4g_flg,
 low_cqi_flg,
 mimo_2_flg,
--
 bad_2g,
 bad_3g,
 bad_4g,
 bad,
--
 calc_cnt,
 calc_data,
 calc,
 all_vol_gb,
--
 sum_bad,
 bad_share,
 sum_calc,
 calc_share,
 bad_share_rn,
 bad_share_flg,
 calc_share_rn,
 calc_share_flg,
 bad_80,
 calc_80,
 sum_bad_80,
 sum_calc_80,
 coeff,
 coeff_80,
--
 sum(coeff_80) over (partition by report_month,subs_id) as sum_coeff_80,
 coeff/sum_coeff_80 as share_coeff_80
from (
select
 a.*,
--
 sum(bad_80) over (partition by report_month,subs_id) as sum_bad_80,
 sum(calc_80) over (partition by report_month,subs_id) as sum_calc_80,
 (bad*calc)/nullifzero((sum_bad_80*sum_calc_80)) as coeff,
 case when bad_share_flg = 1 then coeff else 0 end as coeff_80
from (
select
 a.*,
--
 sum(bad_share) over (partition by report_month,subs_id order by bad_share desc rows unbounded preceding) as bad_share_rn,
 case when bad_share_rn > 0.8 then 0 else 1 end as bad_share_flg,
 sum(calc_share) over (partition by report_month,subs_id order by calc_share desc rows unbounded preceding) as calc_share_rn,
 case when calc_share_rn > 0.8 then 0 else 1 end as calc_share_flg,
 case when bad_share_flg = 1 then bad else 0 end as bad_80,
 case when bad_share_flg = 1 then calc else 0 end as calc_80
from step_4 a
) a
) a
--) with no data
--primary index (subs_id)
;



-- 3 сек. 15 681 391

select tech_score, count(distinct subs_id), count(*) from uat_ca.mc_mc_sqm_score_4 group by 1;
1   14 574      1 387 728
0   14 506      1 537 332


--третий подход
1   21 918      24 964
0   76 546      100 983

--четвертый подход
1   264 768     12 715 920
0   257 706     14 262 332



select top 100 * from uat_ca.mc_mc_sqm_score_4;
select count(distinct subs_id), count(*) from uat_ca.mc_mc_sqm_score_4;      -- 269 755,    26 978 252

select * from uat_ca.mc_mc_sqm_score_4 sample 0.01;


--Абонент с большим количеством плохих событий в секторе не проводит в нем много времени.


--=================================================================================================
--=================================================================================================
--=================================================================================================


show table uat_ca.mc_mc_sqm_score_4;
--drop table uat_ca.mc_mc_sqm_score_4;

create multiset table uat_ca.mc_mc_sqm_score_4 (
 report_month date format 'yy/mm/dd',
 subs_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 rat varchar(25) character set unicode not casespecific,
 standart varchar(25) character set unicode not casespecific,
 nps_score byteint,
 tech_score byteint,
 mean_integrity_4g_flg integer,
 dcsr_2g_flg integer,
 dcsr_3g_flg integer,
 dcsr_4g_flg integer,
 low_cqi_flg integer,
 mimo_2_flg integer,
 bad_2g integer,
 bad_3g integer,
 bad_4g integer,
 bad integer,
 calc_cnt float,
 calc_data float,
 calc float,
 all_vol_gb float,
 sum_bad integer,
 bad_share float,
 sum_calc float,
 calc_share float,
 bad_share_rn float,
 bad_share_flg byteint,
 calc_share_rn float,
 calc_share_flg byteint,
 bad_80 integer,
 calc_80 float,
 sum_bad_80 integer,
 sum_calc_80 float,
 coeff float,
 coeff_80 float,
 sum_coeff_80 float,
 share_coeff_80 float)
primary index (subs_id);



