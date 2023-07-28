
diagnostic helpstats on for session;


--==01 Витрина с опросами NPS BU: Монобренды, Тарифы, Дистанционный сервис (Контакт-центр), Голос и СМС, Мобильный интернет

select top 100 * from uat_ca.v_nps_bu;


--==02 Витрина с заявками на портацию, портациями MNP, причины удержания

select top 100 * from uat_ca.v_mnp;


--==03 Витрина с абонентеми активными по flash (политика учета) на последний день каждого месяца

select top 100 * from uat_ca.mc_base_db;


--==04 Витрина с абонентами ушедшими в disconnect

select top 100 * from uat_ca.mc_churn_db;


--==05 Витрины с данными маркетинга

select top 100 * from uat_ca.v_td_fin;               --детальные данные абонентов NPS TD  с 2020-01-01 по 2022-06-01
select top 100 * from tele2_uat.mc_nps_td_217;       --данные абонентов NPS TD с с 2020-03-01 по 2022-06-01 - для скоринга комментариев


--==06 Витрина с данными по превалирующему сектору абонентов за июнь 2022

select top 100 * from uat_ca.v_prev_sector_tr;

