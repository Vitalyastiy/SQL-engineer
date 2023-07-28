
diagnostic helpstats on for session;

COLLECT STATISTICS
 COLUMN (CREATE_DATE ,MSISDN)
ON uat_ca.mc_nps_bu;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (POINT_NAME),
 COLUMN (CREATE_DATE)
ON uat_ca.vi_mi_call_ds_rtk1;

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE)
ON uat_ca.poll_id_459;



In:
 uat_ca.v_nps_bu                                    --опрос NPS
 uat_ca.v_call_ds (uat_ca.vi_mi_call_ds_rtk1)       --результат обзвона детракторов
 uat_ca.poll_id_459                                 --опрос удовлетворенности
 
 \\corp.tele2.ru\ZRfolders\CrossFunctionalReports   --продуктивная замена uat_ca.v_call_ds (uat_ca.vi_mi_call_ds_rtk1) и uat_ca.poll_id_459

Out:
 uat_ca.close_inhouse_with_DS_2                     --финальная витрина

--=================================================================================================

--==Этап 1 - Опрос NPS по точкам контакта Моибильный интернет и Дистанционный сервис, данные рассчитываются ежедневно

select top 100 * from uat_ca.v_nps_bu;

--Данные на момент последней загрузки
select create_date, count(distinct msisdn), count(*) from uat_ca.v_nps_bu t1
where 1=1
 and point_name in ('Мобильный интернет','Контакт-центр')
 and nps in (1,2,3,4,5,6)
 and create_date >= date '2022-04-27'
 and create_date < date '2022-08-16'
group by 1
order by 1
;

--всего 63 979
--наверно в отчетности необходимо показывать долю дозвона от детракторов


select trunc(create_date,'mm'), count(distinct msisdn), count(*) from uat_ca.v_nps_bu t1
where 1=1
 and point_name in ('Мобильный интернет','Контакт-центр')
 and nps in (1,2,3,4,5,6)
 and create_date >= date '2022-04-27'
 and create_date < date '2022-08-16'
group by 1
order by 1
;
                                        --Данные файла InHouse_NPS.xlsx
2022-04-01      2 224       2 224
2022-05-01      18 479      18 479
2022-06-01      18 116      18 116
2022-07-01      16 003      16 005      --5 338 (данные с 13.07.2022)
2022-08-01      9 155       9 155       --9 974


--=================================================================================================

--==Этап 2 - Результат обзвона детракторов, витрина для загрузки данных обзвона uat_ca.vi_mi_call_ds_rtk1 из сборного файла за разные периоды "фильтрация столбцов (25.08.2022).xlsx"

select top 100 * from uat_ca.vi_mi_call_ds_rtk1;

--25 167, без нулевых дат 25 114 и без нулевых msisdn 25 112, уникальные абоненты 24 456

select create_date, count(distinct msisdn), count(*) from uat_ca.vi_mi_call_ds_rtk1
where 1=1
 and msisdn is not null
 and create_date is not null
group by 1 order by 1;


--Соответствие полей в файле "фильтрация столбцов (25.08.2022).xlsx" и витрине uat_ca.vi_mi_call_ds_rtk1
msisdn                      
create_date                 
NPS                         point_name
offer_fig                   offer_flg
offer_type                  
RTK_voice_index             rtk_voice_flg
RTK_voice_reason            
RTK_MI_index                rtk_mi_flg
RTK_MI_reason               
RTK_DS_index                rtk_ds_flg
RTK_DS_reason               
RTK_monobrand_index         rtk_monobrand_flg
RTK_monobrand_reason        
RTK_roaming_index           rtk_roaming_flg
RTK_roaming_reason          
RTK_dishonesty_index        rtk_dishonesty_flg
RTK_dishonesty_reason       
RTK_LK_index                rtk_lk_flg
RTK_LK_reason               
RTK_annoying_index          rtk_annoying_flg
RTK_annoying_reason         
RTK_tarif_index             rtk_tarif_flg
RTK_tarif_reason            
Ошибочный детракт           error_detract
call_status                 
call_date                   


--==Необходимо формирование промежуточных временных витрин т.к. данные результатов опроса содержат дубликаты записей

--Используем представление uat_ca.v_call_ds


--Кейсы по качеству данных

case when call_status is not null then 1 else 0 end as call_flg

1. Две или более попыток дозвона до абонента с одним признаком дозвона                               -- оставляем запись с фагом call_flg = 1
2. Две или более попыток дозвона до абонента с признаками дозвона более чем в одном случае           -- формируем данные, задаем вопрос коллегам (брать по последней дате дозвона)
3. Две или более попыток дозвона до абонента с отсутствием признака дозвона                          -- берем по последней дате дозвона


--==Шаг 1 Выбор корректных абонентов из дублей

--drop table tg;

