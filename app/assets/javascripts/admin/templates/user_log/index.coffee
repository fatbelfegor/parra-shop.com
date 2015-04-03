app.templates.index.user_log =
	table: [
		{
			tr: [
				{
					td: [
						{
							attrs:
								style: 'width: 1px'
							show: "created_at"
							format:
								date: "dd.MM.yyyy, hh:mm"
						}
						{
							show: "action"
						}
					]
				}
			]
		}
	]