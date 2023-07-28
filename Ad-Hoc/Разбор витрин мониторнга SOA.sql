
diagnostic helpstats on for session;


select 
a.poll_id,
poll_name,
outer_key --    Идентификатор опроса в системе, из которой поступил опрос
from
polls as a

left join (


select
 a.poll_id,
 a.poll_name,
 a.outer_key,                                                   -- Идентификатор опроса в системе, из которой поступил опрос
 case when t1.poll_cnt > 0 then 1 else 0 end as unica_cnt,
 case when t2.poll_cnt > 0 then 1 else 0 end as soa_cnt
from prd2_odw_v.smspoll_polls a
--
left join (
--списки идентификаторов опроса - sub_list_id
select
 poll_id,
 count(*) as poll_cnt
from prd2_odw_v.smspoll_poll_lists
where 1=1
 and created_date = current_date - interval '1' day
 and poll_id in (193,187,181,185,188,189,190,141,142)
group by 1
) t1 on a.poll_id = t1.poll_id
--
left join (
--списка идентификаторов опроса с привязкой к идентификатору коммуникации - current_communication_id
select
 poll_id,
 count(*) as poll_cnt
from 
prd2_odw_v.smspoll_current_communications
where 1=1
 and created_date = current_date - interval '1' day
 and poll_id in (193,187,181,185,188,189,190,141,142)
group by 1
) t2 on a.poll_id = t2.poll_id
--
where 1=1
 and a.poll_id in (193,187,181,185,188,189,190,141,142)
order by 2
qualify sum(unica_cnt+soa_cnt) over (partition by a.poll_id) < 2
;








) as b on a.poll_id = b.poll_id

where a.poll_id in (193,187,181,185,188,189,190,141,142)
and b.poll_id is null
;


select top 100 * from prd2_odw_v.smspoll_current_communications


select top 100 * from PRD2_ODW.SMSPOLL_POLL_REPORTS                 --есть
select top 100 * from PRD2_ODW.SMSPOLL_COMMUNICATION_LISTS          --есть
select top 100 * from PRD2_ODW.SMSPOLL_POLL_LISTS                   --есть
select top 100 * from PRD2_ODW.SMSPOLL_CURRENT_COMMUNICATIONS       --есть
select top 100 * from PRD2_ODW.SMSPOLL_SMS_SENDING_STATUS           --есть
--==справочники
select top 100 * from PRD2_ODW.SMSPOLL_SHORT_NUMBER                 --нет
select top 100 * from PRD2_ODW.SMSPOLL_POLLS                        --нет
select top 100 * from PRD2_ODW.SMSPOLL_POLL_SETTINGS                --нет
select top 100 * from PRD2_ODW.SMSPOLL_CALENDARS                    --нет
select top 100 * from PRD2_ODW.SMSPOLL_POLL_CONTENTS                --нет
select top 100 * from PRD2_ODW.SMSPOLL_BLACK_LISTS                  --нет
