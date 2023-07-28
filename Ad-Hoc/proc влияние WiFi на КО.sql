
diagnostic helpstats on for session;


--==Целевая группа

select top 100 * from uat_ca.fv_wifi_tc;

select count(distinct msisdn), count(*) from uat_ca.fv_wifi_tc;

select distinct t2.region_name as region, count(*) from uat_ca.fv_wifi_tc a
left join prd2_dic_v.branch t1 on a.branch_id = t1.branch_id
left join prd2_dic_v.region t2 on t1.region_id = t2.region_id
group by 1;



--2020-09-01    2022-04-29
select min(nps_date), max(nps_date) from uat_ca.fv_wifi_tc;


--==Тестовая группа для формирования data трафика
create multiset table uat_ca.fv_wifi_tg as (
select
 a.nps_date as create_date,
 t1.region_id,
 t2.subs_id
from uat_ca.fv_wifi_tc a
--
left join uat_ca.v_nps_bu t2 on a.msisdn = t2.msisdn
 and a.nps_date = t2.create_date
 and t2.point_name = 'Мобильный интернет'
 and t2.create_date >= date '2020-09-01'
 and t2.create_date <= date '2022-04-29'
--
left join prd2_dic_v.branch t1 on a.branch_id = t1.branch_id
) with data
primary index (subs_id)
;

select top 100 * from uat_ca.fv_wifi_tg;
select count(*) from uat_ca.fv_wifi_tg where subs_id is null;
select count(*) from uat_ca.fv_wifi_tg where region_id is null;

select top 100 * from uat_ca.fv_wifi_tg where create_date = date '2020-09-01';


--Статистика
COLLECT SUMMARY STATISTICS ON uat_ca.fv_wifi_tg;
COLLECT STATISTICS COLUMN (SUBS_ID) ON uat_ca.fv_wifi_tg;


--==================================================================================================

даты для использования в расчетах на 2022-07-26 для горячих данных prd2_dds_v.ne_subs_revenue_date (глубина хранения 420 дней):
bop     date '2021-06-04'
eop     date '2022-07-27'


даты для использования в расчетах на 2022-07-26 для холодных данных prd2_dds_hist_v.ne_subs_revenue_date (глубина хранения 104 дня):
bop     date '2021-06-04'
eop     date '2021-09-13'


--3 339 абонентов нет исторических данных
select
 distinct
 create_date,
 create_date - interval '90' day as sdate,
 create_date + interval '90' day as edate,
 count(*) as subs_cnt
from uat_ca.fv_wifi_tg
where 1=1
 and create_date < date '2021-08-28'
group by 1,2,3
order by 1
;


--==Периоды для процедуры

select top 100 * from uat_ca.fv_wifi_tg;

--Фаза 1
select
 distinct
 create_date,
 create_date - interval '90' day as sdate,
 create_date + interval '90' day as edate,
 count(*) as subs_cnt
from uat_ca.fv_wifi_tg
where 1=1
 and create_date > date '2021-09-02'
group by 1,2,3
order by 1
;

--Фаза 1
select
 distinct
 create_date,
 trunc(create_date,'mm') as sdate,
 trunc(create_date,'mm') + interval '1' month - interval '1' day as edate,
 count(*) as subs_cnt
from uat_ca.fv_wifi_tg_2
where 1=1
 and create_date > date '2021-09-02'
group by 1,2,3
order by 1
;



--=================================================================================================
--=================================================================================================
--=================================================================================================


--==Справвочник по уникальным NE_ID

--drop table uat_ca.fv_wifi_dic_ne;

create multiset table uat_ca.fv_wifi_dic_ne (
 ne_id decimal(15,0),
 region_id decimal(4,0)
)
primary index (ne_id)
;


replace macro wifi_dic_ne (reg_id decimal(4,0)) as (


--вставка данных 05 сек.
insert into uat_ca.fv_wifi_dic_ne
select
 distinct ne_id,
 :reg_id as region_id
from prd2_dic_v.network_element
where 1=1
 and region_id = :reg_id
;


--конец макроса
);


select * from uat_ca.fv_wifi_dic_ne where ne_id in (10494418101, 795369782);


--2021
Execute wifi_dic_ne (1);        --43 сек.

