
diagnostic helpstats on for session;

select top 100 * from uat_ca.poll_id_185 where create_date >= date '2023-02-01';

select ans_2, count(*) from uat_ca.poll_id_185
where 1=1
 and create_date >= date '2023-01-01'
 and create_date < date '2023-02-01'
group by 1
;

select trunc(create_date, 'mm'), count(*) from uat_ca.poll_id_185
where 1=1
 and create_date >= date '2023-01-01'
 and create_date < date '2023-03-01'
group by 1
;


select top 100 * from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id = 185
-- and created_dttm >= :stime
-- and created_dttm < :etime
 and created_dttm >= timestamp '2023-02-01 00:00:00'
 and created_dttm < timestamp '2023-03-01 00:00:00'
;

select mark, count(*) from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id = 185
-- and created_dttm >= :stime
-- and created_dttm < :etime
 and created_dttm >= timestamp '2023-02-01 00:00:00'
 and created_dttm < timestamp '2023-03-01 00:00:00'
 and q_step = 2
group by 1
;

select q_step, count(*) from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id = 185
-- and created_dttm >= :stime
-- and created_dttm < :etime
 and created_dttm >= timestamp '2023-02-01 00:00:00'
 and created_dttm < timestamp '2023-03-01 00:00:00'
group by 1
;



select top 100 * from sbx_ss.nps_sample;

select ans_1, count(*) from sbx_ss.nps_sample
where 1=1
 and create_date >= date '2023-01-01'
 and create_date < date '2023-02-01'
 and point_name = '�������-�����'
group by 1
;


show procedure uat_ca.mc_nps_bu_185;

/*
2022-01-10
*/

--=================================================================================================

--����� �������� NPS_��_V11_22
select * from prd2_odw_v.smspoll_polls
where 1=1
 and poll_id in (185);

--���������� q_text
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 185
order by 3, 1;


--11
--1
�������, ��� ����������� Tele2! �������� ��� ���� �������������� �� ������� ���������, ������� ���������� ������������� Tele2 �� 1 �� 10, ��� 1-����� �� ������������,
10-����� ������������. ��������� ����� � �����. SMS �� ���� ����� ���������.

/*old
�������, ��� �� � Tele2! �� ���������� � ������ ��������� � �� ������ ��� �������� �� 3 ������� � �������� ������������. 
��� �� ����� ������, �� �������� �� ����������? ��������� ���� ����� � ����� 
1- ��, � ������� ���������
2- ��, �� ����� ���������� ���������
3- ���
SMS �� ���� ����� ���������
*/

--2
��� �� ����� ������, �� �������� �� ���������� � ������ ��������� Tele2? ��������� ���� ����� � �����
1.��, � ������� ���������
2.��, �� ����� ���������� ���������
3.���

/*old
��� ������ ����� ��� ��������� �������� � ������ ���������?
1.���������������� ������ ����������
2.���������� ���������� ������
3.���������� ����������
4.�������� ������� �������
5.����� �������� ���������� � ����������
6.��� ����������
7.������ (�������� ��� ������)
��������� ���� ����� � �����
*/

--3
����� ����������, ���� � ����� �� ������ ��������� �� ��������, ��� ��� ����� �������� � ������ �������, ����� �� ����� ����� ������������� Tele2?

/*old
� ��������� ������. ������� ���������� ������������� �������� Tele2 ������ � ������� �� 1 �� 10, ��� 1 - ����� �� ������������, 10 - ����� ������������.
*/

--4
������� �� ������� � ������, �������� ��� ���!

/*old
������� �� �������! ����� ����������, ���� � ����� �� ������ ��������� �� ����������, ������ ��������� ������ ����� ������.
�������� ��� ���!
*/


--���������� q_text
lock row for access
select q_step, length(q_text) from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 185
order by 1;

1   243
2   172
3   146
4   46



--==������ ��������� �� �����
select
 weeknumber_of_year (a.created_date, 'ISO') as "������",
 trunc (a.created_date,'iw') as first_day_week,
 cast(a.created_date as date) as create_date,
 count(distinct msisdn)
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2022-11-01 00:00:00'
 and b.created_date < timestamp '2022-12-01 00:00:00'
 and b.poll_id = 185
where 1=1
 and a.created_date >= timestamp '2022-11-01 00:00:00'
 and a.created_date < timestamp '2022-12-01 00:00:00'
