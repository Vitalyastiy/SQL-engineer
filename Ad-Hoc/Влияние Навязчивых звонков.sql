
diagnostic helpstats on for session;

/*
����, ������� ���������� ������ ����� ��������, � ������ �� �� ���� �� � ������ ������������.

�������� ��, � ��� ������������ �� �������:
�� ������� ��� ��������� � ����������� � ��������� ������ �� ��������� ��������� ������ ���� TD� � �NPS TD� �� 22 � 23 ���: 
 MSISDN
 ID
 ���� ������
 ���� � ��������� ���������� ������
 ������� ����� �������� ���� TD� � �NPS TD�
������ ��������� ������ �����. ���� TD� ����� �������� ������. �NPS TD� ��������� � ����������,  ��� ������ ��������� �������
*/

--��� td
select top 100 * from uat_ca.v3_nps_main_td;

--td
select top 100 * from uat_ca.mc_base_td;
select report_month, count(*) from uat_ca.mc_base_td group by 1 order by 1;


--��� td
insert into tele2_uat.mc_nps_td
select
 create_date,
 branch_id,
 point_name,
 subs_id,
 msisdn,
 ans_2 as diss_reasons
from uat_ca.v3_nps_main_td
where 1=1
 and create_date >= date '2022-01-01'
 and create_date < date '2022-04-01'
 and nps in (1,2,3,4,5,6,7,8,9,10)
;


--td �� 2023 ����
insert into tele2_uat.mc_nps_td
select
 report_month + interval '1' month - interval '1' day as create_date,
 branch_id,
 'NPS TD' as point_name,
 subs_id,
 msisdn,
 null as diss_reasons
from uat_ca.mc_subs_td /*������ uat_ca.mc_base_td �.�. �������� �����*/
where 1=1
 and create_date >= date '2022-01-01'
 and create_date < date '2023-01-01'
 and nps in (1,2,3,4,5,6,7,8,9,10)
 and subs_id is not null
;

--td � 2023 ����
insert into tele2_uat.mc_nps_td
select
 report_month as create_date,
 branch_id,
 'NPS TD' as point_name,
 subs_id,
 msisdn,
 null as diss_reasons
from uat_ca.mc_subs_td /*������ uat_ca.mc_base_td �.�. �������� �����*/
where 1=1
 and create_date >= date '2023-01-01'
 and create_date < date '2023-05-01'
 and nps in (1,2,3,4,5,6,7,8,9,10)
 and subs_id is not null
;

select * from tele2_uat.mc_nps_td sample 0.01;
select top 100 * from tele2_uat.mc_nps_td;

--delete tele2_uat.mc_nps_td where point_name = 'NPS TD';

select top 100 * from tele2_uat.mc_nps_td;
select point_name, count(*) as subs_cnt from tele2_uat.mc_nps_td group by 1;

--==�����
select trunc(create_date, 'mm'), count(distinct subs_id) as dis_subs, count(*) as row_cnt, row_cnt - dis_subs from tele2_uat.mc_nps_td where point_name = '��� TD' group by 1 order by 1;
select trunc(create_date, 'mm'), count(distinct subs_id) as dis_subs, count(*) as row_cnt, row_cnt - dis_subs from tele2_uat.mc_nps_td where point_name = 'NPS TD' group by 1 order by 1;


--==������
select
 weeknumber_of_year (create_date, 'ISO') as "������",
 count(distinct subs_id) as dis_subs,
 count(*) as row_cnt,
 row_cnt - dis_subs
from tele2_uat.mc_nps_td
where 1=1
 and point_name = '��� TD'
group by 1
order by 1
;

select
 weeknumber_of_year (create_date, 'ISO') as "������",
 count(distinct subs_id) as dis_subs,
 count(*) as row_cnt,
 row_cnt - dis_subs
from tele2_uat.mc_nps_td
where 1=1
 and point_name = 'NPS TD'
group by 1
order by 1
;

select * from tele2_uat.mc_nps_td where subs_id is null;


--==�����
select * from tele2_uat.mc_nps_td where point_name = '��� TD' and create_date >= date '2022-05-01' and create_date < date '2022-06-01'
qualify count(*) over (partition by subs_id) > 1;

select * from uat_ca.v3_nps_main_td where point_name = '��� TD' and create_date >= date '2022-05-01' and create_date < date '2022-06-01'
qualify count(*) over (partition by subs_id) > 1;

select * from uat_ca.mc_base_main_td where point_name = '��� TD' and create_date >= date '2022-05-01' and create_date < date '2022-06-01'
qualify count(*) over (partition by subs_id) > 1;

select * from uat_ca.poll_id_193 where create_date >= date '2022-05-01' and create_date < date '2022-06-01'
qualify count(*) over (partition by subs_id) > 1;

delete select * from uat_ca.poll_id_193 where create_date >= date '2022-05-01' and create_date < date '2022-06-01' and load_id = 3888;



--==������ �������� ������
--drop table tmp;


--==01 ������� � �������
create multiset volatile table tmp, no log as (
--insert into tmp
select * from uat_ca.poll_id_193 where create_date >= date '2022-05-01' and create_date < date '2022-06-01'
qualify count(*) over (partition by subs_id) > 1
) with data
primary index (subs_id)
on commit preserve rows
;

select * from tmp;
delete tmp where load_id = 3887;    --������� ��� �������, ������� ������ �������� � ������������ �������

--==02 ������� ��� �� �������������� �������� ������
create multiset volatile table tmp2, no log as (
--insert into tmp
select * from uat_ca.poll_id_193 where create_date >= date '2022-05-01' and create_date < date '2022-06-01'
) with data
primary index (subs_id)
on commit preserve rows
;

