
diagnostic helpstats on for session;

--==Источники формируемые нами для аналитики CEM

--==Mixx
select * from prd2_dic_v.service_status;

1   Активна
2   Отключена
3   Блокирована
4   Разблокирована


--delete uat_ca.mc_nps_subs_mixx;

replace macro mnp_seg (sdttm timestamp(0), edttm timestamp(0)) as (

--create multiset table uat_ca.mc_nps_subs_mixx as (
insert into uat_ca.mc_nps_subs_mixx
select
 a.report_month,
 a.branch_id,
 a.subs_id,
 a.msisdn,
 a.service_status_id,
 a.service_status_name,
 a.service_id,
 a.service_name,
 min(a.start_date) as start_date,
 max(a.end_date) as end_date,
 sum(a.diff_day) as diff_day,
 min(a.act_date) as act_date,
 max(a.last_change_date) as last_change_date,
 sum(a.charge) as charge
from (
select
 trunc(a.report_date, 'mm') as report_month,
 a.report_date,
 a.branch_id,
 a.subs_id,
 a.msisdn,
 a.service_status_id,
 t2.service_status_name,
 a.start_service_id as service_id,
 t1.service_name as service_name,
 min(a.report_date) as start_date,
 max(a.report_date) as end_date,
 end_date - start_date + 1 as diff_day,
 min(a.act_date) as act_date,
 max(a.last_change_status_date) as last_change_date,
 sum(a.charge_amount) as charge
from prd_rds_v.subs_mixx_d a
--
left join prd2_dic_v.service t1 on a.start_service_id = t1.service_id
left join prd2_dic_v.service_status t2 on a.service_status_id = t2.service_status_id
where 1=1
-- and a.subs_id = 100064981805
 and report_date >= date '2022-04-01'
 and report_date < date '2023-06-01'
group by 1,2,3,4,5,6,7,8,9
) a
group by 1,2,3,4,5,6,7,8
--) with no data
--PRIMARY INDEX ( subs_id )
--PARTITION BY RANGE_N(report_month  BETWEEN DATE '2022-04-01' AND DATE '2023-12-31' EACH INTERVAL '1' MONTH )
;

--delete uat_ca.mc_nps_subs_mixx;


select top 100 * from uat_ca.mc_nps_subs_mixx;
select * from uat_ca.mc_nps_subs_mixx where msisdn = '79521385500';

select
 report_month,
 count(distinct msisdn) as dis_msisdn,
 sum(case when service_status_id in (1,4) then 1 else 0 end) as active_msisdn
from uat_ca.mc_nps_subs_mixx
group by 1
order by 1
;


--== Объем/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('mc_nps_subs_mixx')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          MC_NPS_SUBS_MIXX        MIKHAIL.CHUPIS      2023-05-04 21:06:08     2023-05-04 21:07:11     0,514           6,47



show table uat_ca.mc_nps_subs_mixx;
--drop table uat_ca.mc_nps_subs_mixx;

create multiset table uat_ca.mc_nps_subs_mixx (
 report_month date format 'yy/mm/dd',
 branch_id decimal(3,0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set latin not casespecific,
 service_status_id byteint,
 service_status_name varchar(20) character set unicode casespecific,
 service_id decimal(8,0),
 service_name varchar(50) character set unicode casespecific,
 start_date date format 'yy/mm/dd',
 end_date date format 'yy/mm/dd',
 diff_day integer,
 act_date date format 'yy/mm/dd',
 last_change_date date format 'yy/mm/dd',
 charge decimal(18,6)
)
primary index (subs_id)
partition by range_n(report_month  between date '2022-04-01' and date '2023-12-31' each interval '1' month )
;


--==Услуги
select * from prd_rds_v.subs_mixx_service_d where subs_id = 71354120 and service_id = 31303;
select count(*) from uat_ca.mc_nps_subs_mixx_serv;


--create multiset table uat_ca.mc_nps_subs_mixx_serv as (
insert into uat_ca.mc_nps_subs_mixx_serv
select
 a.report_month,
 a.branch_id,
 a.subs_id,
 a.msisdn,
 a.service_status_id,
 a.service_status_name,
 a.service_id,
 a.service_name,
 a.parent_service_id,
 a.parent_service_name,
 min(a.start_date) as start_date,
 max(a.end_date) as end_date,
 sum(a.diff_day) as diff_day,
 min(a.act_date) as act_date,
 max(a.last_change_date) as last_change_date
from (
select
 trunc(a.report_date, 'mm') as report_month,
 a.report_date,
 a.branch_id,
 a.subs_id,
 a.msisdn,
 a.service_status_id,
 t3.service_status_name,
 a.service_id,
 t1.service_name,
 a.parent_service_id,
 t2.service_name as parent_service_name,
 min(a.report_date) as start_date,
 max(a.report_date) as end_date,
 end_date - start_date + 1 as diff_day,
 min(a.act_date) as act_date,
 max(a.last_change_status_date) as last_change_date
from prd_rds_v.subs_mixx_service_d a
--
left join prd2_dic_v.service t1 on a.service_id = t1.service_id
left join prd2_dic_v.service t2 on a.parent_service_id = t2.service_id
left join prd2_dic_v.service_status t3 on a.service_status_id = t3.service_status_id
--
where 1=1
-- and a.subs_id = 100064981805
 and a.report_date >= date '2022-04-01'
 and a.report_date < date '2023-05-01'
 and a.service_id = 31303
group by 1,2,3,4,5,6,7,8,9,10,11
) a
group by 1,2,3,4,5,6,7,8,9,10
--) with no data
--PRIMARY INDEX ( subs_id )
--PARTITION BY RANGE_N(report_month  BETWEEN DATE '2022-04-01' AND DATE '2023-12-31' EACH INTERVAL '1' MONTH )
;

--delete uat_ca.mc_nps_subs_mixx_serv;

select top 100 * from uat_ca.mc_nps_subs_mixx_serv;


--== Объем/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('mc_nps_subs_mixx_serv')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA,MC_NPS_SUBS_MIXX_SERV,MIKHAIL.CHUPIS,2023-05-04 21:21:06,2023-05-04 21:21:39,0,502,5,982


show table uat_ca.mc_nps_subs_mixx_serv;
--drop table uat_ca.mc_nps_subs_mixx_serv;

create multiset table uat_ca.mc_nps_subs_mixx_serv (
 report_month date format 'yy/mm/dd',
 branch_id decimal(3,0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set latin not casespecific,
 service_status_id byteint,
 service_status_name varchar(20) character set unicode casespecific,
 service_id decimal(8,0),
 service_name varchar(50) character set unicode casespecific,
 parent_service_id decimal(8,0),
 parent_service_name varchar(50) character set unicode casespecific,
 start_date date format 'yy/mm/dd',
 end_date date format 'yy/mm/dd',
 diff_day integer,
 act_date date format 'yy/mm/dd',
 last_change_date date format 'yy/mm/dd')
primary index (subs_id)
partition by range_n(report_month  between date '2022-04-01' and date '2023-12-31' each interval '1' month )
;


--==Услуги, которые необходимо проанализировать

--==Услуги Безлимита

19582      Безлимит на Discord
23302      Безлимит на Telegram
24769      Безлимит на TikTok
9904       Безлимит на Viber
9854       Безлимит на WhatsApp
31415      Безлимит на видео в соц. сетях
31406      Безлимит на Вконтакте
9901       Безлимит на Вконтакте+
31407      Безлимит на Одноклассники
10130      Безлимит на Одноклассники+
10123      Безлимит на ТамТам
35484      Безлимиты на соцсети_опция. Mixx

(19582, 23302, 24769, 9904, 9854, 31415, 31406, 9901, 31407, 10130, 10123, 35484)


--=================================================================================================
--=================================================================================================
--=================================================================================================

--==Ниже разбор продуктивных источников

*
Продцедура формирует источник для отчета \\corp.tele2.ru\SO_Reports\1.Share\63. MIXX\mixx_gi_v5.xlsb
заполняет за последний год
Методика сбора:
1) собираем подключения услгуи MIXX 31299,34552,34553,34554,34555,37326,37327,37328,37329 в статусе активна PRD2_DDS_V.SERVICE_INSTANCE
2) собираем гросс, исключаю тестовых абонов, JUR_TYPE not in ('Физ. лицо СТП', 'Физ. лицо ЦК ТиП') PRD2_DDS_V.SUBS_GROSS_SALES
3) к гроссам присоединяем миксы
4) собираем ненулевые платежи PRD2_BDS_V.SUBS_CHRG_D
5) к гроссам и миксам присоединяем платежи
6) собираем заметки и логины из витрины продукта PRD2_DDS_V.COMMUNICATION + PRD_RDS_V.SUBS_MIXX_D
7) добавляем в итогую таблицу SBX_SO.REPORT_MIXX_GI
*/

