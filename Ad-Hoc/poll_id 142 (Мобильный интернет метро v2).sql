
diagnostic helpstats on for session;

/*
�� ��������� �������� - 05.09.2022
    �NPS �� 2022 ������� - Poll_id = 141
    �NPS �� 2022 ����� - Poll_id = 142
*/

--=================================================================================================
--���������� q_text
lock row for access
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 142
order by 3, 1;


--142
--1
/*
�������, ��� �� � Tele2! �� �����, ����� ��� ���� ������ � ����. ����������, �������� �� ��������� ��������. 
��������� � ����� �� �������� ��������� ���������� Tele2 �� ����� �� 1 �� 10, ��� 1 - �� �������� 10 - ����� ��������. ��������� ����� � �����.
*/

�������, ��� �� ����������� ��������� ���������� Tele2! �������� �������� ���������� ��������� �������,
����������, ���������� ������������� Tele2 �� 1 �� 10, ��� 1 - ����� �� ������������, 10 - ����� ������������. ��������� ����� � �����.


--2
/*
����������� �� �� �������� � ��������� ���������� ���������, ���� ��, �� ��� ���� �����? ��������� ���� �������� ���������� �����.
1- ������� ���
2- ���� (���������� ����������)
3- �� ������\� �����\������������
4- �� �������� ��������\�� ������ (������)
5- �� �������\�� ���� (��������� ����������)
6- ����� ������ � �����������
*/

����������� �� �� �������� � ��������� ���������� ���������, ���� ��, �� ��� ���� �����? ��������� ���� �������� ���������� �����.
1.������� ���
2.���� (���������� ����������)
3.�� ������\� �����\������������
4.�� �������� ��������\�� ������ (������)\� �����
5.�� �������\�� ���� (��������� ����������)
6.����� ������ � �����������


--3
/*
������� ����� ����� �����, ��� ���������� ��������:
1. ������� ���
2. ��������, �� 5 ����� ������������
3. ��������, ���� 5 �����
*/

������� ����� ����� �����, ��� ���������� ��������:
1.������� ���
2.��������, �� 5 ����� ������������
3.��������, ���� 5 �����


--4
/*
������� ����� ����� �����, ��� ���������� ��������:
1. ������������ ����� (���, ������ ������ ��� �����, �������, ���������, �����, ��������, �������� � �.�.)
2. �������������� ������ (������, ����.���� � �.�.)
3. �� ����� (�����, �������, �����\������ � �.�.)
4. ������
*/

������� ����� ����� �����, ��� ���������� ��������:
1.������������ ����� (���, ������ ������ ��� �����, �������, ���������, �����, ��������, �������� � �.�.)
2.�������������� ������ (������, ����.���� � �.�.)
3.�� ����� (�����, �������, �����\������ � �.�.)
4.������


--5
/*
������� ����� ����� �����, ��� ���������� ��������:
1. ������ ������ ������
2. ������ � �������� ���������� ������\�� ����
3. ������ � �������� ������� (�4, �5 � �.�.)
4. ������
*/

������� ����� ����� �����, ��� ���������� ��������:
1.� �����
2.������ ������ ������
3.������ � �������� ���������� ������\�� ����
4.������ � �������� ������� (�4, �5 � �.�.)
5.������

--6
/*
������� ����� ����� �����, ��� ���������� ��������:
1. ����\���
2. ������� ���
3. ����� ������ (�������, �����, �����, �����)
*/

������� ����� ����� �����, ��� ���������� ��������:
1.����\���
2.������� ���
3.����� ������ (�������, �����, �����, �����)


--7
/*
������� ����� ����� �����, ��� ���������� ��������:
1. ������ ���������� ��������� (����, ����, ��������� � �.�.)
2. ������ �������� ������� (���, ���������� ����, ����������)
3. ��� ��������� (���� ������, �����, ��������, � �.�.)
4. ������
*/

������� ����� ����� �����, ��� ���������� ��������:
1.������ ���������� ��������� (����, ����, ��������� � �.�.)
2.������ �������� ������� (���, ���������� ����, ����������)
3.��� ��������� (���� ������, �����, ��������, � �.�.)
4.������


--8
������� �� ������� � ������. �������� ��� ����� ��� ����� - � ����� �� ��� SMS, ���� ���� �������� � ����������, ����������, �������� �����, ����� � ���, ��� ��� ���������. �������� ��� ���!


/* ���� �������� ������ ���
--8
� ��������� ������. ������� ���������� ������������� �������� Tele2 ������ � ������� �� 1 �� 10, ��� 1 - ����� �� ������������, 10 - ����� ������������.

--9
������� �� ������� � ������. �������� ��� ����� ��� ����� - � ����� �� ��� SMS, ���� ���� �������� � ����������, ����������, �������� �����, ����� � ���, ��� ��� ���������. �������� ��� ���!
*/

--���������� q_text
lock row for access
select q_step, length(q_text) from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 142
order by 1;

--������ �������
1       254
2       343
3       132
4       274
5       193
6       128
7       245
8       152
9       190

--����� �������
1       239
2       337
3       129
4       270
5       188
6       125
7       241
8       190



--==������ ��������� �� �����

select
 cast(a.created_date as date) as create_date,
 poll_id,
 count(distinct msisdn)
from prd2_odw_v.smspoll_communication_lists a
inner join prd2_odw_v.smspoll_poll_lists b on a.sub_list_id = b.sub_list_id
 and b.created_date >= timestamp '2022-09-12 00:00:00'
 and b.created_date < timestamp '2022-09-17 00:00:00'
 and b.poll_id in (142)
where 1=1
 and a.created_date >= timestamp '2022-09-12 00:00:00'
 and a.created_date < timestamp '2022-09-17 00:00:00'
group by 1,2
order by 1
;

2022-09-05  16 060
2022-09-06  32�027


select
 cast(created_dttm as date) as created_date,
 poll_id,
 count(distinct subs_id),
 count(*)
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id in (142)
 and created_dttm >= timestamp '2022-09-15 00:00:00'
 and created_dttm < timestamp '2022-09-16 00:00:00'
group by 1,2
;

2022-09-05  767     1 594
2022-09-06  1�476   3�011


--=================================================================================================
--=================================================================================================
--=================================================================================================

REPLACE PROCEDURE uat_ca.mc_nps_bu_142 (in stime timestamp, in etime timestamp)
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

SET proc = 'nps_mi_metro_2022';           -- ������������ �������

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;

-- ����������� ������ ������� ������
--CALL uat_ca.prc_debug (proc,:load_id,session,0,'START');
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START: ' || to_char(142));

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
-- load_id
 :load_id
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id in (142)
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2022-09-05 00:00:00'
-- and created_dttm < timestamp '2022-09-06 00:00:00'
;

--select top 100 * from soa;


-- ����������� �������� �������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'INTERVAL_DATE '|| to_char(cast(stime as date),'DD.MM.YYYY') || '_' ||to_char(cast(etime as date),'DD.MM.YYYY') || ' ����� �����: ' || to_char(142) || ' in - ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));

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
 mark_5 varchar(1024) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 mark_7 varchar(1024) character set unicode not casespecific,
 mark_8 varchar(1024) character set unicode not casespecific,
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
 max (step_5) as mark_5,
 max (step_6) as mark_6,
 max (step_7) as mark_7,
 max (step_8) as mark_8,
 load_id
from (
select * from soa pivot (max(mark) for q_step in (
 '1' as step_1,
 '2' as step_2,
 '3' as step_3,
 '4' as step_4,
 '5' as step_5,
 '6' as step_6,
 '7' as step_7,
 '8' as step_8
)) t2
) a
group by 1,2,3,4,13
;

--select * from soa_2;