select * from tmp2;

delete tmp2
where 1=1
 and (create_date, subs_id, load_id) in (select create_date, subs_id, load_id from (
--==
select * from tmp
--==
) a
where 1=1
 and create_date >= date '2022-05-01'
 and create_date < date '2022-06-01'
)
;

select * from tmp2;

--==�������� �� �������� �������

delete uat_ca.poll_id_193
where 1=1
 and (create_date, subs_id, load_id) in (select create_date, subs_id, load_id from (
--==
select * from tmp
--==
) a
where 1=1
 and create_date >= date '2022-05-01'
 and create_date < date '2022-06-01'
)
;

--==�������� �������� ��������
select
 trunc (create_date,'mm') as "�����",
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.poll_id_193
group by 1
order by 1 desc;


--==����������� ������ �� ����� ��� ���� ����� - tele2_uat.mc_nps_td
delete tele2_uat.mc_nps_td where point_name = '��� TD' and create_date >= date '2022-05-01' and create_date < date '2022-06-01';


--������� ���������� ������, ����� ����������� ������
insert into tele2_uat.mc_nps_td
select
 create_date,
 branch_id,
 point_name,
 subs_id,
 msisdn,
 ans_2 as diss_reasons
from uat_ca.v3_nps_main_td
where 1=1
 and create_date >= date '2022-05-01'
 and create_date < date '2022-06-01'
 and nps in (1,2,3,4,5,6,7,8,9,10)
;

--��������
select trunc(create_date, 'mm'), count(distinct subs_id) as dis_subs, count(*) as row_cnt, row_cnt - dis_subs from tele2_uat.mc_nps_td where point_name = '��� TD' group by 1 order by 1;

select top 100 * from tele2_uat.mc_nps_td;

select point_name, count(*) from tele2_uat.mc_nps_td group by 1

NPS TD  60�939
��� TD  53�951


select diss_reasons, count(*) from tele2_uat.mc_nps_td
where point_name = '��� TD'
group by 1
;


select min(create_date) from tele2_uat.mc_nps_td
where point_name = '��� TD' and diss_reasons = '������ �� ���������'

select diss_reasons, count(*) from (
select
 create_date,
 branch_id,
 point_name,
 subs_id,
 msisdn,
 ans_2 as diss_reasons
from uat_ca.v3_nps_main_td
where 1=1
 and create_date >= date '2022-01-01'
 and create_date < date '2023-01-01'
 and nps in (1,2,3,4,5,6,7,8,9,10)
)a
 group by 1;

31 383


--==================================================================================================
--==================================================================================================
--==================================================================================================

select top 100 * from tele2_uat.di_nps_contacts_sales1356;

select
 trunc(create_date,'mm'),
 count(distinct subs_id) as dis_subs,
 sum(case when contact_date is not null then 1 else 0 end) as row_cnt,
 row_cnt - dis_subs as diff
from tele2_uat.di_nps_contacts_sales1356
where 1=1
 and point_name = '��� TD'
group by 1
order by 1
;

--NPS TD
select
 trunc(create_date,'mm'),
 count(distinct subs_id) as dis_subs,
 sum(case when contact_date is not null then 1 else 0 end) as row_cnt,
 row_cnt - dis_subs as diff
from tele2_uat.di_nps_contacts_sales1356
where 1=1
 and point_name = 'NPS TD'
group by 1
order by 1
;


--==

select * from tele2_uat.di_nps_contacts_sales1356
where 1=1
 and create_date >= date '2022-11-01'
 and create_date < date '2022-12-01'
 and point_name = '��� TD'
qualify count(*) over (partition by subs_id) > 10
;

select * from tele2_uat.di_nps_contacts_sales1356 where msisdn = '79044497698';


--==������������� �� ���-�� ���������

select count_cnt, count(subs_id) from (
select subs_id, sum(case when contact_date is not null then 1 else 0 end) as count_cnt from tele2_uat.di_nps_contacts_sales1356
where 1=1
 and create_date >= date '2022-11-01'
 and create_date < date '2022-12-01'
 and point_name = '��� TD'
 group by 1
) a
group by 1
order by 2 desc, 1 desc
;


--==��������

select * from tele2_uat.di_nps_contacts_sales1356
where 1=1
 and create_date >= date '2022-11-01'
 and create_date < date '2022-12-01'
 and point_name = '��� TD'
 and contact_date is not null
qualify count(*) over (partition by subs_id) = 3
;


select
 create_date,
 point_name,
 subs_id,
 1 as contact_flg,
 sum(contact_flg) as contact_cnt,
 case when response_cnt > 0 then 1 else 0 end as response_flg,
 sum(response_flg) as response_cnt,
 case when tiker_cnt > 0 then 1 else 0 end as tiker_flg,
 sum(tiker_flg) as tiker_cnt
from (
select
 create_date,
 point_name,
 subs_id,
 case when contact_date is not null then 1 else 0 end as contact_flg,
 case when delivery_response_value = 'Yes' then 1 else 0 end as response_flg,
 case when stime is not null then 1 else 0 end as tiker_flg
from tele2_uat.di_nps_contacts_sales1356
where 1=1
 and contact_date is not null
 and subs_id = 13757529
) a
group by 1,2,3
;


select top 100 * from tele2_uat.di_nps_contacts_sales1356;
select top 100 * from tele2_uat.di_nps_contacts_sales1356_gg;
select control_group, count(*) from tele2_uat.di_nps_contacts_sales1356_gg group by 1;

CG      6�441
TG      115�031
null    5�423

select * from tele2_uat.di_nps_contacts_sales1356_gg where control_group is null;
select point_name, count(distinct subs_id), count(*)
from tele2_uat.di_nps_contacts_sales1356_gg
where 1=1
 and control_group is null