Execute wifi_dic_ne (3);
Execute wifi_dic_ne (5);
Execute wifi_dic_ne (6);
Execute wifi_dic_ne (8);
Execute wifi_dic_ne (9);
Execute wifi_dic_ne (10);
Execute wifi_dic_ne (11);
Execute wifi_dic_ne (12);
Execute wifi_dic_ne (13);
Execute wifi_dic_ne (14);
Execute wifi_dic_ne (15);
Execute wifi_dic_ne (18);
Execute wifi_dic_ne (19);
Execute wifi_dic_ne (20);
Execute wifi_dic_ne (22);
Execute wifi_dic_ne (24);
Execute wifi_dic_ne (25);
Execute wifi_dic_ne (26);
Execute wifi_dic_ne (27);
Execute wifi_dic_ne (29);
Execute wifi_dic_ne (30);
Execute wifi_dic_ne (31);
Execute wifi_dic_ne (32);
Execute wifi_dic_ne (33);
Execute wifi_dic_ne (34);
Execute wifi_dic_ne (35);
Execute wifi_dic_ne (36);
Execute wifi_dic_ne (37);
Execute wifi_dic_ne (38);
Execute wifi_dic_ne (39);
Execute wifi_dic_ne (40);
Execute wifi_dic_ne (41);
Execute wifi_dic_ne (42);
Execute wifi_dic_ne (44);
Execute wifi_dic_ne (45);
Execute wifi_dic_ne (46);
Execute wifi_dic_ne (47);
Execute wifi_dic_ne (48);
Execute wifi_dic_ne (49);
Execute wifi_dic_ne (50);
Execute wifi_dic_ne (51);
Execute wifi_dic_ne (52);
Execute wifi_dic_ne (53);
Execute wifi_dic_ne (54);
Execute wifi_dic_ne (55);
Execute wifi_dic_ne (56);
Execute wifi_dic_ne (57);
Execute wifi_dic_ne (59);
Execute wifi_dic_ne (61);
Execute wifi_dic_ne (62);
Execute wifi_dic_ne (63);
Execute wifi_dic_ne (64);
Execute wifi_dic_ne (65);
Execute wifi_dic_ne (66);
Execute wifi_dic_ne (67);
Execute wifi_dic_ne (69);
Execute wifi_dic_ne (70);
Execute wifi_dic_ne (71);
Execute wifi_dic_ne (74);
Execute wifi_dic_ne (78);
Execute wifi_dic_ne (79);       --5 мин. 57 сек.


COLLECT STATISTICS
 COLUMN (REGION_ID),
 COLUMN (NE_ID)
ON uat_ca.fv_wifi_dic_ne;


--==Регионы для макроса
select distinct region_id from uat_ca.fv_wifi_tg order by 1;

select top 100 * from uat_ca.fv_wifi_dic_ne;

select region_id, count(distinct ne_id), count(*) from uat_ca.fv_wifi_dic_ne group by 1;


--Статистика
COLLECT STATISTICS COLUMN (REGION_ID ,NE_ID) ON uat_ca.fv_wifi_dic_ne;



/*
select top 100 * from prd2_dic_v.network_element;

show table prd2_dic.region;
select top 100 * from PRD2_TMD_V.DEFAULT_FIELD_FORMAT where lower(original_field) like'%reg%';

show view prd2_dic_v.network_element;
show table prd2_dic.network_element;
show table prd2_dds.ne_subs_revenue_date;
*/

--================================================================================================-


-- Комментарий
COMMENT ON PROCEDURE uat_ca.mc_wifi_adhoc AS
'Процедура формирования data трафика до ne_id для WiFi. Результирующая таблица: uat_ca.fv_wifi_trf';


--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Вызов процедуры (условие не строгое/ строгое, не строгое/ не строгое)

--2021

call uat_ca.mc_wifi_adhoc (date '2021-09-03', date '2021-06-05', date '2021-12-02');         --3 мин. 08 сек.


call uat_ca.mc_wifi_adhoc (date'2021-09-04', date'2021-06-06', date'2021-12-03');   		 --3 мин. 18 сек.


