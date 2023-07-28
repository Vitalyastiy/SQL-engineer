
diagnostic helpstats on for session;




select top 100 * from uat_ca.ek_my_helper;
select top 100 * from uat_ca.ek_my_helper_compensation;

--==c 2021-01-01 по 2022-07-01
select report_month, count(*) from uat_ca.ek_my_helper group by 1 order by 1;

--==c 2021-01-01 по 2022-07-01
select trunc(report_date,'mm'), count(*) from uat_ca.ek_my_helper_compensation group by 1 order by 1;


--==================================================================================================
--==Compensations
--==================================================================================================

create multiset volatile table money_compens ,no log (
 bal_event_id decimal(15,0),
 subs_id decimal(12,0),
 cust_id decimal(12,0),
 event_amount decimal(18,6),
 event_dttm timestamp(0),
 compens_type varchar(50) character set unicode casespecific,
 bal_event_comment varchar(255) character set unicode casespecific)
primary index (bal_event_id ,subs_id)
on commit preserve rows;


replace macro compens_macro (stime timestamp(0), etime timestamp(0)) as (

--create multiset volatile table money_compens as (
insert into money_compens
select
 b.bal_event_id,
 b.subs_id,
 b.cust_id,
 b.event_amount,
 b.event_dttm,
 t1.bal_event_subtype_name as compens_type,
 b.bal_event_comment
from prd2_dds_v.balance_event b
inner join prd2_dic_v.balance_event_subtype t1 on b.bal_event_subtype_id = t1.bal_event_subtype_id
where 1=1
--  and b.creation_dttm >= '2021-02-01 00:00:00'
--  and b.creation_dttm < '2021-03-01 00:00:00'
 and b.event_dttm >= :stime
 and b.event_dttm < :etime
 and b.bal_event_method_id = -4     -- административные платежи
 and b.bal_event_type_id = -11      -- компенсационное зачисление
--) with no data
--primary index (subs_id, bal_event_id)
--on commit preserve rows;
;

--конец макроса
);


select trunc(event_dttm, 'mm'), count(*) from money_compens group by 1;

--2021
execute compens_macro (timestamp '2021-01-01 00:00:00', timestamp '2021-02-01 00:00:00');
execute compens_macro (timestamp '2021-02-01 00:00:00', timestamp '2021-03-01 00:00:00');
execute compens_macro (timestamp '2021-03-01 00:00:00', timestamp '2021-04-01 00:00:00');
execute compens_macro (timestamp '2021-04-01 00:00:00', timestamp '2021-05-01 00:00:00');
execute compens_macro (timestamp '2021-05-01 00:00:00', timestamp '2021-06-01 00:00:00');
execute compens_macro (timestamp '2021-06-01 00:00:00', timestamp '2021-07-01 00:00:00');
execute compens_macro (timestamp '2021-07-01 00:00:00', timestamp '2021-08-01 00:00:00');
execute compens_macro (timestamp '2021-08-01 00:00:00', timestamp '2021-09-01 00:00:00');
execute compens_macro (timestamp '2021-09-01 00:00:00', timestamp '2021-10-01 00:00:00');
execute compens_macro (timestamp '2021-10-01 00:00:00', timestamp '2021-11-01 00:00:00');
execute compens_macro (timestamp '2021-11-01 00:00:00', timestamp '2021-12-01 00:00:00');
execute compens_macro (timestamp '2021-12-01 00:00:00', timestamp '2022-01-01 00:00:00');

--2022
execute compens_macro (timestamp '2022-01-01 00:00:00', timestamp '2022-02-01 00:00:00');
execute compens_macro (timestamp '2022-02-01 00:00:00', timestamp '2022-03-01 00:00:00');
execute compens_macro (timestamp '2022-03-01 00:00:00', timestamp '2022-04-01 00:00:00');
execute compens_macro (timestamp '2022-04-01 00:00:00', timestamp '2022-05-01 00:00:00');
execute compens_macro (timestamp '2022-05-01 00:00:00', timestamp '2022-06-01 00:00:00');
execute compens_macro (timestamp '2022-06-01 00:00:00', timestamp '2022-07-01 00:00:00');
execute compens_macro (timestamp '2022-07-01 00:00:00', timestamp '2022-08-01 00:00:00');

