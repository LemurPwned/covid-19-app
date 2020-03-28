from bs4 import BeautifulSoup
import urllib.request
import bs4
import json

from collections import defaultdict


def fetch_isolation_hospitals():
    url = 'https://www.gov.pl/web/koronawirus/lista-szpitali'
    with urllib.request.urlopen(url) as url_handl:
        html_code = url_handl.read()
        soup = BeautifulSoup(html_code, 'html.parser')

        active_regions_list = soup.findAll('div',
                                           {'class': 'law-court__list'})[0]
        specific_list = active_regions_list.find('ul')
        # print(specific_list)

        hospital_list = {}
        for reg in specific_list:
            if isinstance(reg, bs4.element.Tag):
                region = reg.find('h3').text
                hospital_list[region] = []
                hospitals = reg.findAll('li')
                for hospital in hospitals:
                    print(hospital.text)
                    hospital_list[region].append(hospital.text)

            # print(reg, type(reg), dir(reg))
        json.dump(hospital_list, open("Hospitals.json", 'w'))


fetch_isolation_hospitals()