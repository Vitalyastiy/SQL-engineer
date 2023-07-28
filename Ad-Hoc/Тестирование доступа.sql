
diagnostic helpstats on for session;


-- 1_Стажер клиентской анатилики CEM (GBR1_CEM-Intern_Analysis)

Необходимо выполнить запрос в каждой из указанных схем.
При возникновении сообщения о отсутвии прав доступа - перечислить данные схемы и направить в письме следующим адресатам: Чупис М.В., Левашов А.А.
с указанием тестируемой роли.


--==Общие схемы для всех ролей

--PRD2_DIC_V - Общие справочники EDW (Dictionary). Содержит представления над таблицами PRD2_DIC, в историцируемых таблицах отображаются только актуальные записи.
select * from prd2_dic_v.branch where id = 32;

--PRD2_DIC_V2 - Общие справочники EDW (Dictionary). Содержит представления над таблицами PRD2_DIC, в историцируемых таблицах отображаются только актуальные записи.
select * from prd2_dic_v2.region where region_id = 40;

--PRD2_BDS_V - Слой бизнес-данных EDW (Business Data Store). Содержит представления над таблицами PRD2_BDS с расшифровками на основе справочников PRD2_DIC.
select * from prd2_bds_v.subs_clr_d where subs_id = 300017474518 and report_date = date '2023-07-01' and branch_id = 95;

--PRD2_BDS_V2 - Слой бизнес-данных EDW (Business Data Store). Содержит представления над таблицами PRD2_BDS без расшифровок идентификаторов.
select * from prd2_bds_v2.subs_clr_d where subs_id = 300017474518 and report_date = date '2023-07-01' and branch_id = 95;

--PRD2_TMD_V - Метаданные EDW: таблицы контрольного механизма, логирование, описание витрин. Содержит представления над таблицами PRD2_TMD.
select * from prd2_tmd_v.bds_load_status where table_name='SUBS_CLR_D';
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablename = 'dic_macro_cluster';

--PRD2_DDS_V - Слой детальных данных EDW (Detail Data Store). Содержит представления над таблицами PRD2_DDS с расшифровками на основе справочников PRD2_DIC.
select * from prd2_dds_v.subscription where subs_id = 300017474518 and report_date = date '2023-07-01';

--PRD2_DDS_V2 - Слой детальных данных EDW (Detail Data Store). Содержит представления над таблицами PRD2_DDS без расшифровок идентификаторов.
select * from prd2_dds_v2.subscription where subs_id = 300017474518 and report_date = date '2023-07-01';

--PRD2_DDS_HIST_V
select * from prd2_dds_hist_v.charge where subs_id = 300017474518 and charge_id = 307169551210 and charge_dttm = timestamp '2021-12-24 02:24:27';

--UAT_CA - "песочница" подразделения Клиентской аналитики
select * from uat_ca.poll_id_193 where subs_id = 100071930388;

--UAT_CA_V - Содержит представления над таблицами UAT_CA
select * from uat_ca.v3_nps_main_td where subs_id = 100071930388;



--==Дополнительные схемы для роли 1_Менеджер по клиентской аналитике CEM (GBR1_CEM-CEM-Analysis)

--PRD2_ODW_V - Слой "сырых" данных: накопление, объединение и преобразование данных перед загрузкой в DDS (Operational Data Warehouse). Содержит представления над таблицами PRD2_ODW
select * from prd2_odw_v.message_sended where msg_type_id = 201 and start_date = timestamp '2023-06-29 23:35:36';
select * from prd2_odw_v.site_margin where mastersite = 'MO000290' and report_date = date '2023-05-01';
select * from prd2_odw_v.smspoll_sms_sending_status where send_id = 761939444 and created_date = timestamp '2023-07-03 11:09:16';

--PRD_RDS_V - Слой подготовленных отчетов EDW (Reports Data Store)
select * from prd_rds_v.product_agg_subs_m where subs_id = 300017474518 and report_month = date '2023-05-01';
select * from prd_rds_v.db_sales_tic_tac_quality_d where subs_id = 73276963 and gross_date = date '2023-06-01';

--PRD_RDS_V2 - Слой подготовленных отчетов EDW (Reports Data Store)
select * from prd_rds_v2.product_agg_subs_m where subs_id = 300017474518 and report_month = date '2023-05-01';