select * from prd2_dic_v.service where service_id in (31299, 34552, 34553, 34554, 34555, 37326, 37327, 37328, 37329);

37326      Mixx S
37328      Mixx L
37327      Mixx M
37329      Mixx Max
34552      Mixx S_03_2023
34554      Mixx L_03_2023
34553      Mixx M_03_2023
34555      Mixx Max_03_2023
31299      Mixx_old

select * from prd2_dic_v.service where lower(service_name) like '%mixx%';

37330,Mixx S'
34556,Mixx S'_03_2023

37332      Mixx L
34558      Mixx L_03_2023
37331      Mixx M
34557      Mixx M_03_2023
37333      Mixx Max'
34559      Mixx Max'_03_2023

35433      "Выгодно вместе"_опция. Mixx
34477      Lamoda. Mixx
39637      Mixx S_абонемент для НЕабонентов
36280      Mixx S кино
34473      VK Play Cloud. Mixx
35416      Xiaomi. Mixx
35484      Безлимиты на соцсети_опция. Mixx
37943      Бесплатный переход на обновлённый Mixx
35471      Двойная защита_разовая. Mixx
34478      Лента. Mixx
34474      Нетология. Mixx
35434      Повышенный курс обмена на смартфон. Mixx
35404      Скидка_Gamersbase Plus. Mixx
35481      Страховка_опция. Mixx
34475      Я.Практикум. Mixx