--03 Step 1 ��������� � ����� �� �������� ��������� ���������� Tele2
/*
�������, ��� �� ����������� ��������� ���������� Tele2! �������� �������� ���������� ��������� �������, ����������, ���������� ������������� Tele2 �� 1 �� 10, ��� 1 - ����� �� ������������, 10 - ����� ������������. ��������� ����� � �����.
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


--04 Step 2 �������� � ���������
/*
����������� �� �� �������� � ��������� ���������� ���������, ���� ��, �� ��� ���� �����? ��������� ���� �������� ���������� �����.
1.������� ���
2.���� (���������� ����������)
3.�� ������\� �����\������������
4.�� �������� ��������\�� ������ (������)\� �����
5.�� �������\�� ���� (��������� ����������)
6.����� ������ � �����������
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
      when a.ans_2 = 1 then '������� ���'
      when a.ans_2 = 2 then '����'
      when a.ans_2 = 3 then '�� ������\� �����\������������'
      when a.ans_2 = 4 then '�� �������� ��������\�� ������\� �����'
      when a.ans_2 = 5 then '�� �������\�� ����'
      when a.ans_2 = 6 then '����� ������ � �����������'
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
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from soa_2
) a
;

--select * from soa_step2;


--05 Step 3 ����� ������������� �������� - ����
/*
������� ����� ����� �����, ��� ���������� ��������:
1.������� ���
2.��������, �� 5 ����� ������������
3.��������, ���� 5 �����

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
      when a.ans_3 = 1 then '������� ���'
      when a.ans_3 = 2 then '��������, �� 5 ����� ������������'
      when a.ans_3 = 3 then '��������, ���� 5 �����'
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
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_3
from soa_2
) a
;

--select * from soa_step3;


--06 Step 4 ����� ������������� �������� - �� ������\� �����\������������
/*
������� ����� ����� �����, ��� ���������� ��������:
1.������������ ����� (���, ������ ������ ��� �����, �������, ���������, �����, ��������, �������� � �.�.)
2.�������������� ������ (������, ����.���� � �.�.)
3.�� ����� (�����, �������, �����\������ � �.�.)
4.������
*/
create multiset volatile table soa_step4, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 ans_4 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

insert into soa_step4
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_4,
 case when a.ans_4 is null then null
      when a.ans_4 = 1 then '������������ �����'
      when a.ans_4 = 2 then '�������������� ������'
      when a.ans_4 = 3 then '�� �����'
      when a.ans_4 = 4 then '������'
      when a.ans_4 = -1 then '������'
      else '-1' end as ans_4
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_4,
 length (oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.','')) length_step_4,
 case when mark_4 is null then null
      when length_step_4 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_4),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_4
from soa_2
) a
;

--select * from soa_step4;


--07 Step 5 ����� ������������� �������� - �� �������� ��������\�� ������
/*
������� ����� ����� �����, ��� ���������� ��������:
1. � �����
2. ������ ������ ������
3. ������ � �������� ���������� ������\�� ����
4. ������ � �������� ������� (�4, �5 � �.�.)
5. ������
*/
create multiset volatile table soa_step5, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 ans_5 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

insert into soa_step5
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_5,
 case when a.ans_5 is null then null
      when a.ans_5 = 1 then '� �����'
      when a.ans_5 = 2 then '������ ������ ������'
      when a.ans_5 = 3 then '������ � �������� ���������� ������\�� ����'
      when a.ans_5 = 4 then '������ � �������� ������� (�4, �5 � �.�.)'
      when a.ans_5 = 5 then '������'
      when a.ans_5 = -1 then '������'
      else '-1' end as ans_5
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_5,
 length (oreplace(oreplace(oreplace(upper(mark_5),' ',''),',',''),'.','')) length_step_5,
 case when mark_5 is null then null
      when length_step_5 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_5),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4', '5')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_5),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_5
from soa_2
) a
;

--select * from soa_step5;


--08 Step 6 ����� ������������� �������� - �� �������\�� ����
/*
������� ����� ����� �����, ��� ���������� ��������:
1.����\���
2.������� ���
3.����� ������ (�������, �����, �����, �����)
*/
create multiset volatile table soa_step6, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 ans_6 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

insert into soa_step6
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_6,
 case when a.ans_6 is null then null
      when a.ans_6 = 1 then '����\���'
      when a.ans_6 = 2 then '������� ���'
      when a.ans_6 = 3 then '����� ������ (�������, �����, �����, �����)'
      when a.ans_6 = -1 then '������'
      else '-1' end as ans_6
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_6,
 length (oreplace(oreplace(oreplace(upper(mark_6),' ',''),',',''),'.','')) length_step_6,
 case when mark_6 is null then null
      when length_step_6 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_6),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_6),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_6