--PRD2_DDS_V - Слой детальных данных EDW (Detail Data Store). Содержит представления над таблицами PRD2_DDS с расшифровками на основе справочников PRD2_DIC.
select * from prd2_dds_v.khachapuri_detail_history where promo_code_value = 1652628 and cre_dttm = timestamp '2022-12-01 10:40:07.351254';

--PRD2_DDS_V2 - Слой детальных данных EDW (Detail Data Store). Содержит представления над таблицами PRD2_DDS без расшифровок идентификаторов.
select * from prd2_dds_v2.khachapuri_detail_history where promo_code_value = 1652628 and cre_dttm = timestamp '2022-12-01 10:40:07.351254';

--PRD_TELESTAR_V - Слой подготовки источников по проектам IFRS15 и BDMA
select * from prd_telestar_v.cost_revenue_subscriber where subs_id = 300017474518 and report_date = date '2023-05-01';

--PRD2_MDS_V -Департамент владельца: Направление развития технологий
select * from prd2_mds_v.dmsc where subs_id = 300017474518 and report_date = date '2022-12-01';

--SBX_SS - Департамент владельца: Направление по развитию отчетности продаж и сервиса
select * from sbx_ss.nps_sample where subs_id = 100053898160;

--SBX_SS_V 
select top 100 * from sbx_ss.v_soa_report where poll_id = 345;

--SBX_SO - Департамент владельца: Направление по развитию отчетности продаж и сервиса
select * from sbx_so.alladin where subs_id = 100062278523 and orderid_req = 215787;

--SBX_MARGIN - Департамент владельца: Служба по управлению маржинальностью бизнес операций и контролю операционных проектов
select * from sbx_margin.cost_revenue_subscriber where subs_id = 9661078 and report_date = date '2019-07-01';

--SBX_MARGIN_V
select * from sbx_margin.cost_revenue_subscriber_all where subs_id = 300017474518;

--SBX_CallCentre - Департамент владельца: Служба реактивного удержания и работы с клиентским опытом
select top 100 * from sbx_callcentre.mnp_out_xmt where request_id = 200027840563 and request_dte = date '2022-08-13';

--SBX_CallCentre_V
select * from sbx_callcentre.v_xmt_mnp_data_new where request_id = 200027840563 and request_dte = date '2022-08-13';

--TELE2_UAT
select * from tele2_uat.nps_sample where subs_id = 100053898160;



--==================================================================================================
--==Дополнительные схемы для роли 1_Менеджер по клиентскому опыту на сети CEM (GBR1_CEM-KO_Analysis)

--PRD2_ODW_V - Слой "сырых" данных: накопление, объединение и преобразование данных перед загрузкой в DDS (Operational Data Warehouse). Содержит представления над таблицами PRD2_ODW
select * from prd2_odw_v.message_sended where msg_type_id = 201 and start_date = timestamp '2023-06-29 23:35:36';
select * from prd2_odw_v.site_margin where mastersite = 'MO000290' and report_date = date '2023-05-01';
select * from prd2_odw_v.smspoll_sms_sending_status where send_id = 761939444 and created_date = timestamp '2023-07-03 11:09:16';

--PRD_RDS_V - Слой подготовленных отчетов EDW (Reports Data Store)
select * from prd_rds_v.product_agg_subs_m where subs_id = 300017474518 and report_month = date '2023-05-01';

--PRD_RDS_V2 - Слой подготовленных отчетов EDW (Reports Data Store)
select * from prd_rds_v2.product_agg_subs_m where subs_id = 300017474518 and report_month = date '2023-05-01';

--TELE2_UAT
select * from tele2_uat.nps_sample where subs_id = 100053898160;


--==SEC_HEW
select * from prd2_sec_v.hwe where subs_id = 300017474518 and report_date = date '2023-05-01';


show table prd2_sec.hwe;
PRIMARY INDEX ( SUBS_ID )
PARTITION BY RANGE_N(REPORT_DATE  BETWEEN DATE '2016-01-01' AND '2030-12-31' EACH INTERVAL '1' MONTH ,
 NO RANGE, UNKNOWN);


--=================================================================================================
--=================================================================================================
--=================================================================================================

--
select top 100 * from prd2_tmd_v.tables_info where databasename = 'sbx_ss' and tablekind = 'View';

--==TMD_V
show view PRD2_TMD_V.CM_WORKFLOWS;
show table prd2_tmd.cm_workflows;
show table prd2_tmd.cm_workflow_load_log;

show view PRD2_TMD_V.TABLES_INFO;

