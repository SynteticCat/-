import requests
from bs4 import BeautifulSoup as BS
import random 
import csv
from faker import Faker
import string

PAGE_COUNT = 8
identety = 1

URL = 'https://mytischi.hh.ru/search/vacancy?st=searchVacancy&text=&salary=&currency_code=RUR&experience=doesNotMatter&order_by=relevance&search_period=0&items_on_page=100&no_magic=true&L_save_area=true'
HEADERS = {'user-agent' : 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:83.0) Gecko/20100101 Firefox/83.0',
'accept' : '*/*'}


def get_html(url, params = None):
	r = requests.get(url, headers = HEADERS, params = params)
	return r


def get_city(item):
	city = ''
	for sym in item:
		if sym == ',':
			break
		else:
			city += sym
	return city

def salary_handler(item):
	numbers = '0123456789'
	salary = ''
	for sym in item:
		if sym == '-':
			break
		elif sym not in numbers:
			continue
		else:
			salary += sym

	return salary

def get_salary(item):
	item = salary_handler(item)
	if item == '':
		return '100000'
	else:
		return item


def save_file_companies(items, path):
	with open(path, 'w', newline = '', encoding = 'utf-8') as file:
		writer = csv.writer(file, delimiter = ';')
		#writer.writerow(['Team', 'Founded', 'Prize amount'])
		for item in items:
			writer.writerow([item['Company'], item['Founded'], item['Income']])

def get_content(html, companies):
	global identety
	faker = Faker()
	soup = BS(html, 'html.parser')
	items = soup.find_all('div', class_ = 'vacancy-serp-item HH-VacancySidebarTrigger-Vacancy vacancy-serp-item_premium')
	
	vacancy = []
	for item in items:
		company_name = item.find('div', class_ = 'vacancy-serp-item__meta-info-company').get_text()
		companies.append(company_name)
		vacancy.append({
			'id' : str(identety),
			'Job title' : item.find('a', class_ = 'bloko-link HH-LinkModifier HH-VacancySidebarTrigger-Link HH-VacancySidebarAnalytics-Link').get_text(),
			'Company' : company_name,
			'City' : get_city(item.find('span', class_ = 'vacancy-serp-item__meta-info').get_text()),
			'Salary' : get_salary(item.find('div', class_ = 'vacancy-serp-item__sidebar').get_text()),
			'Days' : str(random.randint(1, 20))
			})
		identety += 1
	
	return vacancy

def save_file_vac(items, path):
	with open(path, 'w', newline = '', encoding = 'utf-8') as file:
		writer = csv.writer(file, delimiter = ';')
		for item in items:
			writer.writerow([item['id'], item['Job title'], item['Company'], item['City'], item['Salary'], item['Days']])
			#writer.writerow([item['Name'], item['Nickname'], item['Country'], item['Team'], item['Prize amount'], item['Rating']])

	
def parse():
	html = get_html(URL)
	if html.status_code != 200:
		print('Error')
		return -1

	#get_content(html.text, companies)

	vacancy = []
	companies = []
	
	for vac in range(1, PAGE_COUNT + 1):
		print("Parsing page " + str(vac) + " from " + str(PAGE_COUNT) + "...")
		html = get_html(URL + "&page=" + str(vac - 1))
		vacancy.extend(get_content(html.text, companies))
	save_file_vac(vacancy, 'vacancies.csv')

	companies = list(dict.fromkeys(companies))

	companies_r = []

	for i in range(len(companies)):
		companies_r.append({
			'Company' : companies[i],
			'Founded' : str(random.randint(1930, 1990)),
			'Income' : str(random.randint(1000000, 10000000000))
			})
	save_file_companies(companies_r, 'companies.csv')
	
parse()