from soa_2
) a
;

--select * from soa_step6;


--09 Step 7 ����� ������������� �������� - ����� ������ � �����������
/*
������� ����� ����� �����, ��� ���������� ��������:
1.������ ���������� ��������� (����, ����, ��������� � �.�.)
2.������ �������� ������� (���, ���������� ����, ����������)
3.��� ��������� (���� ������, �����, ��������, � �.�.)
4.������
*/
create multiset volatile table soa_step7, no log (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_7 varchar(1024) character set unicode not casespecific,
 ans_7 varchar(1024) character set unicode not casespecific)
primary index (msisdn)
on commit preserve rows;

insert into soa_step7
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_7,
 case when a.ans_7 is null then null
      when a.ans_7 = 1 then '������ ���������� ��������� (����, ����, ��������� � �.�.)'
      when a.ans_7 = 2 then '������ �������� ������� (���, ���������� ����, ����������)'
      when a.ans_7 = 3 then '��� ��������� (���� ������, �����, ��������, � �.�.)'
      when a.ans_7 = 4 then '������'
      when a.ans_7 = -1 then '������'
      else '-1' end as ans_7
from (
select
 create_date,
 msisdn,
 subs_id,
 treatment_code,
 mark_7,
 length (oreplace(oreplace(oreplace(upper(mark_7),' ',''),',',''),'.','')) length_step_7,
 case when mark_7 is null then null
      when length_step_7 = 1
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_7),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_7),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_7
from soa_2
) a
;

--select * from soa_step7;



/*
step 8
������� �� ������� � ������. �������� ��� ����� ��� ����� - � ����� �� ��� SMS, ���� ���� �������� � ����������, ����������, �������� �����, ����� � ���, ��� ��� ���������. �������� ��� ���!
*/


--11 �������� ������
COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step2;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step3;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step4;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step5;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step6;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
ON soa_step7;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE ,MSISDN)
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
 mark_5 varchar(1024) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 mark_7 varchar(1024) character set unicode not casespecific,
 mark_8 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific,
 ans_4 varchar(1024) character set unicode not casespecific,
 ans_5 varchar(1024) character set unicode not casespecific,
 ans_6 varchar(1024) character set unicode not casespecific,
 ans_7 varchar(1024) character set unicode not casespecific,
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
 a.mark_2,              --�������� � ���������
 a.mark_3,              --����� ������������� �������� - ����
 a.mark_4,              --����� ������������� �������� - �� ������\� �����\������������
 a.mark_5,              --����� ������������� �������� - �� �������� ��������\�� ������
 a.mark_6,              --����� ������������� �������� - �� �������\�� ����
 a.mark_7,              --����� ������������� �������� - ����� ������ � �����������
 a.mark_8,              --�����������/���������/�����������/�����
 t2.ans_2,
 t3.ans_3,
 t4.ans_4,
 t5.ans_5,
 t6.ans_6,
 t7.ans_7,
 t8.nps,
 a.load_id
from soa_2 a
--
left join soa_step2   t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date                   --�������� � ���������
left join soa_step3   t3 on a.msisdn = t3.msisdn and a.create_date = t3.create_date                   --����� ������������� �������� - ����
left join soa_step4   t4 on a.msisdn = t4.msisdn and a.create_date = t4.create_date                   --����� ������������� �������� - �� ������\� �����\������������
left join soa_step5   t5 on a.msisdn = t5.msisdn and a.create_date = t5.create_date                   --����� ������������� �������� - �� �������� ��������\�� ������
left join soa_step6   t6 on a.msisdn = t6.msisdn and a.create_date = t6.create_date                   --����� ������������� �������� - �� �������\�� ����
left join soa_step7   t7 on a.msisdn = t7.msisdn and a.create_date = t7.create_date                   --����� ������������� �������� - ����� ������ � �����������
left join soa_nps2    t8 on a.msisdn = t8.msisdn and a.create_date = t8.create_date                   --NPS
;

--select * from soa_fin;


