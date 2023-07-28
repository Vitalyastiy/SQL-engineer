
diagnostic helpstats on for session;


select top 100 * from uat_ca.v_poll_459;
select top 100 * from uat_ca.v_poll_459 where create_date >= date '2022-12-13';



--2022
/*week 50*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2022-12-13 00:00:00', timestamp '2022-12-19 00:00:00');       --47 ���.
/*week 51*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2022-12-19 00:00:00', timestamp '2022-12-26 00:00:00');
/*week 52*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2022-12-26 00:00:00', timestamp '2023-01-02 00:00:00');


--2023
/*week 1*/  call uat_ca.mc_nps_bu_459_2 (timestamp '2023-01-02 00:00:00', timestamp '2023-01-09 00:00:00');
/*week 2*/  call uat_ca.mc_nps_bu_459_2 (timestamp '2023-01-09 00:00:00', timestamp '2023-01-16 00:00:00');
/*week 3*/  call uat_ca.mc_nps_bu_459_2 (timestamp '2023-01-16 00:00:00', timestamp '2023-01-23 00:00:00');
/*week 4*/  call uat_ca.mc_nps_bu_459_2 (timestamp '2023-01-23 00:00:00', timestamp '2023-01-30 00:00:00');
/*week 5*/  call uat_ca.mc_nps_bu_459_2 (timestamp '2023-01-30 00:00:00', timestamp '2023-02-06 00:00:00');
/*week 6*/  call uat_ca.mc_nps_bu_459_2 (timestamp '2023-02-06 00:00:00', timestamp '2023-02-13 00:00:00');

/*week 7*/  call uat_ca.mc_nps_bu_459_2 (timestamp '2023-02-13 00:00:00', timestamp '2023-02-20 00:00:00');
/*week 8*/  call uat_ca.mc_nps_bu_459_2 (timestamp '2023-02-20 00:00:00', timestamp '2023-02-27 00:00:00');
/*week 9*/  call uat_ca.mc_nps_bu_459_2 (timestamp '2023-02-27 00:00:00', timestamp '2023-03-06 00:00:00');
/*week 10*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-03-06 00:00:00', timestamp '2023-03-13 00:00:00');
/*week 11*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-03-13 00:00:00', timestamp '2023-03-20 00:00:00');
/*week 12*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-03-20 00:00:00', timestamp '2023-03-27 00:00:00');
/*week 13*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-03-27 00:00:00', timestamp '2023-04-03 00:00:00');
/*week 14*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-04-03 00:00:00', timestamp '2023-04-10 00:00:00');
/*week 15*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-04-10 00:00:00', timestamp '2023-04-17 00:00:00');
/*week 16*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-04-17 00:00:00', timestamp '2023-04-24 00:00:00');
/*week 17*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-04-24 00:00:00', timestamp '2023-05-01 00:00:00');
/*week 18*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-05-01 00:00:00', timestamp '2023-05-08 00:00:00');
/*week 19*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-05-08 00:00:00', timestamp '2023-05-15 00:00:00');
/*week 20*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-05-15 00:00:00', timestamp '2023-05-22 00:00:00');
/*week 21*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-05-22 00:00:00', timestamp '2023-05-29 00:00:00');
/*week 22*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-05-29 00:00:00', timestamp '2023-06-05 00:00:00');
/*week 23*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-06-05 00:00:00', timestamp '2023-06-12 00:00:00');
/*week 24*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-06-12 00:00:00', timestamp '2023-06-19 00:00:00');
/*week 25*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-06-19 00:00:00', timestamp '2023-06-26 00:00:00');
/*week 26*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-06-26 00:00:00', timestamp '2023-07-03 00:00:00');
/*week 27*/ call uat_ca.mc_nps_bu_459_2 (timestamp '2023-07-03 00:00:00', timestamp '2023-07-10 00:00:00');

--delete uat_ca.poll_id_459 where create_date >= date '2022-12-13';



-- ��� ��������� ������������ ���� � ������ ������ ���������, ���� �� �� ���������� ����������� ������ �� ������� �����:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_459_2'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


--1 ��������� ��������
select
 weeknumber_of_year (create_date, 'ISO') as "������",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1,2
order by 2 desc;

--2 �������� ��������
select
 trunc (create_date,'mm') as "�����",
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1
order by 1 desc;

--3 ������� ��������
select
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1
order by 1 desc;


select * from prd2_odw_v.smspoll_polls
where 1=1
 and poll_id in (459);

459     --��������� ������� ��

select * from prd2_odw_v.smspoll_polls where lower(poll_name) like '%���������%';

473     --����������_����� Telesales

--==================================================================================================
--==UpDate �������==================================================================================
--==================================================================================================


show table uat_ca.poll_id_459;

create multiset table uat_ca.poll_id_459 (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 cuvo_mark varchar(1024) character set unicode not casespecific,
 ans_1 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific,
 cuvo number,
 load_id integer)
