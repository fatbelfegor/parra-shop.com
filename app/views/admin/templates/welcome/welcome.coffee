app.page = ->
	wallpapers = [
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-86222.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-3922.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-108024.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-26545.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-78665.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-53092.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-57785.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-101496.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-6352.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-11706.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-10694.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-6529.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-725.jpg',
		'http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-11779.jpg'
	]
	admin = app.data.users_count is 0
	"<div id='welcome' style='background-image: url(\"#{wallpapers[Math.floor(Math.random() * wallpapers.length)]}\")'>
		<form action='#{if admin then '/create_admin' else '/users/sign_in'}' method='post'#{if admin then " style='height: 268px; margin-top: -155px'" else ""}>
			<p>E-mail:</p>
			<input type='email' name='user[email]'>
			<p>Пароль:</p>
			<input type='password' name='user[password]'>
			#{if admin then "<p>Подтверждение пароля:</p>
				<input type='password' name='user[password_confirmation]'>" else ""}
			<div>
				<label class='checkbox'>
					#{if !admin then "<div>
						<input type='checkbox' name='user[remember_me]' onchange='$(this).parent().toggleClass(\"checked\")'>
					</div>" else ""}
					#{if admin then "Администратор" else 'Запомнить меня'}
				</label>
				<input class='btn blue' type='submit' value='#{if admin then 'Создать' else 'Войти'}'>
			</div>
			<input name='authenticity_token' type='hidden' value='#{app.data.authenticity_token}'>
		</form>
	</div>"