select max(act_month) from sbx_so.nv_set_report_mixx_gi;        --2023-04-22

select top 100 * from sbx_so.report_mixx_gi;
select max(report_date) from sbx_so.report_mixx_gi;                             --2023-04-29
select count(*) from sbx_so.report_mixx_gi;                                     --10 592 968
select count(*) from sbx_so.report_mixx_gi where service_id is not null;        --800 060



--==01 услуги миксов T-1

show table mixx_serv;
--drop table mixx_serv;

create multiset volatile table mixx_serv ,no log (
 report_date_mixx date format 'yy/mm/dd',
 subs_id decimal(12,0),
 service_id decimal(12,0),
 service_name varchar(50) character set unicode casespecific,
 activation_date_mixx timestamp(0),
 end_date_mixx timestamp(0),
 service_status_id byteint,
 service_status_name varchar(20) character set unicode casespecific,
 employee_id decimal(12,0),
 employee_name varchar(100) character set unicode not casespecific,
 creation_dttm timestamp(0))
primary index (subs_id, service_id)
on commit preserve rows;


--create multiset volatile table mixx_serv, no log as (
insert into mixx_serv
select
 si.valid_from_date as report_date_mixx,
 si.subs_id,
 si.service_id,
 si.service_name,
 si.valid_from_dttm as activation_date_mixx,
 si.valid_to_dttm as end_date_mixx,
 si.service_status_id,
 si.service_status_name,
 si.employee_id,
 si.employee_name,
 si.creation_dttm
from prd2_dds_v.service_instance si
--inner join prd2_dds_v.service as s
where 1=1
 and service_status_id in (1) 
 and trunc(si.valid_from_date,'mm') >= add_months(trunc(current_date, 'mm'),-12)
--trunc(sg.activation_dttm) >= add_months(trunc(current_date, 'mm'),-12)
 and si.service_id in (31299,34552,34553,34554,34555,37326,37327,37328,37329)
qualify row_number() over( partition by si.valid_from_date, si.subs_id order by si.valid_from_dttm asc) = 1
--)
--with no data
--primary index (subs_id, service_id)
--on commit preserve rows
;

select top 100 * from mixx_serv;
select trunc(report_date_mixx,'mm'), count(distinct subs_id), count(*) from mixx_serv group by 1 order by 1;
select * from mixx_serv qualify count(*) over (partition by subs_id) >3;
select * from mixx_serv where subs_id = 223663;



--==02 активации T-2

select top 100 * from prd2_dds_v.subs_gross_sales;

show table gi;
--drop table gi;

