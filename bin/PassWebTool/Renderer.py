# -*- coding: utf-8 -*-
from os import linesep, environ

class RenderCLI(object):
    def output(self,s):
        print s

    def print_error(self, error_string):
        self.output(error_string)

    def ask_pwid(self):
        return raw_input('please enter PWID:')

    def print_title(self, s):
        self.output("--- " + s + " ---")

    def print_entry(self, e, mode=''):
        if e['password'].startswith("-----BEGIN RSA PRIVATE KEY-----") and e['password'].endswith('-----END RSA PRIVATE KEY-----'):
            e['password'] = '-----BEGIN RSA PRIVATE KEY-----' + \
                e['password'][len("-----BEGIN RSA PRIVATE KEY-----"):-len('-----END RSA PRIVATE KEY-----')].replace(' ','\n') + \
                '-----END RSA PRIVATE KEY-----'

        if e.has_key(mode):
            print e[mode]
        elif mode == 'password-nl':
            for l in e['password'].split(' '):
                print l
        elif mode == 'mysql':
            print "-h'" + e['host'] + "' -u'" + e['username'] + "' -p'" + e['password'] + "'"
        elif mode == 'url':
            print e['username'] + ':' + e['password'] + '@' + e['host']
        elif mode == 'user@host':
            print e['username'] + '@' + e['host']
        elif mode == 'simple':
            print e['host'] + '\t' + e['username'] + '\t' + e['password']
        elif mode == 'json':
            import simplejson as json
            print json.dumps(e)  #, sort_keys=True, indent=4 * ' ')
        elif mode == 'json-nl' or mode == 'get': # from list-form
            import simplejson as json
            print "<pre>"
            print json.dumps(e, sort_keys=True, indent=4 * ' ')
            print "</pre>"
        else: # default
            for f in e.keys():
                print f + "=" + str(e[f]) + linesep, #+ "<br>"

    def edit_entry(self, entry):
        self.output( "pwid: " + str(entry['pwid']) )
        for f in entry.keys():
            if f == 'pwid' : continue
            new_value = raw_input("please enter new value for '"+f+"'["+str(entry[f])+"]:")
            if new_value != '' : entry[f] = new_value
        return entry

    def print_entry_deleted(self, pwid):
        self.output("removed pwid '"+pwid+"'")
    def print_entry_saved(self, pwid):
        self.output("saved pwid '"+pwid+"'")

    def print_list_header(self):
        for f in ['host', 'service', 'username','notes', 'pwid']:
            print f + '/t',

    def print_list_entry(self, e):
        for f in ['host', 'service', 'username','notes', 'pwid']:
            print "" + str(e[f]) + '/t'

    def print_list_footer(self):
        print ""

    def quit(self, s='', r=0):
        if s != '': self.output(s)
        quit(r)

class RenderCGI(RenderCLI):
    def __init__(self):
        print "Content-type:text/html" + linesep

    def print_title(self, s):
        print "<h2>" + s + "</h2>"

    def ask_pwid(self):
        print """
<form method="post" action="get.py">
 <table>
    <tr> <td>PWID:</td>   <td><input type="text" value="" name="pwid" autocomplete='off'></td></tr>
    <tr><td><input type="submit" /></td>
    <td><select name="mode">
        <option value="get">format:all</option>
        <option value="simple">format:simple</option>
        <option value="mysql">format:mysql</option>
        <option value="url">format:url</option>
        <option value="user@host">format:user@host</option>
        <option value="json">format:json</option>
        <option value="json-nl">format:json-newline</option>
        <option value="user">field:user</option>
        <option value="password">field:password</option>
        <option value="host">field:host</option>
        <option value="service">field:service</option>
        <option value="note">field:note</option>
        <option value="password-nl">field:password-newline</option>
    </select></td>

    </tr>
    </tr>
 </table>
</form>
"""

    def edit_entry(self, e):
        if e['pwid'] == None: e['pwid'] = "None"
        for field in ['pwid', 'host', 'service', 'username', 'password', 'notes']:
            if e[field] is None: e[field] = ""
            else:   e[field] = str(e[field])
        print "<form method='post'> <table>"
        print "  <tr><td>PWID</td>     <td><input type='text' readonly='readonly' value='" + e['pwid'] + "' name='pwid' />    </td> </tr>"
        print "  <tr><td>Host:</td>    <td><input type='text' value='" + e['host'] + "' name='host'></td>  </tr>"
        print "  <tr><td>Service:</td> <td><input type='text' value='" + e['service'] + "'' name='service'></td>  </tr>"
        print "  <tr><td>User:</td>    <td><input type='text' value='" + e['username'] + "' name='username'></td>  </tr>"
        print "  <tr><td>Notes:</td>   <td><input type='text' value='" + e['notes'] + "' name='notes'></td>  </tr>"
        print "  <tr><td>Password:</td><td><input type='text' value='" + e['password'] + "' name='password' autocomplete='off'></td>  </tr>"
        print "  <tr> <td>   <input type='checkbox' name='delete' value='1'/> delete</td>"
        print """
  <td>  <input type='submit' name='mode' value='save'/></td>  </tr>
</table>
</form>
"""
        return None

    def print_list_header(self):
        print "<table style='width:100%'>" \
              "<tr>"
        for e in ['host', 'service', 'username','notes', 'pwid']:
            print "<td><b><i>" + e + "</i></b></td>"
        print "<form method='post' action='edit.py'> <td><input value='add' type='submit'/></td></form>" \
              "</tr>"

    def print_list_entry(self, entry):
        print "<tr>"
        for f in ['host', 'service', 'username', 'notes' , 'pwid']:
            # if f == 'notes' and entry['notes'] is not None and entry['notes'].startswith('http'):
            #     print "<td><a href='"+each['notes']+"'>"+entry['notes']+"</a></td>"
            # else:
                print "<td>" + str(entry[f]) + "</td>"

        print "<form method='post' action='edit.py'>"
        print " <input type='hidden' name='pwid' value='" + str(entry['pwid']) + "' >"
        print "<td><input type='submit' name='mode' value='edit'/></td></form>"


        print "<form method='post' action='get.py'>"
        print " <input type='hidden' name='pwid' value='" + str(entry['pwid']) + "' >"
        print "<td><input type='submit' name='mode' value='get'/></td></form>"

        print "</tr>"


    def print_list_footer(self):
        print "</table> </tr>"

    def quit(self, s='', r=0):
        if s != '': print s
        print "<br><br><br><br><br>   <sub>"
        print "<a href=https://github.com/maldex/PassWebTool>PassWebTool</a>&nbsp;",
        print "<a href='list.py'>list</a>",
        print "<a href='get.py'>get</a>",
        print "<a href='edit.py'>edit</a>",
        print "&nbsp;auth:"
        if environ.has_key('REMOTE_USER'):
            print environ['REMOTE_USER']
        else:
            print "None"


        print "</sub>"
        quit(r)