--Мой расчет
execute compens_macro (timestamp '2022-08-01 00:00:00', timestamp '2022-09-01 00:00:00');
execute compens_macro (timestamp '2022-09-01 00:00:00', timestamp '2022-10-01 00:00:00');
execute compens_macro (timestamp '2022-10-01 00:00:00', timestamp '2022-11-01 00:00:00');
execute compens_macro (timestamp '2022-11-01 00:00:00', timestamp '2022-12-01 00:00:00');

select top 100 * from money_compens;

delete money_compens;

/*
select
 a.*,
 nvl2(comm.subs_id, 1, 0) as mh,
 comm.msisdn,
 comm.report_date
from money_compens a
left join communication comm on a.subs_id = comm.subs_id
where 1=1
--  and bal_event_comment = 'За услуги'
 and mh = 1
 and tp_change_flg = 0
 and bal_event_comment like '%помощник%'
;
*/

--==================================================================================================
--==
--==================================================================================================

/*
select top 100 * from uat_ca.ek_communications_detailed;
--с 2020-01-01 по 2022-07-01
select trunc(report_date, 'mm'), count(*) from uat_ca.ek_communications_detailed group by 1 order by 1;


show table communication;
--drop table communication;

create multiset volatile table communication ,no log (
 report_month date format 'yy/mm/dd',
 report_date date format 'yy/mm/dd',
 communication_id bigint,
 subs_id decimal(15,0),
 msisdn varchar(255) character set unicode not casespecific,
 comm_cat varchar(40) character set unicode not casespecific,
 comm_rsn_full varchar(2000) character set unicode not casespecific,
 lev_1 varchar(2000) character set unicode not casespecific,
 lev_2 varchar(2000) character set unicode not casespecific,
 tp_id decimal(12,0),
 prev_tp_id decimal(12,0),
 tp_change_flg byteint)
primary index ( subs_id )
on commit preserve rows;


--replace macro communication_macro (sdate date format 'yy-mm-dd', edate date format 'yy-mm-dd') as (
--create multiset volatile table communication, no log as (
insert into communication
select
    trunc(comm.report_date, 'mm') as report_month,
    comm.report_date,
    comm.communication_id,
    comm.subs_id,
    comm.msisdn,
    comm.comm_cat,
    comm.comm_rsn_full,
    comm.lev_1,
    comm.lev_2,
    tp.tp_id,
    tp.prev_tp_id,
    tp.tp_change_flg
from uat_ca.mc_communications_detailed comm
left join prd2_bds_v.subs_tp_change tp on comm.subs_id = tp.subs_id
  and comm.report_date = tp.report_date
  and tp.change_rn <= 1
  and tp.report_date >= date '2022-08-01'
  and tp.report_date < date '2022-09-01'
where 1=1
  and comm_rsn_full = 'Дополнительные услуги \ Мой помощник'
  and comm.comm_cat = 'Администрирование'
  and comm.report_date >= date '2022-08-01'
  and comm.report_date < date '2022-09-01'
  and comm.subs_id is not null
--) with no data
--primary index (subs_id)
--on commit preserve rows
;
*/


--==================================================================================================
--==Компенсации по услугам
--==================================================================================================

replace macro service_comp_macro (sdate date format 'yy-mm-dd', edate date format 'yy-mm-dd') as (

--create multiset table uat_ca.ek_my_helper_compensation as (
insert into uat_ca.ek_my_helper_compensation
select
 comm.report_date,
 comm.communication_id,
 comm.subs_id,
 comm.msisdn,
 cp.compens_type,
 cp.bal_event_comment,
 cp.event_amount,
 case when ((cp.bal_event_comment like '%помощник%' or cp.bal_event_comment like '%услуг%') and cp.compens_type = 'К-разовая') then cp.event_amount end as service_amount
from uat_ca.mc_communications_detailed comm
--
left join money_compens cp on comm.subs_id = cp.subs_id
 and comm.report_date = cast(cp.event_dttm as date)
--
where 1=1
 and comm_rsn_full = 'Дополнительные услуги \ Мой помощник'
 and comm.comm_cat = 'Администрирование'
-- and comm.report_date >= date '2022-08-01'
-- and comm.report_date < date '2022-09-01'
 and comm.report_date >= :sdate
 and comm.report_date < :edate
 and comm.subs_id is not null
--) with no data
--primary index (subs_id, report_date);
;

--конец макроса
);