create multiset volatile table gi ,no log (
 activation_date timestamp(0),
 subs_id decimal(12,0),
 msisdn varchar(20) character set latin casespecific,
 branch_id decimal(3,0),
 sch_code varchar(100) character set unicode not casespecific,
 dlr_id decimal(12,0),
 pos_id decimal(15,0),
 pc_pay_id decimal(5,0),
 trpl_id decimal(15,0)
)
primary index (subs_id)
on commit preserve rows;


--create multiset volatile table gi, no log as (
insert into gi
select
 gs.activation_dttm as activation_date,
 gs.subs_id,
 hs.msisdn,
 gs.branch_id,
 gs.sch_code,
 gs.dlr_id,
 gs.pos_id,
 gs.pc_pay_id,
 gs.trpl_id
from prd2_dds_v.subs_gross_sales as gs
--
left join prd2_dds_v.subs_status_history hs on gs.subs_id = hs.subs_id
 and hs.activation_dttm between hs.start_dttm and hs.end_dttm
 and hs.stat_id=1
where 1=1
 and trunc(gs.activation_dttm) >= add_months(trunc(current_date, 'mm'),-12)
 and gs.bsegment='b2c'
 and hs.jur_type not in ('физ. лицо стп', 'физ. лицо цк тип')
--)
--with no data
--primary index (subs_id)
--on commit preserve rows
;

select top 100 * from gi;
select trunc(activation_date,'mm'), count(distinct subs_id), count(distinct msisdn), count(*) from gi group by 1 order by 1;



--==03 активации + миксы


show table mixx_gi;
--drop table mixx_gi;


create multiset volatile table mixx_gi ,no log (
 activation_date timestamp(0),
 macro_region varchar(50) character set unicode casespecific,
 branch_id decimal(3,0),
 branch_name varchar(50) character set unicode casespecific,
 sch_code varchar(100) character set unicode not casespecific,
 dlr_id decimal(12,0),
 dealer_name varchar(60) character set unicode casespecific,
 pos_id decimal(15,0),
 pc_pay_id decimal(5,0),
 trpl_id decimal(15,0),
 trpl_name varchar(255) character set unicode not casespecific,
 msisdn varchar(20) character set latin casespecific,
 subs_id decimal(12,0),
 report_date_mixx date format 'yy/mm/dd',
 service_id decimal(12,0),
 service_name varchar(50) character set unicode casespecific,
 activation_date_mixx timestamp(0),
 end_date_mixx timestamp(0),
 service_status_id byteint,
 service_status_name varchar(20) character set unicode casespecific,
 employee_id decimal(12,0),
 employee_name varchar(100) character set unicode not casespecific,
 creation_dttm timestamp(0))
primary index (subs_id ,service_id)
on commit preserve rows;


COLLECT STATISTICS
 COLUMN (BRANCH_ID),
 COLUMN (DLR_ID),
 COLUMN (SUBS_ID),
 COLUMN (TRPL_ID)
ON gi;

COLLECT STATISTICS
 COLUMN (REPORT_DATE_MIXX ,SUBS_ID)
ON mixx_serv;



--create multiset volatile table mixx_gi, no log as (
insert into mixx_gi
select 
 gs.activation_date,
 br.macro_cc_name as macro_region,
 gs.branch_id,
 br.branch_name,
 gs.sch_code,
 gs.dlr_id,
 dlr.dealer_name,
 gs.pos_id,
 gs.pc_pay_id,
 gs.trpl_id,
 pp.name_commercial as trpl_name,
 gs.msisdn,
 gs.subs_id,
--
 t1.report_date_mixx,
 t1.service_id,
 t1.service_name,
 t1.activation_date_mixx,
 t1.end_date_mixx,
 t1.service_status_id,
 t1.service_status_name,
 t1.employee_id,
 t1.employee_name,
 t1.creation_dttm
from gi gs
--
left join mixx_serv t1 on trunc(gs.activation_date) = t1.report_date_mixx
 and gs.subs_id = t1.subs_id
--справочники
left join prd2_dic_v.price_plan pp on gs.trpl_id = pp.tp_id
left join prd2_dds_v.dealer dlr on gs.dlr_id = dlr.dealer_id
left join prd2_dic_v.branch br on gs.branch_id = br.branch_id
--)
--with no data
--primary index (subs_id, service_id)
--on commit preserve rows
;

