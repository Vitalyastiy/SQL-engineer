
diagnostic helpstats on for session;

--==Запрос 1
Добрый день Михаил.
У Ромы 14.10.22 с 19:10 по 19:20, случился неудачный кейс. Прошу выгрузить тех. детализацию CDR по номеру Ромы: +79085078002



select * from prd2_dds_v.phone_number_2 where msisdn = '79085078002';       --db 4

create multiset volatile table subs, no log as (
--insert into subs
select
 a.call_id,                       --
 cast(start_time as date) as report_date,
 a.start_time,                    --
 a.charging_id,                   --ID сессии
 a.msisdn,                        --
 a.imei,                          --
 a.duration,                      --
 a.cause4term,                    --
 a.rg_id,                         --
 a.vol_in,                        --
 a.vol_out,                       --
 a.vol_in + a.vol_out as vol_sum,
 cast(a.vol_in as float) / 1024 / 1024 as uplink_mb,
 cast(a.vol_out as float) / 1024 / 1024 as downlink_mb,
 cast(vol_sum as float) / 1024 / 1024 as vol_mb,
-- case when downlink_mb = 0 then 1 else 0 end as mb_flg,
-- case when downlink_mb > 1 then 1 else 0 end as mb_flg2,
 case when a.duration = 0 then 1 else 0 end as time_flg,
 case when time_flg = 1 then -1
      else (cast(a.vol_in as float) * 8 / 1024 / 1024) / nullifzero(a.duration) end as uplink_mps,
 case when time_flg = 1 then -1 
      else (cast(a.vol_out as float) * 8 / 1024 / 1024) / nullifzero(a.duration) end as downlink_mps,
 case when time_flg = 1 then -1 
      else (cast(vol_sum as float) * 8 / 1024 / 1024) / nullifzero(a.duration) end as avg_mps,
--
-- case when uplink_mps < 0.300 then 1 else 0 end as uplink_flg,
-- case when downlink_mps < 1.500 then 1 else 0 end as downlink_flg,
-- case when a.vol_out > a.vol_in then 1 else 0 end as vol_out_flg,
--
 a.l_cell_id,
 a.l_lac,
 a.l_eci,
 a.l_tac,
 a.l_rac,
 a.l_sac,
 case when (a.L_ECI is null or a.L_ECI = 0)
      then (nvl(decode(a.L_LAC,0,a.L_TAC,a.L_LAC),a.L_TAC)*100000 + nvl(decode(a.L_CELL_ID,0,a.L_SAC,a.L_CELL_ID),a.L_SAC)) * 10 + 1
      else (a.L_ECI*10) + 2
 end as ne_odw,
 t1.region_id as region_ne,
 t1.sector_name as sector_name,
 t1.stechnology as tech,
 t1.standart,
 t1.district_name,
 t1.address,
 case when t1.sector_name is null then 1 else 0 end as sector_flg
from prd2_odw_v.gprs_calls_rw a
--
left join prd2_dic_v.network_element t1 on ne_odw = t1.ne_id
 and t1.edw_sdate <= timestamp '2022-10-14 00:00:00'
 and t1.edw_edate >= timestamp '2022-10-15 23:59:59'
--
where 1=1
 and a.start_time >= timestamp '2022-10-14 00:00:00'
 and a.start_time < timestamp '2022-10-15 00:00:00'
-- and (a.rg_id = 6000 and a.rg_npp = 1)
 and a.rg_id <> 6000
 and a.msisdn = '79085078002'
) with no data
primary index (call_id)
partition by range_n(start_time  between timestamp '2022-01-01 00:00:00+00:00' and timestamp '2022-12-31 23:59:59+00:00' each interval '1' day )
on commit preserve rows
;

select * from subs order by start_time;