primary index (subs_id);


RENAME TABLE
uat_ca.poll_id_459
as
uat_ca.poll_id_459_tmp
;


insert into uat_ca.poll_id_459
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_1,
 mark_2,
 mark_3,
 mark_4,
 null as cuvo_mark,
 ans_1,
 ans_2,
 ans_3,
 null as cuvo,
 load_id
from uat_ca.poll_id_459_tmp
;

select top 100 * from uat_ca.poll_id_459;
select top 100 * from uat_ca.v_poll_459;
select top 100 * from uat_ca.poll_id_459_tmp;


select
 weeknumber_of_year (create_date, 'ISO') as "������",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.poll_id_459
group by 1,2
order by 2 desc;

--drop table uat_ca.poll_id_459_tmp;



--==View
show view uat_ca.v_poll_459;

replace view uat_ca.v_poll_459 as
lock row for access
select
 a.create_date,
 t2.cluster_name as cluster_name,
 t4.macroregion_name as macroregion,
 t3.region_name as region,
 'In_house' as point_name,
 a.msisdn,
 a.subs_id,
 -- treatment_code,
 case when a.ans_1 = '������' then a.mark_1 end as mark_1,
 case when a.ans_2 = '������' then a.mark_2 end as mark_2,
 case when a.ans_3 = '������' then a.mark_3 end as mark_3,
 a.mark_4,
 a.cuvo_mark,
 a.ans_1,
 a.ans_2,
 a.ans_3,
 a.cuvo
-- load_id,
from uat_ca.poll_id_459 a
--
left join prd2_dds_v.phone_number_2 t1 on a.msisdn = t1.msisdn
 and (a.create_date >= t1.stime and a.create_date < t1.etime)
left join prd2_dic_v.branch t2 on t1.branch_id = t2.branch_id
left join prd2_dic_v.region t3 on t2.region_id = t3.region_id
left join prd2_dic_v.macroregion t4 on t3.macroregion_id = t4.macroregion_id
;


--==��� ������� ��� poll_id 473

--���������� q_text
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 473
order by 3, 1;


--Step 1
������������, ��� Tele2. ��� ����� ����� ���� ������. ����������, �������� �� ��� ������� �������. ����� ��� ������ ��������� Tele2 �� ������� �������/�����. ��� �� ����� ��� ������? ��������� �������� SMS c ������, ��� 1 - �����, 2 - �� �����. SMS ����������. 

--Step 2  ������� 1-9
��� �� ������� ��� ��� ������ ������? ��������� �������� SMS c ������, ���: 1 - ������ �������, 2- ������ ����������.

--Step 3 ������ 7
�������, ����������, ���� ���������� �������� �������� ������ � ��������� � ������� �������� Tele2. ��������� ����� �������, �� ���������� �����. ��������� � ����� �����, ��� 1 - ������ ��, 2 - ������ ���.

--Step 4 
�������! ���� ������ ��� ��� ����� �����. ���� �� ���� �� �������� �� �������� �2�, � �������� SMS ���������, ����������, ����������� � ������� ����� ������.


--==================================================================================================
--==��������� � 13 ������� 2022 ����--==============================================================
--==================================================================================================

REPLACE PROCEDURE uat_ca.mc_nps_bu_459_2 (in stime timestamp, in etime timestamp)
SQL SECURITY INVOKER
BEGIN

-- ���������� ����������
DECLARE proc varchar(50);
DECLARE LOAD_ID int;
DECLARE ERR_MSG VARCHAR(4000) DEFAULT '';
DECLARE ERR_SQLCODE INT;
DECLARE ERR_SQLSTATE INT;
DECLARE ROW_CNT INT;

-- ������ �� ����� ������� SQL ����
DECLARE EXIT HANDLER FOR SqlException
BEGIN
SET ERR_SQLCODE = Cast(SqlCode AS INTEGER);
SET ERR_SQLSTATE = Cast(SqlState AS INTEGER);
SELECT ErrorText INTO :ERR_MSG FROM dbc.errormsgs WHERE Errorcode = :ERR_SQLCODE;
CALL uat_ca.prc_debug (:proc, :load_id, session, 0, 'An error occured during execution: ' || :ERR_MSG);
END;

SET proc = 'nps_459_2';           -- ������������ �������

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;

-- ����������� ������ ������� ������
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START');


--=================================================================================================

--01 ������� ������

--drop table soa;