execute service_comp_macro (date '2021-01-01' , date '2021-02-01');
execute service_comp_macro (date '2021-02-01' , date '2021-03-01');
execute service_comp_macro (date '2021-03-01' , date '2021-04-01');
execute service_comp_macro (date '2021-04-01' , date '2021-05-01');
execute service_comp_macro (date '2021-05-01' , date '2021-06-01');
execute service_comp_macro (date '2021-06-01' , date '2021-07-01');
execute service_comp_macro (date '2021-07-01' , date '2021-08-01');
execute service_comp_macro (date '2021-08-01' , date '2021-09-01');
execute service_comp_macro (date '2021-09-01' , date '2021-10-01');
execute service_comp_macro (date '2021-10-01' , date '2021-11-01');
execute service_comp_macro (date '2021-11-01' , date '2021-12-01');
execute service_comp_macro (date '2021-12-01' , date '2022-01-01');

--2022
execute service_comp_macro (date '2022-01-01' , date '2022-02-01');
execute service_comp_macro (date '2022-02-01' , date '2022-03-01');
execute service_comp_macro (date '2022-03-01' , date '2022-04-01');
execute service_comp_macro (date '2022-04-01' , date '2022-05-01');
execute service_comp_macro (date '2022-05-01' , date '2022-06-01');
execute service_comp_macro (date '2022-06-01' , date '2022-07-01');

--Мой расчет
execute service_comp_macro (date '2022-08-01' , date '2022-09-01');
execute service_comp_macro (date '2022-09-01' , date '2022-10-01');
execute service_comp_macro (date '2022-10-01' , date '2022-11-01');
execute service_comp_macro (date '2022-11-01' , date '2022-12-01');


select top 100 * from uat_ca.ek_my_helper_compensation where report_date >= date '2022-11-01';
select trunc(report_date,'mm'), count(*) from uat_ca.ek_my_helper_compensation group by 1 order by 1;


/*
--select distinct trunc(report_date, 'mm') from uat_ca.ek_my_helper_compensation;

select
--    trunc(event_dttm, 'mm') as report_month,
    compens_type,
    bal_event_comment,
    count(*) as counts,
    sum(event_amount) as amount,
    avg(event_amount) as avg_amount
from money_compens
where 1=1
  and compens_type = 'К-разовая'
  and (bal_event_comment like '%помощник%' or bal_event_comment like '%услуг%')
group by 1,2;

--К-разовая все
select
    compens_type,
    bal_event_comment,
    count(*) as counts,
    sum(event_amount) as amount,
    avg(event_amount) as avg_amount
from money_compens
where 1=1
  and compens_type = 'К-разовая'
group by 1,2
order by counts desc;

select top 100 * from money_compens;
*/



--=================================================================================================
--==COMMUNICATIONS, ном. 1
--=================================================================================================

show table communication;
--drop table communication;

create multiset volatile table communication ,no log (
 report_month date format 'yy/mm/dd',
 call_all integer)
primary index (report_month)
on commit preserve rows;


replace macro communication_macro (sdate date format 'yy-mm-dd', edate date format 'yy-mm-dd') as (

--create multiset volatile table communication, no log as (
insert into communication
select
    trunc(comm.report_date, 'mm') as report_month,
--    comm.report_date,
--    comm.communication_id,
--    comm.subs_id,
--    comm.comm_cat,
--    comm.comm_rsn_full,
--    comm.lev_1,
--    comm.lev_2,
--    tp.tp_id,
--    tp.prev_tp_id,
--    tp.tp_change_flg,
--    count(comm.subs_id) as call_all,
--    count(distinct (case when tp.tp_change_flg = 1 then comm.subs_id end)) as call_change_tp,
--    count(distinct (case when tp.tp_change_flg = 0 then comm.subs_id end)) as call_no_change_tp
    count(distinct comm.subs_id) as call_all
from uat_ca.mc_communications_detailed comm
--left join prd2_bds_v.subs_tp_change tp on comm.subs_id = tp.subs_id
--  and comm.report_date = tp.report_date
--  and tp.change_rn <= 1
----  and tp.report_date >= date '2021-10-01'
----  and tp.report_date < date '2021-11-01'
--  and tp.report_date >= :sdate
--  and tp.report_date < :edate
where 1=1
  and comm_rsn_full = 'Дополнительные услуги \ Мой помощник'
  and comm.comm_cat = 'Администрирование'
--  and comm.report_date >= date '2021-10-01'
--  and comm.report_date < date '2021-11-01'
  and comm.report_date >= :sdate
  and comm.report_date < :edate
  and comm.subs_id is not null
  and comm.subs_id in (select subs_id from my_helper1 where day_diff > 0 and report_month = :sdate)
--  and tp.tp_change_flg = 0
group by 1
--) with no data
--primary index (report_month)
--on commit preserve rows
;

--конец макроса
);


