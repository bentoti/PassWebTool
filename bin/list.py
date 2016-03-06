#!/usr/bin/env python
from PassWebTool import parseParams, PassWebToolException, environ
from PassWebTool.PassWebToolClass import KpDbClass
from PassWebTool.Renderer import RenderCLI, RenderCGI

ui = RenderCLI()
if environ.has_key('HTTP_USER_AGENT'):
    ui = RenderCGI()

try:
    opmode, config, e = parseParams()
    KpDb = KpDbClass(config)
    KpDb.open()
except PassWebToolException, e:
    ui.print_error(str(e))
    ui.quit()

if __name__ == '__main__':
    ui.print_title("LIST")

    ui.print_list_header()
    for each in KpDb.get():
        ui.print_list_entry(each)
    ui.print_list_footer()
    ui.quit()