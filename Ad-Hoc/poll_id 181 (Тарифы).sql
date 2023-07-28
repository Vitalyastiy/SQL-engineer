
diagnostic helpstats on for session;

/*
�� ������ - 07.10.2022
*/

--=================================================================================================
--���������� q_text
select * from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 181
order by 3, 1;


--181
--1
�������, ��� �� ����������� Tele2! �������� ��� ���� ������������� �������� ������, ������� ���������� ������������� Tele2 �� 1 �� 10, ��� 1 - ����� �� ������������, 10 - ����� ������������. ��������� ����� � �����.


--2
����������, �������� �������, �� ������� �� �� ������ ��������� ����� ������� ������? ��������� ���� ����� � �����:
1.���� ���.����� � �������� (������-����������, ���.��������, ������)
2.������, ��� � ������ ����������
3.�� ���������� ����������� ����/��������
4.�� ������� ������/�������
5.������/�������� ���������� �� ������ ������
6.���������� ��� ������ �������� ������/��������
7.�� ����������� �� ���������� � �������
8.����������/�������� �� ���������� ��� ���� �����
9.������


--3
������� �� ������� ������! ����������, �������, ��� �� ������������������ ��� ����������� ������ �����? ��������� ���� ����� � �����:
1.���.������ � ������� (������-����������, ���.��������, ������)
2.�������, ��� � ������ ����������
3.����������� ����/��������
4.������ � ������
5.�����/������ ���������� �� ������ ������
6.�� ���������� ��� ������ ������/��������
7.�������������� �� ���������� � �������
8.����������/�������� �� �������� ��� ���� �����
9.������


--4
������� �� �������! ����� ����������, ���� � ����� �� ������ ��������� �� ����������, ������ �� ������� ������ �������. �������� ��� ���!


--5
������� �� �������! ����� ����������, ���� � ����� �� ������ ��������� �� ����������, ������ ��������� ������ ����� ������. �������� ��� ���!



--���������� q_text
lock row for access
select q_step, length(q_text) from prd2_odw_v.smspoll_poll_contents
where 1=1
 and poll_id = 181
order by 1;

--������ �������
1       254
2       335
3       132
4       274
5       181
6       128
7       245
8       152
9       190

--����� �������
1       239
2       329
3       129
4       270
5       177
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
 and b.poll_id in (141)
where 1=1
 and a.created_date >= timestamp '2022-09-12 00:00:00'
 and a.created_date < timestamp '2022-09-17 00:00:00'
group by 1,2
order by 1
;

2022-09-05  39�534
2022-09-06  77�660
2022-09-07  39�108



select
 cast(created_dttm as date) as created_date,
 poll_id,
 count(distinct subs_id),
 count(*)
from prd2_dds_v.smspoll_detail
where 1=1
 and poll_id in (141)
 and created_dttm >= timestamp '2022-09-15 00:00:00'
 and created_dttm < timestamp '2022-09-16 00:00:00'
group by 1,2
;

2022-09-05  1�627   3�264
2022-09-06  2�959   5�835
2022-09-07  1�779   3�636


--=================================================================================================
--=================================================================================================
--=================================================================================================

REPLACE PROCEDURE uat_ca.mc_nps_bu_181 (in stime timestamp, in etime timestamp)
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

SET proc = 'nps_181';           -- ������������ �������

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;

-- ����������� ������ ������� ������
--CALL uat_ca.prc_debug (proc,:load_id,session,0,'START');
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START: ' || to_char(181));

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
 and poll_id in (181)
 and created_dttm >= :stime
 and created_dttm < :etime
-- and created_dttm >= timestamp '2022-10-10 00:00:00'
-- and created_dttm < timestamp '2022-10-17 00:00:00'
;

--select top 100 * from soa;


