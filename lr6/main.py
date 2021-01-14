import database

def menu():
    print("Choose options:")
    print("1 - Scalar query")
    print("2 - Query with JOIN")
    print("3 - Window function")
    print("4 - Query on metadata")
    print("5 - Scalar function")
    print("6 - Multi table func")
    print("7 - Procedure")
    print("8 - System procedure or function")
    print("9 - Create new table")
    print("10 - Insert new data")

    print("\n0 - Exit \n")

if __name__ == "__main__":

    vacanciesDB = database.DataBase()

    run = True
    while (run == True):
        menu()

        choice = int(input("Please, input your choice\n"))

        if choice == 1:
            print(vacanciesDB.get_job_with_min_salary())
        elif choice == 2:
            print(vacanciesDB.select_more_inf()) 
        elif choice == 3:
            print(vacanciesDB.select_cte_window())
        elif choice == 4:
            print(vacanciesDB.select_metadata())
        elif choice == 5:
            print(vacanciesDB.scalar_func('Москва'))
        elif choice == 6:
            print(vacanciesDB.multi_table_func())
        elif choice == 7:
            vacanciesDB.new_salary()
        elif choice == 8:
            print(vacanciesDB.get_version())
        elif choice == 9:
            vacanciesDB.create_table('vac_demand')
        elif choice == 10:
            vacanciesDB.insert_data('vac_demand', 'Programmist', 900)
        elif choice == 0:
            run = False