create multiset volatile table soa, no log (
 created_date timestamp(0),
 treatment_code varchar(9) character set unicode not casespecific,
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 q_step byteint,
 mark varchar(1024) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa
select
 created_dttm as created_date,
 treatment_code,
 msisdn,
 subs_id,
 q_step,
 mark,
-- load_id
 :load_id
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id in (459)
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2022-12-13 00:00:00'
-- and created_dttm < timestamp '2022-12-19 00:00:00'
;

--select top 100 * from soa;
--select top 100 * from soa where msisdn = '79044505246';


-- ����������� �������� �������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'INTERVAL_DATE '|| to_char(cast(stime as date),'DD.MM.YYYY') || '_' ||to_char(cast(etime as date),'DD.MM.YYYY') || ' ����� �����: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--02 ����������������

COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (MSISDN),
 COLUMN (TREATMENT_CODE),
 COLUMN (CREATED_DATE ,TREATMENT_CODE ,MSISDN ,SUBS_ID ,LOAD_ID),
 COLUMN (LOAD_ID)
ON soa;

--drop table soa_2;

create multiset volatile table soa_2, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 create_date date format 'yy/mm/dd',
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa_2
select
 msisdn,
 subs_id,
 cast(created_date as date) as create_date,
 treatment_code,
 max (step_1) as mark_1,
 max (step_2) as mark_2,
 max (step_3) as mark_3,
 max (step_4) as mark_4,
 load_id
from (
select * from soa pivot (max(mark) for q_step in (
 '1' as step_1,
 '2' as step_2,
 '3' as step_3,
 '4' as step_4
)) t2
) a
--where msisdn= '79044505246'
group by 1,2,3,4,9
;

--select * from soa_2;


--03 Step 1 �����������������
/*
������������, ��� Tele2. ��� ����� ����� ���� ������, ����������, �������� �� ��� ������� �������.
��� ������ ��������� Tele2, ������� ����� ����������� �� ��������� �� ������������. ��������� ��������
SMS c ������ �� 1 �� 5, ��� 1 - ������� �� ������������, � 5 - ���������� ������������.
��� ��������� � �������� � ������ Tele2 � �������� ����.
*/

create multiset volatile table soa_step1, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 cuvo_mark varchar(1024) character set unicode not casespecific,
 cuvo varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

create multiset volatile table soa_step1_1, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 cuvo_mark varchar(1024) character set unicode not casespecific,
 cuvo number)
primary index (msisdn)
on commit preserve rows;


insert into soa_step1
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1 as cuvo_mark,
 case when a.ans_1_1 = '-' then a.ans_1_3 else a.ans_1_1 end as cuvo
from (
select
 a.*,
 case when a.ans_1_2 in ('1','2','3','4','5') then a.ans_1_2 else '-' end as ans_1_3
from ( 
select
 a.*,
 case when a.ans_1_new is not null
      then cast(otranslate(a.ans_1_new,' ','') as varchar(255)) end as ans_1_1,
 cast (case when ans_1_1 = '-'
      then oreplace (a.ans_1, regexp_replace(a.ans_1, '[[:alnum:]]'),'') else '-' end as varchar (255))as ans_1_2
from (
select
 a.*,
 length(trim(otranslate(a.ans_1,otranslate(a.ans_1,'12345',''),''))) ans_1_single,
 length(trim(otranslate(a.ans_1,'12345',''))) ans_1_text,
 case when ans_1_single>0 and ans_1_text=0 then cast(a.ans_1 as varchar(255)) else cast('-' as varchar(255)) end ans_1_new
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_1,
 trim (regexp_replace(trim (both ',' from trim (both '.' from trim(oreplace(mark_1,'.00','')))),'652','',1,1)) ans_1
from soa_2
) a
) a
) a
) a
;

insert into soa_step1_1
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 cuvo_mark,
 to_number(case when cuvo_mark is null then null
                when cuvo in ('1','2','3','4','5') then cuvo
           else '-1' end) as cuvo
from soa_step1
;

--select * from soa_step1_1;



--==04 Step 2 ������� ������� - mark_1, ans_1
/*
��� �� ����� ��� ������? ��������� �������� SMS c ������, ��� 1 - �����, 2 - �� �����.
*/

--drop table soa_step2;
--drop table soa_step2;

create multiset volatile table soa_step2, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 ans_1 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

insert into soa_step2
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_2 as mark_1,
 case when a.ans_2 is null then null
      when a.ans_2 = 1 then '�����'
      when a.ans_2 = 2 then '�� �����'
      when a.ans_2 = -1 then '������'
      else '-1' end as ans_1