--12 ���������� �������
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
insert into uat_ca.poll_id_142
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 coalesce(a.mark_1,  t1.mark_1) as mark_1,
 coalesce(a.mark_2,  t1.mark_2) as mark_2,
 coalesce(a.mark_3,  t1.mark_3) as mark_3,
 coalesce(a.mark_4,  t1.mark_4) as mark_4,
 coalesce(a.mark_5,  t1.mark_5) as mark_5,
 coalesce(a.mark_6,  t1.mark_6) as mark_6,
 coalesce(a.mark_7,  t1.mark_7) as mark_7,
 coalesce(a.mark_8,  t1.mark_8) as mark_8,
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.ans_3,   t1.ans_3) as ans_3,
 coalesce(a.ans_4,   t1.ans_4) as ans_4,
 coalesce(a.ans_5,   t1.ans_5) as ans_5,
 coalesce(a.ans_6,   t1.ans_6) as ans_6,
 coalesce(a.ans_7,   t1.ans_7) as ans_7,
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
CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� �� �������: ' || to_char(142) || ' fin - ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));



--�������� ��� �������
insert into uat_ca.poll_id_142
select
 a.create_date,
 a.msisdn,
 a.subs_id,
 a.treatment_code,
 a.mark_1,
 a.mark_2,
 a.mark_3,
 a.mark_4,
 a.mark_5,
 a.mark_6,
 a.mark_7,
 a.mark_8,
 a.ans_2,
 a.ans_3,
 a.ans_4,
 a.ans_5,
 a.ans_6,
 a.ans_7,
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
CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� ��� �������: ' || to_char(142) || ' fin - ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


drop table soa;
drop table soa_2;
drop table soa_step2;
drop table soa_step3;
drop table soa_step4;
drop table soa_step5;
drop table soa_step6;
drop table soa_step7;
drop table soa_nps;
drop table soa_nps2;
drop table soa_fin;
drop table subs_tmp;


-- ����������� ��������� ������� ������
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,1,'END: ' || to_char(142));

END;

--=================================================================================================
--=================================================================================================
--=================================================================================================

-- �����������
COMMENT ON PROCEDURE uat_ca.mc_nps_bu_142 AS
'��������� ������������ ������� � �������� NPS SOA 2.0, �� ��������� �������� ����� 2022. �������������� �������: uat_ca.poll_id_142';


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- ����� ��������� (������� �������/�� �������)

--2022
/*week 36*/ call uat_ca.mc_nps_bu_142 (timestamp '2022-09-06 00:00:00', timestamp '2022-09-07 00:00:00');   -- 2 ���. 53 ���.

call uat_ca.mc_nps_bu_142 (timestamp '2022-10-05 00:00:00', timestamp '2022-10-06 00:00:00');

--=================================================================================================
--=================================================================================================
--=================================================================================================

-- ����������� �������� � �������� ���������� EDW:
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablekind = 'Procedure' order by "���� ���������� ���������" desc;
select * from prd2_tmd_v.columns_info;


-- ��� ��������� ������������ ���� � ������ ������ ���������, ���� �� �� ���������� ����������� ������ �� ������� �����:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_mi_metro_2022'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


-- �������� �����
select * from uat_ca.v_nps_stat order by 1;


replace view uat_ca.v_nps_stat as
lock row for access
select
 cast(cast(substring(cast(logdate as char(26)) from 1 for 19) as timestamp(0)) as date) as report_date,
 a.poll_id,
 cast(substring(cast(max(case when a.rn = 1 then a.logdate end) as char(26)) from 1 for 19) as timestamp(0)) as sdttm,
 cast(substring(cast(max(case when a.rn = 5 then a.logdate end) as char(26)) from 1 for 19) as timestamp(0)) as edttm,
 rtrim((substring(trim(cast((edttm - sdttm minute to second) as char(13))) from 1 for 5)),'.') as diff,
 sum(case when a.rn = 2 then a.row_cnt end) as in_row,
 sum(case when a.rn = 3 then a.row_cnt end) + sum(case when a.rn = 4 then a.row_cnt end) out_row
