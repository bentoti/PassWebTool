# -*- coding: utf-8 -*-
from keepass import kpdb
import logging, optparse, cgi, time, getpass
from string import ascii_uppercase, ascii_lowercase,digits, punctuation
from random import choice
from pprint import pprint
from os import environ

class KpDbClass(object):
    def __init__(self, config):
        '''
        KeePass Simpled Database for automated requests of passwords
        entries in KDB file must look like:
        - Title:  HOSTNAME::SERVICE
        - URL:    PWID  (PassWordIDentity)
        '''
        self.config = config
        self.db = kpdb.Database

    def open(self):
        logging.debug("opening KeePass file '%s'", self.config['kpfile'])
        try:
            self.db = kpdb.Database(self.config['kpfile'], self.config['kppass'])
            return True
        except IOError, e:
            raise PassWebToolException(e)
            return False
        except UnicodeDecodeError, e:
            logging.fatal(str(e))
            logging.fatal("maybe one of the entries contains an illegal character")

    def save(self):
        logging.debug("saving KeePass file '%s' as user '%s'", self.config['kpfile'], getpass.getuser())
        try:
            self.db.write(self.config['kpfile'], self.config['kppass'])
        except Exception, e:
            raise PassWebToolException(str(e))


    def get_pwid(self, pwid):
        '''
        :param pwid: string
        :return: pwtsctrictire or none
        '''
        if pwid is None: return None
        r = self.get({'pwid': pwid})
        if len(r) > 1:
            logging.warn("found more than one entry for pwid '%s', using latest (%s)", pwid, environ['REMOTE_ADDR'])
            r = [r[-1]]
        elif len(r) < 1:    r = None
        else:               r = r[0]
        if r is None:
            logging.warn("could not find entry for pwid '%s' (%s)", pwid, environ['REMOTE_ADDR'])
        else:
            logging.info("successfully found entry for pwid '%s' (%s)", pwid, environ['REMOTE_ADDR'])
        return r

    def get(self, filter = {}):
        '''
        :param filter assuming entrystructure like
            {'pwid': None, 'host': None, 'service': None, 'username': None, 'password': None, 'notes': None}
        :return: list of all entries found in KeePass
        if any argument given, filter by that
        '''
        ret = []
        try:
            for each in self.db.entries:
                if each.title == "Meta-Info": continue
                if self.db.group('groupid',each.groupid).group_name != self.config['kpgroup']: continue
                try:
                    entry = {'pwid': each.url, 'username': each.username, 'password': each.password,
                             'host': each.title.strip().split('::')[0], 'service': each.title.strip().split('::')[1],
                             'notes': each.notes}
                except IndexError, e:
                    logging.error("entry does not match title (HOSTNAME::SERVICE): %s", str(each))
                    continue

                f_out = False
                for field in ['pwid', 'host', 'service', 'username', 'password', 'notes']:
                    if entry[field] == "None": entry[field] = None
                    if filter.has_key(field) and filter[field] is not None and filter[field] != entry[field]:
                        f_out = True

                if not f_out:
                    ret.append(entry)
        except AttributeError, e:
            raise PassWebToolException("no entries found in KDB File - maybe you inserted a special character")
        return ret

    def remove(self, pwid):
        if pwid is None: return False
        entry = self.get({'pwid':pwid})
        if len(entry) == 0:
            logging.warn("could not remove '%s': pwid not found (%s)", pwid, environ['REMOTE_ADDR'])
            return False
        username = entry[0]['username']
        logging.info("removing pwid '%s' (%s)", pwid, environ['REMOTE_ADDR'])
        self.db.remove_entry(username = username, url = pwid)
        return True

    def add(self, new):
        if new['pwid'] is None:
            raise("pwid must be set")
            new['pwid'] = generate_pwid()
        self.remove(new['pwid'])

        for field in ['host', 'service', 'username', 'password', 'notes']:
            if new[field] is None: new[field] = ""

        title = str(new['host']) + '::' + str(new['service'])

        logging.info("adding pwid '%s' (%s)", new['pwid'], environ['REMOTE_ADDR'])

        self.db.add_entry(path=self.config['kpgroup'], url=new['pwid'], title=title, username=new['username'], password=new['password'],
                          notes=new['notes'], imageid=30)

        return new

    def merge_entries(self, new, old={'pwid': None, 'host': None, 'service': None, 'username': None, 'password': None, 'notes': None}):
        for each in old.keys():
            if new.has_key(each) and new[each] is not None:
                continue # new content to be saved
            elif old.has_key(each):
                new[each] = old[each]
        return new

class PassWebToolException(Exception):
    def __init__(self, message):
        print message
        logging.error(message)
        self.message = message

