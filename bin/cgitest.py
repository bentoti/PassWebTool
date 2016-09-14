#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pprint import pprint
import os

print "Content-type:text/html" + os.linesep

if os.environ.has_key('HTTP_USER_AGENT'):
    print "<pre>"
    for k,v in os.environ.iteritems():
        print k,'-', v
    print "<pre>"