select top 100 * from mixx_gi;




--==04 платежи

show table pay_mixx;
--drop table pay_mixx;

create multiset volatile table pay_mixx ,no log (
 subs_id decimal(12,0),
 is_administrative_bal decimal(1,0),
 m2 date format 'yy/mm/dd',
 m3 date format 'yy/mm/dd',
 pay byteint
)
primary index (subs_id)
on commit preserve rows;


COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (REPORT_DATE_MIXX)
ON mixx_gi;


--create multiset volatile table pay_mixx, no log as (
insert into pay_mixx
select distinct
 scd.subs_id,
 is_administrative_bal,
 trunc (trunc (scd.report_date, 'mm')-1, 'mm') as m2,
 add_months(trunc(scd.report_date,'month'),-2) as m3,
 1 as pay
from prd2_bds_v.subs_chrg_d scd
where 1=1
 and scd.report_date >= add_months(trunc(current_date, 'mm'),-14)
 and scd.service_id in (31299,34552,34553,34554,34555,37326,37327,37328,37329)
        --and scd.bal_type_id = 1
 and scd.charge_amount > 0
 and subs_id in (select distinct subs_id from mixx_gi where report_date_mixx is not null)
--)
--with no data
--primary index ( subs_id)
--on commit preserve rows
;

select top 100 * from pay_mixx;



--==05 платежи по миксам + активации + услуги

show table mixx_gi_pay;
--drop table mixx_gi_pay;


create multiset volatile table mixx_gi_pay ,no log (
 activation_date timestamp(0),
 macro_region varchar(50) character set unicode casespecific,
 branch_id decimal(3,0),
 branch_name varchar(50) character set unicode casespecific,
 sch_code varchar(100) character set unicode not casespecific,
 dlr_id decimal(12,0),
 dealer_name varchar(60) character set unicode casespecific,
 pos_id decimal(15,0),
 pc_pay_id decimal(5,0),
 trpl_id decimal(15,0),
 trpl_name varchar(255) character set unicode not casespecific,
 msisdn varchar(20) character set latin casespecific,
 subs_id decimal(12,0),
 report_date_mixx date format 'yy/mm/dd',
 service_id decimal(12,0),
 service_name varchar(50) character set unicode casespecific,
 activation_date_mixx timestamp(0),
 end_date_mixx timestamp(0),
 service_status_id byteint,
 service_status_name varchar(20) character set unicode casespecific,
 employee_id decimal(12,0),
 employee_name varchar(100) character set unicode not casespecific,
 creation_dttm timestamp(0),
 pay_2 byteint,
 admin_bal_2m decimal(1,0),
 pay_3 byteint,
 admin_bal_3m decimal(1,0)
)
primary index (subs_id)
on commit preserve rows;


COLLECT STATISTICS
 COLUMN (SUBS_ID),
 COLUMN (SUBS_ID ,M3),
 COLUMN (SUBS_ID ,M2)
ON pay_mixx;



--create multiset volatile table mixx_gi_pay, no log as (
insert into mixx_gi_pay
select mg.*,
 pay_2m.pay as pay_2,
 pay_2m.is_administrative_bal as admin_bal_2m,
 pay_3m.pay as pay_3,
 pay_3m.is_administrative_bal admin_bal_3m
from mixx_gi mg
--
left join pay_mixx as pay_2m on trunc(mg.activation_date, 'mm') = pay_2m.m2
 and mg.subs_id = pay_2m.subs_id
--
left join pay_mixx as pay_3m on trunc(mg.activation_date, 'mm') = pay_3m.m3
 and mg.subs_id = pay_3m.subs_id
--)
--with no data
--primary index (subs_id)
--on commit preserve rows
;

select top 100 * from mixx_gi_pay;



--==06 финальная фитриа: ЛОГИНЫ по доподключениям

show table mixx_complete;
--drop table mixx_complete;


