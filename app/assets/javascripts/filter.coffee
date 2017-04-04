color = catalogFilter.dataset.color
id = catalogFilter.dataset.id

applyBtn = """<div data-action class="checkboxes">
	<div class="btn" data-action="apply">Применить</div>
</div>"""

state =
	color: []
	texture: []
	length: []
	width: []
	height: []

refreshProducts = ->
	xhr = new XMLHttpRequest
	url = "/api/filter_get?id=#{id}&color=#{color}"
	for k, v of state
		url += "&#{k}=#{JSON.stringify v}"
	xhr.open "GET", url
	xhr.onload = ->
		products.innerHTML = @response
		$('.photoes').slick()
	xhr.send()

catalogFilter.onclick = (e) ->
	if el = e.target.closest '[data-action]'
		switch el.dataset.action
			when 'dropdown'
				if el.className is 'active'
					el.className = ''
				else if el.ready
					el.className = 'active'
				else
					switch el.dataset.type
						when 'list'
							xhr = new XMLHttpRequest
							xhr.open "GET", "/api/filter_list?id=" +
								id + "&color=#{color}&column=#{el.dataset.column}"
							xhr.onload = ->
								el.ready = true
								s = ''
								for item in JSON.parse @response
									s += """<label>
										<input type="checkbox" value="#{item}"> #{item}
									</label>"""
								s += applyBtn
								el.getElementsByClassName('checkboxes')[0].innerHTML = s
								el.className = 'active'
							xhr.send()
						when 'range'
							xhr = new XMLHttpRequest
							xhr.open "GET", "/api/filter_range?id=" +
								id + "&color=#{color}&column=#{el.dataset.column}"
							xhr.onload = ->
								o = JSON.parse @response
								el.getElementsByClassName('range')[0].innerHTML = """
								<div class="inputs">
									<label>
										<span>от</span>
										<input type="number" value="#{o.min}" min="#{o.min}" max="#{o.max}">
									</label>
									<label>
										<span>до</span>
										<input type="number" value="#{o.max}" min="#{o.min}" max="#{o.max}">
									</label>
								</div>
								""" + applyBtn
								el.className = 'active'
							xhr.send()
			when 'apply'
				wrap = el.closest "[data-type]"
				{type, column} = wrap.dataset
				selected = state[column]
				inputs = wrap.getElementsByTagName 'input'
				switch type
					when 'list'
						selected.length = 0
						for input in inputs
							if input.checked
								selected.push input.value
					when 'range'
						selected[0] = inputs[0].value
						selected[1] = inputs[1].value
				refreshProducts()
			when 'clear'
				state[k].length = 0 for k of state
				refreshProducts()