create table if not exists vacancies (
	id int not null primary key,
	job_title text not null,
	company text references companies(company_name) not null,
	city varchar(60) not null,
	salary bigint check (salary > 0) not null,
	days int not null
);

--copy vacancies from 'C:\Users\kirpa\OneDrive\sviridov\database\lab_01\vacancies.csv' delimiter ';' csv;

create table if not exists contracts(
	employer_id int references employers(id) not null,
	vacancy_id int references vacancies(id) not null,
	agreed_salary bigint not null
);
--copy contracts from 'C:\Users\kirpa\OneDrive\sviridov\database\lab_01\contracts.csv' delimiter ';' csv;

create table if not exists employers(
	id int not null primary key,
	name varchar(100),
	email varchar(100),
	experience int
);

--copy employers from 'C:\Users\kirpa\OneDrive\sviridov\database\lab_01\employers.csv' delimiter ';' csv;

create table if not exists companies(
	company_name varchar(150) not null primary key,
	founded int not null,
	income bigint not null
);

--copy companies from 'C:\Users\kirpa\OneDrive\sviridov\database\lab_01\companies.csv' delimiter ';' csv;

1. beaver

автогенерация er диаграммы

2. delete from employers;

alter table employers add check (name LIKE '[а-яА-Я ]{0,}');
alter table employers add check (email like '%@%');

добавить ограничения на таблицу сотрудников, на поле имя добавить ограничение что это только буквы (в имени нет цифр), 
на поле email добавить стандартное ограничение формат email-а, в обоих вариантах использовать регулярные выражения
altertable (ограничения наложить после создания таблицы)

Продемонстрировать: очистить таблицу сотрудников => побить входной csv файл (в середине вставить невалидное имя или email) => попробовать через copy добавить эти данные
(пояснить результат)
