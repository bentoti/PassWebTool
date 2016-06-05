#!/usr/bin/env python
# -*- coding: utf-8 -*-

import simplejson as json
import requests
requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

def get_credentials(pwid):
    answer = requests.post('https://PassWebTool/get.py', data={ 'pwid': pwid, 'mode': 'json' }, verify=False)
    return json.loads(answer.content)

if __name__ == '__main__':
    from pprint import pprint
    credentials = get_credentials("79IXES")
    pprint(credentials)