from (
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_2,
 length (oreplace(oreplace(oreplace(upper(a.mark_2),' ',''),',',''),'.','')) length_step_2,
 case when a.mark_2 is null then null
      when length_step_2 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(a.mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2')
                then regexp_substr(oreplace(oreplace(oreplace(upper(a.mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from soa_2 a
) a
;

--select * from soa_step2;


--==05 Step 3 ���������� ������ - mark_2, ans_2
/*
��� �� ������� ��� ��� ������ ������? ��������� �������� SMS c ������, ���: 1 - ������ �������, 2- ������ ����������.
*/

--delete soa_step3_1;
--delete soa_step3;

create multiset volatile table soa_step3_1, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 length_step_3 number,
 ans_3 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

create multiset volatile table soa_step3, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step3_1
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_3,
 length (oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.','')) length_step_3,
 case when mark_3 is null then null
      when length_step_3 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[0-9]\d{0,2}') in ('1', '2')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[0-9]\d{0,2}') else '-1' end
      else '-1' end as ans_3
from soa_2
;

insert into soa_step3
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_3 as mark_2,
 case when ans_3 is null then null
      when ans_3 = -1 then '������'
      when ans_3 = 1 then '�������'
      when ans_3 = 2 then '�� �������'
      else '-1' end as ans_2
from soa_step3_1
;

--select * from soa_step3;


--==06 Step 4
/*
�������! ���� ������ ��� ��� ����� �����. ���� �� ���� �� �������� �� �������� �2�, � �������� SMS ���������, ����������, ����������� � ������� ����� ������.
*/



--==07 �������� ������
COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step1_1;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step3;


--drop table soa_fin;

--select top 100 * from soa_step1_1;      --step_1: cuvo
--select top 100 * from soa_step2;        --step_2: mark_1
--select top 100 * from soa_step3;        --step_3: mark_2


create multiset volatile table soa_fin, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 cuvo_mark varchar(1024) character set unicode not casespecific,
 ans_1 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 cuvo number,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa_fin
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 t2.mark_1,                        --������� �������
 t3.mark_2,                        --���������� ������
 a.mark_4 as mark_3,               --mark_4 (step_4) �����������
 t1.cuvo_mark,                     --�����������������
 t2.ans_1,
 t3.ans_2,
 t1.cuvo,
 a.load_id
from soa_2 a
--
left join soa_step1_1  t1 on a.msisdn = t1.msisdn and a.create_date = t1.create_date    --�����������������
left join soa_step2    t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date    --������� �������
left join soa_step3    t3 on a.msisdn = t3.msisdn and a.create_date = t3.create_date    --���������� ������
;

--select * from soa_fin;


--==08 ���������� �������

--drop table subs_tmp;

create multiset volatile table subs_tmp ,no log (
 create_date date format 'yy/mm/dd',
 subs_id decimal(12,0),
 msisdn varchar(20) character set unicode not casespecific)
primary index (subs_id)
on commit preserve rows;


insert into subs_tmp
select create_date, subs_id, msisdn from soa_fin
qualify row_number () over (partition by msisdn order by create_date) = 1
;


COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (CREATE_DATE ,SUBS_ID)
ON soa_fin;

COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (CREATE_DATE ,SUBS_ID)
ON subs_tmp;


--drop table soa_fin2;

create multiset volatile table soa_fin2, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 cuvo_mark varchar(1024) character set unicode not casespecific,
 ans_1 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 cuvo number,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


--�������� � ��������
insert into soa_fin2
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 coalesce(a.mark_1,  t1.mark_1) as mark_1,
 coalesce(a.mark_2,  t1.mark_2) as mark_2,
 coalesce(a.mark_3,  t1.mark_3) as mark_3,
 coalesce(a.cuvo_mark,  t1.cuvo_mark) as cuvo_mark,
 coalesce(a.ans_1,   t1.ans_1) as ans_1,
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.cuvo,   t1.cuvo) as cuvo,
 coalesce(a.load_id, t1.load_id) as load_id
from soa_fin a
--
inner join subs_tmp b on a.subs_id = b.subs_id
 and a.create_date = b.create_date
--
inner join (
select a.* from soa_fin a
left join subs_tmp b on a.subs_id = b.subs_id
 and a.create_date = b.create_date
where 1=1
 and b.subs_id is null
) t1 on a.subs_id = t1.subs_id
;

--select * from soa_fin2;
--select * from soa where subs_id = 13248138;
--select * from soa_2 where subs_id = 13248138;
--select * from soa_step1_1 where subs_id = 13248138;


-- ����������� �������� �������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� �� �������: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--�������� ��� �������
insert into soa_fin2
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 a.mark_2,
 a.mark_3,
 a.cuvo_mark,
 a.ans_1,
 a.ans_2,
 a.cuvo,
 a.load_id
from soa_fin a
left join (
select a.* from soa_fin a
left join subs_tmp b on a.subs_id = b.subs_id
 and a.create_date = b.create_date
where 1=1
 and b.subs_id is null
) b on a.subs_id = b.subs_id
where 1=1
 and b.subs_id is null
;

--select top 100 * from soa_fin2;


--==09 ������� �� �����

--select top 100 * from uat_ca.poll_id_459;
--select max(create_date) from uat_ca.poll_id_459;  --2022-12-12

insert into uat_ca.poll_id_459
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_1,
 mark_2,
 null as mark_3,
 mark_3 as mark_4,
 cuvo_mark,
 ans_1,
 ans_2,
 null as ans_3,
 cuvo,
 load_id
from soa_fin2
;


-- ����������� �������� �������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� ��� �������: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


drop table soa;
drop table soa_2;
drop table soa_step1;
drop table soa_step1_1;
drop table soa_step2;
drop table soa_step3;
drop table soa_step3_1;
drop table soa_fin;
drop table soa_fin2;
drop table subs_tmp;

-- ����������� ��������� ������� ������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,1,'END');


END;



--==================================================================================================
--==��������� �� 2022-12-13=========================================================================
--==================================================================================================

/*
�������, ����� ������� 30.05.22

Poll_id = 135 

*/

--
lock table prd2_odw.smspoll_communication_lists for access
lock table prd2_odw.smspoll_poll_lists for access
select
 weeknumber_of_year (a.created_date, 'ISO') as "������",
 trunc (a.created_date,'iw') as first_day_week,
 cast(a.created_date as date) as create_date,
 count(distinct msisdn)
from prd2_odw.smspoll_communication_lists a
inner join prd2_odw.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2022-06-01 00:00:00'
 and b.created_date < timestamp '2022-07-01 00:00:00'
 and b.poll_id = 459
where 1=1
 and a.created_date >= timestamp '2022-06-01 00:00:00'
 and a.created_date < timestamp '2022-07-01 00:00:00'
group by 1,2,3
order by 3;

22,     2022-05-30,     2022-05-30,     60392, 1941 3,2% response



select * from prd2_odw_v.smspoll_polls
where 1=1
 and poll_id in (459);


--��������� ������� ��      (poll_id = 459)

--���������� q_text
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 459
order by 3, 1;


--Step 1
/*
������������, ��� Tele2. ��� ����� ����� ���� ������, ����������, �������� �� ��� ������� �������. 
����� ��� ������ ��������� Tele2 �� ������� �������� ���������� ���������. ��� �� ����� ��� ������? 
��������� �������� SMS c ������, ��� 1 - �����, 2 - �� �����. SMS ����������. 
*/

--� 13 �������
������������, ��� Tele2. ��� ����� ����� ���� ������, ����������, �������� �� ��� ������� �������.
��� ������ ��������� Tele2, ������� ����� ����������� �� ��������� �� ������������.
��������� �������� SMS c ������ �� 1 �� 5, ��� 1 - ������� �� ������������, � 5 - ���������� ������������.
��� ��������� � �������� � ������ Tele2 � �������� ����.


--Step 2
/*
��� �� ������� ��� ��� ������ ������? ��������� �������� SMS c ������, ���: 1 - ������ �������, 2- ������ ����������.
*/

--� 13 �������
��� �� ����� ��� ������? ��������� �������� SMS c ������, ��� 1 - �����, 2 - �� �����.


--Step 3
/*
�������, ����������, ���� ���������� �������� �������� ������ � ��������� � ������� �������� Tele2. 
��������� ����� �������, �� ���������� �����. ��������� � ����� �����, ��� 1 - ������ ��, 2 - ������ ���.
*/

--� 13 �������
��� �� ������� ��� ��� ������ ������? ��������� �������� SMS c ������, ���: 1 - ������ �������, 2- ������ ����������.


--Step 4  ����������� ��� "������"
/*
�������! ���� ������ ��� ��� ����� �����.
���� �� ���� �� �������� �� �������� �2�, � �������� SMS ���������, ����������, ����������� � ������� ����� ������.
*/

--� 13 �������
�������! ���� ������ ��� ��� ����� �����. ���� �� ���� �� �������� �� �������� �2�, � �������� SMS ���������, ����������, ����������� � ������� ����� ������.



select
 cast (created_dttm as date) as created_date,
 count(*)
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id = 459
group by 1
order by 1
;


select
 top 100 *
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id = 459
 and created_dttm >= timestamp '2022-07-25 00:00:00'
 and created_dttm < timestamp '2022-07-26 00:00:00'
;



--=================================================================================================

REPLACE PROCEDURE uat_ca.mc_nps_bu_459 (in stime timestamp, in etime timestamp)
SQL SECURITY INVOKER
BEGIN

-- ���������� ����������
DECLARE proc varchar(50);
DECLARE LOAD_ID int;
DECLARE ERR_MSG VARCHAR(4000) DEFAULT '';
DECLARE ERR_SQLCODE INT;
DECLARE ERR_SQLSTATE INT;
DECLARE ROW_CNT INT;

-- ������ �� ����� ������� SQL ����
DECLARE EXIT HANDLER FOR SqlException
BEGIN
SET ERR_SQLCODE = Cast(SqlCode AS INTEGER);
SET ERR_SQLSTATE = Cast(SqlState AS INTEGER);
SELECT ErrorText INTO :ERR_MSG FROM dbc.errormsgs WHERE Errorcode = :ERR_SQLCODE;
CALL uat_ca.prc_debug (:proc, :load_id, session, 0, 'An error occured during execution: ' || :ERR_MSG);
END;

SET proc = 'nps_459';           -- ������������ �������

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;

-- ����������� ������ ������� ������
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START');


--=================================================================================================

--01 ������� ������

--drop table soa;

create multiset volatile table soa, no log (
 created_date timestamp(0),
 treatment_code varchar(9) character set unicode not casespecific,
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 q_step byteint,
 mark varchar(1024) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa
select
 created_dttm as created_date,
 treatment_code,
 msisdn,
 subs_id,
 q_step,
 mark,
 load_id
-- :load_id
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id in (459)
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2022-06-01 00:00:00'
-- and created_dttm < timestamp '2022-06-02 00:00:00'
;

--select top 100 * from soa;
--select top 100 * from soa where msisdn = '79044505246';


-- ����������� �������� �������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'INTERVAL_DATE '|| to_char(cast(stime as date),'DD.MM.YYYY') || '_' ||to_char(cast(etime as date),'DD.MM.YYYY') || ' ����� �����: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--02 ����������������

COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (MSISDN),
 COLUMN (TREATMENT_CODE),
 COLUMN (CREATED_DATE ,TREATMENT_CODE ,MSISDN ,SUBS_ID ,LOAD_ID),
 COLUMN (LOAD_ID)
ON soa;

--drop table soa_2;

create multiset volatile table soa_2, no log (
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 create_date date format 'yy/mm/dd',
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa_2
select
 msisdn,
 subs_id,
 cast(created_date as date) as create_date,
 treatment_code,
 max (step_1) as mark_1,
 max (step_2) as mark_2,
 max (step_3) as mark_3,
 max (step_4) as mark_4,
 load_id
from (
select * from soa pivot (max(mark) for q_step in (
 '1' as step_1,
 '2' as step_2,
 '3' as step_3,
 '4' as step_4
)) t2
) a
--where msisdn= '79044505246'
group by 1,2,3,4,9
;

--select * from soa_2;


--03 Step 1 ���������� ������������� (NPS)
/*
������������, ��� Tele2. ��� ����� ����� ���� ������, ����������, �������� �� ��� ������� �������. 
����� ��� ������ ��������� Tele2 �� ������� �������� ���������� ���������. ��� �� ����� ��� ������? 
��������� �������� SMS c ������, ��� 1 - �����, 2 - �� �����. SMS ����������. 
*/

--drop table soa_nps;
--drop table soa_nps2;

create multiset volatile table soa_step1, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 ans_1 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

insert into soa_step1
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 case when a.ans_1 is null then null
      when a.ans_1 = 1 then '�����'
      when a.ans_1 = 2 then '�� �����'
      when a.ans_1 = -1 then '������'
      else '-1' end as ans_1
from (
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 length (oreplace(oreplace(oreplace(upper(a.mark_1),' ',''),',',''),'.','')) length_step_1,
 case when a.mark_1 is null then null
      when length_step_1 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(a.mark_1),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2')
                then regexp_substr(oreplace(oreplace(oreplace(upper(a.mark_1),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_1
from soa_2 a
) a
;

--select * from soa_step1;


--04 Step 2 
/*
��� �� ������� ��� ��� ������ ������? ��������� �������� SMS c ������, ���: 1 - ������ �������, 2- ������ ����������.
*/

--drop table soa_step2;

--delete soa_step2_1;
--delete soa_step2;

create multiset volatile table soa_step2_1, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 length_step_2 number,
 ans_2 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

create multiset volatile table soa_step2, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step2_1
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_2,
 length (oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.','')) length_step_2,
 case when mark_2 is null then null
      when length_step_2 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[0-9]\d{0,2}') in ('1', '2')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[0-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from soa_2
;

insert into soa_step2
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_2,
 case when ans_2 is null then null
      when ans_2 = -1 then '������'
      when ans_2 = 1 then '�������'
      when ans_2 = 2 then '�� �������'
      else '-1' end as ans_2
from soa_step2_1
;

--select * from soa_step2;


--05 Step 3
/*
�������, ����������, ���� ���������� �������� �������� ������ � ��������� � ������� �������� Tele2.
��������� ����� �������, �� ���������� �����. ��������� � ����� �����, ��� 1 � ������ ��, 2 � ������ ���.
*/


create multiset volatile table soa_step3, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step3
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_3,
 case when a.ans_3 is null then null
      when a.ans_3 = 1 then '������ ��'
      when a.ans_3 = 2 then '������ ���'
      when a.ans_3 = -1 then '������'
      else '-1' end as ans_3
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_3,
 length (oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.','')) length_step_3,
 case when mark_3 is null then null
      when length_step_3 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_3
from soa_2
) a
;

--select * from soa_step3;



--==06 Step 4
/*
�������! ���� ������ ��� ��� ����� �����. ���� �� ���� �� �������� �� �������� �2�, � �������� SMS ���������, ����������, ����������� � ������� ����� ������.
*/


--12 �������� ������
COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step1;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step3;


--drop table soa_fin;

create multiset volatile table soa_fin, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 ans_1 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa_fin
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,              --���������� ������������� (NPS)
 a.mark_2,
 a.mark_3,
 a.mark_4,
 t1.ans_1,
 t2.ans_2,
 t3.ans_3,
 a.load_id
from soa_2 a
--
left join soa_step1   t1 on a.msisdn = t1.msisdn and a.create_date = t1.create_date
left join soa_step2   t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date
left join soa_step3   t3 on a.msisdn = t3.msisdn and a.create_date = t3.create_date
;

--select * from soa_fin;


--06 ���������� �������

--drop table subs_tmp;

create multiset volatile table subs_tmp ,no log (
 create_date date format 'yy/mm/dd',
 subs_id decimal(12,0),
 msisdn varchar(20) character set unicode not casespecific)
primary index (subs_id)
on commit preserve rows;


insert into subs_tmp
select create_date, subs_id, msisdn from soa_fin
qualify row_number () over (partition by msisdn order by create_date) = 1
;


COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (CREATE_DATE ,SUBS_ID)
ON soa_fin;

COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (CREATE_DATE ,SUBS_ID)
ON subs_tmp;


--�������� � ��������
insert into uat_ca.poll_id_459
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 coalesce(a.mark_1,  t1.mark_1) as mark_1,
 coalesce(a.mark_2,  t1.mark_2) as mark_2,
 coalesce(a.mark_3,  t1.mark_3) as mark_3,
 coalesce(a.mark_4,  t1.mark_3) as mark_4,
 coalesce(a.ans_1,   t1.ans_1) as ans_1,
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.ans_3,   t1.ans_3) as ans_3,
 coalesce(a.load_id, t1.load_id) as load_id
from soa_fin a
--
inner join subs_tmp b on a.subs_id = b.subs_id
 and a.create_date = b.create_date
--
inner join (
select a.* from soa_fin a
left join subs_tmp b on a.subs_id = b.subs_id
 and a.create_date = b.create_date
where 1=1
 and b.subs_id is null
) t1 on a.subs_id = t1.subs_id
;

-- ����������� �������� �������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� �� �������: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


--�������� ��� �������
insert into uat_ca.poll_id_459
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 a.mark_2,
 a.mark_3,
 a.mark_4,
 a.ans_1,
 a.ans_2,
 a.ans_3,
 a.load_id
from soa_fin a
left join (
select a.* from soa_fin a
left join subs_tmp b on a.subs_id = b.subs_id
 and a.create_date = b.create_date
where 1=1
 and b.subs_id is null
) b on a.subs_id = b.subs_id
where 1=1
 and b.subs_id is null
;


-- ����������� �������� �������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� ��� �������: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


drop table soa;
drop table soa_2;
drop table soa_step1;
drop table soa_step2;
drop table soa_step2_1;
drop table soa_step3;
drop table soa_fin;
drop table subs_tmp;

-- ����������� ��������� ������� ������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,1,'END');


END;


--=================================================================================================
--=================================================================================================
--=================================================================================================

--2022
/*week 17*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-04-25 00:00:00', timestamp '2022-05-02 00:00:00');-- 4 ���. 56 ���.
/*week 18*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-05-02 00:00:00', timestamp '2022-05-09 00:00:00');-- 4 ���. 56 ���.
/*week 19*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-05-09 00:00:00', timestamp '2022-05-16 00:00:00');-- 4 ���. 56 ���.
/*week 20*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-05-16 00:00:00', timestamp '2022-05-23 00:00:00');-- 4 ���. 56 ���.
/*week 21*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-05-23 00:00:00', timestamp '2022-05-30 00:00:00');-- 4 ���. 56 ���.

/*week 22*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-05-30 00:00:00', timestamp '2022-06-06 00:00:00');-- 4 ���. 56 ���.
/*week 23*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-06-06 00:00:00', timestamp '2022-06-13 00:00:00');-- 2 ���. 55 ���.
/*week 24*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-06-13 00:00:00', timestamp '2022-06-20 00:00:00');
/*week 25*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-06-20 00:00:00', timestamp '2022-06-27 00:00:00');-- 34 ���.

/*week 26*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-06-27 00:00:00', timestamp '2022-07-04 00:00:00');-- 2 ���. 38 ���.
/*week 27*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-07-04 00:00:00', timestamp '2022-07-11 00:00:00');-- 3 ���. 34 ���.
/*week 28*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-07-11 00:00:00', timestamp '2022-07-18 00:00:00');-- 
/*week 29*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-07-18 00:00:00', timestamp '2022-07-25 00:00:00');-- 16 ���.
/*week 30*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-07-25 00:00:00', timestamp '2022-08-01 00:00:00');

/*week 31 ��������� ����*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-08-01 00:00:00', timestamp '2022-08-04 00:00:00');
/*week 31 ��������� ����*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-08-04 00:00:00', timestamp '2022-08-08 00:00:00');

/*week 32*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-08-08 00:00:00', timestamp '2022-08-15 00:00:00');
/*week 33*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-08-15 00:00:00', timestamp '2022-08-22 00:00:00');
/*week 34*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-08-22 00:00:00', timestamp '2022-08-29 00:00:00');
/*week 35*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-08-29 00:00:00', timestamp '2022-09-05 00:00:00');
/*week 36*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-09-05 00:00:00', timestamp '2022-09-12 00:00:00');
/*week 37*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-09-12 00:00:00', timestamp '2022-09-19 00:00:00');
/*week 38*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-09-19 00:00:00', timestamp '2022-09-26 00:00:00');
/*week 39*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-09-26 00:00:00', timestamp '2022-10-03 00:00:00');
/*week 40*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-10-03 00:00:00', timestamp '2022-10-10 00:00:00');
/*week 41*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-10-10 00:00:00', timestamp '2022-10-17 00:00:00');   --20 ���. 57 ���.
/*week 42*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-10-17 00:00:00', timestamp '2022-10-24 00:00:00');
/*week 43*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-10-24 00:00:00', timestamp '2022-10-31 00:00:00');
/*week 44*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-10-31 00:00:00', timestamp '2022-11-07 00:00:00');
/*week 45*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-11-07 00:00:00', timestamp '2022-11-14 00:00:00');

/*week 46*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-11-14 00:00:00', timestamp '2022-11-21 00:00:00');
/*week 47*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-11-21 00:00:00', timestamp '2022-11-28 00:00:00');
/*week 48*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-11-28 00:00:00', timestamp '2022-12-05 00:00:00');
/*week 49*/ call uat_ca.mc_nps_bu_459 (timestamp '2022-12-05 00:00:00', timestamp '2022-12-12 00:00:00');



--delete uat_ca.poll_id_459;

-- ��� ��������� ������������ ���� � ������ ������ ���������, ���� �� �� ���������� ����������� ������ �� ������� �����:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_459'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


-- �������� �����
select * from uat_ca.mc_logs order by 1;


--����������
COLLECT SUMMARY STATISTICS ON uat_ca.poll_id_459;

COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (SUBS_ID),
 COLUMN (MSISDN)
ON uat_ca.poll_id_459;


-- �������� ������
select top 100 * from uat_ca.poll_id_459;
select top 100 * from uat_ca.poll_id_459 where create_date >= date '2022-07-25';


--1 ��������� ��������
select
 weeknumber_of_year (create_date, 'ISO') as "������",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1,2
order by 2 desc;

--2 �������� ��������
select
 trunc (create_date,'mm') as "�����",
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1
order by 1 desc;

--3 ������� ��������
select 
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1
order by 1 desc;


select * from uat_ca.poll_id_459
where 1=1
 and create_date >= date '2022-10-24'
 and create_date < date '2022-10-31'
qualify count(*) over (partition by subs_id) > 1;

--delete uat_ca.poll_id_459 where subs_id = 100035974911 and create_date = date '2022-10-24' and mark_2 is null;


--=================================================================================================
--=================================================================================================
--=================================================================================================


select  * from uat_ca.poll_id_459;

--View
replace view uat_ca.v_poll_459 as
lock row for access
select
 a.create_date,
 t2.cluster_name as cluster_name,
 t4.macroregion_name as macroregion,
 t3.region_name as region,
 'In_house' as point_name,
 a.msisdn,
 a.subs_id,
 -- treatment_code,
 case when a.ans_1 = '������' then a.mark_1 end as mark_1,
 case when a.ans_2 = '������' then a.mark_2 end as mark_2,
 case when a.ans_3 = '������' then a.mark_3 end as mark_3,
 a.mark_4,
 a.ans_1,
 a.ans_2,
 a.ans_3
-- load_id,
from uat_ca.poll_id_459 a
--
left join prd2_dds_v.phone_number_2 t1 on a.msisdn = t1.msisdn
 and (a.create_date >= t1.stime and a.create_date < t1.etime)
left join prd2_dic_v.branch t2 on t1.branch_id = t2.branch_id
left join prd2_dic_v.region t3 on t2.region_id = t3.region_id
left join prd2_dic_v.macroregion t4 on t3.macroregion_id = t4.macroregion_id
;


select top 100 * from uat_ca.v_poll_459;
select count(*) from uat_ca.v_poll_459 where region is null;



--1 ��������� ��������
select
 weeknumber_of_year (create_date, 'ISO') as "������",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1,2
order by 2 desc;

--2 �������� ��������
select
 trunc (create_date,'mm') as "�����",
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1
order by 1 desc;

--3 ������� ��������
select 
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1
order by 1 desc;



--=================================================================================================
--=================================================================================================
--=================================================================================================

--show table uat_ca.poll_id_459;

create multiset table uat_ca.poll_id_459 (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 ans_1 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific,
 load_id integer)
primary index (subs_id)
;

