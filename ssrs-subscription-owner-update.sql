
select	'update dbo.Subscriptions set OwnerID = ' + '''' + 'AFC3D62E-8195-4565-B515-B2543063F4B2' + '''' + ' where SubscriptionID = ' + '''' + cast(SubscriptionID as varchar(36)) + '''' + ';' as DeployScript,
		'update dbo.Subscriptions set OwnerID = ' + '''' + cast(OwnerID as varchar(36)) + '''' + ' where SubscriptionID = ' + '''' + cast(SubscriptionID as varchar(36)) + '''' + ';' as RollbackScript,
		*
from	dbo.Subscriptions