group by 1,2,3
order by 3;

45,2022-11-07       2022-11-11,     2

46,2022-11-14       2022-11-14,     5

46,2022-11-14       2022-11-16,     11�980
46,2022-11-14       2022-11-17,     12�167
46,2022-11-14       2022-11-18,     10�337

47,2022-11-21       2022-11-21,     11�850
47,2022-11-21       2022-11-22,     11�231
47,2022-11-21       2022-11-23,     10�695


--=================================================================================================
--=================================================================================================
--=================================================================================================

REPLACE PROCEDURE uat_ca.mc_nps_bu_185 (in stime timestamp, in etime timestamp)
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

SET proc = 'nps_185';           -- ������������ �������

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;

-- ����������� ������ ������� ������
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START');


--=================================================================================================

--01 ������� ������

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
 and poll_id = 185
-- and created_dttm >= :stime
-- and created_dttm < :etime
 and created_dttm >= timestamp '2022-11-21 00:00:00'
 and created_dttm < timestamp '2022-11-28 00:00:00'
;

--select top 100 * from soa;


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
group by 1,2,3,4,9
;

--select * from soa_2;


--03 Step 1 NPS
/*
�������, ��� ����������� Tele2! �������� ��� ���� �������������� �� ������� ���������, ������� ���������� ������������� Tele2 �� 1 �� 10,
��� 1-����� �� ������������, 10-����� ������������. ��������� ����� � �����. SMS �� ���� ����� ���������.
*/
create multiset volatile table soa_nps, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 nps_11 varchar(1024) character set unicode not casespecific,
 nps_12 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

create multiset volatile table soa_nps2, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 nps number)
primary index (msisdn)
on commit preserve rows;


insert into soa_nps
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 a.nps_11,
 a.nps_12
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_1,
 oreplace(mark_1,'.00','') as nps_1,                                                                                                       -- ��������� .00
 oreplace(oreplace(upper(trim (nps_1)), 'T2', ''), '�2', '') as nps_2,                                                                     -- ��������� ������� � ������, ����� � T2
 trim (both ',' from nps_2) as nps_3,                                                                                                      -- ��������� ','
 trim (both '.' from nps_3) as nps_4,                                                                                                      -- ��������� '.'
 trim (both '*' from nps_4) as nps_5,                                                                                                      -- ��������� '*'
 regexp_replace (nps_5, '652', '', 1, 1) as nps_6,                                                                                         -- �������� ������ ��������� 652
 oreplace(oreplace(oreplace(oreplace(upper(trim (nps_6)), '����2', ''), 'TELE2', ''), '���� 2', ''), 'TELE 2', '') as nps_7,               -- ��������� ������� � ������, ����� � ����2
 otranslate(nps_7,'1234567890','') as nps_8,                                                                                               -- ��������� ������ �����
 trim(otranslate(nps_7,otranslate(nps_7,'1234567890',''),'')) as nps_9,                                                                    -- ��������� ������ �����
 case when length (nps_9) > 0 and length (nps_8) = 0 then cast (nps_7 as varchar (255)) else cast ('-' as varchar(255)) end as nps_10,     -- �������� ������ ������ ��� ���� �����
 case when nps_10 is not null then cast(otranslate(nps_10,' ','') as varchar(255)) end as nps_11,                                          -- ��������� ����� �������
 cast (case when nps_11 = '-' then oreplace (nps_7, regexp_replace(nps_7, '[[:alnum:]]'),'')
            else '-' end as varchar (255))as nps_12
from soa_2
) a
;


insert into soa_nps2
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 to_number (case when a.mark_1 is null then null
                 when a.nps_14 in ('0','1','2','3','4','5','6','7','8','9','10') then a.nps_14 else '-1' end) as nps                       -- �������� ������
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_1,
 nps_11,
 nps_12,
 case when nps_12 in ('0','1','2','3','4','5','6','7','8','9','10') then nps_12 else '-' end as nps_13,
 case when nps_11 = '-' then nps_13 else nps_11 end as nps_14                                                                            -- �������� ����� nps
from soa_nps
) a
;

--select * from soa_nps2;


