@image =
	upload: (input) ->
	    if input.files
	    	images = $(input).parent().prev()
	    	if images.hasClass 'images-form'
		    	for f in input.files
		    		reader = new FileReader()
		    		reader.onload = (e) ->
		    			images.append "<div>
								<div class='btn red remove'></div>
								<a href='#{e.target.result}' data-lightbox='product'><img src='#{e.target.result}'></a>
							</div>"
		    		reader.readAsDataURL f
		    else
		    	reader = new FileReader()
	    		reader.onload = (e) ->
	    			images.append "<div>
							<div class='btn red remove' onclick='image.removeNewOneImage(this)'></div>
							<a href='#{e.target.result}' data-lightbox='product'><img src='#{e.target.result}'></a>
						</div>"
		    	reader.readAsDataURL input.files[0]
		    	$(input).parent().hide 300
	removeNewOneImage: (el) ->
		div = $(el).parent()
		label = div.parent().next().show(300)
		input = label.find 'input'
		input.replaceWith(input = input.clone true)
		div.remove()
	removeOneImage: (el, field, val) ->
		$(el).parent().after "<input class='remove-image' type='hidden' data-field='#{field}' value='#{val}'>"
		@removeNewOneImage el