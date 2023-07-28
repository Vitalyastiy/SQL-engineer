
diagnostic helpstats on for session;


subs_id             --абонент тестовой группы
linked_subs_id      --абонент контрольной группы

Индексация была в два этапа:
Индексация февраль
    Линейка конструктор     --indexkonstr
    Линейка матрица         --indexmatrix
    Линейка Безлимиты       --indexonlim

!!! Контрольную группу Безлимитов заиндексировали в июне, начиная с июня ее использовать нельзя

Индексация март             --index2wave


select top 100 * from uat_ca.mc_index_d_g;

select
 report_month,
 count(distinct subs_id),
 count(*)
from uat_ca.mc_index_d_g
group by 1
order by 1
;

2022-02-01      688 796
2022-03-01      54 569



select
 gr_type,
 count(distinct subs_id),
 count(*)
from uat_ca.mc_index_d_g
group by 1
order by 1
;

indexkonstr     250 872
indexmatrix     355 957
indexonlim      81 967
index2wave      54 569


--==Витрина с опросами NPS

select top 100 * from uat_ca.v_nps_bu;


