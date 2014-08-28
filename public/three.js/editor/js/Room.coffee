@roomInit = (editor) ->

	createGrid = (room) ->
		roomObj = new THREE.Object3D()
		roomObj.id = 'room'
		walls = {
			ceil: [[0, 2],
				[
					room.width / 2,
					room.height / 2,
					room.depth / 2
				]
			], floor: [[0, 2],
				[
					room.width / 2,
					-room.height / 2,
					room.depth / 2
				]
			], left: [[0, 1],
				[
					room.width / 2,
					room.height / 2,
					room.depth / 2
				]
			], right: [[0, 1],
				[
					room.width / 2,
					room.height / 2,
					-room.depth / 2
				]
			], front: [[1, 2],
				[
					room.width / 2,
					room.height / 2,
					room.depth / 2
				]
			], back: [[1, 2],
				[
					-room.width / 2,
					room.height / 2,
					room.depth / 2
				]
			]
		}

		roomAdd = (geometry, color) ->
			roomObj.add new THREE.Line( geometry, new THREE.LineBasicMaterial color: color, THREE.LineStrip );

		drawLine = (line, color) ->
			geometry = new THREE.Geometry();
			geometry.vertices = [
				new THREE.Vector3(line[0], line[1], line[2]),
				new THREE.Vector3(line[3], line[4], line[5])
		 	]
			roomAdd geometry, color

		drawSquare = (square) ->
			for i in [0..1]
				a = square[0][i]
				b = square[0][Math.abs(i-1)]
				end = -square[1][a]
				line = [square[1][0], square[1][1], square[1][2], square[1][0], square[1][1], square[1][2]]
				while line[a] >= end
					if line[a] % 100
						color = room.color1
					else
						color = room.color2
					x1 = line[0]
					y1 = line[1]
					z1 = line[2]
					line[b] *= -1
					x2 = line[0]
					y2 = line[1]
					z2 = line[2]
					drawLine([
						x1,
						y1,
						z1,
						x2,
						y2,
						z2
					], color)
					line[a] -= 10

		for wall in room.walls
			if wall.on
				drawSquare walls[wall.name]
		
		editor.scene.add roomObj

	# drawLine = (line, combined) ->
	# 	geometry = new THREE.Geometry();
	# 	geometry.vertices = [new THREE.Vector3(line.x1, line.y1, line.z1), new THREE.Vector3(line.x2, line.y2, line.z2)]
	# 	combined.merge( geometry );
	# 	line.x1 = line.x2
	# 	line.y1 = line.y2
	# 	line.z1 = line.z2
	# 	line

	# createGrid = (size) ->

	# 	drawSquare = (line, cb1, cb2, combined) ->
	# 		line = drawLine line, combined
	# 		line = cb1 line
	# 		line = drawLine line, combined
	# 		line = cb2 line
	# 		line = drawLine line, combined
	# 		drawLine (cb1 line), combined

	# 	newSize = {width: size.width, height: size.height, depth: size.depth}
	# 	while newSize.depth >= -size.depth
	# 		if newSize.depth % 200
	# 			combined = combinedThin
	# 		else
	# 			combined = combinedBold
	# 		drawSquare {x1: -newSize.width/2, y1: -newSize.height/2, z1: -newSize.depth/2, x2: -newSize.width/2, y2: newSize.height/2, z2: -newSize.depth/2}, (line) ->
	# 			line.x2 = -line.x2
	# 			line
	# 		, (line) ->
	# 			line.y2 = -newSize.height/2
	# 			line
	# 		, combined
	# 		newSize.depth -= 10
	# 	room = new THREE.Object3D();
	# 	room.id = 'room'
	# 	room.add new THREE.Line( combinedThin, new THREE.LineBasicMaterial color: size.color1, THREE.LineStrip );
	# 	room.add new THREE.Line( combinedBold, new THREE.LineBasicMaterial color: size.color2, THREE.LineStrip );
	# 	combinedThin = new THREE.Geometry();
	# 	combinedBold = new THREE.Geometry();
	# 	newSize = {width: size.width, height: size.height, depth: size.depth}
	# 	while newSize.height >= -size.height
	# 		if (newSize.height+100) % 200
	# 			combined = combinedThin
	# 		else
	# 			combined = combinedBold
	# 		drawSquare {x1: -newSize.width/2, y1: newSize.height/2, z1: -newSize.depth/2, x2: newSize.width/2, y2: newSize.height/2, z2: -newSize.depth/2}, (line) ->
	# 			line.z2 = -line.z2
	# 			line
	# 		, (line) ->
	# 			line.x2 = -line.x2
	# 			line
	# 		, combined
	# 		newSize.height -= 10
	# 	room.add new THREE.Line( combinedThin, new THREE.LineBasicMaterial color: size.color1, THREE.LineStrip );
	# 	room.add new THREE.Line( combinedBold, new THREE.LineBasicMaterial color: size.color2, THREE.LineStrip );
	# 	combinedThin = new THREE.Geometry();
	# 	combinedBold = new THREE.Geometry();
	# 	newSize = {width: size.width, height: size.height, depth: size.depth}
	# 	while newSize.width >= -size.width
	# 		if newSize.width % 200
	# 			combined = combinedThin
	# 		else
	# 			combined = combinedBold
	# 		drawSquare {x1: -newSize.width/2, y1: -newSize.height/2, z1: -newSize.depth/2, x2: -newSize.width/2, y2: newSize.height/2, z2: -newSize.depth/2}, (line) ->
	# 			line.z2 = -line.z2
	# 			line
	# 		, (line) ->
	# 			line.y2 = -newSize.height/2
	# 			line
	# 		, combined
	# 		newSize.width -= 10
	# 	room.add new THREE.Line( combinedThin, new THREE.LineBasicMaterial color: size.color1, THREE.LineStrip );
	# 	room.add new THREE.Line( combinedBold, new THREE.LineBasicMaterial color: size.color2, THREE.LineStrip );
	# 	editor.scene.add room

	config = new Config();
	room = config.getKey( 'room' )
	unless room?
		room = {}
		room.width = prompt('Введите ширину комнаты (см)', 400)
		room.depth = prompt('Введите длину комнаты (см)', 600)
		room.height = prompt('Введите высоту комнаты (см)', 300)
		room.color1 = 0xffcccc
		room.color2 = 0xff8888
		room.walls = [
			{on: false, name: 'ceil'},
			{on: true, name: 'floor'},
			{on: true, name: 'left'},
			{on: true, name: 'right'},
			{on: false, name: 'front'},
			{on: true, name: 'back'}
		]
		config.setKey( 'room', room );
	attachToGrid = config.getKey( 'attachToGrid' )
	unless attachToGrid?
		config.setKey( 'attachToGrid', false );
	createGrid room