--04 Step 2 ������� �������
/*
��� �� ����� ������, �� �������� �� ���������� � ������ ��������� Tele2? ��������� ���� ����� � �����
1.��, � ������� ���������
2.��, �� ����� ���������� ���������
3.���
*/
create multiset volatile table soa_step2, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;


insert into soa_step2
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_2,
 case when a.ans_2 is null then null
      when a.ans_2 = 1 then '��, � ������� ���������'
      when a.ans_2 = 2 then '��, �� ����� ���������� ���������'
      when a.ans_2 = 3 then '���'
      when a.ans_2 = -1 then '������'
      else '-1' end as ans_2
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_2,
 length (oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.','')) length_step_2,
 case when mark_2 is null then null
      when length_step_2 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from soa_2
) a
;

--select * from soa_step2;


--05 Step 3 ��� ���������� �������� � ������ �������
/*
����� ����������, ���� � ����� �� ������ ��������� �� ��������, ��� ��� ����� �������� � ������ �������, ����� �� ����� ����� ������������� Tele2?
*/

--06 Step 4 �����������/���������/�����������/�����


--07 �������� ������
COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_2;

COLLECT STATISTICS
 COLUMN (MSISDN)
ON soa_nps2;


create multiset volatile table soa_fin, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 nps byteint,
 load_id integer)
primary index (msisdn)
on commit preserve rows;


insert into soa_fin
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,              --NPS
 a.mark_2,              --������� �������
 a.mark_3,              --��� ���������� �������� � ������ �������
 a.mark_4,              --�����������/���������/�����������/�����
 t2.ans_2,
 t1.nps,
 a.load_id
from soa_2 a
--
left join soa_nps2  t1 on a.msisdn = t1.msisdn and a.create_date = t1.create_date                   --NPS
left join soa_step2 t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date                   --������� �������
;

--select * from soa_fin;


--07 ���������� �������

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
insert into uat_ca.poll_id_185
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 coalesce(a.mark_1,  t1.mark_1) as mark_1,
 coalesce(a.mark_2,  t1.mark_2) as mark_2,
 coalesce(a.mark_3,  t1.mark_3) as mark_3,
 coalesce(a.mark_4,  t1.mark_4) as mark_4,
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.nps,     t1.nps) as nps,
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
insert into uat_ca.poll_id_185
select
  a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 a.mark_2,
 a.mark_3,
 a.mark_4,
 a.ans_2,
 a.nps,
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
drop table soa_step2;
drop table soa_nps;
drop table soa_nps2;
drop table soa_fin;
drop table subs_tmp;



-- ����������� ��������� ������� ������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,1,'END');


END;

--=================================================================================================
--=================================================================================================
--=================================================================================================

-- �����������
COMMENT ON PROCEDURE uat_ca.mc_nps_bu_11 AS
'��������� ������������ ������� � �������� NPS SOA 2.0, �� ������������� ������. �������������� �������: uat_ca.poll_id_11';


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- ����� ��������� (������� �������/�� �������)

--2022
/*week 46*/ call uat_ca.mc_nps_bu_185 (timestamp '2022-11-14 00:00:00', timestamp '2022-11-21 00:00:00');
/*week 47*/ call uat_ca.mc_nps_bu_185 (timestamp '2022-11-21 00:00:00', timestamp '2022-11-28 00:00:00');

--=================================================================================================
--=================================================================================================
--=================================================================================================

-- ����������� �������� � �������� ���������� EDW:
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablekind = 'Procedure' order by "���� ���������� ���������" desc;
select * from prd2_tmd_v.columns_info;


-- ��� ��������� ������������ ���� � ������ ������ ���������, ���� �� �� ���������� ����������� ������ �� ������� �����:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_185'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


-- �������� �����
select * from uat_ca.mc_logs order by 1;


--����������
COLLECT SUMMARY STATISTICS ON uat_ca.poll_id_185;

COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (SUBS_ID),
 COLUMN (MSISDN)
ON uat_ca.poll_id_185;


-- �������� ������
select top 100 * from uat_ca.poll_id_185;
select top 100 * from uat_ca.poll_id_185 where create_date >= date '2022-11-14';

--delete uat_ca.poll_id_185 where trunc (create_date,'iw') = date '2022-11-14';


select create_date, count(distinct msisdn), count(*) from uat_ca.poll_id_185 group by 1 order by 1 desc;
select trunc (create_date,'iw') as week_first_day, weeknumber_of_year (create_date, 'ISO') as week_num, count(distinct msisdn), count(*) from uat_ca.poll_id_185 group by 1,2 order by 1 desc;


