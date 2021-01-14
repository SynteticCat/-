-- lab_05

-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres). Для выгрузки в XML
-- проверить все режимы конструкции FOR XML

\copy (select ROW_TO_JSON(vacancies) from vacancies) 
to 'C:\Users\Roket\Desktop\Programming\5_semestr\Data_Base\work\vacancies.json';

-- 2. Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

CREATE TABLE vacancies_copy_help(doc JSON);
COPY vacancies_copy_help FROM 'C:\Users\Roket\Desktop\Programming\5_semestr\Data_Base\work\vacancies.json';

CREATE TABLE IF NOT EXISTS vacancies_copy(LIKE vacancies INCLUDING ALL);
INSERT INTO vacancies_copy
SELECT p.*
FROM vacancies_copy_help, json_populate_record(null::vacancies, doc) AS p;

(
	SELECT * FROM vacancies_copy
	EXCEPT
	SELECT * FROM vacancies
)
UNION
(
	SELECT * FROM vacancies
	EXCEPT
	SELECT * FROM vacancies_copy
)

-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE.

DROP TABLE vacancies_copy;

CREATE TABLE vacancies_copy (LIKE vacancies INCLUDING ALL);

INSERT INTO vacancies_copy
SELECT *
FROM vacancies;

ALTER TABLE vacancies_copy ADD COLUMN data_json JSON;

DROP TABLE vacanciesn_json;

CREATE TABLE vacancies_json(id SERIAL, doc JSON);
COPY vacancies_json(doc) FROM 'C:\Users\Roket\Desktop\Programming\5_semestr\Data_Base\work\vacancies.json';

UPDATE vacancies_copy
SET data_json = (SELECT doc FROM vacancies_json WHERE vacancies_copy.id = vacancies_json.id);

select * from vacancies_copy;

-- 4. Выполнить следующие действия:

	-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа

SELECT *
FROM json_extract_path('{"job_title": "President", "city": "Moscow", "Characteristics": {"Salary": "999999", "Age": "24", "Skill": "Maximum skill"}}', 
					   'Characteristics', 'Skill');

	-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON
--документа

SELECT DISTINCT job_title, (data_json->>'company') AS company, (data_json->>'city') AS city
FROM vacancies_copy
WHERE data_json->>'company' LIKE 'ООО%';

	-- 3. Выполнить проверку существования узла или атрибута

SELECT job_title, company, (data_json->>'city') AS city
FROM vacancies_copy
WHERE data_json::jsonb ? 'city';

	-- 4. Изменить XML/JSON документ

UPDATE vacancies_copy
SET data_json = data_json::jsonb - 'city';

select * from vacancies_copy;

	--5. Разделить XML/JSON документ на несколько строк по узлам

SELECT *
FROM json_each_text('{"job_tite": "President", "company": "The best company", "city": "Moscow"}');

