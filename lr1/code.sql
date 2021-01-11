create table if not exists companies(
	company_name varchar(150) not null primary key,
	founded int not null,
	income bigint not null
);

create table if not exists employers(
	id int not null primary key,
	name varchar(100),
	email varchar(100),
	experience int
);

create table if not exists vacancies (
	id int not null primary key,
	job_title text not null,
	company text references companies(company_name) not null,
	city varchar(60) not null,
	salary bigint check (salary > 0) not null,
	days int not null
);

create table if not exists contracts(
	employer_id int references employers(id) not null,
	vacancy_id int references vacancies(id) not null,
	agreed_salary bigint not null
);

\copy companies from 'C:\sviridovir\Database\lr1\companies.csv' delimiter ';' csv;

\copy employers from 'C:\sviridovir\Database\lr1\employers.csv' delimiter ';' csv;

\copy vacancies from 'C:\sviridovir\Database\lr1\vacancies.csv' delimiter ';' csv;

\copy contracts from 'C:\sviridovir\Database\lr1\contracts.csv' delimiter ';' csv;

select * from companies

select * from employers

select * from vacancies

select * from contracts

// создание тестовой таблицы

create table if not exists test(
	id int not null,
	name varchar(60) not null
);

select * from test;

// добавление столбца

ALTER TABLE test
ADD digit bigint not null DEFAULT 123;

select * from test;

// удаление столбца

ALTER TABLE test
DROP COLUMN digit;

select * from test;

// изменение типа столбца

ALTER TABLE test
ALTER COLUMN digit 
TYPE VARCHAR(50);

select * from test;

// изменение ограничения столбца

ALTER TABLE test
ALTER COLUMN digit
SET not null;

select * from test;

ALTER TABLE test
ALTER COLUMN digit
DROP not null;

select * from test;

// добавление ограничения

ALTER TABLE test
ALTER COLUMN digit TYPE int
ADD CHECK (digit > 10);

select * from test;

// переименовать столбец

ALTER TABLE test
RENAME COLUMN digit TO number;

select * from test;