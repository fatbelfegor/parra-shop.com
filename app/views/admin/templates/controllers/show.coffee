app.page = ->
	contr = app.data.route.contr
	ret = "<h1 class='title'>Контроллер <b>#{contr}</b></h1>
		<div class='content'>
			<br>
			<div class='nav-tabs ace-nav-tabs'>
				<p onclick='openTab(this)' class='active'>Код</p>
				<p onclick='openTab(this)'>Добавить действие</p>
			</div>
			<div class='tabs ace-tabs'>
				<div class='active'>
					<form action='controllers/#{contr}/update'>
						<div class='btn green dashed' onclick='controller.code.update(this)'>Сохранить</div>
						<div class='ace-wrap'>
							<div id='ace-all' class='editor'></div>
						</div>
						<input type='hidden' name='code'>
						<div class='btn green dashed' onclick='controller.code.update(this)'>Сохранить</div>
					</form>
				</div>
				<div>
					<form action='controllers/#{contr}/action/create'>
						<div class='btn purple dashed' onclick='controller.action.create(this)'>Добавить</div>
						<label class='row'><p>Название: </p><input type='text' name='name'></label>
						<label class='checkbox'><div class='checked'><input onchange='checkbox(this)' type='checkbox' checked='checked' name='view'></div>Создать представление (view)</label>
						<label class='checkbox'><div><input onchange='checkbox(this)' type='checkbox' name='root'></div>Сделать главной страницей</label>
						<br>
						<div class='btn purple dashed' onclick='controller.action.create(this)'>Добавить</div>
					</form>
				</div>
			</div>
			<br><br><br>
		</div>
		<script src='/ace/ace.js'>"
	ret
app.after = ->
	contr = app.data.route.contr
	window.aceEditor = ace.edit "ace-all"
	aceEditor.getSession().setMode("ace/mode/ruby")
	aceEditor.setValue(app.data.controllers[contr].code)