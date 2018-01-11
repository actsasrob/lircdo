#!/usr/bin/env python

import copy
import glob
import json
import re
import subprocess

env_file=".env"
catalog_internal_file="./catalog_internal.json"
catalog_external_file="./catalog_external.json"

with open('sslcert/cacert.pem', 'r') as myfile:
    cacert=myfile.read()
#    cacert=myfile.read().replace('\n', '')

catalog_internal={'intents': []}
#catalog_external={'intents': []}
catalog_external={'ca': cacert}

def read_env_vars(envfilename = '.env'): 
   myvars = {}
   with open(envfilename) as myfile:
      for line in myfile:
         name, var = line.partition("=")[::2]
         myvars[name.strip()] = var.strip('\'"\n')
   return myvars

def process_lircscript(filename):
   retVal={ 'numargs': 0 }
   p1 = subprocess.Popen(['grep', 'meta:', filename], stdout=subprocess.PIPE)
   # Run the command
   output = p1.communicate()[0]
   #print "filename=" + filename
   output = output.splitlines()
   #print "output="
   #print repr(output)
   for line in output:
      #print "line: " + line
      m = re.search( r'^(.*meta: )([^=]+)=(.*)$', line, re.M|re.I)
      if m:
         thekey,thevalue=m.group(2,3)
         retVal[thekey] = thevalue
   missingfields=False
   for key in ('name', 'displayname', 'intent'):
      if key not in retVal:
         print 'error: script={} missing {} key'.format(filename, key)
         missingfields=True
   if missingfields:
      print 'info: skipping script={}'.format(filename)
      retVal.clear()
   #print "debug: process_lircscript: retVal=", retVal 
   return retVal

env_vars = read_env_vars(env_file)
print "env_vars: ", env_vars

LIRCSCRIPTS_LOCATION='./lircscripts'
if 'LIRCSCRIPTS_LOCATION' in env_vars:
  LIRCSCRIPTS_LOCATION=env_vars['LIRCSCRIPTS_LOCATION']

if 'LIRCDO_PAGE_SECRET' in env_vars:
   LIRCDO_PAGE_SECRET=env_vars['LIRCDO_PAGE_SECRET']
   catalog_internal['SHARED_SECRET']=LIRCDO_PAGE_SECRET
   catalog_external['SHARED_SECRET']=LIRCDO_PAGE_SECRET
else:
   print 'error: environment vars file {} must set LIRCDO_PAGE_SECRET env var'.format(env_file)
   exit(1)

if 'APP_FQDN' in env_vars:
   APP_FQDN=env_vars['APP_FQDN']
   catalog_external['CALLBACK_APP_FQDN']=APP_FQDN
else:
   print 'error: environment vars file {} must set APP_FQDN env var'.format(env_file)
   exit(1)

if 'PORT' in env_vars:
   PORT=env_vars['PORT']
   catalog_external['CALLBACK_APP_PORT']=PORT
else:
   print 'error: environment vars file {} must set PORT env var'.format(env_file)
   exit(1)

catalog_external['CALLBACK_APP_SCHEME']='https'

print "LIRCSCRIPTS_LOCATION=", LIRCSCRIPTS_LOCATION

lircscripts=glob.glob(LIRCSCRIPTS_LOCATION + '/*.sh')
#print "lircscripts: ", lircscripts
lircscripts=sorted(lircscripts)
#print "lircscripts: ", lircscripts
for filename in lircscripts:
   dict = process_lircscript(filename)
   if len(dict) > 0:
      #intents = catalog_external['intents']
      #intents.append(dict)
      #catalog_external['intents']=intents
      
      internal_dict = copy.deepcopy(dict)
      internal_dict['lircscript']=filename
      intents = catalog_internal['intents']
      intents.append(internal_dict)
      catalog_internal['intents']=intents
#print "catalog_internal"
#print(json.dumps(catalog_internal, indent=4))

#print "\n\n"

print "catalog_external"
print(json.dumps(catalog_external, indent=4))

with open(catalog_internal_file, 'w') as outfile:
    json.dump(catalog_internal, outfile)

with open(catalog_external_file, 'w') as outfile:
    json.dump(catalog_external, outfile)

print 'info: internal catalog written to {}'.format(catalog_internal_file)
print 'info: external catalog written to {}'.format(catalog_external_file)
