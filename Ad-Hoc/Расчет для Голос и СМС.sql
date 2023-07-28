
 
--�������� ��������� �������� ��� ����������

create multiset volatile table voice_msg_servelat, no log as (
select * from uat_ca.mc_nps_bu
where 1=1
and point_name = '����� � ���'
 and create_date >= date '2023-05-01'
 and create_date < date '2023-05-31'
 ) with data
primary index (subs_id)
on commit preserve rows
 ;
 
create multiset volatile table voice_msg_servelat2, no log as (
select * from uat_ca.mc_nps_bu
where 1=1
and point_name = '����� � ���'
 and create_date >= date '2023-05-01'
 and create_date < date '2023-05-31'
 ) with data
primary index (subs_id)
on commit preserve rows
 ;
 
 select count(ans_2) from voice_msg_servelat;
 
select distinct ans_2, count(ans_2) from servelat2
where ans_2 is not null
group by 1;

select distinct servelat_gr, count(servelat_gr) from servelat2 where servelat_gr is not in ('n_a') group by 1;
 
 select count(servelat_gr) from servelat2
 where servelat_gr is not in ('n_a');

 select count(ans_3) from voice_msg_servelat where ans_3 is not in ('������', '������� ���') and ans_3 is not null;
 
 select top 100 * from voice_msg_servelat;
 
 select * from voice_msg_servelat where nps = 1;
 
drop table voice_msg_servelat;
drop table servelat1;
drop table servelat2;
 
 --Q1 mark_5
/*�������, ��� �� ����������� Tele2! 
�������� �������� ��������� ����� �������, ����������, ���������� ������������� Tele2 �� 1 �� 10, ��� 1 - ����� �� ������������, 10 - ����� ������������. 
��������� ����� � �����.*/
 
 --Q2 mark_3
/*����������� �� �� �������� �� ��������? ���� ��, �� �����?
1.������� ���
2.���� ����������
3.������ ����������/������/���/������
4.����� ������
5.�� ���� �����������
6.������ */
 
 --Q3 mark_2, mark_6
 /*mark_2
 ��� ���� ����� �� ����������� �������� �� ��������? ��������� ���� �������� ���������� �����.
1.���� 
2.�� ������\� �����\� ������������
3.� ������ (�� ������)
4.�� �������\�� ���� 
5.� ������ ������ � �����������
 
  mark_6
  ����������, ��������, � ������ ������ ���������� �� �����������?
*/
--Q4 mark_8, mark_9, mark_10, mark_11, mark_12
/*
 mark_8
 ������� ����� ����� �����, ��� ���������� ��������:
1.������� ��� � ������
2.������� ��� �� �������
3.��������, �� 5 ����� ������������
4.��������, ���� 5 �����

 mark_9
������� ����� ����� �����, ��� ���������� ��������:
1.������������ ����� (���, �����, �������, ���������, ��������, �������� � �.�.)
2.�������������� ������ (������, ����.���� � �.�.)
3.�� ����� (�����, �������, � ����� � �.�.)
4.������

 mark_10
 ������� ����� ����� �����, ��� ���������� ��������:
1.������ ������ ������
2.������ � �������� ���������� ������\�� ����
3.������ � �������� ������� (�4, �5 � �.�.)
4.������

 mark_11
 ������� ����� ����� �����, ��� ���������� ��������:
1.����\���
2.������� ��� � ������
3.������� ��� �� �������
4.����� ������ (�������, �����, �����, �����)
 
 mark_12
 ������� ����� ����� �����, ��� ���������� ��������:
1.������ ���������� ��������� (����, ����, ��������� � �.�.)
2.������ �������� ������� (���, ���������� ����, ����������)
3.��� ��������� (���� ������, �����, ��������, � �.�.)
4.������
*/
 
--Q5 mark_7
/*����� ������������, ���� �� �������� ������ �����, ��� ��������� ��������.*/

