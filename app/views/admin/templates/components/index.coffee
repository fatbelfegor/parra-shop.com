app.page = ->
	ret = "<h1>Компоненты</h1>
		<div class='content' id='components'>
			<div>
				<div class='name'><i class='icon-newspaper'></i>Страницы<div class='btn purple' onclick='component.setup(this)'>Настроить</div></div>
				<form class='setup' action='components/create' method='post'>
					<input type='hidden' name='name' value='pages'>
					<label class='checkbox'><div class='checked'><input name='seo_title' checked='checked' type='checkbox' onchange='$(this).parent().toggleClass(\"checked\")'></div><span>Seo_title</span></label>
					<label class='checkbox'><div class='checked'><input name='seo_description' checked='checked' type='checkbox' onchange='$(this).parent().toggleClass(\"checked\")'></div><span>Seo_description</span></label>
					<label class='checkbox'><div class='checked'><input name='seo_keywords' checked='checked' type='checkbox' onchange='$(this).parent().toggleClass(\"checked\")'></div><span>Seo_keywords</span></label>
					<label class='checkbox'><div><input name='seo_keywords' type='checkbox' onchange='$(this).parent().toggleClass(\"checked\")'></div><span>Timestamps</span></label>
					<div class='text-center'><div class='btn green' onclick='component.create(this)'>Добавить</div></div>
				</form>
			</div>
			<div>
				<div class='name'><i class='icon-images'></i>Изображения<div class='btn green'>Добавить</div></div>
			</div>
		</div>"
	ret