group by 1
;

NPS TD      4�931   5�311
��� TD      111     112

select create_date, count(distinct subs_id), count(*)
from tele2_uat.di_nps_contacts_sales1356_gg
where 1=1
 and point_name = 'NPS TD'
 and control_group is null
group by 1
;

select * from tele2_uat.di_nps_contacts_sales1356 where msisdn = '79867900486';
select * from tele2_uat.di_nps_contacts_sales1356_backup where msisdn = '79867900486';
select * from tele2_uat.di_nps_contacts_sales1356_gg where msisdn = '79867900486';


select count(*) from tele2_uat.di_nps_contacts_sales1356;               --126�895
select count(*) from tele2_uat.di_nps_contacts_sales1356_backup;        --225�824
select count(*) from tele2_uat.di_nps_contacts_sales1356_gg;            --126�895


select point_name, count(distinct subs_id), count(*)
from tele2_uat.di_nps_contacts_sales1356
group by 1
;

NPS TD      56�154      68�042
��� TD      53�792      58�853


select point_name, count(distinct subs_id), count(*)
from tele2_uat.di_nps_contacts_sales1356_backup
group by 1
;

NPS TD      56�154      120�908
��� TD      53�792      104�916


select * from tele2_uat.di_nps_contacts_sales1356 where msisdn = '79525759599';
select * from tele2_uat.di_nps_contacts_sales1356_backup where msisdn = '79525759599';


COLLECT STATISTICS
 COLUMN (CONTROL_GROUP),
 COLUMN (SUBS_ID),
 COLUMN (POINT_NAME),
 COLUMN (CREATE_DATE),
 COLUMN (CONTACT_DATE),
 COLUMN (CREATE_DATE ,POINT_NAME ,SUBS_ID ,CONTROL_GROUP)
ON tele2_uat.di_nps_contacts_sales1356_gg;


COLLECT STATISTICS
 COLUMN (CONTROL_GROUP),
 COLUMN (SUBS_ID),
 COLUMN (POINT_NAME),
 COLUMN (CREATE_DATE),
 COLUMN (CONTACT_DATE),
 COLUMN (CREATE_DATE ,POINT_NAME ,SUBS_ID ,CONTROL_GROUP)
ON uat_ca.mc_nps_td_contacts_sales;


create multiset volatile table step_2, no log as (
select
 create_date,
 point_name,
 subs_id,
 cg,
 1 as contact_flg,
 sum(contact_flg) as contact_cnt,
 case when response_cnt > 0 then 1 else 0 end as response_flg,
 sum(response_flg) as response_cnt,
 case when tiker_cnt > 0 then 1 else 0 end as tiker_flg,
 sum(tiker_flg) as tiker_cnt
from (
select
 create_date,
 point_name,
 subs_id,
 coalesce(control_group,'GCG') as cg,
 case when contact_date is not null then 1 else 0 end as contact_flg,
 case when delivery_response_value = 'Yes' then 1 else 0 end as response_flg,
 case when stime is not null then 1 else 0 end as tiker_flg
--from tele2_uat.di_nps_contacts_sales1356
--from tele2_uat.di_nps_contacts_sales1356_gg
from uat_ca.mc_nps_td_contacts_sales
where 1=1
 and contact_date is not null
-- and subs_id = 13757529
) a
group by 1,2,3,4,5
) with data
primary index (subs_id)
on commit preserve rows
;


select top 100 * from tele2_uat.di_nps_contacts_sales1356_gg;
select * from tele2_uat.di_nps_contacts_sales1356_gg where subs_id = 300063020282

show table tele2_uat.di_nps_contacts_sales1356_gg;

create multiset table uat_ca.mc_nps_td_contacts_sales (
  create_date date format 'yy/mm/dd',
  branch_id decimal(3,0),
  point_name varchar(50) character set unicode not casespecific,
  subs_id decimal(12,0),
  msisdn varchar(11) character set unicode not casespecific,
  diss_reasons varchar(255) character set unicode not casespecific,
  contact_date date format 'yy/mm/dd',
  contact_channel varchar(100) character set unicode not casespecific,
  message_id varchar(8) character set latin not casespecific,
  delivery_response_value varchar(3) character set unicode not casespecific,
  stime timestamp(0),
  control_group varchar(50) character set unicode not casespecific)
primary index ( subs_id );


insert into uat_ca.mc_nps_td_contacts_sales
select * from tele2_uat.di_nps_contacts_sales1356_gg
;


--=================================================================================================

select extract(year from create_date), control_group, count(distinct subs_id), count(*)
from tele2_uat.di_nps_contacts_sales1356_gg
where 1=1
 and contact_date is not null
group by 1, 2
;

select control_group, count(*) from tele2_uat.di_nps_contacts_sales1356_gg group by 1;
CG      6�441
TG      115�031
null    5�423


select top 100 * from tele2_uat.di_nps_contacts_sales1356_gg where contact_date is null and control_group = 'CG';
select top 100 * from tele2_uat.di_nps_contacts_sales1356_gg where contact_date is null and control_group is null;      --���
select count(distinct subs_id) from tele2_uat.di_nps_contacts_sales1356_gg where control_group is null;                 --5 042


select
 trunc(create_date,'mm'),
 count(distinct subs_id) as dis_subs,
 count(*) as row_cnt,
 row_cnt - dis_subs as diff
from step_1
where 1=1
 and point_name = 'NPS TD'
group by 1
order by 1
;

select
 trunc(create_date,'mm'),
 count(distinct subs_id) as dis_subs,
 count(*) as row_cnt,
 row_cnt - dis_subs as diff
