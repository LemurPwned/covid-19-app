from bs4 import BeautifulSoup
import urllib.request
import bs4
import json

from collections import defaultdict

from geopy.geocoders import Nominatim
geolocator = Nominatim(user_agent="test-agent")

import time


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


def match_hospitals_with_location():

    data = json.load(open('Hospitals.json', 'r'))

    full_data = defaultdict()

    for region in data:
        for hospital in data[region]:
            datas = hospital.split(',')
            hos = datas[1].strip()
            query = f"{datas[2].strip()}, {datas[0].strip()}"
            res = geolocator.geocode(query)
            try:
                full_data[res.address] = {
                    'latitude': res.latitude,
                    'longitude': res.longitude
                }
                print(res.address, res.latitude, res.longitude)
            except:
                print(res)
            time.sleep(1.5)
            # quit()
    json.dump(full_data, open('full_data.json', 'w'))


# fetch_isolation_hospitals()
match_hospitals_with_location()