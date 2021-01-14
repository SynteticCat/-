import psycopg2

class DataBase:
    # Соединение с БД и получение курсора
    def __init__(self):
        self.connect = psycopg2.connect(dbname='test', user='postgres', 
                                        password='0000', host='localhost')
        self.cursor = self.connect.cursor()

    # 1. Выполнить скалярный запрос;
    # Получение списка названий вакансий с минимальной зп
    def get_job_with_min_salary(self):
        # запрос в БД
        self.cursor.execute('''
            SELECT job_title from vacancies
            where salary = (select min(salary) from vacancies)
            limit 1
        ''' )
        # получение списка всех строк в БД
        return self.cursor.fetchall()

    # 2. Выполнить запрос с несколькими соединениями (JOIN)
    # Получение списка соискателей и их вакансий
    def select_more_inf(self):
        self.cursor.execute('''
            SELECT * from 
            (vacancies join contracts on 
            vacancies.id = contracts.vacancy_id) as cc 
            join employers on employers.id = cc.employer_id
            limit 10
        ''' )
        return self.cursor.fetchall()

    # 3. Выполнить запрос с ОТВ(CTE) и оконными функциями; 
    # Получение вакансий с зп > чем ???
    def select_cte_window(self):
        self.cursor.execute('''
            WITH CTE 
            AS
            (SELECT job_title, company, salary FROM vacancies
            where salary >
                (select avg(salary) over(order by city) as "avg" from vacancies
                limit 1))
            SELECT * FROM CTE
            limit 10
        ''' )
        return self.cursor.fetchall()

    # 4. Выполнить запрос к метаданным
    # Получение списка таблиц в БД со схемой public
    def select_metadata(self):
        self.cursor.execute('''
            SELECT table_name, table_type
            FROM information_schema.tables
            WHERE table_schema = 'public'
        ''' )
        return self.cursor.fetchall()

    # 5. Вызвать скалярную функцию
    # (написанную в третьей лабораторной работе)
    def scalar_func(self, data):
        self.cursor.callproc('scalar_func', [data])
        self.connect.commit()
        return self.cursor.fetchall()

    # 6. Вызвать многооператорную или табличную функцию
    # (написанную в третьей лабораторной работе);
    def multi_table_func(self):
        self.cursor.callproc('multi_table_func')
        self.connect.commit()
        return self.cursor.fetchall()

    # 7. Вызвать хранимую процедуру
    # (написанную в третьей лабораторной работе)
    def new_salary(self):
        self.cursor.execute('call new_salary()')

    # 8. Вызвать системную функцию или процедуру
    # ???
    def get_version(self):
        self.cursor.callproc('version')
        self.connect.commit()
        return self.cursor.fetchall()

    # 9. Создать таблицу в базе данных, соответствующую тематике БД
    # Создание таблицы в БД, с полями id, job_title и rating
    # с произвольным именем
    def create_table(self, name):
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS {name}
            (
                id          SERIAL  PRIMARY KEY,
                job_title   VARCHAR(30) NOT NULL,
                rating      INTEGER NOT NULL
            )
            '''.format(name = name))

        print('Table {name} successfully created\n'.format(name=name))

    # 10. Выполнить вставку данных в созданную таблицу
    # с использованием инструкции INSERT
    def insert_data(self, name, job_title, rating):
        self.cursor.execute('''
            INSERT INTO {name} (job_title, rating) 
            VALUES (%s, %s)
            '''.format(name = name), [job_title, rating])
        print('Insert into {name} successfully\n'.format(name = name))
        