/* ��������� ������ ��������� � ����� � ��������� ���������. ��� ���� �� ���3, ����� ���2 � ����� 8-12, 
������ ��� ������ �� ������� ��(��� �������� ������ ����� �����������, ��� �� ������������ � fine, �� �� ������)
� �������� �� ����� - ��� ����� ������ ����(�������� ����� �� �� ��� �������� �����������!!!)*/
 
 --==����
 --==�� ������
 --==�� �������� ��������
 --==�� �������
 --==����� ������
 

 
 
 create multiset volatile table servelat1, no log as (
select 
create_date,
subs_id,
ans_2,
case when ans_2 = '������� ���' then 1
	 when ans_2 = '������' then 99
--���-------------------------------
	 when ans_2 = '����' and ans_8 is null then 10
	 when ans_2 = '����' and ans_8 = '������' then 11
	 when ans_2 = '����' and (ans_8 is not null or ans_8 <> '������') then 1
--�� ������-------------------------
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 is null then 20
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 = '������' then 21
	 when ans_2 = '�� ������\� �����\� ������������' and (ans_9 is not null or ans_9 <> '������') then 1
--� ������-----------------------
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����') and ans_10 is null then 30
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����') and ans_10 = '������' then 31
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����') and (ans_10 is not null or ans_10 <> '������') then 1
--�� �������---------------------	 
	 when ans_2 = '�� �������\�� ����' and ans_11 is null then 40
	 when ans_2 = '�� �������\�� ����' and ans_11 = '������' then 41
	 when ans_2 = '�� �������\�� ����' and (ans_11 is not null or ans_11 <> '������') then 1
--����� ������-------------------
	 when ans_2 = '� ������ ������ � �����������' and ans_12 is null then 50
	 when ans_2 = '� ������ ������ � �����������' and ans_12 = '������' then 51
	 when ans_2 = '� ������ ������ � �����������' and (ans_12 is not null or ans_12 <> '������') then 1					
else -1 end as servelat_flg,
ans_3,
ans_8,
ans_9,
ans_10,
ans_11,
ans_12
from voice_msg_servelat
 ) with data
primary index (subs_id)
on commit preserve rows
;
 
select count(servelat_gr) from servelat2 where servelat_gr not in ('n_a');
--�������� ans_3
create multiset volatile table servelat2, no log as (
select 
create_date,
 region,
 subs_id,
 point_name,
 ltr,
 nps,
 mark_6,
 ans_2,
case when ans_3 in ('������� ���') then '������� ���'
     when ans_3 in ('������') then '������'
     when ans_2 in ('������') then '������'
     when ans_3 is not null and ans_2 is null then '�������_��_��������'
--���----------------------------	
	 when ans_2 = '����' and ans_8 is null then '��_��������_����'
	 when ans_2 = '����' and ans_8 = '������' then '����_������'
	 when ans_2 = '����' and ans_8 in ('������� ��� � ������', '������� ��� �� �������', '��������, �� 5 ����� ������������', '��������, ���� 5 �����') then ans_8
--�� ������-------------------------
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 = '������' then '��_������_������'
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 is null then '��_��������_��_������'
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 in ('������������ �����', 
	 '�������������� ������', '�� �����') then ans_9
--� ������--------------------------
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����', '�� �������� ��������\�� ������', '�� �������� ��������\�� ������\� �����') and ans_10 = '������' then '�_������_������'
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����', '�� �������� ��������\�� ������', '�� �������� ��������\�� ������\� �����') and ans_10 is null then '��_��������_�_������'
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����', '�� �������� ��������\�� ������', '�� �������� ��������\�� ������\� �����') 
	  and ans_10 in ('������ ������ ������', '������ � �������� ���������� ������\�� ����', '������ � �������� ������� (�4, �5 � �.�.)', '� �����') then ans_10
--�� �������------------------------
	 when ans_2 = '�� �������\�� ����' and ans_11 is null then '��_��������_��_�������'
	 when ans_2 = '�� �������\�� ����' and ans_11 = '������' then '��_��������_������'
	 when ans_2 = '�� �������\�� ����' and ans_11 in ('����\���', '������� ��� � ������', '������� ��� �� �������', '����� ������ (�������, �����, �����, �����)') then ans_11
--����� ������----------------------
	 when ans_2 in ('� ������ ������ � �����������', '����� ������ � �����������') and ans_12 = '������' then '�����_������_������'
	 when ans_2 in ('� ������ ������ � �����������', '����� ������ � �����������') and ans_12 is null then '��_��������_�����_������'
	 when ans_2 in ('� ������ ������ � �����������', '����� ������ � �����������') and ans_12 in ('������ ���������� ��������� (����, ����, ��������� � �.�.)', 
	 '������ �������� ������� (���, ���������� ����, ����������)', '��� ��������� (���� ������, �����, ��������, � �.�.)') then ans_12
else 'n_a' end as servelat_gr,
ans_8,
ans_9,
ans_10,
ans_11,
ans_12
from voice_msg_servelat
 ) with data
