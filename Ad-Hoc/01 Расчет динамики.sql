
diagnostic helpstats on for session;

/*
show view prd2_dds_v.mnp_portation;
show table prd2_dds.mnp_portation;
PRIMARY INDEX ( SUBS_ID )
*/

select top 100 * from prd2_dds_v.mnp_portation
where 1=1
 and request_dttm >= timestamp '2022-07-01 00:00:00'
 and request_dttm < timestamp '2022-07-02 00:00:00'
;


--=================================================================================================
--=================================================================================================
--=================================================================================================

--==��� 01 ������������ ������� � ��������/����������

show table uat_ca.mc_mnp;
--drop table uat_ca.mc_mnp_lite;
--delete uat_ca.mc_mnp_lite;�

create multiset table uat_ca.mc_mnp_lite (
 np_id decimal(16,0),
 parent_request_id decimal(12,0),
 request_id decimal(12,0),
 request_dttm timestamp(0),
 plan_porting_dttm timestamp(0),
 porting_dttm timestamp(0),
 reverse_dttm timestamp(0),
 cancel_dttm timestamp(0),
 branch_id decimal(4,0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set unicode not casespecific,
 msisdn_temp varchar(20) character set unicode not casespecific,
 transfer_direction_id byteint,
 donor varchar(20) character set unicode not casespecific COMPRESS ('mMTS','mTELE2','mBEELINE','mMEGAFON'),
 mnc_donor char(2) character set unicode not casespecific COMPRESS ('01','02','20','99'),
 group_operator_donor varchar(20) character set unicode not casespecific COMPRESS ('MTS','�� Tele2','Beeline','Megafon'),
 recipient varchar(20) character set unicode not casespecific COMPRESS ('mMTS','mTELE2','mBEELINE','mMEGAFON'),
 mnc_recipient char(2) character set unicode not casespecific COMPRESS ('01','02','20','99'),
 group_operator_recipient varchar(20) character set unicode not casespecific COMPRESS ('MTS','�� Tele2','Beeline','Megafon'),
 last_request_status varchar(30) character set unicode not casespecific,
 last_text_id decimal(3,0),
 last_message_text_id decimal(3,0),
 last_message_error_id decimal(4,0),
 internal_portation byteint
)
primary index (request_id)
index (subs_id);



replace MACRO mnp_lite (sdttm timestamp(0), edttm timestamp(0)) as (

--create multiset table uat_ca.mc_mnp as (
insert into uat_ca.mc_mnp_lite
select
 np_id,
 parent_request_id,
 request_id,
 request_dttm,
 plan_porting_date as plan_porting_dttm,
 porting_dttm,
 reverse_dttm,
 cancel_dttm,
 branch_id,
 subs_id,
 msisdn,
 msisdn_temp,
 case when transfer_direction = 'IN'  then 0
      when transfer_direction = 'OUT' then 1
 end as transfer_direction_id,
 donor,
 mnc_donor,
 group_operator_donor,
 recipient,
 mnc_recipient,
 group_operator_recipient,
 last_request_status,
 last_text_id,
 last_message_text_id,
 last_message_error_code as last_message_error_id,
 internal_portation
--from sbx_ss.mnp_portation_new_logic_2020_2022
from prd2_dds_v.mnp_portation
where 1=1
 and request_dttm >= :sdttm
 and request_dttm < :edttm
-- and request_dttm >= timestamp '2022-06-30 00:00:00'
-- and request_dttm < timestamp '2022-07-01 00:00:00'
--) with no data
--primary index (np_id)
--index (subs_id)
;

--����� �������
);


--delete uat_ca.mc_mnp_lite where request_dttm >= timestamp '2022-06-13 00:00:00';

select top 100 * from uat_ca.mc_mnp_lite where request_dttm >= timestamp '2022-06-13 00:00:00';

--2021
/*������*/    Execute mnp_lite (timestamp '2021-01-01 00:00:00', timestamp '2021-02-01 00:00:00');
/*�������*/   Execute mnp_lite (timestamp '2021-02-01 00:00:00', timestamp '2021-03-01 00:00:00');
/*����*/      Execute mnp_lite (timestamp '2021-03-01 00:00:00', timestamp '2021-04-01 00:00:00');
/*������*/    Execute mnp_lite (timestamp '2021-04-01 00:00:00', timestamp '2021-05-01 00:00:00');
/*���*/       Execute mnp_lite (timestamp '2021-05-01 00:00:00', timestamp '2021-06-01 00:00:00');
/*����*/      Execute mnp_lite (timestamp '2021-06-01 00:00:00', timestamp '2021-07-01 00:00:00');
/*����*/      Execute mnp_lite (timestamp '2021-07-01 00:00:00', timestamp '2021-08-01 00:00:00');
/*������*/    Execute mnp_lite (timestamp '2021-08-01 00:00:00', timestamp '2021-09-01 00:00:00');
/*��������*/  Execute mnp_lite (timestamp '2021-09-01 00:00:00', timestamp '2021-10-01 00:00:00');
/*�������*/   Execute mnp_lite (timestamp '2021-10-01 00:00:00', timestamp '2021-11-01 00:00:00');
/*������*/    Execute mnp_lite (timestamp '2021-11-01 00:00:00', timestamp '2021-12-01 00:00:00');
/*�������*/   Execute mnp_lite (timestamp '2021-12-01 00:00:00', timestamp '2022-01-01 00:00:00');

--2022
/*������*/    Execute mnp_lite (timestamp '2022-01-01 00:00:00', timestamp '2022-02-01 00:00:00');
/*�������*/   Execute mnp_lite (timestamp '2022-02-01 00:00:00', timestamp '2022-03-01 00:00:00');
/*����*/      Execute mnp_lite (timestamp '2022-03-01 00:00:00', timestamp '2022-04-01 00:00:00');
/*������*/    Execute mnp_lite (timestamp '2022-04-01 00:00:00', timestamp '2022-05-01 00:00:00');
/*���*/       Execute mnp_lite (timestamp '2022-05-01 00:00:00', timestamp '2022-06-01 00:00:00');

/*����*/      Execute mnp_lite (timestamp '2022-06-01 00:00:00', timestamp '2022-07-01 00:00:00');
/*����*/      Execute mnp_lite (timestamp '2022-07-01 00:00:00', timestamp '2022-08-01 00:00:00');      --1 ���. 34 ���.

/*������*/    Execute mnp_lite (timestamp '2022-08-01 00:00:00', timestamp '2022-08-11 00:00:00');      --1 ���. 34 ���.

Execute mnp_lite (timestamp '2022-08-11 00:00:00', timestamp '2022-09-01 00:00:00');
Execute mnp_lite (timestamp '2022-09-01 00:00:00', timestamp '2022-09-12 00:00:00');



--delete uat_ca.mc_mnp_lite where request_dttm >= timestamp '2022-06-01 00:00:00';


select top 100 * from uat_ca.mc_mnp_lite where request_dttm >= timestamp '2022-06-01 00:00:00';

--1 ��������� ��������
select
 weeknumber_of_year (request_dttm, 'ISO') as "������",
 trunc (request_dttm,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_mnp_lite
group by 1,2
order by 2 desc;

--2 �������� ��������
select
 trunc (request_dttm,'mm') as "�����",
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_mnp_lite
group by 1
order by 1 desc;

--3 ������� ��������
select 
 cast(request_dttm as date) as request_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.mc_mnp_lite
group by 1
order by 1 desc;


--�������� � ������������� subs_id - �� ���� ��������
select count(*) from uat_ca.mc_mnp_lite where subs_id is null;      --21


--������ ������ ���
select * from uat_ca.mc_mnp_lite
where 1=1
 and request_dttm >= timestamp '2022-04-01 00:00:00'
 and request_dttm < timestamp '2022-04-02 00:00:00'
qualify count(*) over (partition by subs_id) >1
;

select * from uat_ca.mc_mnp_lite where subs_id = 685592;



-- �������� ��������
select
 trunc (request_dttm,'mm') as "�����",
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from sbx_ss.mnp_portation_new_logic_2020_2022
group by 1
order by 1 desc;


--=================================================================================================
--=================================================================================================
--=================================================================================================

--==��� 02 ������������ ������ ���������

/*
show table PRD2_DDS.AGREEMENT;
show table prd2_dds.subscription;
PRIMARY INDEX ( SUBS_ID )
PARTITION BY RANGE_N(REPORT_DATE  BETWEEN DATE '2021-11-20' AND DATE '2022-12-31' EACH INTERVAL '1' DAY );
*/

COLLECT STATISTICS
 COLUMN (BRANCH_ID),
 COLUMN (SUBS_ID),
 COLUMN (REQUEST_DTTM)
ON uat_ca.mc_mnp_lite;



show table uat_ca.mc_mnp_lite_metric;
--drop table uat_ca.mc_mnp_lite_metric;

CREATE MULTISET TABLE uat_ca.mc_mnp_lite_metric (
 request_date DATE FORMAT 'YY/MM/DD',
 branch_id DECIMAL(4,0),
 subs_id DECIMAL(12,0),
 cust_id DECIMAL(12,0),
 bsegment varchar(20) character set unicode not casespecific,
 activation_dttm TIMESTAMP(0),
 lt_day INTEGER,
 tp_id DECIMAL(8,0),
 age NUMBER,
 gender DECIMAL(6,0),
 alien_flg BYTEINT)
PRIMARY INDEX (subs_id);


--=================================================================================================
--=================================================================================================
--=================================================================================================

REPLACE PROCEDURE uat_ca.mc_mnp_lite_metrics (in sdate date, in edate date, sdttm timestamp(0), edttm timestamp(0))
SQL SECURITY INVOKER
BEGIN


create multiset volatile table subs, no log (
 request_date date format 'yy/mm/dd',
 branch_id decimal(4,0),
 subs_id decimal(12,0)
)
primary index ( subs_id )
on commit preserve rows;


lock table uat_ca.mc_mnp_lite for access
--create multiset volatile table subs ,no log as (
insert into subs
select
 distinct
 cast(request_dttm as date) as request_date,
 branch_id,
 subs_id
-- msisdn
from uat_ca.mc_mnp_lite
where 1=1
 and request_dttm >= :sdttm
 and request_dttm < :edttm
-- and request_dttm >= timestamp '2022-01-01 00:00:00'
-- and request_dttm < timestamp '2022-02-01 00:00:00'
 and subs_id is not null
 and branch_id is not null
qualify row_number() over (partition by subs_id order by request_dttm) = 1
--) with no data
--primary index ( subs_id )
--on commit preserve rows
;

--select top 100 * from subs;
--select count(distinct subs_id), count(*) from subs;


create multiset volatile table subs_2 ,no log (
 request_date date format 'yy/mm/dd',
 branch_id decimal(4,0),
 subs_id decimal(12,0),
 bsegment varchar(20) character set unicode not casespecific,
 activation_dttm timestamp(0),
 lt_day integer,
 cust_id decimal(12,0),
 tp_id decimal(8,0))
primary index ( subs_id )
on commit preserve rows;

COLLECT STATISTICS
 COLUMN (REQUEST_DATE),
 COLUMN (SUBS_ID),
 COLUMN (REQUEST_DATE ,SUBS_ID)
ON subs;


--create multiset volatile table subs_2, no log as (
insert into subs_2
select
 a.request_date,
 a.branch_id,
 a.subs_id,
 t1.bsegment,
 t1.activation_dttm as activation_dttm,
 a.request_date - cast (t1.activation_dttm as date) as lt_day,
 t1.cust_id as cust_id,
 t1.tp_id as tp_id
from subs a
--
left join prd2_dds_v2.subscription t1 on a.subs_id = t1.subs_id
 and t1.report_date >= :sdate
 and t1.report_date < :edate
-- and t1.report_date >= date '2022-01-01'
-- and t1.report_date < date '2022-02-01'
 and a.request_date = t1.report_date
-- and t1.report_date = :rdate
where 1=1
 and a.request_date >= :sdate
 and a.request_date < :edate
-- and a.request_date >= date '2022-01-01'
-- and a.request_date < date '2022-02-01'
--) with no data
--primary index (subs_id)
--on commit preserve rows
;

--select top 100 * from subs_2;
--select count(distinct subs_id), count(*) from subs_2;
--select count(*) from subs_2 where cust_id is null;


COLLECT STATISTICS
 COLUMN (CUST_ID),
 COLUMN (REQUEST_DATE)
ON subs_2;



--create multiset table uat_ca.mc_mnp_lite_metric as (
insert into uat_ca.mc_mnp_lite_metric
select
 a.request_date,
 a.branch_id,
 a.subs_id,
 a.cust_id,
 a.bsegment,
 a.activation_dttm,
 a.lt_day,
 a.tp_id,
--
 case when a.request_date - t2.birth_date is null then -1
      when months_between(a.request_date, t2.birth_date) < 168 then -1
      when months_between(a.request_date, t2.birth_date) > 1080 then -1
      else round(months_between(a.request_date, t2.birth_date)/12)
      end as age,
 coalesce(t2.gender_id,-1) as gender,
 case when upper(t2.passport) like '%������� �����%' then 1 else 0 end as alien_flg
from subs_2 a
--
left join prd2_dds_v.agreement t1 on a.cust_id = t1.cust_id
left join prd2_sec_v.person t2 on t1.person_id = t2.person_id
--
where 1=1
-- and a.request_date >= date '2022-01-01'
-- and a.request_date < date '2022-02-01'
 and a.request_date >= :sdate
 and a.request_date < :edate
--) with no data
--primary index (subs_id)
;


drop table subs;
drop table subs_2;

END;



--2021
/*������*/    call uat_ca.mc_mnp_lite_metrics (date '2021-01-01', date '2021-02-01', timestamp '2021-01-01 00:00:00', timestamp '2021-02-01 00:00:00');     --6 ���. 34 ���.
/*�������*/   call uat_ca.mc_mnp_lite_metrics (date '2021-02-01', date '2021-03-01', timestamp '2021-02-01 00:00:00', timestamp '2021-03-01 00:00:00');
/*����*/      call uat_ca.mc_mnp_lite_metrics (date '2021-03-01', date '2021-04-01', timestamp '2021-03-01 00:00:00', timestamp '2021-04-01 00:00:00');
/*������*/    call uat_ca.mc_mnp_lite_metrics (date '2021-04-01', date '2021-05-01', timestamp '2021-04-01 00:00:00', timestamp '2021-05-01 00:00:00');
/*���*/       call uat_ca.mc_mnp_lite_metrics (date '2021-05-01', date '2021-06-01', timestamp '2021-05-01 00:00:00', timestamp '2021-06-01 00:00:00');
/*����*/      call uat_ca.mc_mnp_lite_metrics (date '2021-06-01', date '2021-07-01', timestamp '2021-06-01 00:00:00', timestamp '2021-07-01 00:00:00');
/*����*/      call uat_ca.mc_mnp_lite_metrics (date '2021-07-01', date '2021-08-01', timestamp '2021-07-01 00:00:00', timestamp '2021-08-01 00:00:00');
/*������*/    call uat_ca.mc_mnp_lite_metrics (date '2021-08-01', date '2021-09-01', timestamp '2021-08-01 00:00:00', timestamp '2021-09-01 00:00:00');
/*��������*/  call uat_ca.mc_mnp_lite_metrics (date '2021-09-01', date '2021-10-01', timestamp '2021-09-01 00:00:00', timestamp '2021-10-01 00:00:00');
/*�������*/   call uat_ca.mc_mnp_lite_metrics (date '2021-10-01', date '2021-11-01', timestamp '2021-10-01 00:00:00', timestamp '2021-11-01 00:00:00');
/*�������*/   call uat_ca.mc_mnp_lite_metrics (date '2021-11-01', date '2021-12-01', timestamp '2021-11-01 00:00:00', timestamp '2021-12-01 00:00:00');
/*�������*/   call uat_ca.mc_mnp_lite_metrics (date '2021-12-01', date '2021-12-29', timestamp '2021-12-01 00:00:00', timestamp '2021-12-29 00:00:00');

--29, 30 ,31
/*�������*/   call uat_ca.mc_mnp_lite_metrics (date '2021-12-29', date '2021-12-30', timestamp '2021-12-29 00:00:00', timestamp '2021-12-30 00:00:00');
/*�������*/   call uat_ca.mc_mnp_lite_metrics (date '2021-12-30', date '2021-12-31', timestamp '2021-12-30 00:00:00', timestamp '2021-12-31 00:00:00');
/*�������*/   call uat_ca.mc_mnp_lite_metrics (date '2021-12-31', date '2022-01-01', timestamp '2021-12-31 00:00:00', timestamp '2022-01-01 00:00:00');

--2022
/*������*/    call uat_ca.mc_mnp_lite_metrics (date '2022-01-01', date '2022-02-01', timestamp '2022-01-01 00:00:00', timestamp '2022-02-01 00:00:00');     --46 ���.
/*�������*/   call uat_ca.mc_mnp_lite_metrics (date '2022-02-01', date '2022-03-01', timestamp '2022-02-01 00:00:00', timestamp '2022-03-01 00:00:00');
/*����*/      call uat_ca.mc_mnp_lite_metrics (date '2022-03-01', date '2022-04-01', timestamp '2022-03-01 00:00:00', timestamp '2022-04-01 00:00:00');
/*������*/    call uat_ca.mc_mnp_lite_metrics (date '2022-04-01', date '2022-05-01', timestamp '2022-04-01 00:00:00', timestamp '2022-05-01 00:00:00');
/*���*/       call uat_ca.mc_mnp_lite_metrics (date '2022-05-01', date '2022-06-01', timestamp '2022-05-01 00:00:00', timestamp '2022-06-01 00:00:00');     --2 ���. 09 ���.

/*����*/      call uat_ca.mc_mnp_lite_metrics (date '2022-06-01', date '2022-06-30', timestamp '2022-06-01 00:00:00', timestamp '2022-06-30 00:00:00');     --7 ���. 25 ���.
/*����*/      call uat_ca.mc_mnp_lite_metrics (date '2022-07-01', date '2022-07-31', timestamp '2022-07-01 00:00:00', timestamp '2022-07-31 00:00:00');
/*������*/    call uat_ca.mc_mnp_lite_metrics (date '2022-08-01', date '2022-08-10', timestamp '2022-08-01 00:00:00', timestamp '2022-08-10 00:00:00');     --19 ���. 05 ���.


call uat_ca.mc_mnp_lite_metrics (date '2022-08-10', date '2022-09-01', timestamp '2022-08-10 00:00:00', timestamp '2022-09-01 00:00:00');
call uat_ca.mc_mnp_lite_metrics (date '2022-09-01', date '2022-09-12', timestamp '2022-09-01 00:00:00', timestamp '2022-09-12 00:00:00');

call uat_ca.mc_mnp_lite_metrics (date '2022-09-12', date '2022-10-01', timestamp '2022-09-12 00:00:00', timestamp '2022-10-01 00:00:00');
call uat_ca.mc_mnp_lite_metrics (date '2022-10-01', date '2022-11-01', timestamp '2022-10-01 00:00:00', timestamp '2022-11-01 00:00:00');
call uat_ca.mc_mnp_lite_metrics (date '2022-11-01', date '2022-12-01', timestamp '2022-11-01 00:00:00', timestamp '2022-12-01 00:00:00');
call uat_ca.mc_mnp_lite_metrics (date '2022-12-01', date '2023-01-01', timestamp '2022-12-01 00:00:00', timestamp '2023-01-01 00:00:00');

--delete uat_ca.mc_mnp_lite_metric;
--delete uat_ca.mc_mnp_lite_metric where request_date >= date '2021-12-29' and request_date < date '2022-01-01';
--delete uat_ca.mc_mnp_lite_metric where request_date >= date '2022-06-01';


select top 100 * from uat_ca.mc_mnp_lite_metric;
select top 100 * from uat_ca.mc_mnp_lite_metric where request_date >= date '2022-06-01' and request_date < date '2021-02-01';

select * from uat_ca.mc_mnp_lite_metric where cust_id is null;

select gender, count(*) from uat_ca.mc_mnp_lite_metric where request_date = date '2022-07-01' group by 1;
select age, count(*) from uat_ca.mc_mnp_lite_metric where request_date = date '2022-07-01' group by 1;



select * from uat_ca.mc_mnp_lite_metric
where 1=1
 and request_date >= date '2021-12-01'
 and request_date < date '2022-01-01'
qualify count(*) over (partition by subs_id) > 1
;


delete uat_ca.mc_mnp_lite_metric
where 1=1
 and (request_date, subs_id) in (select request_date, subs_id from (
--==
select
 a.*,
 row_number() over (partition by subs_id order by request_date desc) as rn
from uat_ca.mc_mnp_lite_metric a
where 1=1
 and a.request_date >= date '2021-12-01'
 and a.request_date < date '2022-01-01'
qualify count(*) over (partition by subs_id) > 1
--==
) a
where 1=1
-- and subs_id = 1056951
--qualify row_number() over (partition by subs_id order by request_date desc) = 1
 and a.rn = 1
)
 and request_date >= date '2021-12-01'
 and request_date < date '2022-01-01'
;



-- �������� ��������
select
 trunc (request_date,'mm') as "�����",
 count (distinct subs_id) dis_subs,
 count (distinct cust_id) dis_cust,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_cust - row_cnt as diff_cust
from uat_ca.mc_mnp_lite_metric
group by 1
order by 1 desc;

-- ��������� ��������
select
 weeknumber_of_year (request_date, 'ISO') as "������",
 trunc (request_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct cust_id) dis_cust,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_cust - row_cnt as diff_cust
from uat_ca.mc_mnp_lite_metric
where 1=1
 and request_date >= date '2021-12-01'
 and request_date < date '2022-01-01'
group by 1,2
order by 1 desc;

-- ������� ��������
select
 request_date,
 count (distinct subs_id) dis_subs,
 count (distinct cust_id) dis_cust,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_cust - row_cnt as diff_cust
from uat_ca.mc_mnp_lite_metric
where 1=1
-- and request_date >= date '2021-12-01'
-- and request_date < date '2022-01-01'
group by 1
order by 1 desc;


select * from uat_ca.mc_mnp_lite_metric
qualify count(*) over (partition by cust_id) >1
;

select * from uat_ca.mc_mnp_lite_metric where cust_id = 2477716;

lock row for access
select * from prd2_dds.subscription
where 1=1
 and report_date = date '2022-04-26'
 and subs_id in (100071792566, 2485293)
;

--
lock row for access
select min(report_date) from prd2_dds.subscription
;


/*
--�������� ����������� ������
prd2_dds_hist.subscription          report_date < date'2021-05-12'
prd2_dds.subscription               report_date >= date'2021-05-12'

select date '2022-07-01' - interval '183' day;                                                      --2021-12-30

--2021-12-29
select min(report_date) from prd2_dds.subscription
where 1=1
 and report_date >= date '2021-12-25'
 and report_date < date '2022-01-05'
;

--������������ ������
select max_report_date from prd2_tmd_v.dds_load_status where table_name='SUBSCRIPTION';             --2022-06-29


--"��������" ������, ������� �������� (546 ����)
select date '2021-11-19' - interval '546' day;                                                      --2020-05-22


--prd2_dds_hist.subscription                               --2021-12-28
lock row for access
select max(report_date) from prd2_dds_hist.subscription
where 1=1
 and report_date >= date '2021-12-25'
 and report_date < date '2022-01-05'
;


--prd2_dds_hist.subscription                               --2020-05-22
lock row for access
select min(report_date) from prd2_dds_hist.subscription
where 1=1
 and report_date >= date '2020-05-15'
 and report_date < date '2020-05-25'
;



show view prd2_dds_v.subscription;
prd2_dds.subscription        where report_date >=  timestamp'2021-11-20'
prd2_dds_hist.subscription   where report_date <   timestamp'2021-11-20'



--dll
show view prd2_dds_v.subscription;

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

--==��� 03 ������������ �������������

select top 100 * from uat_ca.mc_mnp;                --
select top 100 * from uat_ca.mc_mnp_lite_metric;    --
select top 100 * from uat_ca.mc_mnp_xmt             --




--=================================================================================================
--=================================================================================================
--=================================================================================================

--==1 Size

--������ ���������� ��������������� ������������� �������. ���������� ������ ���� ����� 5% (���������� �������� 1 ���. 32 ���.)
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
 and lower(a.tablename) = 'mc_mnp_lite'
group by 1,2,3,4
;

--==2 Rows/AMP

--������ ���������� ������������� ����� ������� �� AMP. ���������� �� �������� ��� ������������ ��� ������������� �������� ������ ���� ������ 15%
select
 t1.amp_no,
 t1.row_cnt,
 ((t1.row_cnt/t2.row_avr_amp) - 1.0)*100 as deviation
from
(select
 hashamp(hashbucket(hashrow(request_id))) as amp_no,
 cast(count(*) as float) as row_cnt
from uat_ca.mc_mnp_lite
group by 1
) as t1,
(select cast(count(*) as float)/(hashamp()+1) as row_avr_amp from uat_ca.mc_mnp_lite) as t2
order by 2 desc
;


--������������� ����� ������� �� AMP � ������� �������

select top 100 * from uat_ca.mc_mnp_lite;

select HASHAMP(HASHBUCKET(HASHROW(request_id))) AS AMP_NO,COUNT(*)
from uat_ca.mc_mnp_lite
group by 1
order by 2;


--==3 Hash synonyms

--������ ���������� ���������� ���������� ���� ����� ��� ���������� ������� ��� ������� (���������� �������� 3 ���. 45 ���.)
/*��������, � ������� �������� rowhash ��� ������ ����� ���������, ��� ���������� ��� �������
  ���������� ���-���������, ����� ���� ���������� ������ ������������� ��� ����������
    https://www.docs.teradata.com/r/w4DJnG9u9GdDlXzsTXyItA/XfRpR9T7fWZfF_1IZWuwRg
*/
select
 hashrow(subs_id) as row_hash,
 count(*) as row_cnt
from uat_ca.mc_mnp_lite
group by 1
order by 1
having row_cnt > 10
;


--==4 �����/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('mc_mnp_lite')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          MC_MNP_LITE             MIKHAIL.CHUPIS      2022-05-23 04:42:40     null                    0,04            17,98






