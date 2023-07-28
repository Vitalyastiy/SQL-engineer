
--����������� ������������ ����������, � ������ �� ����������, ����� ��������� �������� ������� EXPLAIN, �������������� �������� ����������� � ������� ������
diagnostic helpstats on for session;



--==��� 1 ������ � �������� EDW

�������� ���������� � ������������ �������� � EDW � ������������ � ��� �����, ����� ��������������� � �������, �������� ��������� SQL-�������:

select * from prd2_tmd_v.tables_info;
select * from prd2_tmd_v.columns_info;

https://t2ru-alation-prod-app

� �������� ���������� ��������� ����������:
 ������� �������� ������������ ������ � �������
 �������� ������� ��� �� ��������
 �������������, ������� �������� ���������� ������ �������
 ������� �������� ������
 ������� � ��������� ����������, ������� ��������� ������� ��������
 ������ ������� � GB
 ��� �����-��������������� ������ �� �������-���������� � ������������ ����

--������ ����� �� ���������
��� ����� DDS/BDS/MDS/RDS � ����������� � ������� EDW ��� ������������� ������ ����� ���������� ��������� ������������ � �������
�������������� ��������. ��� ���������� ���������� � �������� ������������� � ��������� �������������� � ����������� � ������� EDW:

select top 100 * from PRD2_TMD_V.DEFAULT_FIELD_FORMAT;



--==��� 2 ������� �������

������ ��� �������� ����� �� ������� ������ �� ���� �������, ������� ����� ���� ������ �������������
    Rows per value
    Rows per hash bucket
    Rows per AMP
    Rows per row partition
    Rows per row partition per AMP
    Rows per row partition per hash bucket
    Rows per row partition per value


--������ ���������� ��������������� ������������� �������. ���������� ������ ���� ����� 5%
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
 and lower(t1.databasename) = 'uat_ca'                  --��� �����
-- and t1.tablekind = 't'
where 1=1
 and lower(a.databasename) = 'uat_ca'                   --��� �����
 and lower(a.tablename) = 'mc_nps_hwe'                  --��� �������
group by 1,2,3,4
;


--������ ���������� ������������� ����� ������� �� AMP. ���������� �� �������� ��� ������������ ��� ������������� �������� ������ ���� ������ 15%
select
 t1.amp_no,
 t1.row_cnt,
 ((t1.row_cnt/t2.row_avr_amp) - 1.0)*100 as deviation
from
(select
 hashamp(hashbucket(hashrow(subs_id))) as amp_no,       --primary index
 cast(count(*) as float) as row_cnt
from uat_ca.mc_nps_hwe                                  --��� �����/�������
group by 1
) as t1,
(select cast(count(*) as float)/(hashamp()+1) as row_avr_amp from uat_ca.mc_nps_hwe) as t2          --��� �����/�������
order by 2 desc
;


--dll �������
show table uat_ca.mc_nps_hwe;
PRIMARY INDEX ( subs_id )
PARTITION BY RANGE_N(create_date  BETWEEN DATE '2020-01-09' AND DATE '2022-12-31' EACH INTERVAL '1' DAY );



--������ ���������� ���������� ���������� ���� ����� ��� ���������� ������� ��� �������
/*��������, � ������� �������� rowhash ��� ������ ����� ���������, ��� ���������� ��� �������
  ���������� ���-���������, ����� ���� ���������� ������ ������������� ��� ����������
  https://www.docs.teradata.com/r/w4DJnG9u9GdDlXzsTXyItA/XfRpR9T7fWZfF_1IZWuwRg
*/

select
 hashrow(subs_id) as row_hash,                      --primary index
 count(*) as row_cnt
from uat_ca.mc_nps_hwe
group by 1
order by 1
having row_cnt > 3
;



--==����� ���������� �������

--������������� ����� ������� �� AMP � ������� �������
Sel HASHAMP(HASHBUCKET(HASHROW(subs_id))) AS AMP_NO,COUNT(*)
from uat_ca.mc_nps_hwe
group by 1
order by 2;