from step_1
where 1=1
 and point_name = '��� TD'
group by 1
order by 1
;


select
 trunc(create_date,'mm'),
 count(distinct subs_id) as dis_subs,
 count(*) as row_cnt,
 row_cnt - dis_subs as diff
from step_2
where 1=1
 and point_name = 'NPS TD'
group by 1
order by 1
;

select
 trunc(create_date,'mm'),
 count(distinct subs_id) as dis_subs,
 count(*) as row_cnt,
 row_cnt - dis_subs as diff
from step_2
where 1=1
 and point_name = '��� TD'
group by 1
order by 1
;


select top 100 * from step_1;
select top 100 * from step_2;

--delete uat_ca.mc_nps_tiker

create multiset table uat_ca.mc_nps_tiker as (      --������ �������
insert into uat_ca.mc_nps_tiker
select
 a.create_date,
 a.branch_id,
 a.point_name,
 a.subs_id,
 a.msisdn,
 a.nps,
 a.nps_key,
 a.diss_reasons,
--
 nvl2(t2.subs_id,1,0) as cg,
 coalesce(t1.contact_flg,0) as contact_flg,
 coalesce(t1.contact_cnt,0) as contact_cnt,
 coalesce(t1.response_flg,0) as response_flg,
 coalesce(t1.response_cnt,0) as response_cnt,
 coalesce(t1.tiker_flg,0) as tiker_flg,
 coalesce(t1.tiker_cnt,0) as tiker_cnt
from step_1 a
--
left join step_2 t1 on a.subs_id = t1.subs_id
 and a.create_date = t1.create_date
--
left join (select create_date, subs_id from tele2_uat.di_nps_contacts_sales1356_gg where control_group is null) t2 on a.subs_id = t2.subs_id
 and a.create_date = t2.create_date
) with data
primary index (subs_id)
;

select top 100 * from uat_ca.mc_nps_tiker;

select * from uat_ca.mc_nps_tiker;
select cg, count(*) from uat_ca.mc_nps_tiker group by 1;
0       109�469
1       5�423

select trunc(create_date,'mm'), count(distinct subs_id) from uat_ca.mc_nps_tiker where point_name = 'NPS TD' group by 1 order by 1;
select * from uat_ca.mc_nps_tiker where subs_id is null;


select point_name, count(*) from uat_ca.mc_nps_tiker group by 1;
NPS TD  60�939
��� TD  53�951
�����   114 890


rename table uat_ca.mc_nps_tiker as uat_ca.mc_nps_tiker_tmp;


select * from  uat_ca.mc_nps_tiker where contact_cnt = 4;
select * from tele2_uat.di_nps_contacts_sales1356_gg where msisdn = '79522486730';


--==���� �������

select top 100 * from step_2;
select top 100 * from step_2 where contact_cnt = 1;
select * from tele2_uat.di_nps_contacts_sales1356_gg where subs_id = 44140460;

1. NPS ��. � ����������� �� ������ �� ������ - diff ��������� � ����������� �� ������ �� ������
2. NPS ��. � ����������� �� ���-�� ������� �������
3. ���� ��� NPS TD - ��. ������� ���������� �� "���������� ������"
   * ������� ������� - robot/�������

select contact_channel, count(*) from tele2_uat.di_nps_contacts_sales1356_gg group by 1;


create multiset volatile table step_3, no log as (
select
 a.create_date,
 t1.contact_date as cont_date,
 cast(t1.stime as date) as tiker_date,
 t1.contact_channel as cont_channel,
-- t1.delivery_response_value as delivery_response,
 a.create_date - cont_date as diff_cont_day,
 a.create_date - tiker_date as diff_tiker_day,
 case when t1.contact_channel is null then null
      when t1.contact_channel in ('TS Robot', 'RT_TS_Robot') then 'robot'
      when t1.contact_channel in ('Call Center', 'RT_CallCenter', '������� Call Ce', '������� Call Center') then 'non robot'
      else 'n/a' end as system_flg,
 a.point_name,
 a.subs_id,
 a.cg,
 a.contact_flg,
 a.contact_cnt,
 a.response_flg,
 a.response_cnt,
 a.tiker_flg,
 a.tiker_cnt
from step_2 a
--
inner join uat_ca.mc_nps_td_contacts_sales t1 on a.subs_id = t1.subs_id
 and a.create_date = t1.create_date
where 1=1
 and a.contact_cnt = 1
) with data
primary index(subs_id)
on commit preserve rows
;

select top 100 * from step_3;

--drop table uat_ca.mc_nps_tiker;
--delete uat_ca.mc_nps_tiker;


--=================================================================================================
--==�������� ������ ��� ����� - nps tiker v.5.xlsb C:\Users\mikhail.chupis\Desktop\����� ���������\���������\���������� ������
--=================================================================================================

step_1                              -- ������ 1051
step_2                              -- ������ 442
step_3                              -- ������ 646
uat_ca.mc_nps_td_contacts_sales     -- ������ 482

select top 100 * from step_1;
select top 100 * from step_2;
select top 100 * from step_3;
select top 100 * from uat_ca.mc_nps_td_contacts_sales;

--�������
�.�. � ��� � 2022 ���� ���� �� ������� ����� ������, � � 2023 ���� �� ��� - �� ������ ������� ��� �� NPS TD
� ������ ������� ����� nps in (1,2,3,4,5,6,7,8)

--delete uat_ca.mc_nps_tiker_2;