from (
select
 distinct
 poll_id,
 row_cnt,
 logdate,
 row_number() over (partition by poll_id order by logdate) as rn
from (
select
 cast(substring(cast(logdate as char(26)) from 1 for 19) as timestamp(0)) as logdate,
 logcomment,
 142 as poll_id,
 trim(strtok(logcomment, '-', 2)) as row_cnt
from (
select
 logdate,
 logcomment
from uat_ca.mc_logs
where 1=1
 and ProcessName = 'nps_mi_metro_2022'
-- and loadid not in (4055, 4062, 4063, 4087, 4095)
-- and logdate >= timestamp '2022-07-24 15:24:01'
) a
) a
) a
--
group by 1,2
;



--����������
COLLECT SUMMARY STATISTICS ON uat_ca.poll_id_142;

COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (SUBS_ID),
 COLUMN (MSISDN)
ON uat_ca.poll_id_142;


-- �������� ������
select top 100 * from uat_ca.poll_id_142;
select top 100 * from uat_ca.poll_id_142 where create_date >= date '2022-09-05';

--delete uat_ca.poll_id_142 where trunc (create_date,'iw') = date '2022-09-05';


select create_date, count(distinct msisdn), count(*) from uat_ca.poll_id_142 group by 1 order by 1 desc;
select trunc (create_date,'iw') as week_first_day, weeknumber_of_year (create_date, 'ISO') as week_num, count(distinct msisdn), count(*) from uat_ca.poll_id_142 group by 1,2 order by 1 desc;


--1 ��������� ��������
select
 weeknumber_of_year (create_date, 'ISO') as "������",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_mi_metro_2
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
from uat_ca.v_poll_mi_metro_2
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
from uat_ca.v_poll_mi_metro_2
group by 1
order by 1 desc;


--View
replace view uat_ca.v_poll_mi_metro_2 as
lock row for access
select
 a.create_date,
 t2.cluster_name as cluster_name,
 t4.macroregion_name as macroregion,
 t3.region_name as region,
 '��������� �������� �����' as point_name,
 a.msisdn,
 a.subs_id,
-- treatment_code,
 case when a.nps = -1 then a.mark_1 end as mark_1,                --��������� � ����� �� �������� ��������� ���������� Tele2
 case when a.ans_2 = '������' then a.mark_2 end as mark_2,          --�������� � ���������
 case when a.ans_3 = '������' then a.mark_3 end as mark_3,          --����� ������������� �������� - ����
 case when a.ans_4 = '������' then a.mark_4 end as mark_4,          --����� ������������� �������� - �� ������\� �����\������������
 case when a.ans_5 = '������' then a.mark_5 end as mark_5,          --����� ������������� �������� - �� �������� ��������\�� ������
 case when a.ans_6 = '������' then a.mark_6 end as mark_6,          --����� ������������� �������� - �� �������\�� ����
 case when a.ans_7 = '������' then a.mark_7 end as mark_7,          --����� ������������� �������� - ����� ������ � �����������
 a.mark_8,                                                        --�����������/���������/�����������/�����
 a.ans_2,
 a.ans_3,
 a.ans_4,
 a.ans_5,
 a.ans_6,
 a.ans_7,
 a.nps,
-- load_id,
--
 case when a.nps between 0 and 6 then 1 else 0 end as detractor,
 case when a.nps between 7 and 8 then 1 else 0 end as passive,
 case when a.nps between 9 and 10 then 1 else 0 end as promoter,
 case when detractor = 1 then 'Detractor'
      when passive = 1 then 'Passive'
      when promoter = 1 then 'Promoter'
      end nps_category,
 case when detractor = 1 then -1
      when passive = 1 then 0
      when promoter = 1 then 1
      end as nps_key
from uat_ca.poll_id_142 a
--
left join prd2_dds_v.phone_number_2 t1 on a.msisdn = t1.msisdn
 and (a.create_date >= t1.stime and a.create_date < t1.etime)
left join prd2_dic_v.branch t2 on t1.branch_id = t2.branch_id
left join prd2_dic_v.region t3 on t2.region_id = t3.region_id
left join prd2_dic_v.macroregion t4 on t3.macroregion_id = t4.macroregion_id
;