--������������� ����� ������� �� AMP � ����������� �������
� �������� ��������/������� ������ � ������� � �������������� left, right, full join ����� ������� ������ ��������������� ������������ �������� ���������� �������,
��� select ������� ������������� ������� ���������� ������������� ��� ������ �������  hashamp(hashbucket(hashrow(pi_candidate)))
��������:

--������ "��������" �������
lock row for access
select hashamp(hashbucket(hashrow(a.msisdn, a.created_date))) as amp_no, count(*)
from (
select
 pr.created_date,                   -- ���� �������� ������/���� ��������� �������
 pr.replay_date,                    -- ���� ��������� ������
 pr.current_communication_id,       -- ������������� ��������                                                         - �� ���������� � poll_reports (��������� step), ���������� � current_communications
 cc.sub_list_id,                    -- ������������� ������ ��������� ������                                          - ����������
 cc.short_number,                   -- �������� �����, � �������� �������� �����
 cc.poll_id,                        -- ������������� ������ �� ������� POLLS (NPS ��������� ��������, NPS_B2B � �.�.)
 cl.treatment_code,                 -- ������������� ������ �������� �� ������� �������
 pr.msisdn,                         -- ��������� ����� ��������
 pr.q_step,                         -- ����� �������
 pc.content_id,                     -- ������������� ������
 pc.q_text_id,                      -- ������������� ������� ��� ����������
 pc.q_text,                         -- ������������ �������
 pc.nps,                            -- ������� nps - 1. �� nps - 0
 pr.mark,                           -- ����� �������� (������������)
 pr.mark_text,                      -- ������������ ������
 cl.addition                        -- �������������� ������ �� ������� �������
from uat_ca.knime_poll_reports pr
--
left join uat_ca.knime_current_communications cc on pr.current_communication_id = cc.current_communication_id
--
left join uat_ca.knime_communication_lists cl on pr.msisdn = cl.msisdn
 and cc.sub_list_id = cl.sub_list_id
--�����������
left join uat_ca.knime_dic_poll_contents pc on cc.poll_id = pc.poll_id
 and pr.q_step = pc.q_step
--
where 1=1
 and cc.poll_id in (8,9,2,3,14,11,1,22,23,309,310,311,312,313,52,53,417)
 and pr.created_date >= timestamp '2021-10-01 00:00:00'
 and pr.created_date < timestamp '2022-01-01 00:00:00'
) a
group by 1
order by 2 desc;

/*
���� �����-���� ������� � ����������� ������ �� ������� �� ����������� (��������, ������� ������������ � ������������� ����, � ������ �� ���
������ ���������� � ����������� ���������, ����� ���� ����� ��������� ���������), �� ������������� ��������� ����� ������� ��� PRIMARY INDEX.
��� �������� ����� ������� � DDL ���������� ���� ������� "NO PRIMARY INDEX". ���� ����� �� �������, � ������ �� ������� PRIMARY INDEX, �� �
�������� PRIMARY INDEX ������������� ����� ����������� ������ ������� ����������� �������. � �������� ��� PRIMARY INDEX (�������� NoPI) ������
�������������� �� AMP'�� ��������� �������, ��� ������������ ������������� ����� �������������. ��������������, ���� ��� ������ ����� � ��� ��
����� � ������� ������������� �� �� AMP'�� ������ ��� ����� ����� (���������� - ���� ������ ����������� �� ������ ������� Teradata. ����� ���
����� ������������ �� �� �� AMP'�, �� ������� ��� ��������� � �������-���������).
*/



--������ ������� � SkewFactor

--show view show_table_size;


--(100 - (Avg(s.CurrentPerm)/Max(s.CurrentPerm)*100)) as SkewFactor

select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('mc_nps_hwe')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          MC_NPS_HWE              MIKHAIL.CHUPIS      2021-07-05 05:04:22     2021-12-27 16:46:15     46,895          14,624
UAT_CA          MC_NPS_HWE              MIKHAIL.CHUPIS      2022-05-27 13:40:08     2022-07-04 15:46:21     0,441           9,114



--==��� 3 ������������ ������ � ������� �������� ������

select top 100 * from prd2_tmd_v.bds_load_status where table_name='SUBS_CLR_D';       --���� ������-������ EDW TERADATA
select top 100 * from prd2_tmd_v.dds_load_status where table_name='SUBSCRIPTION';       --���� ��������� ������ EDW TERADATA

