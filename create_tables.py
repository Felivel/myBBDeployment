import requests
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--dbhost", help="Database hostname")
parser.add_argument("--dbengine", help="Database engine")
parser.add_argument("--dbuser", help="Database user")
parser.add_argument("--dbpass", help="Database password")
parser.add_argument("--dbname", help="Database name")
parser.add_argument("--tableprefix", help="Table prefix")
parser.add_argument("--encoding", help="Database encoding")
args = parser.parse_args()

url = "http://localhost/install/index.php"

# Create Tables
payload = {}
payload['dbengine'] = args.dbengine
payload['config[mysqli][dbhost]'] = args.dbhost
payload['config[mysqli][dbuser]'] = args.dbuser
payload['config[mysqli][dbpass]'] = args.dbpass
payload['config[mysqli][dbname]'] = args.dbname
payload['config[mysqli][tableprefix]'] = args.tableprefix
payload['config[mysqli][encoding]'] = args.encoding 
payload['config[mysql][dbhost]'] = ''
payload['config[mysql][dbuser]'] = ''
payload['config[mysql][dbpass]'] = ''
payload['config[mysql][dbname]'] = ''
payload['config[mysql][tableprefix]'] = ''
payload['config[mysql][encoding]'] = ''
payload['config[sqlite][dbname]'] = ''
payload['config[sqlite][tableprefix]'] = ''
payload['action'] = 'create_tables'

r = requests.post(url, payload)
if r.status_code = 200:
	print "Tables created sucessfully."
else:
	print r.status_code


# Populate tables
payload = {'action':'populate_tables'}
r = requests.post(url, payload)
if r.status_code = 200:
	print "Tables populated sucessfully."
else:
	print r.status_code

# Install Theme
payload = {'action':'templates'}
r = requests.post(url, payload)
if r.status_code = 200:
	print "Themes installed sucessfully."
else:
	print r.status_code

payload = {'action':'configuration'}
r = requests.post(url, payload)
if r.status_code = 200
	print "Configuration created sucessfully."
else:
	print r.status_code