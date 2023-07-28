


select top 100 * from uat_ca.v_nps_bu;

--просмотр структуры View
show view uat_ca.v_nps_bu;


--справочник branch
select top 100 * from prd2_dic_v.branch;


--пример основной витрины на абонента
show view prd2_bds_v.subs_clr_d;
show view prd2_bds_v2.subs_clr_d;


replace view uat_ca.v_nps_bu as lock row for access
select
 a.create_date,
 a.cluster_name,
 t1.cluster_name as cluster_actual,
 a.macroregion,
 a.region,
 a.branch_id,
 a.cust_id,
 a.subs_id,
 a.msisdn,
 a.lt_day,
 a.lt_gr,
 a.age,
 a.gender,
 a.alien_flg,
/*Формируем во View*/
 weeknumber_of_year (a.create_date, 'iso') as "week",
 case when extract(month from a.create_date) = 1 then 'январь'
      when extract(month from a.create_date) = 2 then 'февраль'
      when extract(month from a.create_date) = 3 then 'март'
      when extract(month from a.create_date) = 4 then 'апрель'
      when extract(month from a.create_date) = 5 then 'май'
      when extract(month from a.create_date) = 6 then 'июнь'
      when extract(month from a.create_date) = 7 then 'июль'
      when extract(month from a.create_date) = 8 then 'август'
      when extract(month from a.create_date) = 9 then 'сентябрь'
      when extract(month from a.create_date) = 10 then 'октябрь'
      when extract(month from a.create_date) = 11 then 'ноябрь'
      when extract(month from a.create_date) = 12 then 'декабрь' else '' end as "month",
 extract(year from a.create_date) as "year",
--
 case when a.point_name in ('Монобренды covid') then 'Монобренды'
      when a.point_name in ('Тарифы covid') then 'Тарифы'
      when a.point_name in ('Контакт-центр covid') then 'Контакт-центр'
      when a.point_name in ('Голос и СМС метро') then 'Голос и СМС'
      when a.point_name in ('Мобильный интернет covid', 'Мобильный интернет метро', 'Мобильный интернет метро covid') then 'Мобильный интернет'
 else a.point_name end as point_name,
--
 a.mark_1,
 a.mark_2,
 a.mark_3,
 a.mark_4,
 a.mark_5,
 a.mark_6,
 a.mark_7,
 a.mark_8,
 a.mark_9,
 a.mark_10,
 a.mark_11,
 a.mark_12,
--
 a.ans_1,
 a.ans_2,
 a.ans_3,
 a.ans_4,
 a.ans_5,
 a.ans_6,
 a.ans_7,
 a.ans_8,
 a.ans_9,
 a.ans_10,
 a.ans_11,
 a.ans_12,
--==Сервелат
 case
--Проблем нет
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and a.ans_2 in ('Проблем нет') then 'Проблем нет'
--Другое
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and a.ans_2 in ('Другое') then 'Другое_ans_2'

      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and a.ans_2 is null then 'null_ans_2'
--Дома
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and a.ans_2 in ('Дома') then a.ans_8
--На работе\в школе\университете
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and a.ans_2 in ('На работе\в школе\университете') then a.ans_9
--По маршруту движения\на дороге, По маршруту движения\на дороге\в метро
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and a.ans_2 in ('По маршруту движения\на дороге', 'По маршруту движения\на дороге\в метро') then a.ans_10
--За городом\на даче
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and a.ans_2 in ('За городом\на даче') then a.ans_11
--Места отдыха и развлечений
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and a.ans_2 in ('Места отдыха и развлечений') then a.ans_12
 end as servelat,
--==Категории Сервелат
 case
--Проблем нет
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and servelat in ('Проблем нет') then 'Проблем нет'
--Другое
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and servelat in ('Другое') then 'Другое'

      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and servelat in ('Другое_ans_2') then 'Другое'

      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and servelat is null then 'Другое'

      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and servelat in ('null_ans_2') then 'Другое'

--      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
--           and servelat in ('Индустриальный объект') then 'Другое'
--Категории Авгученко
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and servelat in ('Внутри большого объекта (ТРЦ, концертные залы, кинотеатры)',
                            'Внутри небольшого помещения (кафе, бары, рестораны и т.д.)',
                            'Квартира, выше 5 этажа',
                            'Квартира, до 5 этажа включительно',
                            'Общественное место',
                            'В метро',
                            'Индустриальный объект'
                            ) then 'Indoor в этажной застройке'