primary index (subs_id)
on commit preserve rows
;

select ans_3, ans_2 from voice_msg_servelat where ans_3 is not null;

select * from servelat2;

select ans_2, count(ans_2) from voice_msg_servelat group by 1;

select count(ans_3) from voice_msg_servelat where ans_3 is not null;

select count(servelat_gr) from servelat2 where servelat_gr is not in ('n_a'); 

drop table servelat2;

������� ����� ����� �����, ��� ���������� ��������:
1.������ ���������� ��������� (����, ����, ��������� � �.�.)
2.������ �������� ������� (���, ���������� ����, ����������)
3.��� ��������� (���� ������, �����, ��������, � �.�.)
4.������

������� ����� ����� �����, ��� ���������� ��������:
1.����\���
2.������� ��� � ������
3.������� ��� �� �������
4.����� ������ (�������, �����, �����, �����)

������� ����� ����� �����, ��� ���������� ��������:
1.� �����
2.������ ������ ������
3.������ � �������� ���������� ������\�� ����
4.������ � �������� ������� (�4, �5 � �.�.)
5.������

������� ����� ����� �����, ��� ���������� ��������:
1.������������ ����� (���, �����, �������, ���������, ��������, �������� � �.�.)
2.�������������� ������ (������, ����.���� � �.�.)
3.�� ����� (�����, �������, � ����� � �.�.)
4.������

������� ����� ����� �����, ��� ���������� ��������:
1.������� ��� � ������
2.������� ��� �� �������
3.��������, �� 5 ����� ������������
4.��������, ���� 5 �����

 drop table servelat1;
 
 
 select * from servelat1;
 
--������ �����-----------------------------------------��������
case when ans_2 = '������� ���' then 1
	 when ans_2 = '������' then 99
--���-------------------------------
	 when ans_2 = '����' and ans_8 is null then 10
	 when ans_2 = '����' and ans_8 = '������' then 11
	 when ans_2 = '����' and (ans_8 is not null or ans_8 <> '������') then 1
--�� ������-------------------------
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 is null then 20
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 = '������' then 21
	 when ans_2 = '�� ������\� �����\� ������������' and (ans_9 is not null or ans_9 <> '������') then 1
--� ������-----------------------
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����') and ans_10 is null then 30
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����') and ans_10 = '������' then 31
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����') and (ans_10 is not null or ans_10 <> '������') then 1
--�� �������---------------------	 
	 when ans_2 = '�� �������\�� ����' and ans_11 is null then 40
	 when ans_2 = '�� �������\�� ����' and ans_11 = '������' then 41
	 when ans_2 = '�� �������\�� ����' and (ans_11 is not null or ans_11 <> '������') then 1
