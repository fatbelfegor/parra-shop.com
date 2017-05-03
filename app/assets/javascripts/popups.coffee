@openPopup = (html) ->
	document.body.style.overflow = 'hidden'
	popupContainer.innerHTML = html
	popupContainer.style.display = 'flex'
	getComputedStyle(popupContainer).top
	popupContainer.className = 'active'

@closePopup = (e) ->
	if e is true or e.target is popupContainer
		popupContainer.style.display = 'none'
		document.body.style.overflow = 'auto'

@openOrderProjectPopup = ->
	openPopup """<form id="popupOrderProject">
		<div class='close' onclick='closePopup(true)'>✖</div>
		<header>
			<div class="title">Выберите удобный для Вас салон</div>
			<div class="subtitle">продавцы-консультанты свяжутся с Вами для уточнения деталей проекта</div>
		</header>
		<hr>
		<div class="list">
			<div class="item">
				<div class="input"><input type="radio" name="shop" value="МЦ «Мебель PARK»"></div>
				<div class="color red"></div>
				<p>
					<b>МЦ «Мебель PARK»</b><img src="/assets/metro.png">«Румянцево»,
					<br>
					г.Москва, Киевское шоссе, Строение 1, 3 вход, 3 этаж, тел: +7-499-940-12-29
				</p>
			</div>
			<div class="item">
				<div class="input"><input type="radio" name="shop" value="МЦ «Армада»"></div>
				<div class="color gray"></div>
				<p>
					<b>МЦ «Армада»</b><img src="/assets/metro.png">«Пражская»,
					<br>
					г.Москва, ул. Кировоградская, д. 11/1, 2 этаж, тел: +7-495-665-11-52
				</p>
			</div>
			<div class="item">
				<div class="input"><input type="radio" name="shop" value="МЦ «Roomer»"></div>
				<div class="color gray"></div>
				<p>
					<b>МЦ «Roomer»</b><img src="/assets/metro.png">«Автозаводская»,
					<br>
					г.Москва, ул. Ленинская Слобода, д. 26, 2 этаж, тел: +7-499-426-46-06
				</p>
			</div>
			<div class="item">
				<div class="input"><input type="radio" name="shop" value="ТЦ «Твой дом - Крокус»"></div>
				<div class="color blue"></div>
				<p>
					<b>ТЦ «Твой дом - Крокус»</b><img src="/assets/metro.png">«Мякинино»,
					<br>
					г.Москва, 65-66 км МКАД, 2 этаж, тел: +7-499-340-09-08
				</p>
			</div>
			<div class="item">
				<div class="input"><input type="radio" name="shop" value="МЦ «Империя»"></div>
				<div class="color gray"></div>
				<p>
					<b>МЦ «Империя»</b><img src="/assets/metro.png">«Алфутьево»,
					<br>
					г.Москва, Дмитровское шоссе д. 159, 3 этаж, тел: +7-499-899-07-09
				</p>
			</div>
			<div class="item">
				<div class="input"><input type="radio" name="shop" value="ТРК «Красный Кит»"></div>
				<div class="color orange"></div>
				<p>
					<b>ТРК «Красный Кит»</b><img src="/assets/metro.png">«Медедково»,
					<br>
					г.Мытищи, Шараповский проезд, вл. 2, 1 этаж, тел: +7-499-347-09-09
				</p>
			</div>
			<div class="item">
				<div class="input"><input type="radio" name="shop" value="МЦ «Вагант»"></div>
				<div class="color gray"></div>
				<p>
					<b>МЦ «Вагант»</b><img src="/assets/metro.png">«Бульвар Дмитрия Донского»,
					<br>
					г.Подольск, ул. Стационарная, д.11, 1 этаж, тел: +7-499-400-58-18
				</p>
			</div>
		</div>
		<hr>
		<div class="form">
			<label class="input">
				<span>Ваше имя *</span>
				<input type="text" name="name" required>
			</label>
			<label class="input">
				<span>Email *</span>
				<input type="email" name="email" required>
			</label>
			<label class="input">
				<span>Телефон *</span>
				<input class="short" type="text" name="phone" required>
			</label>
			<div class="hint">* Поля, обязательные для заполнения</div>
		</div>
		<hr>
		<label class="submit">
			<div class="btn white">Заказать дизайн проект</div>
			<input type="submit">
		</label>
	</form>"""
	popupOrderProject.onsubmit = ->
		d = @elements
		$.post '/api/order_project', name: d.name.value, email: d.email.value, phone: d.phone.value

		openPopup "<div class='success'>Ваша заявка отправлена!" +
			"<div class='close' onclick='closePopup(true)'>✖</div></div>"

		setTimeout ->
			closePopup true
		, 3000
		
		false

@openOrderCredit = ->
	openPopup """<form id="popupOrderProject">
		<div class='close' onclick='closePopup(true)'>✖</div>
		<header>
			<div class="title">Заказать покупку в кредит</div>
			<div class="subtitle">продавцы-консультанты свяжутся с Вами для уточнения деталей</div>
		</header>
		<hr>
		<div class="form">
			<label class="input">
				<span>Ваше имя *</span>
				<input type="text" name="name" required>
			</label>
			<label class="input">
				<span>Email *</span>
				<input type="email" name="email" required>
			</label>
			<label class="input">
				<span>Телефон *</span>
				<input class="short" type="text" name="phone" required>
			</label>
			<div class="hint">* Поля, обязательные для заполнения</div>
		</div>
		<hr>
		<label class="submit">
			<div class="btn white">Заказать дизайн проект</div>
			<input type="submit">
		</label>
	</form>"""
	popupOrderProject.onsubmit = ->
		d = @elements
		$.post '/api/order_credit', name: d.name.value, email: d.email.value, phone: d.phone.value

		openPopup "<div class='success'>Ваша заявка отправлена!" +
			"<div class='close' onclick='closePopup(true)'>✖</div></div>"

		setTimeout ->
			closePopup true
		, 3000
		
		false