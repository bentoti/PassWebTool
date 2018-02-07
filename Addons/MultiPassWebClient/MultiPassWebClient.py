# -*- coding: utf-8 -*-
import os, re
from PassWebClient import PassWebClient

os.environ['AppEnv'] = 'devel'   # better to set this externally, for the sake of demonstration

class MultiPassWebClient(PassWebClient):
    def __init__(self, filename=None):
        super(type(self), self).__init__()
        if filename is None:
            filename = '.credentials.' + os.environ['AppEnv'] + '.sh'
        self.__filename = filename

    def find(self, value_name):
        """find given value als key"""
        for k, v in self.getAll().iteritems():
            if v.has_key(value_name):
                return v[value_name]
        return None

    def getPwid(self, value_name):
        """get pwid for a certain key"""
        return self.find(value_name)

    def get(self, name):
        """"get credentials of a certain key"""
        return super(type(self), self).get( self.getPwid( name)  )

    def getAll(self):
        """ parses filename for bash-dicts and returns them as dict of dicts
        expected KV assignment in bash-script should look like
        declare -A MyUsers=( ["root"]="XXXXXX"  ["admin"]="XXXXXX"  ["reader"]="XXXXXX"   ["SQL"]="XXXXXX" )
        """

        regex = r"\[\"(\w+)\"\]=\"([^\s]+)\""  # regex to match    ["<KEY>"]="<VALUE>"   multiple times
        ret = {}

        with open(self.__filename, 'r') as f:
            for line in [l.strip() for l in f.readlines()]:  # strip each line already
                if line == "" or not line.upper().startswith('DECLARE -A '):
                    continue  # skip lines not starting with a declare statement

                var_name = line.split('=')[0].split(' ')[-1]  # left of =, right of any ' ' expect the variable name
                var_value = '='.join(line.split('=')[1])

                ret[var_name] = {}  # create key with name of variable

                matches = re.finditer(regex, line)

                for i, match in enumerate(matches):
                    kvset = match.groups()  # returnes (key, value) as set
                    ret[var_name][kvset[0]] = kvset[1]
        return ret


if  __name__ == "__main__":
    from pprint import pprint

    MyMultiPass = MultiPassWebClient()

    pprint(MyMultiPass.get('john_doe'))