call uat_ca.mc_wifi_adhoc (date'2021-09-06', date'2021-06-08', date'2021-12-05');
call uat_ca.mc_wifi_adhoc (date'2021-09-07', date'2021-06-09', date'2021-12-06');
call uat_ca.mc_wifi_adhoc (date'2021-09-08', date'2021-06-10', date'2021-12-07');
call uat_ca.mc_wifi_adhoc (date'2021-09-09', date'2021-06-11', date'2021-12-08');
call uat_ca.mc_wifi_adhoc (date'2021-09-10', date'2021-06-12', date'2021-12-09');
call uat_ca.mc_wifi_adhoc (date'2021-09-11', date'2021-06-13', date'2021-12-10');
call uat_ca.mc_wifi_adhoc (date'2021-09-13', date'2021-06-15', date'2021-12-12');
call uat_ca.mc_wifi_adhoc (date'2021-09-14', date'2021-06-16', date'2021-12-13');
call uat_ca.mc_wifi_adhoc (date'2021-09-15', date'2021-06-17', date'2021-12-14');
call uat_ca.mc_wifi_adhoc (date'2021-09-20', date'2021-06-22', date'2021-12-19');
call uat_ca.mc_wifi_adhoc (date'2021-09-22', date'2021-06-24', date'2021-12-21');
call uat_ca.mc_wifi_adhoc (date'2021-09-23', date'2021-06-25', date'2021-12-22');
call uat_ca.mc_wifi_adhoc (date'2021-09-24', date'2021-06-26', date'2021-12-23');
call uat_ca.mc_wifi_adhoc (date'2021-09-27', date'2021-06-29', date'2021-12-26');
call uat_ca.mc_wifi_adhoc (date'2021-09-28', date'2021-06-30', date'2021-12-27');
call uat_ca.mc_wifi_adhoc (date'2021-09-29', date'2021-07-01', date'2021-12-28');
call uat_ca.mc_wifi_adhoc (date'2021-09-30', date'2021-07-02', date'2021-12-29');
call uat_ca.mc_wifi_adhoc (date'2021-10-01', date'2021-07-03', date'2021-12-30');
call uat_ca.mc_wifi_adhoc (date'2021-10-04', date'2021-07-06', date'2022-01-02');
call uat_ca.mc_wifi_adhoc (date'2021-10-06', date'2021-07-08', date'2022-01-04');
call uat_ca.mc_wifi_adhoc (date'2021-10-07', date'2021-07-09', date'2022-01-05');
call uat_ca.mc_wifi_adhoc (date'2021-10-08', date'2021-07-10', date'2022-01-06');
call uat_ca.mc_wifi_adhoc (date'2021-10-11', date'2021-07-13', date'2022-01-09');
call uat_ca.mc_wifi_adhoc (date'2021-10-12', date'2021-07-14', date'2022-01-10');
call uat_ca.mc_wifi_adhoc (date'2021-10-13', date'2021-07-15', date'2022-01-11');
call uat_ca.mc_wifi_adhoc (date'2021-10-15', date'2021-07-17', date'2022-01-13');
call uat_ca.mc_wifi_adhoc (date'2021-10-18', date'2021-07-20', date'2022-01-16');
call uat_ca.mc_wifi_adhoc (date'2021-10-19', date'2021-07-21', date'2022-01-17');
call uat_ca.mc_wifi_adhoc (date'2021-10-20', date'2021-07-22', date'2022-01-18');
call uat_ca.mc_wifi_adhoc (date'2021-10-21', date'2021-07-23', date'2022-01-19');
call uat_ca.mc_wifi_adhoc (date'2021-10-22', date'2021-07-24', date'2022-01-20');
call uat_ca.mc_wifi_adhoc (date'2021-10-25', date'2021-07-27', date'2022-01-23');
call uat_ca.mc_wifi_adhoc (date'2021-10-26', date'2021-07-28', date'2022-01-24');
call uat_ca.mc_wifi_adhoc (date'2021-10-27', date'2021-07-29', date'2022-01-25');
call uat_ca.mc_wifi_adhoc (date'2021-10-28', date'2021-07-30', date'2022-01-26');
call uat_ca.mc_wifi_adhoc (date'2021-10-29', date'2021-07-31', date'2022-01-27');
call uat_ca.mc_wifi_adhoc (date'2021-11-01', date'2021-08-03', date'2022-01-30');
call uat_ca.mc_wifi_adhoc (date'2021-11-02', date'2021-08-04', date'2022-01-31');
call uat_ca.mc_wifi_adhoc (date'2021-11-03', date'2021-08-05', date'2022-02-01');
call uat_ca.mc_wifi_adhoc (date'2021-11-09', date'2021-08-11', date'2022-02-07');
call uat_ca.mc_wifi_adhoc (date'2021-11-10', date'2021-08-12', date'2022-02-08');
call uat_ca.mc_wifi_adhoc (date'2021-11-11', date'2021-08-13', date'2022-02-09');
call uat_ca.mc_wifi_adhoc (date'2021-11-12', date'2021-08-14', date'2022-02-10');
call uat_ca.mc_wifi_adhoc (date'2021-11-15', date'2021-08-17', date'2022-02-13');
call uat_ca.mc_wifi_adhoc (date'2021-11-16', date'2021-08-18', date'2022-02-14');
call uat_ca.mc_wifi_adhoc (date'2021-11-17', date'2021-08-19', date'2022-02-15');
call uat_ca.mc_wifi_adhoc (date'2021-11-18', date'2021-08-20', date'2022-02-16');
call uat_ca.mc_wifi_adhoc (date'2021-11-19', date'2021-08-21', date'2022-02-17');
call uat_ca.mc_wifi_adhoc (date'2021-11-22', date'2021-08-24', date'2022-02-20');
call uat_ca.mc_wifi_adhoc (date'2021-11-23', date'2021-08-25', date'2022-02-21');
call uat_ca.mc_wifi_adhoc (date'2021-11-24', date'2021-08-26', date'2022-02-22');
call uat_ca.mc_wifi_adhoc (date'2021-11-25', date'2021-08-27', date'2022-02-23');
call uat_ca.mc_wifi_adhoc (date'2021-11-26', date'2021-08-28', date'2022-02-24');
call uat_ca.mc_wifi_adhoc (date'2021-11-29', date'2021-08-31', date'2022-02-27');
call uat_ca.mc_wifi_adhoc (date'2021-11-30', date'2021-09-01', date'2022-02-28');
call uat_ca.mc_wifi_adhoc (date'2021-12-01', date'2021-09-02', date'2022-03-01');
call uat_ca.mc_wifi_adhoc (date'2021-12-02', date'2021-09-03', date'2022-03-02');
call uat_ca.mc_wifi_adhoc (date'2021-12-03', date'2021-09-04', date'2022-03-03');
call uat_ca.mc_wifi_adhoc (date'2021-12-06', date'2021-09-07', date'2022-03-06');
call uat_ca.mc_wifi_adhoc (date'2021-12-07', date'2021-09-08', date'2022-03-07');
call uat_ca.mc_wifi_adhoc (date'2021-12-08', date'2021-09-09', date'2022-03-08');
call uat_ca.mc_wifi_adhoc (date'2021-12-09', date'2021-09-10', date'2022-03-09');
call uat_ca.mc_wifi_adhoc (date'2021-12-10', date'2021-09-11', date'2022-03-10');
call uat_ca.mc_wifi_adhoc (date'2021-12-11', date'2021-09-12', date'2022-03-11');
call uat_ca.mc_wifi_adhoc (date'2021-12-13', date'2021-09-14', date'2022-03-13');
call uat_ca.mc_wifi_adhoc (date'2021-12-14', date'2021-09-15', date'2022-03-14');
call uat_ca.mc_wifi_adhoc (date'2021-12-15', date'2021-09-16', date'2022-03-15');
call uat_ca.mc_wifi_adhoc (date'2021-12-16', date'2021-09-17', date'2022-03-16');
call uat_ca.mc_wifi_adhoc (date'2021-12-17', date'2021-09-18', date'2022-03-17');
call uat_ca.mc_wifi_adhoc (date'2021-12-20', date'2021-09-21', date'2022-03-20');
call uat_ca.mc_wifi_adhoc (date'2021-12-21', date'2021-09-22', date'2022-03-21');
call uat_ca.mc_wifi_adhoc (date'2021-12-22', date'2021-09-23', date'2022-03-22');
call uat_ca.mc_wifi_adhoc (date'2021-12-23', date'2021-09-24', date'2022-03-23');
call uat_ca.mc_wifi_adhoc (date'2021-12-24', date'2021-09-25', date'2022-03-24');
call uat_ca.mc_wifi_adhoc (date'2021-12-27', date'2021-09-28', date'2022-03-27');
call uat_ca.mc_wifi_adhoc (date'2021-12-28', date'2021-09-29', date'2022-03-28');
call uat_ca.mc_wifi_adhoc (date'2021-12-29', date'2021-09-30', date'2022-03-29');
call uat_ca.mc_wifi_adhoc (date'2021-12-30', date'2021-10-01', date'2022-03-30');           -- 3 ч. 13 мин 


