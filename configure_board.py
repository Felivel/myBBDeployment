import requests
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--bbname", help="myBB Name")
parser.add_argument("--bburl", help="myBB URL")
parser.add_argument("--websitename", help="Website name.")
parser.add_argument("--websiteurl", help="Website URL.")
parser.add_argument("--cookiedomain", help="Cookie domain.")
parser.add_argument("--cookiepath", help="Cookie path.")
parser.add_argument("--contactemail", help="Site contact email.")
parser.add_argument("--pin", help="Administrator pin.")

parser.add_argument("--adminuser", help="Administrator user.")
parser.add_argument("--adminpass", help="Administrator password.")
parser.add_argument("--adminemail", help="Administrator email.")

args = parser.parse_args()

url = "http://localhost/install/index.php"

# Create board
payload = {}
payload['bbname'] = args.bbname
payload['bburl'] = args.bburl
payload['websitename]'] = args.websitename
payload['websiteurl'] = args.websiteurl
payload['cookiedomain'] = args.cookiedomain
payload['cookiepath'] = args.cookiepath
payload['contactemail'] = args.contactemail 
payload['pin'] = args.pin
payload['action'] = 'adminuser'
r = requests.post(url, payload)
if r.status_code == 200:
	print "Board created sucessfully."
else:
	print r.status_code

# Create admin
payload = {}
payload['adminuser'] = args.adminuser
payload['adminpass'] = args.adminpass
payload['adminpass2]'] = args.adminpass
payload['adminemail'] = args.adminemail
r = requests.post(url, payload)
if r.status_code == 200:
	print "Site admin created sucessfully."
else:
	print r.status_code

payload = {'action':'final'}
r = requests.post(url, payload)
if r.status_code == 200:
	print "Install Done."
else:
	print r.status_code