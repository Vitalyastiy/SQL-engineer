


select top 100 * from uat_ca.v_nps_bu;

--�������� ��������� View
show view uat_ca.v_nps_bu;


--���������� branch
select top 100 * from prd2_dic_v.branch;


--������ �������� ������� �� ��������
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
/*��������� �� View*/
 weeknumber_of_year (a.create_date, 'iso') as "week",
 case when extract(month from a.create_date) = 1 then '������'
      when extract(month from a.create_date) = 2 then '�������'
      when extract(month from a.create_date) = 3 then '����'
      when extract(month from a.create_date) = 4 then '������'
      when extract(month from a.create_date) = 5 then '���'
      when extract(month from a.create_date) = 6 then '����'
      when extract(month from a.create_date) = 7 then '����'
      when extract(month from a.create_date) = 8 then '������'
      when extract(month from a.create_date) = 9 then '��������'
      when extract(month from a.create_date) = 10 then '�������'
      when extract(month from a.create_date) = 11 then '������'
      when extract(month from a.create_date) = 12 then '�������' else '' end as "month",
 extract(year from a.create_date) as "year",
--
 case when a.point_name in ('���������� covid') then '����������'
      when a.point_name in ('������ covid') then '������'
      when a.point_name in ('�������-����� covid') then '�������-�����'
      when a.point_name in ('����� � ��� �����') then '����� � ���'
      when a.point_name in ('��������� �������� covid', '��������� �������� �����', '��������� �������� ����� covid') then '��������� ��������'
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
--==��������
 case
--������� ���
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and a.ans_2 in ('������� ���') then '������� ���'
--������
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and a.ans_2 in ('������') then '������_ans_2'

      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and a.ans_2 is null then 'null_ans_2'
--����
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and a.ans_2 in ('����') then a.ans_8
--�� ������\� �����\������������
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and a.ans_2 in ('�� ������\� �����\������������') then a.ans_9
--�� �������� ��������\�� ������, �� �������� ��������\�� ������\� �����
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and a.ans_2 in ('�� �������� ��������\�� ������', '�� �������� ��������\�� ������\� �����') then a.ans_10
--�� �������\�� ����
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and a.ans_2 in ('�� �������\�� ����') then a.ans_11
--����� ������ � �����������
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and a.ans_2 in ('����� ������ � �����������') then a.ans_12
 end as servelat,
--==��������� ��������
 case
--������� ���
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and servelat in ('������� ���') then '������� ���'
--������
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and servelat in ('������') then '������'

      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and servelat in ('������_ans_2') then '������'

      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and servelat is null then '������'

      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and servelat in ('null_ans_2') then '������'

--      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
--           and servelat in ('�������������� ������') then '������'
--��������� ���������
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and servelat in ('������ �������� ������� (���, ���������� ����, ����������)',
                            '������ ���������� ��������� (����, ����, ��������� � �.�.)',
                            '��������, ���� 5 �����',
                            '��������, �� 5 ����� ������������',
                            '������������ �����',
                            '� �����',
                            '�������������� ������'
                            ) then 'Indoor � ������� ���������'
--
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and servelat in ('��� ��������� (���� ������, �����, ��������, � �.�.)',
                            '������ � �������� ���������� ������\�� ����',
                            '������ � �������� ������� (�4, �5 � �.�.)',
                            '������ ������ ������',
                            '����� ������ (�������, �����, �����, �����)',
                            '�� �����'
                           ) then '�� �����/�� �������'
--
      when a.create_date >= date '2021-01-01' and a.point_name in('��������� ��������', '��������� �������� �����', '��������� �������� covid', '��������� �������� ����� covid')
           and servelat in ('����\���',
                            '������� ���'
                           ) then '������� ������'
 end as servelat_gr,
--�������������
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
/*��������� ������ �������� �� View*/
-- seg_1,                              --"2g_only"
-- seg_2,                              --"3g_only"
-- seg_3,                              --"4g>0%"
-- seg_4,                              --"2g_0,1%-5%"
-- seg_5,                              --"2g_5,1%-99,9%"
-- seg_6,                              --"4g_1%-10%"
-- seg_7,                              --"4g>10%"
-- seg_8,                              --"2g_�������"
-- seg_9,                              --"3g_�������"
-- seg_10,                             --"4g_�������"
--
 a.create_date_comm         as "���� � ����� �������",
 a.source_system            as "�������",
 a.pos_id,
 a.call_center              as "���������� ����� ��������",
 a.line_ca_name             as "����� ��",
 a.line_in_ca_name          as "����� �� ��",
 a.comm_cnl                 as "����� ���������",
 a.employee                 as "��������",
 a.employee_call_center     as "�� ���������",
 a.position_name            as "��������� ���������",
 a.employee_group           as "������ ���������",
 a.seg_11                   as "���. ��������",
 a.seg_12                   as "�����������������",
 a.seg_13                   as "��������� � �����������",
 a.seg_14                   as "��������� � ��������",
 a.seg_15                   as "����������",
 a.dis_day_cnt              as "���-�� ���� � �����������",
 a.total_comm_cnt           as "����� ���-�� ���������",
--
 a.invoice,
 a.key_flg,
 --������
 coalesce(case when t7.scor_type = 'Bronze' then 1 else 0 end, -1) as GSB_Bronze,
 coalesce(case when t7.scor_type = 'Eralash' then 1 else 0 end, -1) as Eralash
from uat_ca.mc_nps_bu a
--
left join prd2_dic_v.branch t1 on a.branch_id = t1.branch_id
--left join prd2_dic_v.region t2 on t1.region_id = t2.region_id
--left join prd2_dic_v.macroregion t3 on t2.macroregion_id = t3.macroregion_id
--�������������
left join uat_ca.mc_nps_class_mark_6_new t2 on a.subs_id = t2.subs_id
 and t2.scoring_date = date '2022-06-01'
-- and t2.scoring_date = date '2021-11-21'
 and a.create_date = t2.create_date

--gsb� ������
left join uat_ca.mc_nps_detail_step_6 t7 on a.subs_id = t7.subs_id
 and a.create_date = t7.create_date
 and a.point_name = t7.point_name
--
where 1=1
 and a.point_name not in ('��������� �������� short', '��������� �������� ����� short');



--�������� �������
select top 100 * from uat_ca.mc_nps_bu;


