--1 ��������� ��������
select
 weeknumber_of_year (create_date, 'ISO') as "������",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_185
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
from uat_ca.v_poll_185
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
from uat_ca.v_poll_185
group by 1
order by 1 desc;



--View
replace view uat_ca.v_poll_185 as
lock row for access
select
 create_date,
 msisdn,
 subs_id,
-- treatment_code,
 case when nps = -1 then mark_1 end as mark_1,                  --NPS
 case when ans_2 = '������' then mark_2 end as mark_2,          --������� �������
 mark_3,                                                        --��� ���������� ��������� � ������ �������
 mark_4,                                                        --�����������/���������/�����������/�����
 ans_2,
 nps,
-- load_id,
--
 case when nps between 0 and 6 then 1 else 0 end as detractor,
 case when nps between 7 and 8 then 1 else 0 end as passive,
 case when nps between 9 and 10 then 1 else 0 end as promoter,
 case when detractor = 1 then 'Detractor'
      when passive = 1 then 'Passive'
      when promoter = 1 then 'Promoter'
      end nps_category,
 case when detractor = 1 then -1
      when passive = 1 then 0
      when promoter = 1 then 1
      end as nps_key
from uat_ca.poll_id_185
where 1=1
 and create_date >= date '2022-11-21'
;


/*
--show view uat_ca.v_poll_11;
comment on view uat_ca.v_poll_11 as 'NPS ������������� ������';

comment on column uat_ca.v_poll_11.create_date as '���� ����������� ������';
comment on column uat_ca.v_poll_11.mark_1 as '����� ��� ���� �� ������: ��� �� ����� ������, �� �������� �� ����������?';
comment on column uat_ca.v_poll_11.mark_2 as '����� ��� ���� �� ������: ��� ������ ����� ��� ��������� �������� � ������ ���������?';
comment on column uat_ca.v_poll_11.mark_3 as '����� ��� ���� �� ������: NPS';
comment on column uat_ca.v_poll_11.mark_4 as '����� ��� ���� �� ������: �����������/���������/�����������/�����';

comment on column uat_ca.v_poll_11.ans_1 as '��������������� ����� �� ������: ��� �� ����� ������, �� �������� �� ����������?';
comment on column uat_ca.v_poll_11.ans_2 as '��������������� ����� �� ������: ��� ������ ����� ��� ��������� �������� � ������ ���������?';
comment on column uat_ca.v_poll_11.nps as '��������������� ����� �� ������: NPS';
*/


select top 100 * from uat_ca.v_poll_185;
select * from uat_ca.v_poll_185 sample 25;

select
-- report_month,
 create_date,
 point_name,
 100*nps (format 'zz.z%') (varchar(10)) as nps_bu,
 subs_cnt,
 100*(1.96*stddev/sqrt(subs_cnt)) (format 'zz.zz%') (varchar(10)) as "�����������",
 100*(nps - (1.96*stddev/sqrt(subs_cnt))) (format 'zz.z%') (varchar(10)) as lower_threshold,
 100*(nps + (1.96*stddev/sqrt(subs_cnt))) (format 'zz.z%') (varchar(10)) as upper_threshold
from (
select
-- trunc (create_date,'mm') as report_month,
 create_date,
 '�������-�����' as point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v_poll_185
where 1=1
 and create_date >= date '2022-11-21'
 and create_date < date '2022-11-28'
 and nps_key in (-1,0,1)
group by 1,2
) a
;


select 
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_11
where 1=1
 and nps_key in (-1,0,1)
group by 1
order by 1 desc;

select 
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_11
where 1=1
 and nps is not null
group by 1
order by 1 desc;

select * from uat_ca.v_poll_11;


������������� ������            61 674
�������                         6 419
NPS                             3 277

10.41%

������������� ������            59 584
�������                         6 040
NPS                             3 278

10.14%

������������� ������            57 226
�������                         5 959
NPS                             3 214

10.14%



select top 100 * from uat_ca.knime_poll_11 where create_date >= date '2022-01-10';
select count(distinct msisdn), count(*) from uat_ca.knime_poll_11 where create_date >= date '2022-01-10';   --

