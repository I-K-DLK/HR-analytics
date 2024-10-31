/*
 1) Выгрузить число созданных вакансий (в динамике по месяцам), опубликованных по городам России, 
 в названии которых встречается слово «водитель», предлагающих «Гибкий график» работы, за 2020-2021 годы. 
 Важно, чтобы вакансии на момент сбора данных не были удаленными / заблокированными.
 */
  

select a.area_name as "Город",  to_char(cast (v.creation_time as timestamp), 'Month') as "Месяц" , count(v.vacancy_id) as "Число"
 from candidates.vacancy v 
	inner join candidates.area a using(area_id)
where date_part('year',  cast (v.creation_time as timestamp)) in (2020,2021) 
	and v.name ~ '(Водитель| водитель|^водитель)' 
		and v.work_schedule = 'Гибкий график' 
			and a.country_name = 'Россия'
				and v.archived = 'False'
					and v.disabled = 'False'			
group by  to_char(cast (v.creation_time as timestamp), 'Month'), a.area_name
order by Город, Месяц;
 
/*
Город          |Месяц    |Число|
---------------+---------+-----+
Москва         |August   |    1|
Москва         |December |    1|
Москва         |February |    1|
Москва         |January  |    3|
Москва         |May      |    1|
Санкт-Петербург|February |    3|
Санкт-Петербург|June     |    1|
Санкт-Петербург|March    |    1|
*/


/*
2) Выяснить, в каких регионах РФ (85 штук) выше всего доля вакансий, предлагающих удаленную работу. 
Вакансии должны быть не заархивированными, не заблокированными и не удаленными, 
и быть созданными в 2021-2022 годах.
*/

-- Можно сделать  это таким образом, сверху списка будут требуемые регионы: 

with ca as (select a.region_name as "Регион", sum(case when v.work_schedule = 'Удаленная работа' then 1 else 0 end) as remote_jobs,	
	sum(1) as all_Jobs
from candidates.area a 
	left join candidates.vacancy v using(area_id)
where date_part('year',  cast (v.creation_time as timestamp)) in (2021,2022) 
		--and v.work_schedule = 'Удаленная работа' 
			and a.country_name = 'Россия'
				and v.archived = 'False'
					and v.disabled = 'False'			
group by Регион)
 
select ca.Регион, round(ca.remote_jobs::decimal*100/ca.all_jobs,0) as "Доля, %" 
from ca
order by "Доля, %" desc;

/*
Регион               |Доля, %|
---------------------+-------+
Новосибирская область|     67|
Москва               |     20|
Санкт-Петербург      |     14|
*/

-- Но так как список из 85 регионов будет длинный, то можно оставить только топовые: 
 
with ca as (select a.region_name as "Регион", sum(case when v.work_schedule = 'Удаленная работа' then 1 else 0 end) as remote_jobs, 
	sum(1) as all_Jobs
	
from candidates.area a 
	left join candidates.vacancy v using(area_id)
where date_part('year',  cast (v.creation_time as timestamp)) in (2021,2022) 
		--and v.work_schedule = 'Удаленная работа' 
			and a.country_name = 'Россия'
				and v.archived = 'False'
					and v.disabled = 'False'			
group by Регион)

select ca.Регион, round(ca.remote_jobs::decimal*100/ca.all_jobs,0) as "Доля, %" 
from ca
where round(ca.remote_jobs::decimal*100/ca.all_jobs,0) = (select max(round(ca.remote_jobs::decimal*100/ca.all_jobs,0)) from ca);


/*
Регион               |Доля, %|
---------------------+-------+
Новосибирская область|     67|
*/
 

/*
3) Подсчитать «вилку» (10,25,50,75 и 90 процентиль) ожидаемых зарплат (в рублях) из московских и питерских резюме, 
имеющих роль «разработчик» (id роли — 91), по городам и возрастным группам (группы сделать как в примере таблицы ниже, 
не учитывать резюме без указания даты рождения — такие тоже есть). Возрастные группы считать на дату составления запроса. 
Резюме должно быть не удалено и иметь статус «завершено». 
Дополнительно выяснить (при помощи того же запроса) долю резюме по каждой группе, в которых указана ожидаемая зарплата.
*/

with salaries as(
select r.resume_id,  r.compensation / c.rate as salary, a.area_name, 
	substring(age(r.birth_day)::text,1,position(' ' in age(r.birth_day)::text))::int as age
from candidates.resume r 
	inner join candidates.area a 
		using(area_id) 
	inner join candidates.currency c 
		on r.currency = c.code
where a.area_name in('Москва','Санкт-Петербург') 
	and r.disabled = 'False' 
		and r.is_finished = 1 
			and 91 = any (r.role_id_list ) 
				and age(r.birth_day) is not null
)
 
select
	s.area_name as "Город", round(sum(case when s.salary is not NULL then 1 else 0 end)::decimal*100/count(*),2) as "Доля",
	case when s.age <= 17 then '17 лет и младше' 
		 when s.age between 18 and 24 then '18–24' 
		 when s.age between 25 and 34 then '25–34' 
		 when s.age between 35 and 44 then '35–44'
		 when s.age between 45 and 54 then '45–54'
		 else '55 и старше' end as "Возраст",
	
	round(percentile_cont(0.1) within group (order by s.salary)::decimal,2) as  "10 процентиль",
	round(percentile_cont(0.25) within group (order by s.salary)::decimal,2) as  "25 процентиль",
	round(percentile_cont(0.50) within group (order by s.salary)::decimal,2) as  "50 процентиль",
	round(percentile_cont(0.75) within group (order by s.salary)::decimal,2) as  "75 процентиль",
	round(percentile_cont(0.90) within group (order by s.salary)::decimal,2) as  "90 процентиль"
	
from salaries s
group by Город, Возраст;

/*
Город          |Доля  |Возраст    |10 процентиль|25 процентиль|50 процентиль|75 процентиль|90 процентиль|
---------------+------+-----------+-------------+-------------+-------------+-------------+-------------+
Москва         | 50.00|18–24      |     76487.69|     76487.69|     76487.69|     76487.69|     76487.69|
Москва         |100.00|25–34      |     40538.47|     43980.42|     49717.00|     55453.57|     58895.52|
Москва         |100.00|55 и старше|    178252.60|    186787.68|    201012.81|    215237.93|    223773.01|
Санкт-Петербург| 50.00|18–24      |     61190.15|     61190.15|     61190.15|     61190.15|     61190.15|
Санкт-Петербург|100.00|25–34      |     30595.07|     30595.07|     30595.07|     30595.07|     30595.07|
Санкт-Петербург|100.00|55 и старше|     39773.60|     42068.23|     45892.61|     49717.00|     52011.63|
*/
 