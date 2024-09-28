select
	'CREATE CREDENTIAL ' + name + ' WITH IDENTITY = ''' + credential_identity + ''', SECRET = ''MY-PASSWORD'';'
from
	sys.credentials 
order by name;