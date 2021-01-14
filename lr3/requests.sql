--lab_03

-- Функции --

-- Скалярная функция
-- Поик id первой попавшейся записи с city = 'Москва'

CREATE OR REPLACE FUNCTION scalar_func(city_name varchar(60)) 
RETURNS int 
AS
$$
	select id from vacancies
	where city = city_name
$$ 
LANGUAGE SQL;

select scalar_func('Москва');

-- Подставляема табличная функция
-- Поиск свех записей с city = 'Москва'

CREATE OR REPLACE FUNCTION inserted_table_func(city_name varchar(60)) 
RETURNS table(id int, job_title text, company text, 
			  city varchar(60), salary bigint, days int) AS
$$
	select * from vacancies
	where city = city_name
$$
LANGUAGE SQL;

select * from inserted_table_func('Москва'); 

-- Многооператорная табличная функция
-- вычисление количества вакансий с зп равной максимальной зп

CREATE OR REPLACE FUNCTION multi_table_func() 
RETURNS int AS
$$
	declare
		vs_t int[];
		max_num int;
		temp_p int;
		elem int;
		count int;
	begin
		max_num := (select max(salary) from vacancies);
		vs_t := array(select id from vacancies);
		count := 0;
		foreach elem in array vs_t
		loop
			temp_p := (select salary from vacancies where id = elem);
			if temp_p = max_num
				then count := count + 1;
			end if;
		end loop;
		return count;
	end;
$$ 
LANGUAGE PLPGSQL;

select * from multi_table_func();

-- Рекурсивную функцию или функцию с рекурсивным ОТВ
-- создание плоской иерархии

create or replace function recursion_func() 
returns table(id int, company text)
as
$$
    with recursive cte as
    (
        select id as index, company as company_name from vacancies where id = 1
        union 
        select vacancies.id as index, vacancies.company as company_name
        from cte join vacancies on cte.index + 1 = vacancies.id
        where vacancies.id <= 20
    )
    select * from cte;
$$ language sql;

select *
from recursion_func();

-- Процедуры --

-- Хранимую процедуру без параметров или с параметрами
-- Установить зарплату в 7777, для компаний с названием, начинающимся с 'ООО'

DROP TABLE IF EXISTS help_table CASCADE;

SELECT id, job_title, company, salary INTO help_table FROM vacancies
WHERE salary > 50000
LIMIT 20;

select * from help_table;

CREATE OR REPLACE PROCEDURE new_salary() AS
$$
  update help_table
  set salary = 7777
  where company like 'ООО%'
$$ 
LANGUAGE SQL;

CALL new_salary();

select * from help_table;

-- Рекурсивно хранимая процедура
-- Аналогично обычной рекурсии

drop table if exists help_table;

select id, job_title, company, salary
into help_table from vacancies
limit 20;

create or replace procedure salary_between_id(begin_id int, end_id int, new_salary bigint) as
$$
begin
    if (begin_id <= end_id)
    then
        update help_table
        set salary = new_salary
        where id = begin_id;
        call salary_between_id(begin_id + 1, end_id, new_salary);
    end if;
end;
$$ language plpgsql;

call salary_between_id(1, 6, 9999999999);

select *
from help_table
order by id;

-- Хранимую процедуру с курсором
-- Итератор, указатель на запись в памяти
-- Удаляем записи с переданным значением зп

drop table if exists help_table;

select id, job_title, company, salary
into help_table from vacancies
limit 20;

create or replace procedure delete_str(temp_salary int) as
$$
    declare cur cursor 
    for select * 
    from help_table;
    temp record;
    begin
        open cur;
        loop
            fetch cur into temp;
            exit when not found;
            delete from help_table
            where salary = temp_salary;
        end loop;
        close cur;
    end;
$$ language plpgsql;

call delete_str(1200);

select *
from help_table
order by id;
	

-- Хранимую процедуру доступа к метаданным
-- Метаданные к БД, данные о данных таблицы
-- вывод таблицы названий и размеров таблиц

select table_name, pg_relation_size(cast(table_name as varchar)) as size FROM information_schema.tables WHERE table_schema='public';

create or replace procedure table_info() as
$$
    declare my_cursor cursor
	for select table_name, size
	from (
		select table_name,
		pg_relation_size(cast(table_name as varchar)) as size 
		from information_schema.tables
		WHERE table_schema='public'
	) AS temp_table;
	temp record;
begin
	open my_cursor;
	loop
		fetch my_cursor into temp;
		exit when not found;
		raise info 'name - %, size - %', temp.table_name, temp.size;
	end loop;
	close my_cursor;
end
$$ language plpgsql;

call table_info();

-- Триггеры --
-- триггер after

drop table if exists help_table;

select id, city
into help_table from vacancies
limit 20;

create or replace function insert_func() returns trigger as
$$
   begin
      insert into help_table(id, city) values (24, old.city);
      RETURN new;
   end;
$$ language plpgsql;

create trigger instead_update_insert
after update on help_table for each row
execute function insert_func();

select * from help_table;

update help_table
set city = 'Вондерленд'
where id = 16;

select * from help_table
order by id;

-- триггер instead of

drop view if exists help_view cascade;
drop table if exists help_table cascade;

create table help_table(id int, num int);
INSERT into help_table(id, num) values (1, 2);
INSERT into help_table(id, num) values (2, 3);
INSERT into help_table(id, num) values (3, 4);

create view help_view as
select *
from help_table;

create or replace function insert_instead_update() returns trigger as
$$
    begin
        insert into help_view(id, num) 
	values (old.id * 4, new.num);
        RETURN new;
    end;
$$ language plpgsql;

create trigger update_trigger
instead of update on help_view for each row 
execute function insert_instead_update();

select * from help_view;
update help_view
set num = 10
where id = 4;

select * from help_view;

------------------------
drop view if exists help_view cascade;
drop table if exists help_table cascade;

select id, job_title, city, salary
into help_table
from vacancies
limit 20;

create view help_view as
select *
from help_table;

create or replace function insert_instead_update() returns trigger as
$$
    begin
        update help_view 
		set city = 'Cosmos'
		where id = old.id;
		return new;
    end;
$$ language plpgsql;

create trigger update_trigger
instead of delete on help_view for each row 
execute function insert_instead_update();

select * from help_view;

delete from help_view
where id = 1;

select * from help_view
order by id
------------------------