select top 100 * from communication;


--==================================================================================================
--==ном. 2
--==================================================================================================

show table communication_all;

create multiset volatile table communication_all ,no log (
 report_month date format 'yy/mm/dd',
 all_comm integer)
primary index ( report_month )
on commit preserve rows;


replace macro communication_all_macro (sdate date format 'yy-mm-dd', edate date format 'yy-mm-dd') as (

--create multiset volatile table communication_all, no log as (
insert into communication_all
select
 trunc(comm.report_date, 'mm') as report_month,
 count(distinct subs_id) as all_comm
from uat_ca.mc_communications_detailed comm
where 1=1
  and comm_rsn_full <> 'Дополнительные услуги \ Мой помощник'
  and comm.comm_cat = 'Администрирование'
--  and comm.report_date >= date '2021-10-01'
--  and comm.report_date < date '2021-11-01'
  and comm.report_date >= :sdate
  and comm.report_date < :edate
  and comm.subs_id is not null
group by 1
--) with no data
--primary index (report_month)
--on commit preserve rows;
;

--конец макроса
);


/*
select
    *
from communication
where subs_id is not null
qualify row_number() over (partition by subs_id order by report_month) > 1;

select * from uat_ca.ek_communications_detailed where subs_id = 200077564951;
  
select
    distinct lev_2
from uat_ca.ek_communications_detailed
where 1=1
  and lev_1 = 'Дополнительные услуги';
*/

select top 100 * from communication_all;


--==================================================================================================
--==BASE, ном. 3
--==================================================================================================

show table subs;
--drop table subs;

create multiset volatile table subs ,no log (
 report_month date format 'yy/mm/dd',
 all_subs integer)
primary index ( report_month )
on commit preserve rows
;


replace macro subs_macro (sdate date format 'yy-mm-dd', edate date format 'yy-mm-dd') as (

--create multiset volatile table subs, no log as (
insert into subs
select
    trunc(report_date, 'mm') as report_month,
    count(distinct subs_id) as all_subs
--    branch_id,
--    activation_dttm,
--    last_flash_date,
--    subs_id,
--    msisdn,
--    tp_id,
--    age,
--    gender,
--    mb_30,
--    arpu_segment
from uat_ca.mc_base_db
where 1=1
--  and report_date >= date '2021-10-01'
--  and report_date < date '2021-11-01'
  and report_date >= :sdate
  and report_date < :edate
group by 1
--) with no data
--primary index (report_month)
--on commit preserve rows;
;

--конец макроса
);

select top 100 * from subs;


--=================================================================================================
--==Пользователи Мой помощник
--=================================================================================================

--drop table my_helper1;
--drop table my_helper2;

create multiset volatile table my_helper1 ,no log (
 report_month date format 'yy/mm/dd',
 subs_id decimal(12,0),
 day_diff integer)
primary index (report_month ,subs_id)
on commit preserve rows;


create multiset volatile table my_helper2 ,no log (
 report_month date format 'yy/mm/dd',
 mh_subs integer)
primary index (report_month)
on commit preserve rows;


