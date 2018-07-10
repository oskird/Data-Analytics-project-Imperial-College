import pandas as pd

from bs4 import BeautifulSoup

import requests

import re

import unicodedata

attributes=['Crossing','Finishing','Heading accuracy',

 'Short passing','Volleys','Dribbling','Curve',

 'Free kick accuracy','Long passing','Ball control','Acceleration',

 'Sprint speed','Agility','Reactions','Balance',

 'Shot power','Jumping','Stamina','Strength',

 'Long shots','Aggression','Interceptions','Positioning',

 'Vision','Penalties','Composure','Marking',

 'Standing tackle','Sliding tackle','GK diving',

 'GK handling','GK kicking','GK positioning','GK reflexes']



 

links=[]   #get all argentinian players

for offset in ['0','80','160','240','320','400','480','560']:

    page=requests.get('http://sofifa.com/players?na=52&offset='+offset) 

    soup=BeautifulSoup(page.content,'html.parser')

    for link in soup.find_all('a'):

        links.append(link.get('href'))

links=['http://sofifa.com'+l for l in links if 'player/'in l]  



#pattern regular expression 

pattern=r"""\s*([\w\s]*?)\s*FIFA"""   #file starts with empty spaces... players name...FIFA...other stuff     

for attr in attributes:

    pattern+=r""".*?(\d*\s*"""+attr+r""")"""  #for each attribute we have other stuff..number..attribute..other stuff

pat=re.compile(pattern, re.DOTALL)    #parsing multiline text



rows=[]

links=links[10:]

for j,link in enumerate(links):

    print(j,link)

    row=[link]

    playerpage=requests.get(link)

    playersoup=BeautifulSoup(playerpage.content,'html.parser')
    
    text=playersoup.get_text()

    # text=unicodedata.normalize('NFKD', text).encode('ascii','ignore')

    a=pat.match(text)

    row.append(a.group(1))

    for i in range(2,len(attributes)+2):

        row.append(int(a.group(i).split()[0]))

    rows.append(row)

    print(row[1])

df=pd.DataFrame(rows,columns=['link','name']+attributes)

# convert the name into 'ascii'
df.name = [str(unicodedata.normalize('NFKD', i).encode('ascii','ignore'))[2:-1] for i in list(df.name)]
# save the dataset in a .csv file
df.to_csv('ArgentinaPlayers.csv',index=False)