select
 report_month,
 point_name,
 nps,
 subs_cnt,
 1.96*stddev/sqrt(subs_cnt) as st_error,
 nps - st_error as lower_threshold,
 nps + st_error as upper_threshold
from (
select
 trunc (create_date,'mm') as report_month,
 '������������� ������' as point_name,
 count(msisdn) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from (
select
 create_date,
 msisdn,
 nps_key
from (
select
 create_date,
 msisdn,
 case when nps between 0 and 6 then 1 else 0 end as detractor,
 case when nps between 7 and 8 then 1 else 0 end as passive,
 case when nps between 9 and 10 then 1 else 0 end as promoter,
 case when detractor = 1 then 'Detractor'
      when passive = 1 then 'Passive'
      when promoter = 1 then 'Promoter'
      end nps_category,
 case when detractor = 1 then -1
      when passive = 1 then 0
      when promoter = 1 then 1
      end as nps_key
from uat_ca.knime_poll_11
where 1=1
 and create_date >= date '2022-01-10'
-- and msisdn not in ('79004372983', '79004393319')
) a
where 1=1
 and nps_key in (-1,0,1)
) a
group by 1,2
) a
;


select
 a.* from (
select
 a.create_date,
 a.msisdn,
 a.mark_3,
 a.nps,
 t1.nps as nps_new,
 t1.mark_3 as mark_3_new,
 case when a.nps = nps_new then 1 else 0 end as nps_key,
 case when a.mark_3 = mark_3_new then 1 else 0 end as mark_key
from uat_ca.knime_poll_11 a
left join uat_ca.v_poll_11 t1 on a.msisdn = t1.msisdn
 and a.create_date = t1.create_date
where 1=1
 and a.create_date >= date '2022-01-10'
) a
where 1=1
 and nps_key = 0
;

select * from uat_ca.knime_poll_11 where msisdn = '79004372983';
select * from uat_ca.v_poll_11 where msisdn = '79004372983';


select
 a.* from (
select
 a.create_date,
 a.msisdn,
 a.mark_3,
 a.nps,
 t1.nps as nps_new,
 t1.mark_3 as mark_3_new,
 case when a.nps = nps_new then 1 else 0 end as nps_key,
 case when a.mark_3 = mark_3_new then 1 else 0 end as mark_key
from uat_ca.knime_poll_11 t1
left join uat_ca.v_poll_11 a on a.msisdn = t1.msisdn
 and a.create_date = t1.create_date
where 1=1
 and a.create_date >= date '2022-01-10'
) a
where 1=1
 and nps_key = 0
;

select * from uat_ca.knime_poll_11 where msisdn = '79961770890';
select * from uat_ca.v_poll_11 where msisdn = '79961770890';
select * from prd2_dds_v.smspoll_detail where msisdn = '79961770890';

--=================================================================================================
--=================================================================================================
--=================================================================================================

--show table uat_ca.poll_id_185;

create multiset table uat_ca.poll_id_185 (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 nps byteint,
 load_id integer)
primary index (subs_id)
;

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
 and lower(a.tablename) = 'knime_poll_112'
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
 hashamp(hashbucket(hashrow(subs_id))) as amp_no,
 cast(count(*) as float) as row_cnt
from uat_ca.knime_poll_112
group by 1
) as t1,
(select cast(count(*) as float)/(hashamp()+1) as row_avr_amp from uat_ca.knime_poll_112) as t2
order by 2 desc
;


--==3 Hash synonyms

--������ ���������� ���������� ���������� ���� ����� ��� ���������� ������� ��� ������� (���������� �������� 3 ���. 45 ���.)
/*��������, � ������� �������� rowhash ��� ������ ����� ���������, ��� ���������� ��� �������
  ���������� ���-���������, ����� ���� ���������� ������ ������������� ��� ����������
    https://www.docs.teradata.com/r/w4DJnG9u9GdDlXzsTXyItA/XfRpR9T7fWZfF_1IZWuwRg
*/
select
 hashrow(subs_id) as row_hash,
 count(*) as row_cnt
from uat_ca.knime_poll_112
group by 1
order by 1
having row_cnt > 10
;


--==4 �����/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('knime_poll_112')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          KNIME_POLL_112          MIKHAIL.CHUPIS      2022-01-12 17:44:05     2022-01-12 19:42:04     0,004           38,62



