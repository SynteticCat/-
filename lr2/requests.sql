--1. Инструкция SELECT, использующая предикат сравнения.

select job_title, company, city from vacancies
where city = 'Москва'


--2. Инструкция SELECT, использующая предикат BETWEEN.

select job_title, company, city, salary from vacancies
where salary between 50000 and 100000

--3. Инструкция SELECT, использующая предикат LIKE.

select * from vacancies
where company like 'ООО%'

where name like 'Земля'
where name in ('Земля', 'Марс')

where name like '%e%'

--4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом. 

select * from vacancies
where company in 
(select company_name from companies
where income > 1000000)

--5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- все вакансии с id, которые есть в списке контрактов
-- если подзапрос содержить любое количество строкб  EXISTS вернет TRUE

select * from vacancies
where exists 
(select * from contracts
where contracts.vacancy_id = vacancies.id) 

--6. Инструкция SELECT, использующая предикат сравнения с квантором.
-- оператор вернет TRUE если какое либо значение подзапроса соответсвует условию
-- вывести все вакансии с зарплатой больше зарплаты по Москве

select * from vacancies
where salary > ALL
(select salary from vacancies
where city = 'Москва')

--7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов
-- COUNT подсчитает количество записей по конкретному значению атрибута

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
when 'Минск' then 'Minsk'
when 'Екатеринбург' then 'Yekaterinburg'
else ''
end city
from vacancies

--10. Инструкция SELECT, использующая поисковое выражение CASE.

select job_title, company,
case 
when city = 'Москва' then 'Moscow'
when city = 'Минск' then 'Minsk'
when city = 'Екатеринбург' then 'Yekaterinburg'
else ''
end city
from vacancies

--11. Создание новой временной локальной таблицы из результирующего набора
--данных инструкции SELECT.
-- SELECT INTO создает новую локальную таблицу на основе старой

select *
into moscow_vacancies from vacancies
where city = 'Москва';

select * from moscow_vacancies

--12. Инструкция SELECT, использующая вложенные коррелированные подзапросы 
--в качестве производных таблиц в предложении FROM.
-- В таких запросах внутренний запрос зависит от внешнего запроса
-- получение строки кандидата от родителя => выполнение действий с ней => исключение или включение строки кандидата и т.д.

SELECT job_title, company, salary FROM vacancies as v_outer
WHERE salary > (
	SELECT AVG(salary) FROM vacancies
	WHERE company = v_outer.company)

--13. Инструкция SELECT, использующая вложенные подзапросы с уровнем
--вложенности 3.

select name, job_title, company, agreed_salary from employers
join (select * from contracts
      join (select * from vacancies
            where company in (select company_name from companies
			      where company like 'ООО%')
	   ) as top_company
      on contracts.vacancy_id = top_company.id
     ) as employer_vacancy
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
-- результирующего набора данных вложенного подзапроса.

insert into companies
values 
('ООО max income', 2020, (select max(income) from companies)),
('ООО Супер Фирма', 2020, 10000000),
('ООО Мега Фирма', 2019, 2300000);

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
	join vacancies as c1 on cs.vacancy_id = c1.id
	where salary > 100000)

--22. Инструкция SELECT, использующая простое обобщенное табличное
-- выражение (ОТВ)

WITH CTE AS (SELECT * FROM vacancies)

SELECT * FROM CTE

--23. Инструкция SELECT, использующая рекурсивное обобщенное табличное
--выражение.
-- рекурсия - это способ иерархического представления данных табличной модели

CREATE TABLE vacancies_substitute
(
	id bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 ),
	job_title varchar(32) NOT NULL,
	city varchar(30) NOT NULL,
	substitute_for bigint NULL
);

// корневой элемент со значением substitute_for = NULL
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

WITH RECURSIVE recCTE(id, job_title, city, substite_for, rotation_level) AS (
	-- выполняется 1 раз, определяет якорь рекурсии, накапливает результат рекурсии
	SELECT id, job_title, city, substitute_for, 0 AS rotation_level FROM vacancies_substitute WHERE substitute_for IS NULL
	UNION ALL
	-- содержит ссылку на ОТВ
	SELECT vs.id, vs.job_title, vs.city, vs.substitute_for, rotation_level + 1 FROM vacancies_substitute AS vs 
	JOIN recCTE AS rc ON vs.substitute_for = rc.id
)

SELECT * FROM recCTE 
ORDER BY rotation_level;

--24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
-- отличается от GROUP BY тем, что не уменьшает количество исходных записей таблицы

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

// формируем cte и выставляем row_number для одинаковых записей
with cte
as
(select id, job_title, city, salary,
row_number() over(partition BY job_title, city, salary) AS row_number
FROM overlapping)
 
// удалить дубли, т.е. записи с row_number > 1
delete from overlapping
where id in (select id from cte
where row_number > 1)