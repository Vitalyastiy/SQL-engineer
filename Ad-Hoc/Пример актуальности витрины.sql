
diagnostic helpstats on for session;
EXEC sysdba.ABORTSESSIONS (�����_������);

--=================================================================================================

--������� �� ����������� ������� � ������ ��� � ����� ������� � ������� ��������, �������� �������� � ���� (https://t2ru-alation-prod-app/table/319009)
PRD2_DDS_V.NE_SUBS_REVENUE_DATE

--��������� View
show view PRD2_DDS_V.NE_SUBS_REVENUE_DATE;

from PRD2_DDS.NE_SUBS_REVENUE_DATE
 WHERE REPORT_DATE >= DATE'2021-06-11'

from PRD2_DDS_HIST.NE_SUBS_REVENUE_DATE
 WHERE REPORT_DATE < DATE'2021-06-11';


--==view v2

--������� �� ����������� ������� � ������ ��� � ����� ������� � ������� ��������, �������� �������� � ����
PRD2_DDS_V2.NE_SUBS_REVENUE_DATE

--������� �� ����������� ������� � ������ ��� � ����� ������� � ������� ��������, �������� �������� � ���� (������������ ������)
PRD2_DDS_HIST_V2.NE_SUBS_REVENUE_DATE


--=================================================================================================

--dll ������
show table PRD2_DDS.NE_SUBS_REVENUE_DATE;

PRIMARY INDEX ( SUBS_ID )
PARTITION BY RANGE_N(REPORT_DATE  BETWEEN DATE '2021-06-11' AND DATE '2022-12-31' EACH INTERVAL '1' DAY )

show table PRD2_DDS_HIST.NE_SUBS_REVENUE_DATE;

PRIMARY AMP INDEX ( SUBS_ID )
PARTITION BY ( COLUMN ADD 10,RANGE_N(REPORT_DATE  BETWEEN DATE '2015-08-01' AND DATE '2121-12-31' EACH INTERVAL '1' DAY ) )


--������ � �������

select top 100 * from prd2_tmd_v.tables_info
where 1=1
 and tablename in ('NE_SUBS_REVENUE_DATE')
;

�������                             PRD2_DDS.NE_SUBS_REVENUE_DATE
��������                            TAKHMAZYAN_VS
�������������                       EDW
wiki                                
������� ��������                    420. DAY                            --�� ����� 390
������                              3528                                --�� ����� �� 2022-07-07: 3 527,542 (��� prd2_dds_hist.ne_subs_revenue_date - 505,789)
���������� ������                   2
���-�� ��������������� ��������     3


select * from show_table_size where lower(databasename) in ('prd2_dds','prd2_dds_hist') and lower(tablename) in ('ne_subs_revenue_date');

DataBaseName        "TableName"                 CreatorName             CreateTimeStamp             LastAccessTimeStamp         TableSize       SkewFactor
 ------------       ----------------------      ----------------        -------------------         -------------------         ---------       ----------
PRD2_DDS            NE_SUBS_REVENUE_DATE        IVANOV_VS               2019-04-09 13:34:08         2022-07-07 16:01:47         3527,542        1,635
PRD2_DDS_HIST       NE_SUBS_REVENUE_DATE        VADIM.S.IVANOV          2021-07-05 21:59:29         2022-07-07 16:07:10         505,789         2,106


--=================================================================================================

--==01 ���������� ������ � ������� � "��������" ������� prd2_dds.ne_subs_revenue_date

select max_report_date from prd2_tmd_v.dds_load_status where table_name='DDS_NE_SUBS_REVENUE_DATE';     --2022-07-27


--==02 ����������� ���� � ������� � "��������" ������� prd2_dds.ne_subs_revenue_date

select date '2022-07-29' - interval '389' day;                                                          --2021-07-05

--2021-06-04
select min(report_date) from prd2_dds_v.ne_subs_revenue_date
where 1=1
 and report_date >= date '2021-05-31'
 and report_date < date '2021-06-10'
;

���� ��� ������������� � �������� �� 2022-07-26 ��� ������� ������ prd2_dds_v.ne_subs_revenue_date (������� �������� 420 ����):
bop     date '2021-06-04'
eop     date '2022-07-27'

select date '2022-07-25' - date '2021-06-01' + 1;       --420


--==03 ������������ ���� � ������� � "��������� �������" prd2_dds_hist.ne_subs_revenue_date

--2021-09-13
lock row for access
select max(report_date) from prd2_dds_hist_v.ne_subs_revenue_date
where 1=1
 and report_date >= date '2021-09-10'
 and report_date < date '2021-09-20'
;


--==04 ����������� ���� � ������� � "��������� �������" prd2_dds_hist.ne_subs_revenue_date

select date '2021-09-13' - interval '104' day;                                                          --2021-06-01

--2021-06-04
select min(report_date) from prd2_dds_hist_v.ne_subs_revenue_date
where 1=1
 and report_date >= date '2021-05-01'
 and report_date < date '2021-06-10'
;

���� ��� ������������� � �������� �� 2022-07-26 ��� �������� ������ prd2_dds_hist_v.ne_subs_revenue_date (������� �������� 104 ���):
bop     date '2021-06-04'
eop     date '2021-09-13'

select date '2021-09-13' - date '2021-05-13' + 1;       --124


--==================================================================================================

--==����� �� 2022-07-07:

--View

--������� �� ����������� ������� � ������ ��� � ����� ������� � ������� ��������, �������� �������� � ����
PRD2_DDS_V2.NE_SUBS_REVENUE_DATE

--������� �� ����������� ������� � ������ ��� � ����� ������� � ������� ��������, �������� �������� � ���� (������������ ������)
PRD2_DDS_HIST_V2.NE_SUBS_REVENUE_DATE


���� ��� ������������� � �������� �� 2022-07-07 ��� ������� ������ prd2_dds.ne_subs_revenue_date (������� �������� 390 ����):
bop     date '2021-06-11'
eop     date '2022-07-05'

���� ��� ������������� � �������� �� 2022-07-07 ��� �������� ������ prd2_dds_hisr.ne_subs_revenue_date (������� �������� 124 ���):
bop     date '2021-05-13'
eop     date '2021-09-13'



