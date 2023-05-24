
--Шаг 1. Формируем вьюху со структурой запроса(create volatile .... where 1= 0)
--Шаг 2. Пишем макрос, в параметры передаем месяцы
--Шаг 3. Добавляем значения  (Execute) 

replace macro nps_all (s_nps date, e_nps date, sdate date, edate date) as (

--create multiset volatile table subs_all, no log as (
insert into subs_all
select a.* from (
	select
	 a.create_date,
	 a.cluster_actual as cluster_name,
	 a.macroregion as macroregion,
	 a.region as region,
	 a.branch_id,
	 a.cust_id,
	 a.subs_id,
	 a.msisdn,
	 a.point_name,
	 a.ltr as nps,
	 a.nps as nps_key,
	-- a.lt_day,
	 case when a.lt_day is null or a.lt_day = - 1 then 'null'
	      when a.lt_day < 91 then '3'
	      when a.lt_day < 181  then '4-6'
	      when a.lt_day < 361 then '7-12'
	      when a.lt_day < 721 then '13-24'
	      else '25+' end as lt_gr,
	-- a.age,
	 case when a.age is null or a.age = -1 then 'n/a'
	      when a.age < 21 then '16-20'
	      when a.age < 36 then '21-35'
	      when a.age < 46 then '36-45'
	      when a.age < 56 then '46-55'
	      else '56 +' end as age_gr,
	-- a.gender,
	 case when a.gender is null or a.gender = -1 then 'n/a'
	      when a.gender = 0 then 'Ì'
	      when a.gender = 1 then 'Æ'
	      end as gender,
	 a.data_gb,
	 case when data_gb is null then '0'
	      when data_gb = 0 then '0'
	      when data_gb <= 10 then '10'
	      when data_gb <= 30 then 'îò 10-30'
	      when data_gb <= 50 then 'îò 30-50'
	      when data_gb <= 100 then 'îò 50-100'
	      else '100+'
	 end as data_gr,
	--
	-- t1.report_month,
	 t1.create_dttm,
	 t1.event_date_to_rtk,
	 t1.event_date_instal,
	 t1.alladin_system,
	 t1.last_status_name,
	 t1.reason,
	 a.create_date - cast(t1.event_date_instal as date) as diff_day
	from uat_ca.v3_nps_bu a
	--
	inner join uat_ca.mc_alladin_subs t1 on a.subs_id = t1.subs_id
	 --and t1.event_date_instal >= date '2022-06-01'
	 --and t1.event_date_instal < date '2022-08-01'
	 and t1.event_date_instal >= :sdate
	 and t1.event_date_instal < :edate
	where 1=1
	 --and a.create_date >= date '2022-07-01'
	 --and a.create_date < date '2022-08-01'
	 and a.create_date >= :s_nps
	 and a.create_date < :e_nps
) a
where 1=0 ;
--)with no data;
);

--2022
/*ßíâàðü*/     Execute nps_all (date '2022-01-01', date '2022-02-01', date '2021-12-01', date '2022-02-01');
/*Ôåâðàëü*/    Execute nps_all (date '2022-02-01', date '2022-03-01', date '2022-01-01', date '2022-03-01');
/*Ìàðò*/       Execute nps_all (date '2022-03-01', date '2022-04-01', date '2022-02-01', date '2022-04-01');
/*Àïðåëü*/     Execute nps_all (date '2022-04-01', date '2022-05-01', date '2022-03-01', date '2022-05-01');
/*Ìàé*/        Execute nps_all (date '2022-05-01', date '2022-06-01', date '2022-04-01', date '2022-06-01');
/*Èþíü*/       Execute nps_all (date '2022-06-01', date '2022-07-01', date '2022-05-01', date '2022-07-01');
/*Èþëü*/       Execute nps_all (date '2022-07-01', date '2022-08-01', date '2022-06-01', date '2022-08-01');
/*Àâãóñò*/     Execute nps_all (date '2022-08-01', date '2022-09-01', date '2022-07-01', date '2022-09-01');
/*Ñåíòÿáðü*/   Execute nps_all (date '2022-09-01', date '2022-10-01', date '2022-08-01', date '2022-10-01');
/*Îêòÿáðü*/    Execute nps_all (date '2022-10-01', date '2022-11-01', date '2022-09-01', date '2022-11-01');
/*Íîÿáðü*/     Execute nps_all (date '2022-11-01', date '2022-12-01', date '2022-10-01', date '2022-12-01');
/*Äåêàáðü*/    Execute nps_all (date '2022-12-01', date '2023-01-01', date '2022-11-01', date '2023-01-01');


--2023
/*ßíâàðü*/     Execute nps_all (date '2023-01-01', date '2023-02-01', date '2022-12-01', date '2023-02-01');
/*Ôåâðàëü*/    Execute nps_all (date '2023-02-01', date '2023-03-01', date '2023-01-01', date '2023-03-01');
/*Ìàðò*/       Execute nps_all (date '2023-03-01', date '2023-04-01', date '2023-02-01', date '2023-04-01');
/*Àïðåëü*/     Execute nps_all (date '2023-04-01', date '2023-05-01', date '2023-03-01', date '2023-05-01');
-------------------------------------------------

select * from subs_all