--==при рассчете меняем диапазон дат
create multiset volatile table tg, no log as (
select * from (
select
 msisdn,
 min(create_date) as min_create_date,
 max(call_date) as last_call,
 count(*) call_cnt,
 sum(call_flg) as try_cnt
from (
select * from uat_ca.v_call_ds
where 1=1
 and create_date < date '2022-08-16'
qualify count(*) over (partition by msisdn) > 1
) a
group by 1
) a
where 1=1
 and try_cnt = 1
) with data
primary index (msisdn)
on commit preserve rows
;

select top 100 * from tg;
select count(*) from tg;        156

--пример
select * from uat_ca.vi_mi_call_ds_rtk1 where msisdn = '79001015716';



--drop table tg_2;

create multiset volatile table tg_2, no log as (
select
 msisdn,
 min(create_date) as create_date,
 max(case when call_flg = 0 then call_date end) as date_null,
 max(case when call_flg = 1 then call_date end) as date_one,
 case when date_null = date_one then 0
      when date_null < date_one then 1
      when date_null > date_one then -1
      else 99 end as quality_flg
from (
select a.* from uat_ca.v_call_ds a
inner join tg t1 on a.msisdn = t1.msisdn
 and a.create_date = t1.min_create_date
where 1=1
 and a.create_date < date '2022-08-16'
) a
group by 1
) with data
primary index (msisdn)
on commit preserve rows
;

select top 100 * from tg_2;
select count(*) from tg_2;        155


--пример
select * from tg_2 where msisdn = '79001015716';


--Абоненты соответствующие криетрию "качество данных"

--drop table tg_quality;

create multiset volatile table tg_quality, no log as (
select a.* from uat_ca.v_call_ds a
inner join tg_2 t1 on a.msisdn = t1.msisdn
 and a.create_date = t1.create_date
 and a.call_date = t1.date_one
 and t1.quality_flg = 1
where 1=1
 and a.create_date < date '2022-08-16'
) with data
primary index (msisdn)
on commit preserve rows
;


select top 100 * from tg_quality;
select count(*) from tg_quality;        27

--пример
select * from tg_quality where msisdn = '79001015716';


--==Шаг 2 Абоненты без дублей + корректные абоненты с шага 1

--drop table subs_fin;

create multiset volatile table subs_fin, no log as (
--абоненты без дублей
select a.* from uat_ca.v_call_ds a
left join tg t1 on a.msisdn = t1.msisdn
 and a.create_date = t1.min_create_date
where 1=1
 and a.create_date < date '2022-08-16'
 and t1.msisdn is null
--абоенты соответствующие критерию "качество данных"
qualify row_number() over (partition by a.msisdn order by a.call_date desc) = 1
union all
select * from tg_quality
) with data
primary index (msisdn)
on commit preserve rows
;

select top 100 * from subs_fin;
select count(*) from subs_fin;      --23 263

--проверка дубликатов
select * from subs_fin
qualify count(*) over (partition by msisdn) > 1
;


--==Шаг 3 Формирование готового источника: опрос NPS + результат обзвона + результат опроса удовлетворенности

COLLECT STATISTICS
 COLUMN (MSISDN),
 COLUMN (CREATE_DATE),
 COLUMN (CREATE_DATE ,MSISDN)
ON subs_fin;



create multiset volatile table close_inhouse_with_ds_2, no log as (
select
 a.create_date,
 t1.cluster_actual as cluster_name,
 t1.macroregion,
 t1.region,
 a.call_date,
 a.call_flg,
 a.point_name,
 t1.cust_id,
 t1.subs_id,
 a.msisdn,
 t1.lt_day,
 t1.lt_gr,
 t1.age,
 t1.gender,
 t1.mark_6,
 t1.class_mark_6,
 t1.micro_class_mark_6,
 t1.cluster_mark_6_pr_2,
 t1.servelat,
 t1.servelat_gr,
 t1.ltr as nps,
 t1.nps as nps_key,
 t1.tp_id,
 t1.tp_name,
 t1.tac,
 t1.arpu_segment,
 t1.segment_value,
 t1.mb_last_30 as data_mb,
 t1.gsb_bronze,
 t1.eralash,
 a.offer_flg,
 a.offer_type,
 a.rtk_voice_flg,
 a.rtk_voice_reason,
 a.rtk_mi_flg,
 a.rtk_mi_reason,
 a.rtk_ds_flg,
 a.rtk_ds_reason,
 a.rtk_monobrand_flg,
 a.rtk_monobrand_reason,
 a.rtk_roaming_flg,
 a.rtk_roaming_reason,
 a.rtk_dishonesty_flg,
 a.rtk_dishonesty_reason,
 a.rtk_lk_flg,
 a.rtk_lk_reason,
 a.rtk_annoying_flg,
 a.rtk_annoying_reason,
 a.rtk_tarif_flg,
 a.rtk_tarif_reason,
 a.error_detract,
--данные удовлетворенности, 459
 t2.mark_1,
 t2.mark_2,
 t2.mark_3,
 t2.mark_4,
 t2.ans_1,
 t2.ans_2,
 t2.ans_3,
 nvl2(t2.msisdn,1,0) as flg_459,
 a.rtk_flg
from subs_fin a
--
inner join uat_ca.v_nps_bu t1 on a.msisdn = t1.msisdn
 and t1.create_date >= date '2022-04-27'
 and t1.create_date < date '2022-08-16'
 and a.create_date = t1.create_date
--
left join uat_ca.v_poll_459 t2 on a.msisdn = t2.msisdn
 and t2.create_date >= date '2022-04-27'
 and t2.create_date < date '2022-08-16'
) with data
primary index (subs_id)
on commit preserve rows
;