call uat_ca.mc_wifi_adhoc (date'2022-01-10', date'2021-10-12', date'2022-04-10');
call uat_ca.mc_wifi_adhoc (date'2022-01-11', date'2021-10-13', date'2022-04-11');
call uat_ca.mc_wifi_adhoc (date'2022-01-12', date'2021-10-14', date'2022-04-12');
call uat_ca.mc_wifi_adhoc (date'2022-01-13', date'2021-10-15', date'2022-04-13');
call uat_ca.mc_wifi_adhoc (date'2022-01-14', date'2021-10-16', date'2022-04-14');
call uat_ca.mc_wifi_adhoc (date'2022-01-17', date'2021-10-19', date'2022-04-17');
call uat_ca.mc_wifi_adhoc (date'2022-01-18', date'2021-10-20', date'2022-04-18');
call uat_ca.mc_wifi_adhoc (date'2022-01-19', date'2021-10-21', date'2022-04-19');
call uat_ca.mc_wifi_adhoc (date'2022-01-20', date'2021-10-22', date'2022-04-20');
call uat_ca.mc_wifi_adhoc (date'2022-01-21', date'2021-10-23', date'2022-04-21');
call uat_ca.mc_wifi_adhoc (date'2022-01-24', date'2021-10-26', date'2022-04-24');
call uat_ca.mc_wifi_adhoc (date'2022-01-25', date'2021-10-27', date'2022-04-25');
call uat_ca.mc_wifi_adhoc (date'2022-01-26', date'2021-10-28', date'2022-04-26');
call uat_ca.mc_wifi_adhoc (date'2022-01-27', date'2021-10-29', date'2022-04-27');
call uat_ca.mc_wifi_adhoc (date'2022-01-28', date'2021-10-30', date'2022-04-28');
call uat_ca.mc_wifi_adhoc (date'2022-01-31', date'2021-11-02', date'2022-05-01');
call uat_ca.mc_wifi_adhoc (date'2022-02-01', date'2021-11-03', date'2022-05-02');
call uat_ca.mc_wifi_adhoc (date'2022-02-02', date'2021-11-04', date'2022-05-03');
call uat_ca.mc_wifi_adhoc (date'2022-02-04', date'2021-11-06', date'2022-05-05');
call uat_ca.mc_wifi_adhoc (date'2022-02-07', date'2021-11-09', date'2022-05-08');
call uat_ca.mc_wifi_adhoc (date'2022-02-08', date'2021-11-10', date'2022-05-09');
call uat_ca.mc_wifi_adhoc (date'2022-02-09', date'2021-11-11', date'2022-05-10');
call uat_ca.mc_wifi_adhoc (date'2022-02-10', date'2021-11-12', date'2022-05-11');
call uat_ca.mc_wifi_adhoc (date'2022-02-11', date'2021-11-13', date'2022-05-12');
call uat_ca.mc_wifi_adhoc (date'2022-02-14', date'2021-11-16', date'2022-05-15');
call uat_ca.mc_wifi_adhoc (date'2022-02-15', date'2021-11-17', date'2022-05-16');
call uat_ca.mc_wifi_adhoc (date'2022-02-16', date'2021-11-18', date'2022-05-17');
call uat_ca.mc_wifi_adhoc (date'2022-02-17', date'2021-11-19', date'2022-05-18');
call uat_ca.mc_wifi_adhoc (date'2022-02-18', date'2021-11-20', date'2022-05-19');
call uat_ca.mc_wifi_adhoc (date'2022-02-21', date'2021-11-23', date'2022-05-22');
call uat_ca.mc_wifi_adhoc (date'2022-02-22', date'2021-11-24', date'2022-05-23');
call uat_ca.mc_wifi_adhoc (date'2022-02-25', date'2021-11-27', date'2022-05-26');
call uat_ca.mc_wifi_adhoc (date'2022-02-26', date'2021-11-28', date'2022-05-27');
call uat_ca.mc_wifi_adhoc (date'2022-02-28', date'2021-11-30', date'2022-05-29');
call uat_ca.mc_wifi_adhoc (date'2022-03-01', date'2021-12-01', date'2022-05-30');
call uat_ca.mc_wifi_adhoc (date'2022-03-02', date'2021-12-02', date'2022-05-31');
call uat_ca.mc_wifi_adhoc (date'2022-03-03', date'2021-12-03', date'2022-06-01');
call uat_ca.mc_wifi_adhoc (date'2022-03-04', date'2021-12-04', date'2022-06-02');
call uat_ca.mc_wifi_adhoc (date'2022-03-05', date'2021-12-05', date'2022-06-03');
call uat_ca.mc_wifi_adhoc (date'2022-03-06', date'2021-12-06', date'2022-06-04');
call uat_ca.mc_wifi_adhoc (date'2022-03-10', date'2021-12-10', date'2022-06-08');
call uat_ca.mc_wifi_adhoc (date'2022-03-11', date'2021-12-11', date'2022-06-09');
call uat_ca.mc_wifi_adhoc (date'2022-03-14', date'2021-12-14', date'2022-06-12');
call uat_ca.mc_wifi_adhoc (date'2022-03-15', date'2021-12-15', date'2022-06-13');
call uat_ca.mc_wifi_adhoc (date'2022-03-16', date'2021-12-16', date'2022-06-14');
call uat_ca.mc_wifi_adhoc (date'2022-03-17', date'2021-12-17', date'2022-06-15');
call uat_ca.mc_wifi_adhoc (date'2022-03-18', date'2021-12-18', date'2022-06-16');
call uat_ca.mc_wifi_adhoc (date'2022-03-19', date'2021-12-19', date'2022-06-17');
call uat_ca.mc_wifi_adhoc (date'2022-03-21', date'2021-12-21', date'2022-06-19');
call uat_ca.mc_wifi_adhoc (date'2022-03-22', date'2021-12-22', date'2022-06-20');
call uat_ca.mc_wifi_adhoc (date'2022-03-23', date'2021-12-23', date'2022-06-21');
call uat_ca.mc_wifi_adhoc (date'2022-03-24', date'2021-12-24', date'2022-06-22');
call uat_ca.mc_wifi_adhoc (date'2022-03-25', date'2021-12-25', date'2022-06-23');
call uat_ca.mc_wifi_adhoc (date'2022-03-28', date'2021-12-28', date'2022-06-26');
call uat_ca.mc_wifi_adhoc (date'2022-03-29', date'2021-12-29', date'2022-06-27');
call uat_ca.mc_wifi_adhoc (date'2022-03-30', date'2021-12-30', date'2022-06-28');
call uat_ca.mc_wifi_adhoc (date'2022-03-31', date'2021-12-31', date'2022-06-29');
call uat_ca.mc_wifi_adhoc (date'2022-04-01', date'2022-01-01', date'2022-06-30');
call uat_ca.mc_wifi_adhoc (date'2022-04-04', date'2022-01-04', date'2022-07-03');
call uat_ca.mc_wifi_adhoc (date'2022-04-05', date'2022-01-05', date'2022-07-04');
call uat_ca.mc_wifi_adhoc (date'2022-04-07', date'2022-01-07', date'2022-07-06');
call uat_ca.mc_wifi_adhoc (date'2022-04-08', date'2022-01-08', date'2022-07-07');
call uat_ca.mc_wifi_adhoc (date'2022-04-11', date'2022-01-11', date'2022-07-10');
call uat_ca.mc_wifi_adhoc (date'2022-04-12', date'2022-01-12', date'2022-07-11');
call uat_ca.mc_wifi_adhoc (date'2022-04-13', date'2022-01-13', date'2022-07-12');
call uat_ca.mc_wifi_adhoc (date'2022-04-14', date'2022-01-14', date'2022-07-13');
call uat_ca.mc_wifi_adhoc (date'2022-04-18', date'2022-01-18', date'2022-07-17');
call uat_ca.mc_wifi_adhoc (date'2022-04-19', date'2022-01-19', date'2022-07-18');
call uat_ca.mc_wifi_adhoc (date'2022-04-20', date'2022-01-20', date'2022-07-19');
call uat_ca.mc_wifi_adhoc (date'2022-04-21', date'2022-01-21', date'2022-07-20');
call uat_ca.mc_wifi_adhoc (date'2022-04-22', date'2022-01-22', date'2022-07-21');
call uat_ca.mc_wifi_adhoc (date'2022-04-25', date'2022-01-25', date'2022-07-24');
call uat_ca.mc_wifi_adhoc (date'2022-04-26', date'2022-01-26', date'2022-07-25');
call uat_ca.mc_wifi_adhoc (date'2022-04-27', date'2022-01-27', date'2022-07-26');
call uat_ca.mc_wifi_adhoc (date'2022-04-28', date'2022-01-28', date'2022-07-27');
call uat_ca.mc_wifi_adhoc (date'2022-04-29', date'2022-01-29', date'2022-07-28');       -- 43 мин. 


