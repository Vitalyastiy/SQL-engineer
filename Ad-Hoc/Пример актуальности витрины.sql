
diagnostic helpstats on for session;
EXEC sysdba.ABORTSESSIONS (НОМЕР_СЕССИИ);

--=================================================================================================

--выручка от непакетного трафика с учётом НДС и объём трафика в разрезе абонента, сетевого элемента и даты (https://t2ru-alation-prod-app/table/319009)
PRD2_DDS_V.NE_SUBS_REVENUE_DATE

--структура View
show view PRD2_DDS_V.NE_SUBS_REVENUE_DATE;

from PRD2_DDS.NE_SUBS_REVENUE_DATE
 WHERE REPORT_DATE >= DATE'2021-06-11'

from PRD2_DDS_HIST.NE_SUBS_REVENUE_DATE
 WHERE REPORT_DATE < DATE'2021-06-11';


--==view v2

--выручка от непакетного трафика с учётом НДС и объём трафика в разрезе абонента, сетевого элемента и даты
PRD2_DDS_V2.NE_SUBS_REVENUE_DATE

--выручка от непакетного трафика с учётом НДС и объём трафика в разрезе абонента, сетевого элемента и даты (исторические данные)
PRD2_DDS_HIST_V2.NE_SUBS_REVENUE_DATE


--=================================================================================================

--dll витрин
show table PRD2_DDS.NE_SUBS_REVENUE_DATE;

PRIMARY INDEX ( SUBS_ID )
PARTITION BY RANGE_N(REPORT_DATE  BETWEEN DATE '2021-06-11' AND DATE '2022-12-31' EACH INTERVAL '1' DAY )

show table PRD2_DDS_HIST.NE_SUBS_REVENUE_DATE;

PRIMARY AMP INDEX ( SUBS_ID )
PARTITION BY ( COLUMN ADD 10,RANGE_N(REPORT_DATE  BETWEEN DATE '2015-08-01' AND DATE '2121-12-31' EACH INTERVAL '1' DAY ) )


--данные о витрине

select top 100 * from prd2_tmd_v.tables_info
where 1=1
 and tablename in ('NE_SUBS_REVENUE_DATE')
;

витрина                             PRD2_DDS.NE_SUBS_REVENUE_DATE
владелец                            TAKHMAZYAN_VS
подразделение                       EDW
wiki                                
глубина хранения                    420. DAY                            --по факту 390
размер                              3528                                --по факту на 2022-07-07: 3 527,542 (для prd2_dds_hist.ne_subs_revenue_date - 505,789)
отставание данных                   2
кол-во пересчитываемых периодов     3


select * from show_table_size where lower(databasename) in ('prd2_dds','prd2_dds_hist') and lower(tablename) in ('ne_subs_revenue_date');

DataBaseName        "TableName"                 CreatorName             CreateTimeStamp             LastAccessTimeStamp         TableSize       SkewFactor
 ------------       ----------------------      ----------------        -------------------         -------------------         ---------       ----------
PRD2_DDS            NE_SUBS_REVENUE_DATE        IVANOV_VS               2019-04-09 13:34:08         2022-07-07 16:01:47         3527,542        1,635
PRD2_DDS_HIST       NE_SUBS_REVENUE_DATE        VADIM.S.IVANOV          2021-07-05 21:59:29         2022-07-07 16:07:10         505,789         2,106


--=================================================================================================

--==01 актуальные данные в витрине с "горячими" данными prd2_dds.ne_subs_revenue_date

select max_report_date from prd2_tmd_v.dds_load_status where table_name='DDS_NE_SUBS_REVENUE_DATE';     --2022-07-27


--==02 минимальная дата в витрине с "горячими" данными prd2_dds.ne_subs_revenue_date

select date '2022-07-29' - interval '389' day;                                                          --2021-07-05

--2021-06-04
select min(report_date) from prd2_dds_v.ne_subs_revenue_date
where 1=1
 and report_date >= date '2021-05-31'
 and report_date < date '2021-06-10'
;

даты для использования в расчетах на 2022-07-26 для горячих данных prd2_dds_v.ne_subs_revenue_date (глубина хранения 420 дней):
bop     date '2021-06-04'
eop     date '2022-07-27'

select date '2022-07-25' - date '2021-06-01' + 1;       --420


--==03 максимальная дата в витрине с "холодными данными" prd2_dds_hist.ne_subs_revenue_date

--2021-09-13
lock row for access
select max(report_date) from prd2_dds_hist_v.ne_subs_revenue_date
where 1=1
 and report_date >= date '2021-09-10'
 and report_date < date '2021-09-20'
;


--==04 минимальная дата в витрине с "холодными данными" prd2_dds_hist.ne_subs_revenue_date

select date '2021-09-13' - interval '104' day;                                                          --2021-06-01

--2021-06-04
select min(report_date) from prd2_dds_hist_v.ne_subs_revenue_date
where 1=1
 and report_date >= date '2021-05-01'
 and report_date < date '2021-06-10'
;

даты для использования в расчетах на 2022-07-26 для холодных данных prd2_dds_hist_v.ne_subs_revenue_date (глубина хранения 104 дня):
bop     date '2021-06-04'
eop     date '2021-09-13'

select date '2021-09-13' - date '2021-05-13' + 1;       --124


--==================================================================================================

--==Итого на 2022-07-07:

--View

--выручка от непакетного трафика с учётом НДС и объём трафика в разрезе абонента, сетевого элемента и даты
PRD2_DDS_V2.NE_SUBS_REVENUE_DATE

--выручка от непакетного трафика с учётом НДС и объём трафика в разрезе абонента, сетевого элемента и даты (исторические данные)
PRD2_DDS_HIST_V2.NE_SUBS_REVENUE_DATE


даты для использования в расчетах на 2022-07-07 для горячих данных prd2_dds.ne_subs_revenue_date (глубина хранения 390 дней):
bop     date '2021-06-11'
eop     date '2022-07-05'

даты для использования в расчетах на 2022-07-07 для холодных данных prd2_dds_hisr.ne_subs_revenue_date (глубина хранения 124 дня):
bop     date '2021-05-13'
eop     date '2021-09-13'