select top 100 * from close_inhouse_with_ds_2;

--21 721
--с 27.04.2022 по 15.08.2022
select create_date, count(distinct subs_id), count(*) from close_inhouse_with_ds_2 group by 1 order by 1;

--=================================================================================================

--==Этап 3  - Опрос удовлетворенности, - процедура uat_ca.mc_nps_bu_459 (/Scripts_2022/Опросы NPS/Замыкание контура МИ (poll_id_459)/poll_id 459.sql)

select top 100 * from uat_ca.v_poll_459;

--дневная динамика
select 
 create_date,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1
order by 1 desc;


--недельная динамика
select
 weeknumber_of_year (create_date, 'ISO') as "неделя",
 trunc (create_date,'iw') as first_day_week,
 count (distinct subs_id) dis_subs,
 count (distinct msisdn) dis_msisdn,
 count (*) as row_cnt,
 dis_subs - row_cnt as diff_subs,
 dis_msisdn - row_cnt as diff_msisdn
from uat_ca.v_poll_459
group by 1,2
order by 2 desc;


--Данные рассчитаны с 26.04.2022 по 15.10.2022


--=================================================================================================

--==Этап 4 - Формирование финальной витрины для использования в FineBI

select top 100 * from uat_ca.close_inhouse_with_DS_2;

--21 721
--с 27.04.2022 по 15.08.2022
select create_date, count(distinct subs_id), count(*) from uat_ca.close_inhouse_with_ds_2 group by 1 order by 1;
































--=================================================================================================
--=================================================================================================
--=================================================================================================

replace view uat_ca.v_call_ds as
lock row for access
select
 create_date,
 coalesce(call_date, date '2000-01-01') as call_date,
 case when call_status is not null then 1 else 0 end as call_flg,
 point_name,
 msisdn,
 coalesce(offer_flg,0) as offer_flg,
 coalesce(offer_type,'Не предложен') as offer_type,
 coalesce(rtk_voice_flg,0) as rtk_voice_flg,
 coalesce(rtk_voice_reason,'Другая РТК') as rtk_voice_reason,
 coalesce(rtk_mi_flg,0) as rtk_mi_flg,
 coalesce(rtk_mi_reason,'Другая РТК') as rtk_mi_reason,
 coalesce(rtk_ds_flg,0) as rtk_ds_flg,
 coalesce(rtk_ds_reason,'Другая РТК') as rtk_ds_reason,
 coalesce(rtk_monobrand_flg,0) as rtk_monobrand_flg,
 coalesce(rtk_monobrand_reason,'Другая РТК') as rtk_monobrand_reason,
 coalesce(rtk_roaming_flg,0) as rtk_roaming_flg,
 coalesce(rtk_roaming_reason,'Другая РТК') as rtk_roaming_reason,
 coalesce(rtk_dishonesty_flg,0) as rtk_dishonesty_flg,
 coalesce(rtk_dishonesty_reason,'Другая РТК') as rtk_dishonesty_reason,
 coalesce(rtk_lk_flg,0) as rtk_lk_flg,
 coalesce(rtk_lk_reason,'Другая РТК') as rtk_lk_reason,
 coalesce(rtk_annoying_flg,0) as rtk_annoying_flg,
 coalesce(rtk_annoying_reason,'Другая РТК') as rtk_annoying_reason,
 coalesce(rtk_tarif_flg,0) as rtk_tarif_flg,
 coalesce(rtk_tarif_reason,'Другая РТК') as rtk_tarif_reason,
 coalesce(error_detract,0) as error_detract,
 case when (rtk_voice_flg + rtk_mi_flg + rtk_ds_flg + rtk_monobrand_flg + rtk_roaming_flg + rtk_dishonesty_flg + rtk_lk_flg + rtk_annoying_flg + rtk_tarif_flg) > 0 then 1 else 0 end rtk_flg
from uat_ca.vi_mi_call_ds_rtk1
where 1=1
 and (point_name = 'Контакт-центр'
 or point_name = 'Мобильный интернет'
 )
;