--delete uat_ca.fv_wifi_trf;

--=================================================================================================
--=================================================================================================
--=================================================================================================

-- Комментарии доступны в витринах метаданных EDW:
select * from prd2_tmd_v.tables_info where databasename = 'uat_ca' and tablekind = 'Procedure' order by "Дата последнего изменения" desc;
select * from prd2_tmd_v.columns_info;


-- Для просмотра рассчитанных дней в момент работы процедуры, либо по ее завершению используйте запрос по таблице логов:
lock row for access
select * from uat_ca.mc_logs t1
where t1.ProcessName = 'wifi_adhoc'
 and t1.logdate > current_timestamp(0) - interval '1' month
order by logdate desc;


-- Просмотр логов
select * from uat_ca.mc_logs order by 1;


--Статистика
COLLECT SUMMARY STATISTICS ON uat_ca.uat_ca.fv_wifi_trf;

COLLECT STATISTICS
 ...
ON uat_ca.uat_ca.fv_wifi_trf;


-- Просмотр витрин
select top 100 * from uat_ca.fv_wifi_trf;
select region, count(*) from uat_ca.uat_ca.fv_wifi_trf group by 1 order by 1;

select * from uat_ca.uat_ca.fv_wifi_trf where region <> 'Москва';

--=================================================================================================
--=================================================================================================
--=================================================================================================