-- ����������� �������� �������
get diagnostics ROW_CNT = row_count;
--CALL uat_ca.prc_debug (proc,:load_id,session,null,'INTERVAL_DATE '|| to_char(cast(stime as date),'DD.MM.YYYY') || '_' ||to_char(cast(etime as date),'DD.MM.YYYY') || ' ����� �����: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));
CALL uat_ca.prc_debug (proc,:load_id,session,null,'INTERVAL_DATE '|| to_char(cast(stime as date),'DD.MM.YYYY') || '_' ||to_char(cast(etime as date),'DD.MM.YYYY') || ' ����� �����: ' || to_char(181) || ' in - ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));

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
 load_id
from (
select * from soa pivot (max(mark) for q_step in (
 '1' as step_1,
 '2' as step_2,
 '3' as step_3,
 '4' as step_4,
 '5' as step_5
)) t2
) a
group by 1,2,3,4,10
;

--select * from soa_2;


--03 Step 1 ��������� � ����� �� �������� ��������� ���������� Tele2
/*
�������, ��� �� ����������� Tele2! �������� ��� ���� ������������� �������� ������, ������� ����������
 ������������� Tele2 �� 1 �� 10, ��� 1 - ����� �� ������������, 10 - ����� ������������. ��������� ����� � �����.
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


--04 Step 2 ������ �� �� ������ ��������� ����� ������� ������
/*
����������, �������� �������, �� ������� �� �� ������ ��������� ����� ������� ������? ��������� ���� ����� � �����:
1.���� ���.����� � �������� (������-����������, ���.��������, ������)
2.������, ��� � ������ ����������
3.�� ���������� ����������� ����/��������
4.�� ������� ������/�������
5.������/�������� ���������� �� ������ ������
6.���������� ��� ������ �������� ������/��������
7.�� ����������� �� ���������� � �������
8.����������/�������� �� ���������� ��� ���� �����
9.������
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
      when a.ans_2 = 1 then '���� ���.����� � ��������'
      when a.ans_2 = 2 then '������, ��� � ������ ����������'
      when a.ans_2 = 3 then '�� ���������� ����������� ����/��������'
      when a.ans_2 = 4 then '�� ������� ������/�������'
      when a.ans_2 = 5 then '������/�������� ���������� �� ������ ������'
      when a.ans_2 = 6 then '���������� ��� ������ �������� ������/��������'
      when a.ans_2 = 7 then '�� ����������� �� ���������� � �������'
      when a.ans_2 = 8 then '����������/�������� �� ���������� ��� ���� �����'
      when a.ans_2 = 9 then '������'
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
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6', '7', '8', '9')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_2),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_2
from soa_2
) a
;

--select * from soa_step2;


--05 Step 3 ������ �� ������� ������ �������
/*
������� �� ������� ������! ����������, �������, ��� �� ������������������ ��� ����������� ������ �����? ��������� ���� ����� � �����:
1.���.������ � ������� (������-����������, ���.��������, ������)
2.�������, ��� � ������ ����������
3.����������� ����/��������
4.������ � ������
5.�����/������ ���������� �� ������ ������
6.�� ���������� ��� ������ ������/��������
7.�������������� �� ���������� � �������
8.����������/�������� �� �������� ��� ���� �����
9.������
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
      when a.ans_3 = 1 then '���.������ � �������'
      when a.ans_3 = 2 then '�������, ��� � ������ ����������'
      when a.ans_3 = 3 then '����������� ����/��������'
      when a.ans_3 = 4 then '������ � ������'
      when a.ans_3 = 5 then '�����/������ ���������� �� ������ ������'
      when a.ans_3 = 6 then '�� ���������� ��� ������ ������/��������'
      when a.ans_3 = 7 then '�������������� �� ���������� � �������'
      when a.ans_3 = 8 then '����������/�������� �� �������� ��� ���� �����'
      when a.ans_3 = 9 then '������'
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
      then case when regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[1-9]\d{0,2}') in ('1', '2', '3', '4', '5', '6', '7', '8', '9')
                then regexp_substr(oreplace(oreplace(oreplace(upper(mark_3),' ',''),',',''),'.',''), '[1-9]\d{0,2}') else '-1' end
      else '-1' end as ans_3
from soa_2
) a
;

--select * from soa_step3;



/*
������� �� �������! ����� ����������, ���� � ����� �� ������ ��������� �� ����������, ������ �� ������� ������ �������. �������� ��� ���!
*/

/*
������� �� �������! ����� ����������, ���� � ����� �� ������ ��������� �� ����������, ������ ��������� ������ ����� ������. �������� ��� ���!
*/




--06 �������� ������
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
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific,
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
 a.mark_2,              --
 a.mark_3,              --
 a.mark_4,              --
 a.mark_5,              --
 t2.ans_2,
 t3.ans_3,
 t1.nps,
 a.load_id
from soa_2 a
--
left join soa_nps2    t1 on a.msisdn = t1.msisdn and a.create_date = t1.create_date                   --NPS
left join soa_step2   t2 on a.msisdn = t2.msisdn and a.create_date = t2.create_date                   --�������� � ���������
left join soa_step3   t3 on a.msisdn = t3.msisdn and a.create_date = t3.create_date                   --����� ������������� �������� - ����
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
insert into uat_ca.poll_id_181
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
 coalesce(a.ans_2,   t1.ans_2) as ans_2,
 coalesce(a.ans_3,   t1.ans_3) as ans_3,
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
--CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� �� �������: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));
CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� �� �������: ' || to_char(181) || ' fin - ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));



