@roomInit = (editor) ->
	combinedThin = new THREE.Geometry();
	combinedBold = new THREE.Geometry();

	drawLine = (line, combined) ->
		geometry = new THREE.Geometry();
		geometry.vertices = [new THREE.Vector3(line.x1, line.y1, line.z1), new THREE.Vector3(line.x2, line.y2, line.z2)]
		combined.merge( geometry );
		line.x1 = line.x2
		line.y1 = line.y2
		line.z1 = line.z2
		line

	createGrid = (size) ->

		drawSquare = (line, cb1, cb2, combined) ->
			line = drawLine line, combined
			line = cb1 line
			line = drawLine line, combined
			line = cb2 line
			line = drawLine line, combined
			drawLine (cb1 line), combined

		newSize = {width: size.width, height: size.height, depth: size.depth}
		while newSize.depth >= -size.depth
			if newSize.depth % 200
				combined = combinedThin
			else
				combined = combinedBold
			drawSquare {x1: -newSize.width/2, y1: -newSize.height/2, z1: -newSize.depth/2, x2: -newSize.width/2, y2: newSize.height/2, z2: -newSize.depth/2}, (line) ->
				line.x2 = -line.x2
				line
			, (line) ->
				line.y2 = -newSize.height/2
				line
			, combined
			newSize.depth -= 10
		room = new THREE.Object3D();
		room.id = 'room'
		room.add new THREE.Line( combinedThin, new THREE.LineBasicMaterial color: size.color1, THREE.LineStrip );
		room.add new THREE.Line( combinedBold, new THREE.LineBasicMaterial color: size.color2, THREE.LineStrip );
		combinedThin = new THREE.Geometry();
		combinedBold = new THREE.Geometry();
		newSize = {width: size.width, height: size.height, depth: size.depth}
		while newSize.height >= -size.height
			if (newSize.height+100) % 200
				combined = combinedThin
			else
				combined = combinedBold
			drawSquare {x1: -newSize.width/2, y1: newSize.height/2, z1: -newSize.depth/2, x2: newSize.width/2, y2: newSize.height/2, z2: -newSize.depth/2}, (line) ->
				line.z2 = -line.z2
				line
			, (line) ->
				line.x2 = -line.x2
				line
			, combined
			newSize.height -= 10
		room.add new THREE.Line( combinedThin, new THREE.LineBasicMaterial color: size.color1, THREE.LineStrip );
		room.add new THREE.Line( combinedBold, new THREE.LineBasicMaterial color: size.color2, THREE.LineStrip );
		combinedThin = new THREE.Geometry();
		combinedBold = new THREE.Geometry();
		newSize = {width: size.width, height: size.height, depth: size.depth}
		while newSize.width >= -size.width
			if newSize.width % 200
				combined = combinedThin
			else
				combined = combinedBold
			drawSquare {x1: -newSize.width/2, y1: -newSize.height/2, z1: -newSize.depth/2, x2: -newSize.width/2, y2: newSize.height/2, z2: -newSize.depth/2}, (line) ->
				line.z2 = -line.z2
				line
			, (line) ->
				line.y2 = -newSize.height/2
				line
			, combined
			newSize.width -= 10
		room.add new THREE.Line( combinedThin, new THREE.LineBasicMaterial color: size.color1, THREE.LineStrip );
		room.add new THREE.Line( combinedBold, new THREE.LineBasicMaterial color: size.color2, THREE.LineStrip );
		editor.scene.add room

	config = new Config();
	room = config.getKey( 'room' )
	unless room?
		room = {}
		room.width = prompt('Введите ширину комнаты (см)', 400)
		room.depth = prompt('Введите длину комнаты (см)', 600)
		room.height = prompt('Введите высоту комнаты (см)', 300)
		room.color1 = 0xffcccc
		room.color2 = 0xff8888
		config.setKey( 'room', room );
	attachToGrid = config.getKey( 'attachToGrid' )
	unless room?
		config.setKey( 'attachToGrid', false );
	createGrid room