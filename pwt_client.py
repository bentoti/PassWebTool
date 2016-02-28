import requests, os
answer = requests.post("https://PassWebTool/get.py", verify=False, data={'pwid': '79IXES'}).text
from pprint import pprint


for each in answer.split(os.linesep):
    pprint (each)