����:
ODW  - Operational Data Warehouse:   ���� ������ �������. �������� ��� ����������� ������ �� ������� ����������
DDS  - Detail Data Store:            ���� ��������� ������ EDW TERADATA
BDS  - Business Data Store:          ���� ������-������ EDW TERADATA
RDS  - Reports Data Store:           ���� �������������� ������� EDW TERADATA
DIC  - Dictionary:                   ����� ����������� EDW TERADATA
SEC  - Secure:                       ���� ������������ ������ EDW TERADATA

MDS  - Marts Data Store:             ���� �������������� ������ EDW TERADATA (������� ��� ������� �� ������� Data Science � ���������� ������������ �������)
TMD  - Technical Metadata:           ���������� EDW TERADATA (������� ������������ ���������, �����������)
HIST - History Data Store:           ���� ������������ ������ EDW TERADATA
DQS  - Data Quality Store:           ���� ������ �������� ������ EDW TERADATA
SVA  - SAS Visual Analytics:         C��� �������������� ������ ��� ����������� � SAS VA TERADATA
SPSS - DM:                           Data Mining (���� �������� ��������� � ������� ����� SPSS Modeler)

***������� ��� V �� V2 � ���, ��� View � V2 �������� "�������" ��������������� ������, � � V ���������� �������������� ���������� �� �������������


select max_report_date from prd2_tmd_v.bds_load_status where table_name='SUBS_CLR_D';               --2022-07-02
select max_report_date from prd2_tmd_v.bds_load_status where table_name='SUBS_CHRG_D';              --2021-12-25
select max_report_date from prd2_tmd_v.bds_load_status where table_name='SUBS_USG_D';               --2021-12-25

select max_report_date from prd2_tmd_v.dds_load_status where table_name='SUBSCRIPTION';             --2022-07-02
select max_report_date from prd2_tmd_v.dds_load_status where table_name='PHONE_NUMBER_2';           --2021-12-26
select max_report_date from prd2_tmd_v.dds_load_status where table_name='SMSPOLL_DETAIL';           --2021-12-26

select max_report_date from prd2_tmd_v.dds_load_status where table_name='USAGE_CDR';                --2021-12-25
select max_report_date from prd2_tmd_v.dds_load_status where table_name='USAGE_GPRS';               --2021-12-25
select max_report_date from prd2_tmd_v.dds_load_status where table_name='USAGE_BILLING';            --2021-12-25
select max_report_date from prd2_tmd_v.dds_load_status where table_name='LOAD_DIGITAL_SUITE';       --2021-12-24



--������ ����������� ������������ ��������� ��������
select max(report_date)
from PRD2_BDS_V2.SUBS_CLR_D
where 1=1
 and report_date between current_date-5 and current_date
 and subs_id=300017474518
 and branch_id=95
;



--==������� �������� ������ � ��������

--�������� ����������� ������

show view prd2_dds_v.subscription;
prd2_dds.subscription        where report_date >=  timestamp'2022-01-11'
prd2_dds_hist.subscription   where report_date <   timestamp'2022-01-11'


prd2_dds_hist.subscription          report_date  date'2020-07-04' - date '2022-01-01'
prd2_dds.subscription               report_date  date'2022-01-02' - date'2022-07-02'

select date '2022-07-13' - interval '183' day;                                                      --2022-01-11

--2022-01-11
select min(report_date) from prd2_dds.subscription
where 1=1
 and report_date >= date '2022-01-05'
 and report_date < date '2022-01-15'
;

--������������ ������
select max_report_date from prd2_tmd_v.dds_load_status where table_name='SUBSCRIPTION';             --2022-07-02


--"��������" ������, ������� �������� (546 ����)
select date '2022-01-02' - interval '546' day;                                                      --2020-07-05


--prd2_dds_hist.subscription                               --2020-07-04
lock row for access
select min(report_date) from prd2_dds_hist.subscription
where 1=1
 and report_date >= date '2020-07-01'
 and report_date < date '2020-07-05'
;


