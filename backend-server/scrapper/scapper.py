from bs4 import BeautifulSoup
import urllib.request


def fetch_isolation_hospitals():
    url = 'https://www.gov.pl/web/koronawirus/lista-szpitali'
    with urllib.request.urlopen(url) as url_handl:
        html_code = url_handl.read()
        soup = BeautifulSoup(html_code, 'html.parser')

        active_regions_list = soup.findAll('div',
                                           {'class': 'law-court__list'})[0]
        specific_list = active_regions_list.find('ul')
        # print(specific_list)
        for reg in specific_list:
            if isinstance(reg, BeautifulSoup.element.Tag):
                print('\n', reg)
                print(type(reg), dir(reg))
            # print(reg, type(reg), dir(reg))


fetch_isolation_hospitals()