REPLACE PROCEDURE uat_ca.mc_wifi_adhoc (in r_date date, in dt1 date, in dt2 date)
SQL SECURITY INVOKER
BEGIN

-- объявление переменных
DECLARE dt date;
DECLARE proc varchar(50);
DECLARE LOAD_ID int;
DECLARE ERR_MSG VARCHAR(4000) DEFAULT '';
DECLARE ERR_SQLCODE INT;
DECLARE ERR_SQLSTATE INT;
DECLARE ROW_CNT INT;
DECLARE TOTAL_ROW_CNT INT;


-- Ошибка на этапе запуска SQL кода
DECLARE EXIT HANDLER FOR SqlException
BEGIN
SET ERR_SQLCODE = Cast(SqlCode AS INTEGER);
SET ERR_SQLSTATE = Cast(SqlState AS INTEGER);
SELECT ErrorText INTO :ERR_MSG FROM dbc.errormsgs WHERE Errorcode = :ERR_SQLCODE;
CALL uat_ca.prc_debug (:proc, :load_id, session, 0, 'An error occured during execution: ' || :ERR_MSG);
END;


SET dt = DT1;
SET proc = 'wifi_adhoc';           -- наименование расчета
SET TOTAL_ROW_CNT = 0;

select max(zeroifnull(loadid)+1) into load_id
from uat_ca.mc_logs;


-- логирование начала расчета данных
CALL uat_ca.prc_debug (proc,:load_id,session,0,'START: ');



--==03 Временная для Данные по трафику

create multiset volatile table subs ,no log (
 report_date date format 'yy/mm/dd',
 subs_id decimal(12,0),
 region_id decimal(4,0),
 ne_id decimal(12,0),
 ne_region_id decimal(4,0),
 voice_dur decimal(10,0),
 voice_dur_no_bucket decimal(10,0),
 voice_dur_inc decimal(10,0),
 data_vol decimal(18,0),
 data_vol_no_bucket decimal(18,0)
)
primary index (subs_id)
on commit preserve rows
;



BT;

-- цикл по датам
WHILE (dt <= DT2) DO



--==04 Вставка данных по трафику

--вставка данных за один день 56 сек.
insert into subs
select
 a.report_date,
 a.subs_id,
 a.subs_region_id as region_id,
 a.ne_id,
 a.ne_region_id,
--Voice
 a.voice_duration_bucket as voice_dur,
 a.voice_duration_no_bucket as voice_dur_no_bucket,
 a.voice_duration_incoming as voice_dur_inc,
--Data
 a.data_volume_bucket as data_vol,
 a.data_volume_no_bucket as data_vol_no_bucket
from prd2_dds_v2.ne_subs_revenue_date a
--
inner join uat_ca.fv_wifi_dic_ne t1 on a.ne_id = t1.ne_id
-- and t1.region_id = :reg_id
-- and t1.region_id = 40
inner join uat_ca.fv_wifi_tg t2 on a.subs_id = t2.subs_id
 and t2.create_date = :r_date
-- and t2.subs_id = 300025954865
--
where 1=1
 and a.report_date = dt
-- and a.report_date = date '2021-08-31'            --для расчета региона Москва вручную
;

--select * from uat_ca.fv_wifi_tg where subs_id = 300025954865;
--select top 100 * from subs;
--delete subs;

-- Увеличиваем дату dt
SET dt = dt + INTERVAL '1' DAY;
get diagnostics ROW_CNT = row_count;


SET TOTAL_ROW_CNT = TOTAL_ROW_CNT + ROW_CNT;
END WHILE;

ET;

-- логирование текущего расчета
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Всего строк: ' || ' in - ' || trim(cast(total_row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));



--==05 Статистика

COLLECT STATISTICS
 COLUMN (NE_ID)
ON subs;



--==06 Справочник по секторам для которых был сформирован трафик

