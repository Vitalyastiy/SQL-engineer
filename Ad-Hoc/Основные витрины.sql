
diagnostic helpstats on for session;


--==01 ������� � �������� NPS BU: ����������, ������, ������������� ������ (�������-�����), ����� � ���, ��������� ��������

select top 100 * from uat_ca.v_nps_bu;


--==02 ������� � �������� �� ��������, ���������� MNP, ������� ���������

select top 100 * from uat_ca.v_mnp;


--==03 ������� � ���������� ��������� �� flash (�������� �����) �� ��������� ���� ������� ������

select top 100 * from uat_ca.mc_base_db;


--==04 ������� � ���������� �������� � disconnect

select top 100 * from uat_ca.mc_churn_db;


--==05 ������� � ������� ����������

select top 100 * from uat_ca.v_td_fin;               --��������� ������ ��������� NPS TD  � 2020-01-01 �� 2022-06-01
select top 100 * from tele2_uat.mc_nps_td_217;       --������ ��������� NPS TD � � 2020-03-01 �� 2022-06-01 - ��� �������� ������������


--==06 ������� � ������� �� �������������� ������� ��������� �� ���� 2022

select top 100 * from uat_ca.v_prev_sector_tr;

