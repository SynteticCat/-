--1. Инструкция SELECT, использующая предикат сравнения.

select job_title, company, city from vacancies
where city = 'Москва'


--2. Инструкция SELECT, использующая предикат BETWEEN.

select job_title, company, city, salary from vacancies
where salary between 50000 and 100000

--3. Инструкция SELECT, использующая предикат LIKE.

select * from vacancies
where company like 'ООО%'

--4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом. 

select * from vacancies
where company in 
(select company_name from companies
where income > 1000000)

--5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.

select * from vacancies
where exists 
(select * from contracts
where contracts.vacancy_id = vacancies.id)

--6. Инструкция SELECT, использующая предикат сравнения с квантором.

select * from vacancies
where salary > ALL
(select salary from vacancies
where city = 'Москва')

--7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.

select job_title, count(job_title) from vacancies
group by job_title
order by count(job_title)

--8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.

select * from vacancies 
where salary = (select max(salary) from vacancies)

--9. Инструкция SELECT, использующая простое выражение CASE.

select job_title, company,
case city
when 'Москва' then 'Moscow'
else ''
end city
from vacancies

--10. Инструкция SELECT, использующая поисковое выражение CASE.

select job_title, company,
case 
when city = 'Москва' then 'Moscow'
else ''
end city
from vacancies

--11. Создание новой временной локальной таблицы из результирующего набора
--данных инструкции SELECT.

select *
into moscow_vacancies from vacancies
where city = 'Москва';

select * from moscow_vacancies

--12. Инструкция SELECT, использующая вложенные коррелированные подзапросы 
--в качестве производных таблиц в предложении FROM.

select * from (select job_title, company, 
(select income from companies
where vacancies.company = companies.company_name) as company_income
from vacancies) as company_prize
where company_income > 1000000 

--13. Инструкция SELECT, использующая вложенные подзапросы с уровнем
--вложенности 3.

select name, job_title, company, agreed_salary
from employers
	join (select * from contracts
		 join (select * from vacancies
			  where company in (select company_name from companies
							  where company like 'ООО%')
			  ) as top_company
on contracts.vacancy_id = top_company.id) as employer_vacancy
on employers.id = employer_vacancy.employer_id

--14. Инструкция SELECT, консолидирующая данные с помощью предложения
--GROUP BY, но без предложения HAVING.

select company_name, founded, round(avg(income)) as avg_income from companies
join vacancies on
vacancies.company = companies.company_name
where city = 'Москва'
group by company_name, city

--15. Инструкция SELECT, консолидирующая данные с помощью предложения
--GROUP BY и предложения HAVING.

select company, count(company) from vacancies 
group by company
having count(company) > 4

--16.Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
--строки значений.

insert into companies
values ('ООО Фирма', 2020, 1000000000);

select * from companies

--17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
--результирующего набора данных вложенного подзапроса.

insert into companies
values ('ООО max income', 2020, (select max(income) from companies)),
('ООО Супер Фирма', 2020, 10000000);

select * from companies

--18. Простая инструкция UPDATE.

update companies
set founded = 2019
where company_name = 'ООО Фирма';

select * from companies

--19. Инструкция UPDATE со скалярным подзапросом в предложении SET.

update companies
set founded = (select max(founded) from companies)
where company_name = 'ООО Фирма';

select * from companies

--20. Простая инструкция DELETE.

delete from companies
where company_name = 'ООО max income';

select * from companies

--21. Инструкция DELETE с вложенным коррелированным подзапросом в
--предложении WHERE.

delete from contracts 
where vacancy_id in (
select job_title, cs.player_id from contracts as cs
join vacancies as c1
on cs.vacancy_id = c1.id
where salary > 100000)

--22. Инструкция SELECT, использующая простое обобщенное табличное
--выражение

WITH CTE 
AS
(SELECT * FROM vacancies)

SELECT * FROM CTE

--23. Инструкция SELECT, использующая рекурсивное обобщенное табличное
--выражение.

CREATE TABLE vacancies_substitute
(
	id bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 ),
	job_title varchar(32) NOT NULL,
	city varchar(30) NOT NULL,
	substitute_for bigint NULL
);