create multiset volatile table dic_ne_2 ,no log (
 ne_id decimal(12,0),
 mastersite varchar(30) character set unicode not casespecific,
 bs_name varchar(50) character set unicode not casespecific,
 sector_name varchar(25) character set unicode not casespecific,
 standart varchar(25) character set unicode not casespecific,
 technology varchar(25) character set unicode not casespecific,
 district_name varchar(400) character set unicode not casespecific,
 address varchar(400) character set unicode not casespecific,
 edw_sdate timestamp(0),
 edw_edate timestamp(0),
 ne_flg byteint
)
primary index (ne_id)
on commit preserve rows
;


insert into dic_ne_2
select
 distinct
 a.ne_id,
--
 t1.mastersite,
 t1.bs_name,
 t1.sector_name,
 t1.standart,
 t1.stechnology as technology,
 t1.district_name,
 t1.address,
 t1.edw_sdate,
 t1.edw_edate,
 nvl2(t1.ne_id,1,0) as ne_flg
from subs a
--
left join prd2_dic_v.network_element t1 on a.ne_id = t1.ne_id
 and t1.mastersite is not null
 and t1.district_name is not null
where 1=1
qualify row_number() over (partition by t1.ne_id order by t1.edw_sdate desc) = 1
;



--==08 Статистика

COLLECT STATISTICS
 COLUMN (NE_ID),
 COLUMN (SECTOR_NAME),
 COLUMN (NE_FLG)
ON dic_ne_2;



--==07 Целевая группа - данные по трафику + сектора

create multiset volatile table subs2 ,no log (
 report_date date format 'yy/mm/dd',
 subs_id decimal(12,0),
 region_id decimal(4,0),
 ne_id decimal(12,0),
 ne_region_id decimal(4,0),
 roamer byteint,
 voice_dur decimal(10,0),
 voice_dur_no_bucket decimal(10,0),
 voice_dur_inc decimal(10,0),
 data_vol decimal(18,0),
 data_vol_no_bucket decimal(18,0),
 mastersite varchar(30) character set unicode not casespecific,
 bs_name varchar(50) character set unicode not casespecific,
 sector_name varchar(25) character set unicode not casespecific,
 standart varchar(25) character set unicode not casespecific,
 technology varchar(25) character set unicode not casespecific,
 district_name varchar(400) character set unicode not casespecific,
 address varchar(400) character set unicode not casespecific
)
primary index (subs_id)
on commit preserve rows
;


--вставка данных за один день 01 сек.
insert into subs2
select
 a.report_date,
 a.subs_id,
 a.region_id,
 a.ne_id,
 a.ne_region_id,
 case when a.region_id = a.ne_region_id then 0 else 1 end as roamer,
 a.voice_dur,
 a.voice_dur_no_bucket,
 a.voice_dur_inc,
 a.data_vol,
 a.data_vol_no_bucket,
--
 t1.mastersite,
 t1.bs_name,
 t1.sector_name,
 t1.standart,
 t1.technology,
 t1.district_name,
 t1.address
from subs a
--
inner join dic_ne_2 t1 on a.ne_id = t1.ne_id
 and t1.ne_flg = 1
;



--==08 Статистика

COLLECT STATISTICS
 COLUMN (DISTRICT_NAME),
 COLUMN (ADDRESS),
 COLUMN (ROAMER),
 COLUMN (TECHNOLOGY),
 COLUMN (STANDART),
 COLUMN (SUBS_ID ,ROAMER ,SECTOR_NAME,STANDART ,TECHNOLOGY ,DISTRICT_NAME ,ADDRESS)
ON subs2;



--==09 Агрегат данных за месяц

create multiset volatile table subs3 ,no log (
 report_month date format 'yy/mm/dd',
 subs_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 standart varchar(25) character set unicode not casespecific,
 technology varchar(25) character set unicode not casespecific,
 district_name varchar(400) character set unicode not casespecific,
 address varchar(400) character set unicode not casespecific,
 roamer byteint,
 voice_dur decimal(15,0),
 voice_dur_no_bucket decimal(15,0),
 voice_dur_inc decimal(15,0),
 data_vol decimal(18,0),
 data_vol_no_bucket decimal(18,0)
)
primary index (subs_id)
on commit preserve rows
;


--вставка данных за один день 08 сек.
insert into subs3
select
-- date '2022-06-01' as report_month,
 trunc(:dt1,'mm') as report_mont,
 subs_id,
 sector_name,
 standart,
 technology,
 district_name,
 address,
 roamer,
--
 sum(voice_dur) as voice_dur,
 sum(voice_dur_no_bucket) as voice_dur_no_bucket,
 sum(voice_dur_inc) as voice_dur_inc,
 sum(data_vol) as data_vol,
 sum(data_vol_no_bucket) as data_vol_no_bucket
from subs2
group by 1,2,3,4,5,6,7,8
;



--==10 Статистика

COLLECT STATISTICS
 COLUMN (TECHNOLOGY)
ON subs3;



--==11 Расчет драйвер распределения по универсальному трафику

create multiset volatile table subs4 ,no log (
 report_month date format 'yy/mm/dd',
 subs_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 standart varchar(25) character set unicode not casespecific,
 technology varchar(25) character set unicode not casespecific,
 district_name varchar(400) character set unicode not casespecific,
 address varchar(400) character set unicode not casespecific,
 roamer byteint,
 voice_dur decimal(15,0),
 voice_dur_no_bucket decimal(15,0),
 voice_dur_inc decimal(15,0),
 voice_all decimal(15,0),
 data_vol decimal(18,0),
 data_vol_no_bucket decimal(18,0),
 data_all decimal(18,0),
 ut_driver float
)
primary index (subs_id)
on commit preserve rows
;


