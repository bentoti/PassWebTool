#!/usr/bin/env python
# -*- coding: utf-8 -*-
from PassWebTool import parseParams, PassWebToolException, environ
from PassWebTool import generate_pwid, ascii_lowercase, ascii_uppercase, digits, punctuation
from PassWebTool.PassWebToolClass import KpDbClass
from PassWebTool.Renderer import RenderCLI, RenderCGI

ui = RenderCLI()
if environ.has_key('HTTP_USER_AGENT'):
    ui = RenderCGI()
else:
    environ['REMOTE_ADDR'] = environ['USER']

try:
    opmode, config, e = parseParams()
    KpDb = KpDbClass(config)
    KpDb.open()
except PassWebToolException, e:
    ui.print_error(str(e))
    ui.quit()

if __name__ == '__main__':
    new = e

    ui.print_title("EDIT")


    # check if this is a removal
    if opmode == 'delete' or opmode == 'del':
        if new['pwid'] is None:
            ui.print_error("cannot remove pwid 'None' as it is of type None which is as much as None")
            ui.quit()
        if not KpDb.remove(pwid=new['pwid']):
            ui.print_error("could not remove '"+str(new['pwid'])+"'")
        ui.print_entry_deleted(new['pwid'])

    if new['pwid'] is None: new['pwid'] = generate_pwid(length=config['pwid_length'])

    if opmode is None or opmode == '' or opmode == 'edit':
        old = KpDb.get_pwid(pwid=new['pwid'])
        if old is not None:
            new = KpDb.merge_entries(new, old)
        if new['password'] == None: new['password'] = generate_pwid(length=12, chars=ascii_lowercase + ascii_uppercase + digits)
        new = ui.edit_entry(new)
        if new is None:
            ui.quit()
        opmode = 'save'

    if opmode == 'save':
        KpDb.add(new)
        ui.print_entry_saved(new['pwid'])

    try:
        KpDb.save()
    except PassWebToolException, e:
        ui.print_error(str(e))

    ui.quit()