INSERT INTO vacancies_substitute (job_title, city, substitute_for)
VALUES ('President', 'Moscow', NULL);

INSERT INTO vacancies_substitute (job_title, city, substitute_for)
VALUES ('Engeneer', 'Moscow', 1);

INSERT INTO vacancies_substitute (job_title, city, substitute_for)
VALUES ('Umnik', 'St. Petersburg', 1);

INSERT INTO vacancies_substitute (job_title, city, substitute_for)
VALUES ('Glovar', 'Kazan', 1);

INSERT INTO vacancies_substitute (job_title, city, substitute_for)
VALUES ('Captain', 'St. Petersburg', 2);

INSERT INTO vacancies_substitute (job_title, city, substitute_for)
VALUES ('Programmist', 'Moscow', 3);

INSERT INTO vacancies_substitute (job_title, city, substitute_for)
VALUES ('Footboler', 'Moscow', 6);

with recursive recCTE(id, job_title, city, substite_for, rotation_level)
as
(
select id, job_title, city, substitute_for, 0 as rotation_level
from vacancies_substitute where substitute_for is null
union all
select vs.id, vs.job_title, vs.city, vs.substitute_for, rotation_level + 1
from vacancies_substitute as vs join recCTE as rc on vs.substitute_for = rc.id
)

select * from recCTE order by rotation_level

--24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()

select job_title, city, 
min(salary) over(partition by city) as "min",
max(salary) over(partition by city) as "max",
round(avg(salary) over(partition by city)) as "avg"
from vacancies

--25. Оконные функции для устранения дублей

CREATE TABLE overlapping
(
	id bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 ),
	job_title varchar(32) NOT NULL,
	city varchar(30) NOT NULL,
	salary varchar(30) NOT NULL
);

INSERT INTO overlapping (job_title, city, salary)
VALUES ('Programmist', 'Moscow', 500000),
('Glavar', 'St.Petersburg', 200000),
('Glavar', 'St.Petersburg', 200000),
('Engeneer', 'Moscow', 300000);

with cte
as
(select id, job_title, city, salary,
row_number() over(partition BY job_title, city, salary) AS row_number
FROM overlapping)
 
delete from overlapping
where id in (select id from cte
where row_number > 1)

/*
Дополнительное задание на дополнительные баллы
Создать таблицы:
• Table1{id: integer, var1: string, valid_from_dttm: date, valid_to_dttm: date}
• Table2{id: integer, var2: string, valid_from_dttm: date, valid_to_dttm: date}
Версионность в таблицах непрерывная, разрывов нет (если valid_to_dttm = '2018-09-05', то
для следующей строки соответсвующего ID valid_from_dttm = '2018-09-06', т.е. на день
больше). Для каждого ID дата начала версионности и дата конца версионности в Table1 и
Table2 совпадают.
Выполнить версионное соединение двух талиц по полю id.
*/

CREATE TABLE first(
  id INTEGER,
  var1 CHAR,
  from_dttm DATE,
  to_dttm DATE
);

CREATE TABLE second(
  id INTEGER,
  var2 CHAR,
  from_dttm DATE,
  to_dttm DATE
);

INSERT INTO first (id, var1, from_dttm, to_dttm) 
VALUES(1, 'A', '2018-09-01', '2018-09-15');
INSERT INTO first (id, var1, from_dttm, to_dttm) 
VALUES(1, 'B', '2018-09-16', '5999-12-31');
INSERT INTO second (id, var2, from_dttm, to_dttm) 
VALUES(1, 'A', '2018-09-01', '2018-09-14');
INSERT INTO second (id, var2, from_dttm, to_dttm) 
VALUES(1, 'B', '2018-09-15', '5999-12-31');

select * from 
(
    select first.id as id, first.var1 as var1, second.var2 as var2,
        case when first.from_dttm >= second.from_dttm then first.from_dttm
            else second.from_dttm 
        end as from_dttm,
        case when first.to_dttm <= second.to_dttm then first.to_dttm
            else second.to_dttm
        end as to_dttm
    from first left join second on first.id = second.id
) as res
where to_dttm >= from_dttm