create multiset volatile table mixx_complete ,no log (
 activation_date timestamp(0),
 macro_region varchar(50) character set unicode casespecific,
 branch_id decimal(3,0),
 branch_name varchar(50) character set unicode casespecific,
 sch_code varchar(100) character set unicode not casespecific,
 dlr_id decimal(12,0),
 dealer_name varchar(60) character set unicode casespecific,
 pos_id decimal(15,0),
 pc_pay_id decimal(5,0),
 trpl_id decimal(15,0),
 trpl_name varchar(255) character set unicode not casespecific,
 msisdn varchar(20) character set latin casespecific,
 subs_id decimal(12,0),
 report_date_mixx date format 'yy/mm/dd',
 service_id decimal(12,0),
 service_name varchar(50) character set unicode casespecific,
 activation_date_mixx timestamp(0),
 end_date_mixx timestamp(0),
 service_status_id byteint,
 service_status_name varchar(20) character set unicode casespecific,
 employee_id decimal(12,0),
 employee_name varchar(100) character set unicode not casespecific,
 creation_dttm timestamp(0),
 pay_2 byteint,
 admin_bal_2m decimal(1,0),
 pay_3 byteint,
 admin_bal_3m decimal(1,0),
 employee_id_pr decimal(12,0),
 set_flag byteint,
 employee_login_pr varchar(100) character set unicode not casespecific,
 change_channel varchar(20) character set unicode not casespecific,
 create_com_wd timestamp(0),
 pos_id_wd decimal(12,0),
 employee_login_wd varchar(100) character set unicode not casespecific
)
primary index (subs_id)
on commit preserve rows;


COLLECT STATISTICS
 COLUMN (SUBS_ID ,REPORT_DATE_MIXX),
 COLUMN (REPORT_DATE_MIXX),
 COLUMN (SUBS_ID)
ON mixx_gi_pay;



--create multiset volatile table mixx_complete, no log as (
insert into mixx_complete
select
 mgp.*,
 mixx_d_pr.employee_id as employee_id_pr,                       --Идентификатор пользователя, подключившего услугу
 mixx_d_pr.set_flag,                                            --Признак комплекта при подключении
 case when emp2.employee_id is null then emp.login_code
      else emp2.employee_login
      end employee_login_pr,
 emp.change_channel,
 comm.create_dttm as create_com_wd,
 comm.pos_id pos_id_wd,
 comm.employee_login as employee_login_wd
from mixx_gi_pay mgp
--
left join (
select
 subs_id,
 create_dttm,
 close_dttm,
 communication_id
from prd2_dds_v.communication_case
where 1=1
 and communication_case.comm_rsn_id in (39237,32217)            --мультиподписка mixx (микс)
 and comm_cat_id in (0,4)                                       --администрирование и информирование
 and create_dttm >= add_months(trunc(current_date, 'mm'),-12)   --and create_dttm >= current_date -60 
qualify row_number() over (partition by subs_id, communication_id order by communication_case.comm_rsn_id desc) = 1
) comm_case on mgp.subs_id=comm_case.subs_id
 and mgp.activation_date_mixx between comm_case.create_dttm - interval '60' second and comm_case.close_dttm + interval '600' second
 and trunc(mgp.activation_date_mixx) = trunc(comm_case.create_dttm)
--
left join prd2_dds_v.communication comm on comm_case.subs_id=comm.subs_id
 and comm_case.communication_id= comm.communication_id
--
left join prd_rds_v.subs_mixx_d mixx_d_pr on mgp.subs_id = mixx_d_pr.subs_id
 and mgp.report_date_mixx=mixx_d_pr.report_date
 and  mixx_d_pr.report_date>= add_months(trunc(current_date, 'mm'),-12)
--
left join prd2_dds_v.employee_2 emp2 on mixx_d_pr.employee_id=emp2.employee_id
--
left join prd2_dds_v.employee emp on mixx_d_pr.employee_id=emp.employee_id
--)
--with no data
--primary index (subs_id)
--on commit preserve rows
;

select top 100 * from mixx_complete;










--Kristina.Kudritskaya

select top 100 * from sbx_so.report_mixx_gi;
select max(report_date) from sbx_so.report_mixx_gi;                                                                                                 --2023-04-29
select count(*) from sbx_so.report_mixx_gi;                                                                                                         --10 592 968
select count(*) from sbx_so.report_mixx_gi where service_id is not null;                                                                            --800 060
select trunc(report_date,'mm'), count(distinct subs_id), count(*) from sbx_so.report_mixx_gi group by 1 order by 1;
select trunc(report_date,'mm'), count(distinct subs_id), count(*) from sbx_so.report_mixx_gi where service_id is not null group by 1 order by 1;    --2022-05-01