--����� 1
create multiset table uat_ca.mc_nps_tiker_2 as (
--insert into uat_ca.mc_nps_tiker_2
select
 a.create_date,
 t3.cont_date,
 t3.tiker_date,
 t3.cont_channel,
 t3.diff_cont_day,
 t3.diff_tiker_day,
 t3.system_flg,
 a.branch_id,
 a.point_name,
 a.subs_id,
 a.msisdn,
 a.nps,
 a.nps_key,
 a.diss_reasons,
--
 nvl2(t2.subs_id,1,0) as cg,
 coalesce(t1.contact_flg,0) as contact_flg,
 coalesce(t1.contact_cnt,0) as contact_cnt,
 coalesce(t1.response_flg,0) as response_flg,
 coalesce(t1.response_cnt,0) as response_cnt,
 coalesce(t1.tiker_flg,0) as tiker_flg,
 coalesce(t1.tiker_cnt,0) as tiker_cnt,
 nvl2(t3.subs_id,1,0) as one_cont_flg,
--
 coalesce(t4.bad_call_flg,0) as bad_call_flg,
 coalesce(t4.res_count, 0) as res_count,
 coalesce(t4.res_count_non_bad_call, 0) as res_count_non_bad_call,
 coalesce(t4.q217ac1, 0) as q217ac1,
 coalesce(t4.q217ac2, 0) as q217ac2,
 coalesce(t4.q217ac3, 0) as q217ac3,
 coalesce(t4.q217ac4, 0) as q217ac4,
 coalesce(t4.q217ac5, 0) as q217ac5,
 coalesce(t4.q217ac6, 0) as q217ac6,
 coalesce(t4.q217ac7, 0) as q217ac7,
 coalesce(t4.q217ac8, 0) as q217ac8,
 coalesce(t4.q217ac9, 0) as q217ac9,
 coalesce(t4.q217ac10, 0) as q217ac10,
 coalesce(t4.q217ac11, 0) as q217ac11,
 coalesce(t4.q217ac12, 0) as q217ac12,
 coalesce(t4.q217ac13, 0) as q217ac13,
 coalesce(t4.q217ac14, 0) as q217ac14,
 coalesce(t4.q217ac15, 0) as q217ac15,
 case when t4.bad_call_flg = 1 and t4.res_count = 1 then 1 else 0 end as bad_one_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac2 = 1 then 1 else 0 end as bad_zone_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac3 = 1 then 1 else 0 end as bad_tp_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac5 = 1 then 1 else 0 end as bad_rouming_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac4 = 1 then 1 else 0 end as bad_rouming_abroad_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac1 = 1 then 1 else 0 end as bad_quality_flg,
 nvl2(t4.msisdn,1,0) as dess_res_subs_flg
from step_1 a
--
left join step_2 t1 on a.subs_id = t1.subs_id
 and a.create_date = t1.create_date
--���
left join (select create_date, subs_id from uat_ca.mc_nps_td_contacts_sales where control_group is null) t2 on a.subs_id = t2.subs_id
 and a.create_date = t2.create_date
--���� �������
left join step_3 t3 on a.subs_id = t3.subs_id
 and a.create_date = t3.create_date
--�������� ������� ���������� ������
left join (
select
 report_month,
 msisdn,
 q217ac12_flg as bad_call_flg,
 res_count,
 res_count_non_ac12 as res_count_non_bad_call,
 q217ac1,
 q217ac2,
 q217ac3,
 q217ac4,
 q217ac5,
 q217ac6,
 q217ac7,
 q217ac8,
 q217ac9,
 q217ac10,
 q217ac11,
 q217ac12,
 q217ac13,
 q217ac14,
 q217ac15
from uat_ca.mc_msisdn_td_add
where 1=1
 and nps in (1,2,3,4,5,6,7,8,9,10)
 and report_month < date '2023-01-01'
-- and report_month >= date '2023-01-01'
-- and report_month < date '2023-05-01'
) t4 on a.msisdn = t4.msisdn
-- and a.create_date = t4.report_month
 and trunc(a.create_date,'mm') = trunc(t4.report_month,'mm')
-- and trunc(a.create_date,'yy') = trunc(t4.report_month,'yy')
 and a.point_name = 'NPS TD'
--
where 1=1
 and a.create_date < date '2023-01-01'
-- and a.create_date >= date '2023-01-01'
) with data
primary index (subs_id)
;

--����� 2
insert into uat_ca.mc_nps_tiker_2
select
 a.create_date,
 t3.cont_date,
 t3.tiker_date,
 t3.cont_channel,
 t3.diff_cont_day,
 t3.diff_tiker_day,
 t3.system_flg,
 a.branch_id,
 a.point_name,
 a.subs_id,
 a.msisdn,
 a.nps,
 a.nps_key,
 a.diss_reasons,
--
 nvl2(t2.subs_id,1,0) as cg,
 coalesce(t1.contact_flg,0) as contact_flg,
 coalesce(t1.contact_cnt,0) as contact_cnt,
 coalesce(t1.response_flg,0) as response_flg,
 coalesce(t1.response_cnt,0) as response_cnt,
 coalesce(t1.tiker_flg,0) as tiker_flg,
 coalesce(t1.tiker_cnt,0) as tiker_cnt,
 nvl2(t3.subs_id,1,0) as one_cont_flg,
