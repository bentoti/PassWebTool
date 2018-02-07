# -*- coding: utf-8 -*-
import simplejson as json
import requests
requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

class PassWebClient(object):
    """Client Class, Retrieve Credentials from PassWebTool"""
    def __init__(self, PassWebToolUrl='https://PassWebTool/get.py', verifySsl=False):
        self.__url = PassWebToolUrl
        self.__verifySsl = verifySsl

    def get(self, pwid):
        try:
            answer = requests.post(self.__url, data={'pwid': pwid, 'mode': 'json'}, verify=self.__verifySsl)
            return json.loads(answer.content)
        except requests.exceptions.ConnectionError as e:
            raise requests.exceptions.ConnectionError("PassWebTool unreachable at '" + self.__url + "'")
        except json.JSONDecodeError as e:
            raise Exception("pwid '" + str(pwid) + "' is not valid: " + str(e))


if __name__ == "__main__":
    print PassWebClient().get("79IXES")