
diagnostic helpstats on for session;

--=================================================================================================

/*
show view prd2_dds_v.segmentation_arpu;
show table prd2_dds.segmentation_arpu;
PRIMARY INDEX ( SUBS_ID )
PARTITION BY RANGE_N(REPORT_DATE  BETWEEN DATE '2015-11-01' AND DATE '2023-04-30' EACH INTERVAL '1' MONTH );
*/

--=================================================================================================


create multiset volatile table step_1 ,no log (
 create_date date format 'yy/mm/dd',
 subs_id decimal(12,0),
 point_name varchar(50) character set unicode not casespecific)
primary index (subs_id)
on commit preserve rows;

create multiset volatile table step_1_1 ,no log (
 create_date date format 'yy/mm/dd',
 subs_id decimal(18,0),
 point_name varchar(50) character set unicode not casespecific,
 arpu_region_id decimal(2,0),
 arpu_segment varchar(20) character set unicode casespecific,
 arpu_value decimal(18,6))
primary index ( subs_id )
on commit preserve rows;


--==������ NPS ������ �� 1 ����
insert into step_1
select
 create_date,
 subs_id,
 point_name
from uat_ca.mc_nps_detail_metric
where 1=1
 and create_date >= date '2022-08-16'
 and create_date < date '2022-08-17'
;


--==���� ����������
COLLECT STATISTICS
 COLUMN (SUBS_ID)
ON step_1;


--==���������� ������� �� �������� �������� � ��� �������� ���������� �� 12 �������
insert into step_1_1
select
 a.create_date,
 a.subs_id,
 a.point_name,
--
 b.branched_segment_id as arpu_region_id,           --id ��������
 t1.subscription_segment_name as arpu_segment,      --��� ��������
 b.avg_charge as arpu_value                         --������� ����������
from step_1 a
--������ � ������� ���������� ����������, ������� ���������� ������������ ���� � �������
left join (
select subs_id, branched_segment_id, avg_charge from prd2_dds_v.segmentation_arpu
where 1=1
 and report_date = (select max(cast(report_date as date)) from prd2_dds_v.segmentation_arpu)
qualify 1 = row_number() over (partition by subs_id order by branched_segment_id desc)
) b on a.subs_id = b.subs_id
--���������� ��� id ��������
left join prd2_dic_v.subscription_segment as t1 on b.branched_segment_id = t1.subscription_segment_id
;


select top 100 * from step_1_1;
select arpu_segment, count(*) from step_1_1 group by 1;


--==��������� ������
select
 create_date,
 subs_id,
 point_name,
--
 case when arpu_segment is null then 'n/a'
      when arpu_segment = '-' then 'n/a'
      when arpu_segment = 'New B2B' then 'New'
      when arpu_segment = 'Low B2B' then 'Low'
      when arpu_segment = 'Medium B2B' then 'Medium'
      when arpu_segment = 'High B2B' then 'High'
      when arpu_segment = 'New B2C' then 'New'
      when arpu_segment = 'Low B2C' then 'Low'
      when arpu_segment = 'Medium B2C' then 'Medium'
      when arpu_segment = 'High B2C' then 'High'
      else arpu_segment end as arpu_segment,
 arpu_value
from step_1_1
;