--replace macro mh_macro (sdate date format 'yy-mm-dd', edate date format 'yy-mm-dd') as (
----create multiset volatile table my_helper, no log as (
--insert into my_helper
--select
----    date '2021-10-01' as report_month,
--    :sdate as report_month,
----    subs_id,
----    min(case when service_status_id = 1 then valid_from_date end) as min_date
--    count(distinct subs_id) as mh_subs
--from prd2_dds_v.service_instance
--where 1=1
--  and service_id = 19738
--  and service_status_id in (1,4)
----  and valid_to_date >= date '2021-10-01'
----  and valid_from_date < date '2021-11-01'
--  and valid_to_date >= :sdate
--  and valid_from_date < :edate
--group by 1;
----) with no data
----primary index (report_month)
----on commit preserve rows;
--);


replace macro mh_macro (sdate date format 'yy-mm-dd', edate date format 'yy-mm-dd') as (

insert into my_helper1
select
 :sdate as report_month,
 subs_id,
 sum(cast(((case
  when valid_to_dttm = timestamp '2999-12-31 00:00:00' then current_timestamp(0)
  when valid_to_dttm = timestamp '2999-12-31 23:59:59' then current_timestamp(0)
  else valid_to_dttm
 end - valid_from_dttm) day(4)) as int)) as day_diff
from prd2_dds_v.service_instance
where 1=1
  and service_id = 19738
  and service_status_id in (1,4)
  and valid_to_date >= :sdate
  and valid_from_date < :edate
group by 1,2;

insert into my_helper2
select
 report_month,
 count(subs_id) as mh_subs
from my_helper1
where 1=1 
  and day_diff > 0
  and report_month = :sdate
group by 1
;

--конец макроса
);


select top 100 * from my_helper1;
select top 100 * from my_helper2;


--==Общий запуск
replace macro all_macro(sdate date format 'yy-mm-dd', edate date format 'yy-mm-dd') as (

execute mh_macro (:sdate , :edate);                     --
execute communication_macro (:sdate , :edate);          --ном. 1
execute communication_all_macro (:sdate , :edate);      --ном. 2
execute subs_macro (:sdate , :edate);                   --ном. 3
);


execute all_macro (date '2021-01-01' , date '2021-02-01');
execute all_macro (date '2021-02-01' , date '2021-03-01');
execute all_macro (date '2021-03-01' , date '2021-04-01');
execute all_macro (date '2021-04-01' , date '2021-05-01');
execute all_macro (date '2021-05-01' , date '2021-06-01');
execute all_macro (date '2021-06-01' , date '2021-07-01');
execute all_macro (date '2021-07-01' , date '2021-08-01');
execute all_macro (date '2021-08-01' , date '2021-09-01');
execute all_macro (date '2021-09-01' , date '2021-10-01');
execute all_macro (date '2021-10-01' , date '2021-11-01');
execute all_macro (date '2021-11-01' , date '2021-12-01');
execute all_macro (date '2021-12-01' , date '2022-01-01');

--2022
execute all_macro (date '2022-01-01' , date '2022-02-01');
execute all_macro (date '2022-02-01' , date '2022-03-01');
execute all_macro (date '2022-03-01' , date '2022-04-01');
execute all_macro (date '2022-04-01' , date '2022-05-01');
execute all_macro (date '2022-05-01' , date '2022-06-01');
execute all_macro (date '2022-06-01' , date '2022-07-01');

--Мой расчет
execute all_macro (date '2022-08-01' , date '2022-09-01');
execute all_macro (date '2022-09-01' , date '2022-10-01');
execute all_macro (date '2022-10-01' , date '2022-11-01');
execute all_macro (date '2022-11-01' , date '2022-12-01');


delete my_helper1;
delete my_helper2;
delete communication;
delete communication_all;
delete subs;


select top 100 * from my_helper1;
select top 100 * from my_helper2;
select top 100 * from communication;
select top 100 * from communication_all;
select top 100 * from subs;


--create multiset table uat_ca.ek_my_helper as (
insert into uat_ca.ek_my_helper
select
 a.report_month,
 a.all_subs,
 mh.mh_subs,
 comm.call_all,
 comm2.all_comm
from subs a                                                                 --ном. 3
left join my_helper2 mh on a.report_month = mh.report_month                 --mh_macro
left join communication comm on a.report_month = comm.report_month          --ном. 1
left join communication_all comm2 on a.report_month = comm2.report_month    --ном. 2
--) with no data
--primary index (report_month)
;


select top 100 * from uat_ca.ek_my_helper order by 1;

select report_month, count(*) from uat_ca.ek_my_helper group by 1 order by 1;