--
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and servelat in ('Вне помещений (зоны отдыха, парки, стадионы, и т.д.)',
                            'Дорога в соседние населенные пункты\на дачу',
                            'Дорога в соседние регионы (М4, М5 и т.д.)',
                            'Дорога внутри города',
                            'Места отдыха (рыбалка, охота, пляжи, спорт)',
                            'На улице'
                           ) then 'На улице/за городом'
--
      when a.create_date >= date '2021-01-01' and a.point_name in('Мобильный интернет', 'Мобильный интернет метро', 'Мобильный интернет covid', 'Мобильный интернет метро covid')
           and servelat in ('Дача\СНТ',
                            'Частный дом'
                           ) then 'Частный сектор'
 end as servelat_gr,
--Кластеризация
 t2.cluster_mark_6 as class_mark_6,
 t2.micro_cluster_mark_6 as micro_class_mark_6,
 t2.cluster_mark_6_pr_2,
--
 a.ltr,
 a.detractor,
 a.passive,
 a.promoter,
 a.nps,
 a.nps_category,
--
 a.tp_id,
 a.tp_name,
 a.tp_short,
 a.tp_short2,
 a.bundle_flg,
 a.tp_tarification,
 a.concept,
--
 a.imei,
 a.tac,
 a.vendor_name,
 a.model_name,
 a.multi_sim,
 a."3g",
 a."4g",
 a.device_type,
 a.os_name,
 a.operating_frequency,
 a.usim,
 a.arpu_segment,
 a.segment_value,
--
 a.kpi_min,
 a.kpi_target,
 a.kpi_max,
--
 a.mb_last_30,
 a.share_2g,
 a.share_3g,
 a.share_4g,
 a.adu,
/*формируем данные сегменты во View*/
-- seg_1,                              --"2g_only"
-- seg_2,                              --"3g_only"
-- seg_3,                              --"4g>0%"
-- seg_4,                              --"2g_0,1%-5%"
-- seg_5,                              --"2g_5,1%-99,9%"
-- seg_6,                              --"4g_1%-10%"
-- seg_7,                              --"4g>10%"
-- seg_8,                              --"2g_сегмент"
-- seg_9,                              --"3g_сегмент"
-- seg_10,                             --"4g_сегмент"
--
 a.create_date_comm         as "дата и время заметки",
 a.source_system            as "система",
 a.pos_id,
 a.call_center              as "контактный центр абонента",
 a.line_ca_name             as "линия са",
 a.line_in_ca_name          as "линия по са",
 a.comm_cnl                 as "канал обращения",
 a.employee                 as "оператор",
 a.employee_call_center     as "кц оператора",
 a.position_name            as "должность оператора",
 a.employee_group           as "группа оператора",
 a.seg_11                   as "тех. проблема",
 a.seg_12                   as "администрирование",
 a.seg_13                   as "претензии к тарификации",
 a.seg_14                   as "пожелание к продукту",
 a.seg_15                   as "информация",
 a.dis_day_cnt              as "кол-во дней с обращениями",
 a.total_comm_cnt           as "общее кол-во обращений",
--
 a.invoice,
 a.key_flg,
 --Ералаш
 coalesce(case when t7.scor_type = 'Bronze' then 1 else 0 end, -1) as GSB_Bronze,
 coalesce(case when t7.scor_type = 'Eralash' then 1 else 0 end, -1) as Eralash
from uat_ca.mc_nps_bu a
--
left join prd2_dic_v.branch t1 on a.branch_id = t1.branch_id
--left join prd2_dic_v.region t2 on t1.region_id = t2.region_id
--left join prd2_dic_v.macroregion t3 on t2.macroregion_id = t3.macroregion_id
--Кластеризация
left join uat_ca.mc_nps_class_mark_6_new t2 on a.subs_id = t2.subs_id
 and t2.scoring_date = date '2022-06-01'
-- and t2.scoring_date = date '2021-11-21'
 and a.create_date = t2.create_date

--gsbб ералаш
left join uat_ca.mc_nps_detail_step_6 t7 on a.subs_id = t7.subs_id
 and a.create_date = t7.create_date
 and a.point_name = t7.point_name
--
where 1=1
 and a.point_name not in ('Мобильный интернет short', 'Мобильный интернет метро short');



--основная витрина
select top 100 * from uat_ca.mc_nps_bu;


























