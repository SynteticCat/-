import random
from faker import Faker
import csv

CONTRACTS = 200
EMPLOYERS_COUNT = 400
VACANCY_COUNT = 800

def save_file_employers(items, path):
	with open(path, 'w', newline = '', encoding = 'utf-8') as file:
		writer = csv.writer(file, delimiter = ';')
		for item in items:
			writer.writerow([item['id'], item['Employers\'s name'], item['Employers\'s email'], item['Experience']])

def save_file_contracts(items, path):
	with open(path, 'w', newline = '', encoding = 'utf-8') as file:
		writer = csv.writer(file, delimiter = ';')
		for item in items:
			writer.writerow([item['Employer_id'], item['Vacancy_id'], item['Agreed_salary']])

faker = Faker('ru_RU')
employers = []
for i in range(EMPLOYERS_COUNT):
	name = faker.name()
	employers.append({
			'id' : str(i),
			'Employers\'s name' : name,
			'Employers\'s email' :  faker.email(),
			'Experience' : str(random.randint(1, 20))	
			})


contracts = []
for i in range(CONTRACTS):
	contracts.append({
			'Employer_id' : random.randint(1, len(employers) - 1),
			'Vacancy_id' : str(random.randint(1, VACANCY_COUNT)),
			'Agreed_salary' : str(random.randint(40000, 100000))	
			})


save_file_employers(employers, 'employers.csv')
save_file_contracts(contracts, 'contracts.csv')