--����� ������-------------------
	 when ans_2 = '� ������ ������ � �����������' and ans_12 is null then 50
	 when ans_2 = '� ������ ������ � �����������' and ans_12 = '������' then 51
	 when ans_2 = '� ������ ������ � �����������' and (ans_12 is not null or ans_12 <> '������') then 1					
else -1 end as servelat_flg,

	 
	 
	 
--������ �����--------------------------------------��������
case 
--���----------------------------	
	 when ans_2 = '����' and ans_8 = null then '��_��������_����'
	 when ans_2 = '����' and ans_8 in ('������� ��� � ������', '������� ��� �� �������', '�� �������\�� ����', '��������, ���� 5 �����') then ans_8
--�� ������-------------------------
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 = '������' then '��_������_������'
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 is null then '��_��������_��_������'
	 when ans_2 = '�� ������\� �����\� ������������' and ans_9 in ('������������ ����� (���, �����, �������, ���������, ��������, �������� � �.�.)', 
	 '�������������� ������ (������, ����.���� � �.�.)', '�� ����� (�����, �������, � ����� � �.�.)') then ans_9
--� ������--------------------------
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����') and ans_10 = '������' then '�_������_������'
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����') and ans_10 is null then '��_��������_�_������'
	 when ans_2 in ('� ������ (�� ������)', '� ������ (�� ������)\� �����') 
	  and ans_10 �� ('������ ������ ������', '������ � �������� ���������� ������\�� ����', '������ � �������� ������� (�4, �5 � �.�.)', '� �����') then ans_10
--�� �������------------------------
	 when ans_2 = '�� �������\�� ����' and ans_11 is null then '��_��������_��_�������'
	 when ans_2 = '�� �������\�� ����' and ans_11 in ('����\���', '������� ��� � ������', '������� ��� �� �������', '����� ������ (�������, �����, �����, �����)') then ans_11
--����� ������----------------------
	 when ans_2 = '� ������ ������ � �����������' and ans_12 = '������' then '�����_������_������'
	 when ans_2 = '� ������ ������ � �����������' and ans_12 is null then '��_��������_�����_������'
	 when ans_2 = '� ������ ������ � �����������' 
	  and ans_12 in ('������ ���������� ��������� (����, ����, ��������� � �.�.)', 
	  '������ �������� ������� (���, ���������� ����, ����������)', '��� ��������� (���� ������, �����, ��������, � �.�.)') then ans_12
end as servelat
	 

	 
	 
	 
	 
	 
	 
ans_2
 1.���� 
2.�� ������\� �����\� ������������
3.� ������ (�� ������)
4.�� �������\�� ���� 
5.� ������ ������ � �����������	 

  mark_12
 ������� ����� ����� �����, ��� ���������� ��������:
1.������ ���������� ��������� (����, ����, ��������� � �.�.)
2.������ �������� ������� (���, ���������� ����, ����������)
3.��� ��������� (���� ������, �����, ��������, � �.�.)
4.������
	 
mark_11
 ������� ����� ����� �����, ��� ���������� ��������:
1.����\���
2.������� ��� � ������
3.������� ��� �� �������
4.����� ������ (�������, �����, �����, �����) 
	 
 mark_10
 ������� ����� ����� �����, ��� ���������� ��������:
1.������ ������ ������
2.������ � �������� ���������� ������\�� ����
3.������ � �������� ������� (�4, �5 � �.�.)
4.������
5.� �����	 
	  
 ans_8
 1.������� ��� � ������
2.������� ��� �� �������
3.��������, �� 5 ����� ������������
4.��������, ���� 5 �����
 
 mark_9
������� ����� ����� �����, ��� ���������� ��������:
1.������������ ����� (���, �����, �������, ���������, ��������, �������� � �.�.)
2.�������������� ������ (������, ����.���� � �.�.)
3.�� ����� (�����, �������, � ����� � �.�.)
4.������



 
 
 ans_3
 1.������� ���
2.���� ����������
3.������ ����������/������/���/������
4.����� ������
5.�� ���� �����������
6.������
 
 
 
