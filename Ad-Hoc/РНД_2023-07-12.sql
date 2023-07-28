diagnostic helpstats on for session;
select top 100 * from uat_ca.mc_mc_sqm_score_4 where  sector_name = 'RO0317_081'


--Вариант 1 ()
-- drop table uat_ca.vf_rostov_research_12072023
-----------------------------------------------
create multiset table uat_ca.vf_rostov_research_12072023 as(
select t1.subs_id, t1.sector_name, bs_position, t1.coeff_80, t1.tech_score,  t1.top_3, t2.site_name
	 , case when coeff_80 is null then 'not_bad_coeff'
	 	    when coeff_80 = 0 then 'not_bad_coeff'
	 	    else coeff_80 end as coeff_80_new
	 , LON, LAT, ST_POINT
from(	 	    
	select subs_id 
		 , sector_name
		 , coeff_80
		 , tech_score
		 , row_number() over(partition by subs_id order by coeff_80 desc ) as top_3
	from uat_ca.mc_mc_sqm_score_4
	where tech_score = 1
	qualify top_3 <=3
) t1 
left join (

	select region_id, ne_id, bs_name, site_name, sector_name, bs_position, edw_sdate, edw_edate
	--edw_edate - нельзя использовать много дублей, в мусор
		, row_number() over(partition by sector_name order by edw_sdate desc) actual_date_sector 
		, bs_position.st_x() as LON,  bs_position.st_y() as LAT
		, new st_geometry('ST_Point', bs_position.st_x(), bs_position.st_y()) as ST_POINT
		
	from prd2_dic_v.network_element
	where 1=1 
		and region_id = 52
	
		and current_timestamp(0) between edw_sdate and edw_edate
	qualify actual_date_sector = 1
) t2 on t1.sector_name = t2.sector_name

)
with data
primary index (subs_id);
---------------------
select count(*) from uat_ca.vf_rostov_research_12072023
select *  from uat_ca.vf_rostov_research_12072023
-------------------------
-------------------------

-- drop table uat_ca.vf_rostov_research_12072023_hwe
---Step 2(необязательная витрина пропустить)
create multiset table uat_ca.vf_rostov_research_12072023_hwe as(
select
 case
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME),1) IN ('4','7') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-1)||'1'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-2,3) IN ('021','011','081','041') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-3)||'1'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-3,4) IN ('1_3G','4_3G','7_3G') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-4)||'1'
--
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME),1) IN ('5','8') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-1)||'2'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-2,3) IN ('022','012','082','042') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-3)||'2'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-3,4) IN ('2_3G','5_3G','8_3G') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-4)||'2'
--
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME),1) IN ('6','9') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-1)||'3'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-2,3) IN ('023','013','083','043') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-3)||'3'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-3,4) IN ('3_3G','6_3G','9_3G') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-4)||'3'
  else sector_name end as hwe_sector, 
--
 t1.*, 
 t2.report_date, t2.home_sector, t2.subs_id as subs_id_hwe
 from uat_ca.vf_rostov_research_12072023 t1 
left join  prd2_sec_v.hwe t2 on t1.subs_id = t2.subs_id  
   						    and t2.report_date = '2023-03-01') 
with data
primary index (subs_id);


-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
---Step 3 добавление рабочего сектора и сектора максимальной даты
create multiset table uat_ca.vf_rostov_research_12072023_hwe_all as(
select
 case
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME),1) IN ('4','7') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-1)||'1'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-2,3) IN ('021','011','081','041') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-3)||'1'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-3,4) IN ('1_3G','4_3G','7_3G') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-4)||'1'
--
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME),1) IN ('5','8') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-1)||'2'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-2,3) IN ('022','012','082','042') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-3)||'2'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-3,4) IN ('2_3G','5_3G','8_3G') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-4)||'2'
--
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME),1) IN ('6','9') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-1)||'3'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-2,3) IN ('023','013','083','043') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-3)||'3'
  WHEN SUBSTR(SECTOR_NAME,LENGTH(SECTOR_NAME)-3,4) IN ('3_3G','6_3G','9_3G') THEN SUBSTR(SECTOR_NAME, 1, LENGTH(SECTOR_NAME)-4)||'3'
  else sector_name end as hwe_sector, 
--
 t1.*, 
 t2.report_date, t2.home_sector, t2.work_sector, t2.maxdata_sector, t2.subs_id as subs_id_hwe
from uat_ca.vf_rostov_research_12072023 t1 
left join  prd2_sec_v.hwe t2 on t1.subs_id = t2.subs_id  
						    and t2.report_date = '2023-03-01') 
with data
primary index (subs_id);
-------------------------------------------------------------------------------------------------------------------------------------------------
тесты: 

select * from uat_ca.vf_rostov_research_12072023_hwe_all where subs_id = '11514510'
select hwe_sector, subs_id, count(sector_name) from uat_ca.vf_rostov_research_12072023_hwe_all group by 1,2 having count(sector_name)> 1

select top 100 * 
from uat_ca.vf_rostov_research_18052023_hwe_all 
  						    
select bs_position, count(distinct hwe_sector)--, count(distinct subs_id)
from uat_ca.vf_rostov_research_052023_hwe
where hwe_sector = home_sector
group by 1
order by 2 desc
------------------------------------------------------------------------------------------------------------------------------------------------
-- Пивот для Мустафы


select top 100 * from uat_ca.mc_mc_sqm_score_4




select sector_name
	 , rat
	 , sum(bad)
	 , sum(tech_score)
	 , count(subs_id)
 from(
	select sector_name
		 , rat
		 , tech_score
		 , coeff_80
		 , bad
		 , subs_id
		 , row_number() over(partition by subs_id order by coeff_80 desc ) as top_3
	  from uat_ca.mc_mc_sqm_score_4
	qualify top_3 <=3
) t1
group by 1,2 