--вставка данных за один день 01 сек.
insert into subs4
select
 a.report_month,
 a.subs_id,
 a.sector_name,
 a.standart,
 a.technology,
 a.district_name,
 a.address,
 a.roamer,
--голосовой трафик
 a.voice_dur,
 a.voice_dur_no_bucket,
 a.voice_dur_inc,
 (a.voice_dur + a.voice_dur_no_bucket + a.voice_dur_inc) as voice_all,
--data трафик
 a.data_vol,
 a.data_vol_no_bucket,
 (a.data_vol + a.data_vol_no_bucket) as data_all,
--драйвер распределения по универсальному трафику
 case when coalesce(a.technology,'') <> ''
      then coalesce (cast (voice_all as float) / 60 / nullif (t1.rate, 0), 0) + coalesce (cast (data_all as float) / 1024 / 1024, 0)
      else 0
 end as ut_driver
from subs3 a
--
left join uat_ca.mc_dic_rate t1 on a.technology = t1.stechnology
;



--==12 Статистика

COLLECT STATISTICS
 COLUMN (REPORT_MONTH ,SUBS_ID)
ON subs4;



--==13 Финальная витрина


--вставка данных за один день 01 сек.
insert into uat_ca.fv_wifi_trf
select
 a.report_month,
 t1.create_date,
-- :reg_id as region_id,
-- 40 as region_id,         --для расчета региона Москва вручную
 t1.region_id as region_id,
 a.subs_id,
 a.sector_name,
--
 a.voice_all,
 a.data_all,
 a.ut_driver,
 case when sum (a.ut_driver) over (partition by a.report_month, a.subs_id) = 0 then 0
      else a.ut_driver / sum (a.ut_driver) over (partition by a.report_month, a.subs_id)
 end as ut_share,                                                                   --универсальный трафик на всех секторах в %
 case when ut_share < cast('0.05' as decimal(4,2)) then 1
      else 0
 end as sector_transit,                                                               --признак транзитного сектора
--
 a.standart,
 a.technology,
 a.district_name,
 a.address,
 a.roamer,
--
 a.voice_dur,
 a.voice_dur_no_bucket,
 a.voice_dur_inc,
 a.data_vol,
 a.data_vol_no_bucket
from subs4 a
--
left join uat_ca.fv_wifi_tg t1 on a.subs_id = t1.subs_id
;


-- логирование текущего расчета
get diagnostics ROW_CNT = row_count;
CALL uat_ca.prc_debug (proc,:load_id,session,null,'Всего строк: '|| ' fin - ' || trim(cast(row_cnt as VARCHAR(4000) CHARACTER SET UNICODE NOT CASESPECIFIC)));


drop table dic_ne_2;
drop table subs;
drop table subs2;
drop table subs3;
drop table subs4;


-- логирование окончания расчета данных
CALL uat_ca.prc_debug (proc,:load_id,session,1,'END: ');



END;


--select top 100 * from dic_ne_2;
--select top 100 * from subs;
--select top 100 * from subs2;
--select top 100 * from subs3;
--select top 100 * from subs4;


--=================================================================================================
--=================================================================================================
--=================================================================================================

select * from uat_ca.fv_wifi_trf;

--delete uat_ca.fv_wifi_trf;


--== Объем/SkewFactor
select * from show_table_size
where 1=1
 and lower(databasename) = 'uat_ca'
 and lower(tablename) in ('fv_wifi_trf')
order by 1,2;

DataBaseName    "TableName"             CreatorName         CreateTimeStamp         LastAccessTimeStamp     TableSize       SkewFactor
 ------------   ----------------------  ----------------    -------------------     -------------------     ---------       ----------
UAT_CA          FV_WIFI_TRF             MIKHAIL.CHUPIS      2022-07-29 10:19:38     2022-07-29 10:26:22     0,004           96,828




--=================================================================================================
--=================================================================================================
--=================================================================================================

select top 100 * from uat_ca.fv_wifi_trf;

show table uat_ca.fv_wifi_trf;
--drop table uat_ca.fv_wifi_trf;

create multiset table uat_ca.fv_wifi_trf (
 report_month date format 'yy/mm/dd',
 create_date date format 'yy/mm/dd',
 region_id byteint,
 subs_id decimal(12,0),
 sector_name varchar(25) character set unicode not casespecific,
 voice_all decimal(15,0),
 data_all decimal(18,0),
 ut_driver float,
 ut_share float,
 sector_transit byteint,
 standart varchar(25) character set unicode not casespecific,
 technology varchar(25) character set unicode not casespecific,
 district_name varchar(400) character set unicode not casespecific,
 address varchar(400) character set unicode not casespecific,
 roamer byteint,
 voice_dur decimal(15,0),
 voice_dur_no_bucket decimal(15,0),
 voice_dur_inc decimal(15,0),
 data_vol decimal(18,0),
 data_vol_no_bucket decimal(18,0))
primary index (subs_id)
partition by range_n(report_month  between date '2021-01-01' and date '2022-12-31' each interval '1' month )
;





