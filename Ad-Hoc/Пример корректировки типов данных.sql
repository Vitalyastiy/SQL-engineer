

diagnostic helpstats on for session;

UAT_CA  vi_close_inhouse2   TP_ID   DECIMAL(8,0)    DECIMAL(12,0)
UAT_CA  vi_close_inhouse3   TP_ID   DECIMAL(8,0)    DECIMAL(12,0)


--==01 Шаг 1
show table uat_ca.vi_close_inhouse2;

CREATE MULTISET TABLE uat_ca.vi_close_inhouse2 (
      create_date DATE FORMAT 'YY/MM/DD',
      cluster_name VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
      macroregion VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
      region VARCHAR(50) CHARACTER SET UNICODE CASESPECIFIC,
      call_date DATE FORMAT 'YY/MM/DD',
      call_flg BYTEINT,
      point_name VARCHAR(25) CHARACTER SET UNICODE NOT CASESPECIFIC,
      cust_id DECIMAL(12,0),
      subs_id DECIMAL(12,0),
      msisdn VARCHAR(20) CHARACTER SET UNICODE NOT CASESPECIFIC,
      lt_day INTEGER,
      lt_gr VARCHAR(5) CHARACTER SET UNICODE NOT CASESPECIFIC,
      age INTEGER,
      gender DECIMAL(6,0),
      mark_6 VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      class_mark_6 VARCHAR(200) CHARACTER SET UNICODE NOT CASESPECIFIC,
      micro_class_mark_6 VARCHAR(200) CHARACTER SET UNICODE NOT CASESPECIFIC,
      cluster_mark_6_pr_2 VARCHAR(200) CHARACTER SET UNICODE NOT CASESPECIFIC,
      servelat VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      servelat_gr VARCHAR(26) CHARACTER SET UNICODE NOT CASESPECIFIC,
      nps BYTEINT,
      nps_key BYTEINT,
      tp_id DECIMAL(8,0),                                                              --исправить
      tp_name VARCHAR(255) CHARACTER SET UNICODE CASESPECIFIC,
      tac VARCHAR(8) CHARACTER SET UNICODE CASESPECIFIC,
      arpu_segment VARCHAR(200) CHARACTER SET UNICODE CASESPECIFIC,
      segment_value DECIMAL(18,6),
      data_mb FLOAT,
      GSB_Bronze BYTEINT,
      Eralash BYTEINT,
      offer_flg BYTEINT,
      offer_type VARCHAR(20) CHARACTER SET UNICODE NOT CASESPECIFIC,
      rtk_voice_flg BYTEINT,
      rtk_voice_reason VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      rtk_mi_flg BYTEINT,
      rtk_mi_reason VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      rtk_ds_flg BYTEINT,
      rtk_ds_reason VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      rtk_monobrand_flg BYTEINT,
      rtk_monobrand_reason VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      rtk_roaming_flg BYTEINT,
      rtk_roaming_reason VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      rtk_dishonesty_flg BYTEINT,
      rtk_dishonesty_reason VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      rtk_lk_flg BYTEINT,
      rtk_lk_reason VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      rtk_annoying_flg BYTEINT,
      rtk_annoying_reason VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      rtk_tarif_flg BYTEINT,
      rtk_tarif_reason VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      error_detract VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      mark_1 VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      mark_2 VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      mark_3 VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      mark_4 VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      ans_1 VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      ans_2 VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      ans_3 VARCHAR(1024) CHARACTER SET UNICODE NOT CASESPECIFIC,
      flg_459 BYTEINT,
      rtk_flg BYTEINT)
PRIMARY INDEX ( subs_id );


--==02 Переименовываем текущую витрину

rename table 
uat_ca.vi_close_inhouse2
as
uat_ca.vi_close_inhouse2_tmp
;


select top 100 * from uat_ca.vi_close_inhouse2_tmp;



--==03 Создаем витрину с корректным типом

смотрим текущую show table uat_ca.vi_close_inhouse2;
корретируем необходимые поля
создаем новую витрину


--==04 Вставка данных

insert into uat_ca.vi_close_inhouse2
select * from uat_ca.vi_close_inhouse2_tmp
;


--==05 Контроль

select count(*) from uat_ca.vi_close_inhouse2;      --16 363

select count(*) from uat_ca.vi_close_inhouse2_tmp;  --16 363


--==06 Удаление временной TMP

--drop table uat_ca.vi_close_inhouse2_tmp;


--==07 Проверка размера/skewfactor

select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('vi_close_inhouse2')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          VI_CLOSE_INHOUSE2       MIKHAIL.CHUPIS      2022-08-30 16:03:49     2022-08-30 16:06:22     0,015           6,675