--
 coalesce(t4.bad_call_flg,0) as bad_call_flg,
 coalesce(t4.res_count, 0) as res_count,
 coalesce(t4.res_count_non_bad_call, 0) as res_count_non_bad_call,
 coalesce(t4.q217ac1, 0) as q217ac1,
 coalesce(t4.q217ac2, 0) as q217ac2,
 coalesce(t4.q217ac3, 0) as q217ac3,
 coalesce(t4.q217ac4, 0) as q217ac4,
 coalesce(t4.q217ac5, 0) as q217ac5,
 coalesce(t4.q217ac6, 0) as q217ac6,
 coalesce(t4.q217ac7, 0) as q217ac7,
 coalesce(t4.q217ac8, 0) as q217ac8,
 coalesce(t4.q217ac9, 0) as q217ac9,
 coalesce(t4.q217ac10, 0) as q217ac10,
 coalesce(t4.q217ac11, 0) as q217ac11,
 coalesce(t4.q217ac12, 0) as q217ac12,
 coalesce(t4.q217ac13, 0) as q217ac13,
 coalesce(t4.q217ac14, 0) as q217ac14,
 coalesce(t4.q217ac15, 0) as q217ac15,
 case when t4.bad_call_flg = 1 and t4.res_count = 1 then 1 else 0 end as bad_one_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac2 = 1 then 1 else 0 end as bad_zone_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac3 = 1 then 1 else 0 end as bad_tp_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac5 = 1 then 1 else 0 end as bad_rouming_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac4 = 1 then 1 else 0 end as bad_rouming_abroad_flg,
 case when t4.bad_call_flg = 1 and t4.q217ac1 = 1 then 1 else 0 end as bad_quality_flg,
 nvl2(t4.msisdn,1,0) as dess_res_subs_flg
from step_1 a
--
left join step_2 t1 on a.subs_id = t1.subs_id
 and a.create_date = t1.create_date
--���
left join (select create_date, subs_id from uat_ca.mc_nps_td_contacts_sales where control_group is null) t2 on a.subs_id = t2.subs_id
 and a.create_date = t2.create_date
--���� �������
left join step_3 t3 on a.subs_id = t3.subs_id
 and a.create_date = t3.create_date
--�������� ������� ���������� ������ q217bc12
left join (
select
 report_month,
 msisdn,
 q217ac12_flg as bad_call_flg,
 res_count,
 res_count_non_ac12 as res_count_non_bad_call,
 q217ac1,
 q217ac2,
 q217ac3,
 q217ac4,
 q217ac5,
 q217ac6,
 q217ac7,
 q217ac8,
 q217ac9,
 q217ac10,
 q217ac11,
 q217ac12,
 q217ac13,
 q217ac14,
 q217ac15
from uat_ca.mc_msisdn_td_add
where 1=1
 and nps in (1,2,3,4,5,6,7,8,9,10)
 and report_month >= date '2023-01-01'
 and report_month < date '2023-05-01'
) t4 on a.msisdn = t4.msisdn
 and trunc(a.create_date,'yy') = trunc(t4.report_month,'yy')
 and a.point_name = 'NPS TD'
--
where 1=1
 and a.create_date >= date '2023-01-01'
;


select * from uat_ca.mc_nps_tiker;
select * from uat_ca.mc_nps_tiker_2;

select count(*) from uat_ca.mc_nps_tiker;       --114�926
select count(*) from uat_ca.mc_nps_tiker_2;     --114�920


select top 100 * from uat_ca.mc_nps_tiker_2 where bad_call_flg is null;

select nps, count(*) from uat_ca.mc_nps_tiker_2 where bad_call_flg = 1 group by 1;



select q217ac12_flg, count(*) from uat_ca.mc_msisdn_td_add group by 1;

1       7�992
null    22�318
0       35�088

select nps, count(*) from uat_ca.mc_msisdn_td_add where q217ac12_flg = 1 group by 1;

-1,858
1,662
2,132
3,411
4,382
5,1�303
6,735
7,1�449
8,1�423
9,637

select nps, count(*) from uat_ca.mc_msisdn_td_add where q217ac12_flg = 0 group by 1;

-1,4�779
1,2�093
2,435
3,1�052
4,1�223
5,5�206
6,2�896
7,6�227
8,7�247
9,3�930

select nps, count(*) from uat_ca.mc_msisdn_td_add where q217ac12_flg is null group by 1;

9,792
10,21�526




--�������� � ���� C:\Users\mikhail.chupis\Desktop\����� ���������\���������\���������� ������\nps_tiker.csv
select * from uat_ca.mc_nps_tiker_2;


select top 100 * from uat_ca.mc_nps_tiker;
select dess_res_subs_flg, count(*) from uat_ca.mc_nps_tiker group by 1;

--������ ��������
0   107�007
1   7�897

--������ ��������
1   28�826
0   86�100
114 926

--������ ��������
1   32�387
0   84�771
117 158

--��������� ��������
1   28�826
0   86�100
114 926     --114 904


--==��������� �������
select a.* from step_1 a
inner join tmp t1 on a.msisdn = t1.msisdn
 and trunc(a.create_date,'yy') = trunc(t1.report_month,'yy')
-- and a.create_date = t1.report_month
 and a.point_name = 'NPS TD'
where 1=1
;

select count(*) from uat_ca.mc_nps_tiker where point_name = '��� TD' and dess_res_subs_flg = 1;

select create_date, count(*) from step_1 where point_name = 'NPS TD' group by 1 order by 1;

select * from step_1 where msisdn = '79040768540';
select * from uat_ca.mc_msisdn_td_add where msisdn = '79040768540';



--�������� ������� ���������� ������
select top 100 * from uat_ca.mc_msisdn_td_add;

--drop table tmp;

create multiset volatile table tmp, no log as (
select
 report_month,
 msisdn,
 q217ac12_flg as bad_call_flg,
 res_count,
 res_count_non_ac12 as res_count_non_bad_call,
 q217ac1,
 q217ac2,
 q217ac3,
 q217ac4,
 q217ac5,
 q217ac6,
 q217ac7,
 q217ac8,
 q217ac9,
 q217ac10,
 q217ac11,
 q217ac12,
 q217ac13,
 q217ac14,
 q217ac15
from uat_ca.mc_msisdn_td_add
where 1=1
 and nps in (1,2,3,4,5,6,7,8)
 and report_month < date '2023-05-01'
) with data
primary index (msisdn)
on commit preserve rows
;