--�������� ��� �������
insert into uat_ca.poll_id_181
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
 a.ans_2,
 a.ans_3,
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
--CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� ��� �������: ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));
CALL uat_ca.prc_debug (proc,:load_id,session,null,'����� ��� �������: ' || to_char(181) || ' fin - ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


drop table soa;
drop table soa_2;
drop table soa_step2;
drop table soa_step3;
drop table soa_nps;
drop table soa_nps2;
drop table soa_fin;
drop table subs_tmp;


-- ����������� ��������� ������� ������
get diagnostics ROW_CNT = row_count;
--CALL uat_ca.prc_debug (proc,:load_id,session,1,'END');
CALL uat_ca.prc_debug (proc,:load_id,session,1,'END: ' || to_char(181));

END;

--=================================================================================================
--=================================================================================================
--=================================================================================================

-- �����������
COMMENT ON PROCEDURE uat_ca.mc_nps_bu_181 AS
'��������� ������������ ������� � �������� NPS SOA 2.0, �� ��������� �������� 2022. �������������� �������: uat_ca.poll_id_181';


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- ����� ��������� (������� �������/�� �������)

--2022
/*week 42*/ call uat_ca.mc_nps_bu_181 (timestamp '2022-10-17 00:00:00', timestamp '2022-10-18 00:00:00');   -- 2 ���. 53 ���.


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- ����������� �������� � �������� ���������� EDW:
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablekind = 'Procedure' order by "���� ���������� ���������" desc;
select * from prd2_tmd_v.columns_info;


-- ��� ��������� ������������ ���� � ������ ������ ���������, ���� �� �� ���������� ����������� ������ �� ������� �����:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'nps_181'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;



--����������
COLLECT SUMMARY STATISTICS ON uat_ca.poll_id_181;

COLLECT STATISTICS
 COLUMN (CREATE_DATE),
 COLUMN (SUBS_ID),
 COLUMN (MSISDN)
ON uat_ca.poll_id_181;


-- �������� ������
select top 100 * from uat_ca.poll_id_181;
select top 100 * from uat_ca.poll_id_181 where create_date >= date '2022-10-17';


select ans_3, nps, count(*) from uat_ca.poll_id_181 group by 1,2 order by 1,2;


--delete uat_ca.poll_id_181 where trunc (create_date,'iw') = date '2022-10-17';


select create_date, count(distinct msisdn), count(*) from uat_ca.poll_id_181 group by 1 order by 1 desc;
select trunc (create_date,'iw') as week_first_day, weeknumber_of_year (create_date, 'ISO') as week_num, count(distinct msisdn), count(*) from uat_ca.poll_id_181 group by 1,2 order by 1 desc;


--1 ��������� ��������
select
 weeknumber_of_year (create_date, 'ISO') as "������",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_181
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
from uat_ca.v_poll_181
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
from uat_ca.v_poll_181
group by 1
order by 1 desc;


--View
replace view uat_ca.v_poll_181 as
lock row for access
select
 a.create_date,
 t2.cluster_name as cluster_name,
 t4.macroregion_name as macroregion,
 t3.region_name as region,
 '������' as point_name,
 a.msisdn,
 a.subs_id,
-- treatment_code,
 case when a.nps = -1 then a.mark_1 end as mark_1,
 case when a.ans_2 = '������' then a.mark_2 end as mark_2,
 case when a.ans_3 = '������' then a.mark_3 end as mark_3,
 a.mark_4,
 a.mark_5,
 a.ans_2,
 a.ans_3,
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
from uat_ca.poll_id_181 a
--
left join prd2_dds_v.phone_number_2 t1 on a.msisdn = t1.msisdn
 and (a.create_date >= t1.stime and a.create_date < t1.etime)
left join prd2_dic_v.branch t2 on t1.branch_id = t2.branch_id
left join prd2_dic_v.region t3 on t2.region_id = t3.region_id
left join prd2_dic_v.macroregion t4 on t3.macroregion_id = t4.macroregion_id
;

/*
--show view uat_ca.v_poll_mi;
comment on view uat_ca.v_poll_mi_2 as 'NPS ��������� �������� 2022';

comment on column uat_ca.v_poll_mi_2.create_date as '���� ����������� ������';
comment on column uat_ca.v_poll_mi_2.mark_1 as '����� ��� ���� �� ������: NPS';
comment on column uat_ca.v_poll_mi_2.mark_2 as '����� ��� ���� �� ������: ����������� �� �� �������� � ��������� ���������� ���������, ���� ��, �� ��� ���� �����?';
comment on column uat_ca.v_poll_mi_2.mark_3 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� ����';
comment on column uat_ca.v_poll_mi_2.mark_4 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� ������\� �����\������������';
comment on column uat_ca.v_poll_mi_2.mark_5 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� �������� ��������\�� ������';
comment on column uat_ca.v_poll_mi_2.mark_6 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� �������\�� ����';
comment on column uat_ca.v_poll_mi_2.mark_7 as '����� ��� ���� �� ������: ������� ����� ����� �����, ��� ���������� �������� ����� ������ � �����������';
comment on column uat_ca.v_poll_mi_2.mark_8 as '����� ��� ���� �� ������: �����������/���������/�����������/�����';

comment on column uat_ca.v_poll_mi_2.ans_2 as '��������������� ����� �� ������: ����������� �� �� �������� � ��������� ���������� ���������, ���� ��, �� ��� ���� �����?';
comment on column uat_ca.v_poll_mi_2.ans_3 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� ����';
comment on column uat_ca.v_poll_mi_2.ans_4 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� ������\� �����\������������';
comment on column uat_ca.v_poll_mi_2.ans_5 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� �������� ��������\�� ������';
comment on column uat_ca.v_poll_mi_2.ans_6 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� �� �������\�� ����';
comment on column uat_ca.v_poll_mi_2.ans_7 as '��������������� ����� �� ������: ������� ����� ����� �����, ��� ���������� �������� ����� ������ � �����������';
comment on column uat_ca.v_poll_mi_2.nps as '��������������� ����� �� ������: NPS';
*/

select top 100 * from uat_ca.v_poll_181;
select * from uat_ca.v_poll_181 where region is null;

select * from uat_ca.v_poll_181 sample 25;

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
 '������' as point_name,
 count(subs_id) as subs_cnt,
 avg(nps_key) as nps,
 stddev_samp(nps_key) as stddev
from uat_ca.v_poll_181
where 1=1
 and create_date >= date '2022-10-10'
 and create_date < date '2022-10-17'
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
from uat_ca.v_poll_181
where 1=1
 and nps_key in (-1,0,1)
group by 1
order by 1 desc;

select * from uat_ca.v_poll_181;



--=================================================================================================
--=================================================================================================
--=================================================================================================

--show table uat_ca.poll_id_141;

create multiset table uat_ca.poll_id_181 (
 create_date date format 'yy/mm/dd',
 msisdn varchar(20) character set unicode not casespecific,
 subs_id decimal(12,0),
 treatment_code varchar(9) character set unicode not casespecific,
 mark_1 varchar(1024) character set unicode not casespecific,
 mark_2 varchar(1024) character set unicode not casespecific,
 mark_3 varchar(1024) character set unicode not casespecific,
 mark_4 varchar(1024) character set unicode not casespecific,
 mark_5 varchar(1024) character set unicode not casespecific,
 ans_2 varchar(1024) character set unicode not casespecific,
 ans_3 varchar(1024) character set unicode not casespecific,
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
 and lower(a.tablename) = 'poll_id_141'
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
from uat_ca.poll_id_141
group by 1
) as t1,
(select cast(count(*) as float)/(hashamp()+1) as row_avr_amp from uat_ca.poll_id_141) as t2
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
from uat_ca.poll_id_141
group by 1
order by 1
having row_cnt > 10
;


--==4 �����/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('poll_id_141')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          POLL_ID_141             MIKHAIL.CHUPIS      2022-09-06 14:05:14     2022-09-07 04:10:07     0,006           7,842