--Подневая витрина по Mixx
select top 100 * from prd_rds_v.subs_mixx_d;

select trunc(report_date,'mm'), count(distinct subs_id), count(*) from prd_rds_v.subs_mixx_d group by 1 order by 1;
select operator_code, count(distinct subs_id), count(*) from prd_rds_v.subs_mixx_d group by 1 order by 1;

mTELE2          2 767 747       252 932 413
mMTS            907             39 869
mBEELINE        602             29 362
mMEGAFON        625             28 851
mTINKOFF        260             10 985
mJUTA           185             9 207
mRTK            117             4 319
mSBERTEL        70              2 630
mEKATERINBURG   26              801
mSMARTSK        9               479
mNMK            10              411
mVTBMOBAYL      5               144
mMGTS           6               143
mTVETEL         1               115
mSPITERBURG     8               91
mASTRAN         1               60

select start_service_id, count(distinct subs_id), count(*) from prd_rds_v.subs_mixx_d group by 1 order by 1;

34552      1 551 024        --Mixx S_03_2023
31299      1 148 540        --Mixx_old
37326      434 903          --Mixx S
34555      130 367          --Mixx Max_03_2023
34553      109 231          --Mixx M_03_2023
34554      44 113           --Mixx L_03_2023
37329      27 739           --Mixx Max
37327      25 388           --Mixx M
37328      13 839           --Mixx L


select * from mixx_serv where subs_id = 223663 order by 1;
select * from gi where subs_id = 223663;
select * from mixx_gi where subs_id = 223663;
select * from pay_mixx where subs_id = 223663;
select * from mixx_gi_pay where subs_id = 223663;

select * from sbx_so.report_mixx_gi where subs_id = 223663;
select * from prd_rds_v.subs_mixx_d where subs_id = 223663;
select * from prd_rds_v.subs_mixx_service_d where subs_id = 223663 order by 1;


select
 trunc(a.report_date, 'mm') as report_month,
 a.subs_id,
 a.msisdn,
-- a.act_date,
 a.start_service_id,
 t1.service_name,
 min(a.report_date) as start_date,
 max(a.report_date) as end_date,
 min(a.act_date) as act_date
from prd_rds_v.subs_mixx_d a
left join prd2_dic_v.service t1 on a.start_service_id = t1.service_id
where 1=1
 and a.subs_id = 223663
group by 1,2,3,4,5
;


select
 trunc(a.report_date, 'mm') as report_month,
 a.subs_id,
 a.msisdn,
-- a.act_date,
 a.service_id,
 t1.service_name,
 a.parent_service_id,
 t2.service_name as parent_service_name,
 min(a.report_date) as start_date,
 max(a.report_date) as end_date,
 min(a.act_date) as act_date
from prd_rds_v.subs_mixx_service_d a
left join prd2_dic_v.service t1 on a.service_id = t1.service_id
left join prd2_dic_v.service t2 on a.parent_service_id = t2.service_id
where 1=1
 and a.subs_id = 223663
group by 1,2,3,4,5,6,7
;

select
 trunc(a.report_date, 'mm') as report_month,
 a.subs_id,
 a.msisdn,
-- a.act_date,
-- a.service_id,
-- t1.service_name,
 a.parent_service_id,
 t2.service_name as parent_service_name,
 min(a.report_date) as start_date,
 max(a.report_date) as end_date,
 min(a.act_date) as act_date
from prd_rds_v.subs_mixx_service_d a
--left join prd2_dic_v.service t1 on a.service_id = t1.service_id
left join prd2_dic_v.service t2 on a.parent_service_id = t2.service_id
where 1=1
 and a.subs_id = 223663
group by 1,2,3,4,5
;


SUBS_ID MSISDN      PARENT_SERVICE_ID parent_service_name       start_date      end_date        act_date   
 ------- ----------- ----------------- -------------------      ----------      ----------      ---------- 
 223 663 79043318863            31 299 Mixx_old                 2022-09-03      2022-10-23      2000-01-01
 223 663 79043318863            34 552 Mixx S_03_2023           2022-10-24      2023-03-02      2000-01-01
 223 663 79043318863            37 326 Mixx S                   2023-04-03      2023-04-29      2023-04-03


