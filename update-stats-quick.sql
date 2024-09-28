select      'update statistics ' + name + ';'
from        sys .tables
where       type_desc = 'user_table'
			and Name not in (
			''
			)
order by     Name

