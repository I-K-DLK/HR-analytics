
 
-- создадим новую схему

create schema candidates; 

-- создадим таблицы currency, area, resume и vacancy
 
-- 1) currency

drop table if exists candidates.currency;
 
create table candidates.currency(

code text,
rate decimal
);
 
-- 2) area

drop table if exists candidates.area;
 
create table candidates.area(

area_id	int primary key,
area_name text,
region_name text,
country_name text
);
 
-- 3) resume

drop table if exists candidates.resume;
 
create table candidates.resume(

resume_id int primary key,
disabled boolean,
is_finished	int,
area_id	int,
compensation bigint,
currency text,
position text,
birth_day timestamp,
role_id_list integer ARRAY
);
 
-- 4) vacancy
 
drop table if exists candidates.vacancy;
 
create table candidates.vacancy(
vacancy_id int primary key,
name text,
work_schedule text,
disabled boolean,
area_id	int,
creation_time text,
archived boolean
);

-- Загрузим данные в тaблицы через терминал


/*
\copy candidates.area from 'C:/Users/dalyuki.SAN-I-E14-253/Desktop/BI analyst/T 1/Tables/area.csv' delimiter ',' CSV header ENCODING 'UTF8';

\copy candidates.currency from 'C:/Users/dalyuki.SAN-I-E14-253/Desktop/BI analyst/T 1/Tables/currency.csv' delimiter ',' CSV header ENCODING 'UTF8';

\copy candidates.resume (resume_id,	disabled, is_finished,	area_id, compensation, currency, birth_day, role_id_list) from 'C:/Users/dalyuki.SAN-I-E14-253/Desktop/BI analyst/T 1/Tables/resume.csv' delimiter ',' CSV header ENCODING 'UTF8';

\copy candidates.vacancy from 'C:/Users/dalyuki.SAN-I-E14-253/Desktop/BI analyst/T 1/Tables/vacancy.csv' delimiter ',' CSV header ENCODING 'UTF8';
*/


-- Проверим правильность загрузки данных


select * from candidates.vacancy limit 10;

/*
vacancy_id|name              |work_schedule   |disabled|area_id|creation_time   |archived|
----------+------------------+----------------+--------+-------+----------------+--------+
         1|Курьер            |Гибкий график   |true    |      1|03/01/2020 14:02|false   |
         2|Аналитик          |Полный день     |false   |      2|10/02/2021 13:13|true    |
         3|Маркетолог        |Удаленная работа|true    |     13|01/02/2022 11:25|false   |
         4|Водитель          |Гибкий график   |false   |      1|03/01/2020 14:02|false   |
         5|Руководитель      |Гибкий график   |false   |      2|10/02/2021 13:13|false   |
         6|Трезвый водитель  |Гибкий график   |false   |      1|03/01/2020 14:02|false   |
         7|Водитель такси    |Гибкий график   |false   |      2|10/02/2021 13:13|false   |
         8|Самогруза водитель|Гибкий график   |false   |      1|03/01/2020 14:02|false   |
         9|Водитель          |Гибкий график   |false   |      2|10/02/2021 13:13|false   |
        10|Аналитик          |Удаленная работа|false   |      3|10/02/2021 13:13|false   |
*/

select * from candidates.area limit 10;
/*
area_id|area_name      |region_name            |country_name|
-------+---------------+-----------------------+------------+
      1|Москва         |Москва                 |Россия      |
      2|Санкт-Петербург|Санкт-Петербург        |Россия      |
      3|Новосибирск    |Новосибирская область  |Россия      |
      4|Омск           |Омская область         |Россия      |
      5|Калининград    |Калининградская область|Россия      |
      6|Бишкек         |Киргизстан             |Киргизстан  |
      7|Белград        |Сербия                 |Сербия      |
*/

select * from candidates.resume limit 10;

/*
resume_id|disabled|is_finished|area_id|compensation|currency|position|birth_day              |role_id_list|
---------+--------+-----------+-------+------------+--------+--------+-----------------------+------------+
        1|true    |          1|      1|         300|EUR     |        |1975-10-13 00:00:00.000|{1,13,41}   |
        2|false   |          2|      2|      100000|RUR     |        |1993-05-21 00:00:00.000|{2,14}      |
        3|true    |          3|      4|        1500|USD     |        |1987-12-12 00:00:00.000|{91}        |
        4|true    |          3|      1|        1500|USD     |        |1997-12-12 00:00:00.000|{91}        |
        5|true    |          3|      2|        2000|USD     |        |1981-12-12 00:00:00.000|{91}        |
        6|true    |          3|      1|        1500|USD     |        |1989-12-12 00:00:00.000|{91}        |
        7|true    |          1|      0|        1000|USD     |        |1976-12-12 00:00:00.000|{91}        |
        8|false   |          1|      1|         500|USD     |        |1995-12-12 00:00:00.000|{91}        |
        9|false   |          1|      2|         400|USD     |        |1998-12-12 00:00:00.000|{91}        |
       10|false   |          1|      1|         800|USD     |        |1992-12-12 00:00:00.000|{91}        |
*/
 
select * from candidates.currency;
 
/*
code|rate    |
----+--------+
RUR |       1|
USD |0.013074|
EUR | 0.01159|
 */