--=================================================================================================
--==��� td
--=================================================================================================

select top 100 * from uat_ca.v3_nps_main_td;

--delete step_1;

create multiset volatile table step_1, no log as (
--insert into step_1
select
 create_date,
 branch_id,
 point_name,
 subs_id,
 msisdn,
 nps,
 nps_key,
 ans_2 as diss_reasons
from uat_ca.v3_nps_main_td
where 1=1
 and create_date >= date '2022-01-01'
 and create_date < date '2023-05-01'
 and nps in (1,2,3,4,5,6,7,8,9,10)
) with data
primary index (subs_id)
on commit preserve rows
;

select count(*) from step_1;
60 639
53 951

select point_name, count(*) from step_1 group by 1;
NPS TD  60�939
��� TD  53�951


--==����

--td �� 2023 ����
select top 100 * from uat_ca.mc_subs_td;

insert into step_1
select
 report_month + interval '1' month - interval '1' day as create_date,
 branch_id,
 'NPS TD' as point_name,
 subs_id,
 msisdn,
 nps,
 case when nps in (1,2,3,4,5,6) then -1
      when nps in (7,8) then 0
      when nps in (9,10) then 1
      end as nps_key,
 null as diss_reasons
from uat_ca.mc_subs_td /*������ uat_ca.mc_base_td �.�. �������� �����*/
where 1=1
 and create_date >= date '2022-01-01'
 and create_date < date '2023-01-01'
 and nps in (1,2,3,4,5,6,7,8,9,10)
 and subs_id is not null
;

--td � 2023 ����
insert into step_1
select
 report_month as create_date,
 branch_id,
 'NPS TD' as point_name,
 subs_id,
 msisdn,
 nps,
 case when nps in (1,2,3,4,5,6) then -1
      when nps in (7,8) then 0
      when nps in (9,10) then 1
      end as nps_key,
 null as diss_reasons
from uat_ca.mc_subs_td /*������ uat_ca.mc_base_td �.�. �������� �����*/
where 1=1
 and create_date >= date '2023-01-01'
 and create_date < date '2023-05-01'
 and nps in (1,2,3,4,5,6,7,8,9,10)
 and subs_id is not null
;



--==================================================================================================
--==�������� ��������� ����� NPS TD
--==================================================================================================

create multiset table uat_ca.mc_msisdn_td_add (
 msisdn varchar(11) character set unicode not casespecific,
 id decimal(12,0),
 report_month date format 'yy/mm/dd',
 operator_name varchar(50) character set unicode casespecific,
 nps byteint,
 nps_key byteint,
 ad_hoc varchar(50) character set unicode casespecific,
 q217ac12_flg byteint,
 res_count_non_ac12 decimal(3,0),
 res_count decimal(3,0),
 q217ac1 byteint,
 q217ac2 byteint,
 q217ac3 byteint,
 q217ac4 byteint,
 q217ac5 byteint,
 q217ac6 byteint,
 q217ac7 byteint,
 q217ac8 byteint,
 q217ac9 byteint,
 q217ac10 byteint,
 q217ac11 byteint,
 q217ac12 byteint,
 q217ac13 byteint,
 q217ac14 byteint,
 q217ac15 byteint,
 q217ac99 byteint
)
primary index (msisdn)
;

select top 100 * from uat_ca.mc_msisdn_td_add;

--43�080
select count(*) from uat_ca.mc_msisdn_td_add;



select trunc(report_month,'mm'), count(distinct msisdn), count(*) from uat_ca.mc_msisdn_td_add group by 1 order by 1;
select trunc(report_month,'mm'), count(distinct msisdn), count(*) - count(distinct msisdn) as non_unique from uat_ca.mc_msisdn_td_add group by 1 order by 1;

--����� ��� �������� C:\Users\mikhail.chupis\Desktop\����� ���������\���������\�������� ������ NPS TD\_�������� ��������� ����� �� msisdn
43 080      --addtional request Diss reasons 2022_2023.xlsx
22 318      --addtional request Diss reasons 2022_2023 (9 � 10).xlsx
�����:  65 398


�������:
--�� ��������� ����� � 9 � 10
������   -2 106
�������  -2 164
--�� ��������� ����� ��� 10
����     -1 842
����     -1 775
�����:   7 887

65 339
65 398

--43 044
2022-01-01     2�354       2
2022-02-01     2�364       4
2022-03-01     2�495       9
2022-04-01     2�281       0
2022-05-01     3�146       0
2022-06-01     2�688       0
2022-07-01     2�680       0
2022-08-01     2�811       0
2022-09-01     2�688       0
2022-10-01     2�226       14
2022-11-01     2�406       1
2022-12-01     2�313       5
2023-01-01     2�805       1
2023-02-01     3�038       0
2023-03-01     2�503       0
2023-04-01     2�191       0
2023-05-01     2�055       0


--��� �������� ��������� �����
select top 100 * from uat_ca.mc_msisdn_td;
select report_month, count(*) from uat_ca.mc_msisdn_td group by 1 order by 1;
select trunc(report_month,'mm'), count(distinct msisdn), count(*) from uat_ca.mc_msisdn_td where report_month >= date '2022-01-01' group by 1 order by 1;

73 214
73 258

--=================================================================================================
--167 419, � ����� excel 167 446, ������� 27 ��������� - �� ����������� � EDW, ������ ��� �����

--==������� 1
select top 100 * from uat_ca.mc_msisdn_td;

