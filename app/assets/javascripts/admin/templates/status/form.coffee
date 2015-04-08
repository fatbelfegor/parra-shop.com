app.templates.form.status =
	table: [
		{
			tr: [
				{
					td: [
						{
							header: "name"
							field: "name"
							validation:
								presence: true
								uniq: true
						}
					]
				}
			]
		}
	]