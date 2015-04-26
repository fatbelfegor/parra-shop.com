app.templates.form.page =
	page: ->
		ret = tr [
			td field("Название", "name", validation: presence: true), attrs: width: '50%'
			td field("URL", "url", validation: {presence: true, uniq: true}), attrs: width: '50%'
		]
		ret += tr [
			td field("SEO title", "seo_title")
			td field("SEO keywords (через запятую)", "seo_keywords")
		]
		ret += tr td text("Описание": "description", "SEO description": "seo_description": "textarea"), attrs: colspan: 3
		title('статью') + form btn_save() + "<table>" + ret + "</table>" + btn_save()