--show view uat_ca.v_poll_mi;
comment on view uat_ca.v_poll_mi_metro_2 as 'NPS ��������� �������� ����� 2022';

comment on column uat_ca.v_poll_mi_metro_2.create_date as '���� ����������� ������';
comment on column uat_ca.v_poll_mi_metro_2.mark_1 as '����� ��� ���� �� ������: NPS';
comment on column uat_ca.v_poll_mi_metro_2.mark_2 as '����� ��� ���� �� ������: ����������� �� �� �������� � ��������� ���������� ���������, ���� ��, �� ��� ���� �����?';
comment on column uat_ca.v_poll_mi_metro_2.mark_3 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� ����';
comment on column uat_ca.v_poll_mi_metro_2.mark_4 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� ������\� �����\������������';
comment on column uat_ca.v_poll_mi_metro_2.mark_5 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� �������� ��������\�� ������ (������)\� �����';
comment on column uat_ca.v_poll_mi_metro_2.mark_6 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� �������\�� ����';
comment on column uat_ca.v_poll_mi_metro_2.mark_7 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� ����� ������ � �����������';
comment on column uat_ca.v_poll_mi_metro_2.mark_8 as '����� ��� ���� �� ������: �����������/���������/�����������/�����';

comment on column uat_ca.v_poll_mi_metro_2.ans_2 as '��������������� ����� �� ������: ����������� �� �� �������� � ��������� ���������� ���������, ���� ��, �� ��� ���� �����?';
comment on column uat_ca.v_poll_mi_metro_2.ans_3 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� ����';
comment on column uat_ca.v_poll_mi_metro_2.ans_4 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� ������\� �����\������������';
comment on column uat_ca.v_poll_mi_metro_2.ans_5 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� �������� ��������\�� ������ (������)\� �����';
comment on column uat_ca.v_poll_mi_metro_2.ans_6 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� �������\�� ����';
comment on column uat_ca.v_poll_mi_metro_2.ans_7 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� ����� ������ � �����������';
comment on column uat_ca.v_poll_mi_metro_2.nps as '��������������� ����� �� ������: NPS';



select top 100 * from uat_ca.v_poll_mi_metro_2;
select * from uat_ca.v_poll_mi_metro_2 where region is null;

select * from uat_ca.v_poll_mi_metro_2 sample 25;

select
 report_month,
 point_name,
 nps,
 subs_cnt,
 1.96*stddev/sqrt(subs_cnt) as st_error,
-- 1.96*stddev/sqrt(subs_cnt) as st_error,
 nps - st_error as lower_threshold,
 nps + st_error as upper_threshold
from (
select
 trunc (create_date,'mm') as report_month,
 '��������� ��������' as point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v_poll_mi_metro_2
where 1=1
 and create_date >= date '2022-09-05'
 and create_date < date '2022-09-13'
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
from uat_ca.v_poll_mi_2
where 1=1
 and nps_key in (-1,0,1)
group by 1
order by 1 desc;

select * from uat_ca.v_poll_mi__metro_2;



--=================================================================================================
--=================================================================================================
--=================================================================================================

--show table uat_ca.poll_id_142;

create multiset table uat_ca.poll_id_142 (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 mark_6 varchar(1024) character set unicode not casespecific,
 mark_7 varchar(1024) character set unicode not casespecific,
 mark_8 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific,
 ans_4 varchar(1024) character set unicode not casespecific,
 ans_5 varchar(1024) character set unicode not casespecific,
 ans_6 varchar(1024) character set unicode not casespecific,
 ans_7 varchar(1024) character set unicode not casespecific,
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
 and lower(a.tablename) = 'poll_id_142'
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
from uat_ca.poll_id_142
group by 1
) as t1,
(select cast(count(*) as float)/(hashamp()+1) as row_avr_amp from uat_ca.poll_id_142) as t2
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
from uat_ca.poll_id_142
group by 1
order by 1
having row_cnt > 10
;


--==4 �����/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('poll_id_142')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          POLL_ID_141             MIKHAIL.CHUPIS      2022-09-06 14:05:14     2022-09-07 04:10:07     0,006           7,842