--prd2_dds_hist.subscription                               --2021-01-01
lock row for access
select max(report_date) from prd2_dds_hist.subscription
where 1=1
 and report_date >= date '2021-12-25'
 and report_date < date '2022-01-02'
;


/*
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

������� ���������� �� ���������� �� ������� ����:
help stats on prd2_dds.usage_billing;          ��������� ���������� �� �������
show statistics on prd2_dds.usage_billing;     ������ ����� ��������� �� �������

--=================================================================================================
--=================================================================================================
--=================================================================================================

--== �������� �������

--1 ������ ����������� ������ � SUBS_ID, �������� (������������: �������� �������� index: msisdn partition: no)
--show table PRD2_DDS.PHONE_NUMBER_2;

select * from PRD2_DDS_V.PHONE_NUMBER_2
where 1=1
 and msisdn = '79776991059';


--2 ������� �� �������� (������������: ������ �� ������ ���� index: cust_id partition: report_date, branch_id)
--show table PRD2_BDS.CUST_CLR_D;

select * from PRD2_BDS_V.CUST_CLR_D
where 1=1
 and branch_id = 95
 and report_date = date '2020-07-28'
 and cust_id = 300018768796;


--3 ������� �� ��������� (������������: ������ �� ������ ���� index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_CLR_D;

select * from PRD2_BDS_V.SUBS_CLR_D
 where 1=1
   and branch_id = 95
   and report_date = date '2020-07-28'
   and subs_id = 300017474518;


--4 �������� ������� �� ����� ��� (������������: ������ �� ������ ���� index: cust_id partition: report_date)
--show table PRD2_BDS.CUST_BAL_D;

select * from PRD2_BDS_V.CUST_BAL_D
where 1=1
 and branch_id = 95
 and report_date = date '2020-07-28'
 and cust_id = 300018768796;


--5 ������� �� ���������� ������� (������������: ������ �� ������ ���� index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_BEV_D;

select * from PRD2_BDS_V.SUBS_BEV_D
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;

select top 100 * from PRD2_DDS_V.BALANCE_EVENT
where 1=1
 and cust_id = 300018768796;

select top 100 * from PRD2_DDS_V.BALANCE_HISTORY
where 1=1
 and cust_bal_id in ('300038240449')
 and edttm >= timestamp '2020-07-01 00:00:00';


--6 ������� �� ����������� (������������: ������ �� ������ ���� index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_CHRG_D;

select * from PRD2_BDS_V.SUBS_CHRG_D
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;

--7 ��������� ����� �� �������� (������������: ������ �� ������ ���� index: subs_id partition: branch_id)
--show table PRD2_BDS.SUBS_SERV;

select * from PRD2_BDS_V.SUBS_SERV
where 1=1
 and branch_id = 95
 and subs_id = 300017474518;
;

--8 ��������� ����� �� �������� (������������: ������ �� ������ ����)
--show table PRD2_DDS.SERVICE_INSTANCE;

select * from PRD2_BDS_V.SUBS_SERV_D
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;

select top 100 * from PRD2_DDS_V.SERVICE_INSTANCE
 where 1=1
 and subs_id = 300017474518
 and valid_to_date >= timestamp '2020-07-01 00:00:00'
;


--9 ������� �� ������� � ����������� (������������: ������ �� ������ ���� index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_USG_D;

select * from PRD2_BDS_V.SUBS_USG_D
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and report_date < date '2020-08-01'
 and subs_id = 300017474518;


--10 ������� �� ���������� ������� (������������: ������ �� ������ ���� index: subs_id partition: report_date, branch_id)
--show table PRD2_BDS.SUBS_CONTENT_D_2;

select * from PRD2_BDS_V.SUBS_CONTENT_D_2
where 1=1
 and branch_id = 95
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;

--* c 04.06.2020 ���������� ��������� ������� ������ ���  ������� PRD2_BDS.SUBS_CONTENT_D_2


--11 ������� �� ����� ��������� ����� (������������: ������ �� ������ ����)

show view PRD2_BDS_V.SUBS_TP_CHANGE
select * from PRD2_BDS_V.SUBS_TP_CHANGE
where 1=1
 and report_date >= date '2020-07-01'
 and subs_id = 300017474518;