select
 report_month,
 count(*)
from uat_ca.mc_msisdn_td
where 1=1
 and report_month < date '2023-01-01'
group by 1
order by 1;


select
 trunc(report_month, 'y') as years,
 count(*)
from uat_ca.mc_msisdn_td
where 1=1
 and report_month >= date '2022-06-01'
 and report_month < date '2023-04-01'
group by 1
order by 1;



--==������� 2
select top 100 * from uat_ca.mc_msisdn_td_add;

select
 report_month,
 count(*)
from uat_ca.mc_msisdn_td_add
where 1=1
group by 1
order by 1;


select
 trunc(report_month, 'y') as years,
 count(*)
from uat_ca.mc_msisdn_td_add
where 1=1
 and report_month >= date '2022-06-01'
 and report_month < date '2023-04-01'
group by 1
order by 1;



--==������ �� ���������, ������� ���������� � 2022 ����

--29 340
select
 report_month,
 msisdn,
 nps
from uat_ca.mc_msisdn_td
where 1=1
 and report_month >= date '2022-06-01'
 and report_month < date '2023-01-01'
;

--25 725
select
 report_month,
 msisdn,
 nps
from uat_ca.mc_msisdn_td_add
where 1=1
 and report_month >= date '2022-06-01'
 and report_month < date '2023-01-01'
;


select report_month, count(*) from (
select nps, count(*) from (
select * from (
select
 a.report_month,
 a.msisdn,
 a.nps
from uat_ca.mc_msisdn_td a
--
left join (
select
 report_month,
 msisdn,
 nps
from uat_ca.mc_msisdn_td_add
where 1=1
 and report_month >= date '2022-06-01'
 and report_month < date '2023-01-01'
) t1 on a.msisdn = t1.msisdn
where 1=1
 and a.report_month >= date '2022-06-01'
 and a.report_month < date '2023-01-01'
 and t1.msisdn is null
) a
where 1=1
 and nps in (10)
sample 0.01
 and nps in (5,7,8,9,-1)
group by 1
order by 1
;



--31 613
select
 report_month,
 msisdn,
 nps
from uat_ca.mc_msisdn_td
where 1=1
 and report_month >= date '2022-01-01'
 and report_month < date '2022-08-01'
;


--23 741
select
 report_month,
 msisdn,
 nps
from uat_ca.mc_msisdn_td_add
where 1=1
 and report_month >= date '2022-01-01'
 and report_month < date '2022-08-01'
;



--37 655
select
 report_month,
 msisdn,
 nps
from uat_ca.mc_msisdn_td
where 1=1
 and report_month >= date '2022-08-01'
 and report_month < date '2023-05-01'
;


--37 667
select
 report_month,
 msisdn,
 nps
from uat_ca.mc_msisdn_td_add
where 1=1
 and report_month >= date '2022-08-01'
 and report_month < date '2023-05-01'
;

--=================================================================================================



select top 100 * from uat_ca.mc_subs_td;

select top 100 * from uat_ca.mc_base_td;
select top 100 * from uat_ca.mc_base_td where subs_id is null;


--�������� ����������� 10 537 (10 538)

--drop table test;

create multiset volatile table test, no log as (
select
 a.report_month,
 a.msisdn,
 a.nps,
 t1.nps as nps_one,
 case when a.nps = t1.nps then 1 else 0 end as nps_flg
from uat_ca.mc_msisdn_td_add a
left join uat_ca.mc_msisdn_td t1 on a.msisdn = t1.msisdn
 and a.report_month = t1.report_month
 and t1.report_month >= date '2023-01-01'
 and t1.report_month < date '2023-05-01'
 and t1.nps not in (10)
where 1=1
 and a.report_month >= date '2023-01-01'
 and a.report_month < date '2023-05-01'
 and t1.msisdn is null
) with data
primary index (msisdn)
on commit preserve rows
;

select nps_flg, count(*) from test group by 1;

1   10�403

select * from test qualify count(*) over (partition by msisdn) > 1;

select * from test where msisdn = '79003501494';
select * from uat_ca.mc_msisdn_td where msisdn = '79003501494';
select * from uat_ca.mc_msisdn_td_add where msisdn = '79003501494';


--������� ��� �������, ������� �� �������� �� ����� � ������ ��������� �� ������
2023-02-05     79515125252
2023-03-24     79044491799
2023-01-15     79081815224
2023-03-14     79515161697
2023-01-20     79001243572

select * from uat_ca.mc_msisdn_td where msisdn in ('79515125252', '79044491799', '79081815224', '79515161697', '79001243572');

select * from uat_ca.mc_msisdn_td_add where msisdn in ('79515125252', '79044491799', '79081815224', '79515161697', '79001243572');

2023-01-01     79001243572      7
2022-09-01     79044491799      2
2022-12-01     79044491799      6
2023-03-01     79044491799      3
2023-01-01     79081815224      5
2023-02-01     79515125252      7
2023-03-01     79515161697      -1

2023-01-20     79001243572
2022-09-17     79044491799
2023-03-24     79044491799
2022-12-07     79044491799
2023-01-15     79081815224
2023-02-05     79515125252
2023-03-14     79515161697





















--==================================================================================================

show table tele2_uat.mc_nps_td;
--drop table tele2_uat.mc_nps_td;

create multiset table tele2_uat.mc_nps_td (
 create_date date format 'yy/mm/dd',
 branch_id decimal(3,0),
 point_name varchar(50) character set unicode not casespecific,
 subs_id decimal(12,0),
 msisdn varchar(11) character set unicode not casespecific,
 diss_reasons varchar(255) character set unicode not casespecific)
primary index (subs_id);










































