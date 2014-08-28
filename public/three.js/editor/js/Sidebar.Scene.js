Sidebar.Scene = function ( editor ) {

	var signals = editor.signals;

	var container = new UI.CollapsiblePanel();

	container.addStatic( new UI.Text( 'SCENE' ) );
	container.add( new UI.Break() );

	var ignoreObjectSelectedSignal = false;

	var outliner = new UI.FancySelect().setId( 'outliner' );
	outliner.onChange( function () {

		ignoreObjectSelectedSignal = true;

		editor.selectById( parseInt( outliner.getValue() ) );

		ignoreObjectSelectedSignal = false;

	} );
	container.add( outliner );
	container.add( new UI.Break() );

	// fog

	var updateFogParameters = function () {

		var near = fogNear.getValue();
		var far = fogFar.getValue();
		var density = fogDensity.getValue();

		signals.fogParametersChanged.dispatch( near, far, density );

	};

	var fogTypeRow = new UI.Panel();
	var fogType = new UI.Select().setOptions( {

		'None': 'None',
		'Fog': 'Linear',
		'FogExp2': 'Exponential'

	} ).setWidth( '150px' ).setColor( '#444' ).setFontSize( '12px' )
	fogType.onChange( function () {

		var type = fogType.getValue();
		signals.fogTypeChanged.dispatch( type );

		refreshFogUI();

	} );

	fogTypeRow.add( new UI.Text( 'Fog' ).setWidth( '90px' ) );
	fogTypeRow.add( fogType );

	container.add( fogTypeRow );

	// fog color

	var fogColorRow = new UI.Panel();
	fogColorRow.setDisplay( 'none' );

	var fogColor = new UI.Color().setValue( '#aaaaaa' )
	fogColor.onChange( function () {

		signals.fogColorChanged.dispatch( fogColor.getHexValue() );

	} );

	fogColorRow.add( new UI.Text( 'Fog color' ).setWidth( '90px' ) );
	fogColorRow.add( fogColor );

	container.add( fogColorRow );

	// fog near

	var fogNearRow = new UI.Panel();
	fogNearRow.setDisplay( 'none' );

	var fogNear = new UI.Number( 1 ).setWidth( '60px' ).setRange( 0, Infinity ).onChange( updateFogParameters );

	fogNearRow.add( new UI.Text( 'Fog near' ).setWidth( '90px' ) );
	fogNearRow.add( fogNear );

	container.add( fogNearRow );

	var fogFarRow = new UI.Panel();
	fogFarRow.setDisplay( 'none' );

	// fog far

	var fogFar = new UI.Number( 5000 ).setWidth( '60px' ).setRange( 0, Infinity ).onChange( updateFogParameters );

	fogFarRow.add( new UI.Text( 'Fog far' ).setWidth( '90px' ) );
	fogFarRow.add( fogFar );

	container.add( fogFarRow );

	// fog density

	var fogDensityRow = new UI.Panel();
	fogDensityRow.setDisplay( 'none' );

	var fogDensity = new UI.Number( 0.00025 ).setWidth( '60px' ).setRange( 0, 0.1 ).setPrecision( 5 ).onChange( updateFogParameters );

	fogDensityRow.add( new UI.Text( 'Fog density' ).setWidth( '90px' ) );
	fogDensityRow.add( fogDensity );

	container.add( fogDensityRow );

	//

	var refreshFogUI = function () {

		var type = fogType.getValue();

		fogColorRow.setDisplay( type === 'None' ? 'none' : '' );
		fogNearRow.setDisplay( type === 'Fog' ? '' : 'none' );
		fogFarRow.setDisplay( type === 'Fog' ? '' : 'none' );
		fogDensityRow.setDisplay( type === 'FogExp2' ? '' : 'none' );

	};

	var roomSizeChange = function () {
		editor.scene.remove(editor.scene.getObjectById('room'))
		config.setKey( 'room', room );
		roomInit(editor);
	}

	var hexToRgb = function (hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16)/255,
        g: parseInt(result[2], 16)/255,
        b: parseInt(result[3], 16)/255
    } : null;
	}
	var setRoomColor = function (hex) {
		rgb = hexToRgb(hex);
		lines = editor.scene.getObjectById('room').children
		lines[0].material.color.r = rgb.r
		lines[0].material.color.g = rgb.g
		lines[0].material.color.b = rgb.b
		lines[2].material.color.r = rgb.r
		lines[2].material.color.g = rgb.g
		lines[2].material.color.b = rgb.b
		lines[4].material.color.r = rgb.r
		lines[4].material.color.g = rgb.g
		lines[4].material.color.b = rgb.b
		config.setKey( 'room', room );
	}
	var setRoomColor2 = function (hex) {
		rgb = hexToRgb(hex);
		lines = editor.scene.getObjectById('room').children
		lines[1].material.color.r = rgb.r
		lines[1].material.color.g = rgb.g
		lines[1].material.color.b = rgb.b
		lines[3].material.color.r = rgb.r
		lines[3].material.color.g = rgb.g
		lines[3].material.color.b = rgb.b
		lines[5].material.color.r = rgb.r
		lines[5].material.color.g = rgb.g
		lines[5].material.color.b = rgb.b
		config.setKey( 'room', room );
	}

	var config = new Config();
	var room = config.getKey( 'room', room )
	var roomUI = new UI.Panel();
	roomUI.add(new UI.Text( 'Ширина комнаты (см): ' ).setWidth( '180px' ));
	roomUI.add(new UI.Integer( parseFloat(room.width) ).setWidth( '60px' ).onChange( function () {
		room.width = parseInt(this.dom.value)
		roomSizeChange()
	}));
	roomUI.add(new UI.Text( 'Длина комнаты (см): ' ).setWidth( '180px' ));
	roomUI.add(new UI.Integer( parseFloat(room.depth) ).setWidth( '60px' ).onChange( function () {
		room.depth = parseInt(this.dom.value)
		roomSizeChange()
	}));
	roomUI.add(new UI.Text( 'Высота комнаты (см): ' ).setWidth( '180px' ));
	roomUI.add(new UI.Integer( parseFloat(room.height) ).setWidth( '60px' ).onChange( function () {
		room.height = parseInt(this.dom.value)
		roomSizeChange()
	}));
	roomUI.add(new UI.Text( 'Цвет: ' ).setWidth( '180px' ));
	roomUI.add(new UI.Color().setValue( '#'+room.color1.toString(16) ).onChange( function () {
		setRoomColor(this.dom.value);
	}));
	roomUI.add(new UI.Text( 'Цвет 2: ' ).setWidth( '180px' ));
	roomUI.add(new UI.Color().setValue( '#'+room.color2.toString(16) ).onChange( function () {
		setRoomColor2(this.dom.value);
	}));
	roomUI.add(new UI.Text( 'Перемещать по сетке: ' ).setWidth( '180px' ));
	roomUI.add(new UI.Checkbox().setValue(config.getKey( 'attachToGrid' )).onChange( function () {
		config.setKey( 'attachToGrid', this.dom.checked );
	}));
	roomUI.add(new UI.Text( 'Показывать потолок: ' ).setWidth( '180px' ));
	roomUI.add(new UI.Checkbox().setValue(room.walls[0].on).onChange( function () {
		room.walls[0].on = this.dom.checked
		roomSizeChange()
	}));
	container.add(roomUI);
	roomUI.add(new UI.Text( 'Показывать пол: ' ).setWidth( '180px' ));
	roomUI.add(new UI.Checkbox().setValue(room.walls[1].on).onChange( function () {
		room.walls[1].on = this.dom.checked
		roomSizeChange()
	}));
	container.add(roomUI);
	roomUI.add(new UI.Text( 'Показывать левую стену: ' ).setWidth( '180px' ));
	roomUI.add(new UI.Checkbox().setValue(room.walls[2].on).onChange( function () {
		room.walls[2].on = this.dom.checked
		roomSizeChange()
	}));
	container.add(roomUI);
	roomUI.add(new UI.Text( 'Показывать правую стену: ' ).setWidth( '180px' ));
	roomUI.add(new UI.Checkbox().setValue(room.walls[3].on).onChange( function () {
		room.walls[3].on = this.dom.checked
		roomSizeChange()
	}));
	container.add(roomUI);
	roomUI.add(new UI.Text( 'Показывать переднюю стену: ' ).setWidth( '180px' ));
	roomUI.add(new UI.Checkbox().setValue(room.walls[4].on).onChange( function () {
		room.walls[4].on = this.dom.checked
		roomSizeChange()
	}));
	container.add(roomUI);
	roomUI.add(new UI.Text( 'Показывать заднюю стену: ' ).setWidth( '180px' ));
	roomUI.add(new UI.Checkbox().setValue(room.walls[5].on).onChange( function () {
		room.walls[5].on = this.dom.checked
		roomSizeChange()
	}));
	container.add(roomUI);

	// events

	signals.sceneGraphChanged.add( function () {

		var scene = editor.scene;
		var sceneType = editor.getObjectType( scene );

		var options = [];

		options.push( { value: scene.id, html: '<span class="type ' + sceneType + '"></span> ' + scene.name } );

		( function addObjects( objects, pad ) {

			for ( var i = 0, l = objects.length; i < l; i ++ ) {

				var object = objects[ i ];
				var objectType = editor.getObjectType( object );

				var html = pad + '<span class="type ' + objectType + '"></span> ' + object.name;

				if ( object instanceof THREE.Mesh ) {

					var geometry = object.geometry;
					var material = object.material;

					var geometryType = editor.getGeometryType( geometry );
					var materialType = editor.getMaterialType( material );

					html += ' <span class="type ' + geometryType + '"></span> ' + geometry.name;
					html += ' <span class="type ' + materialType + '"></span> ' + material.name;

				}

				options.push( { value: object.id, html: html } );

				addObjects( object.children, pad + '&nbsp;&nbsp;&nbsp;' );

			}

		} )( scene.children, '&nbsp;&nbsp;&nbsp;' );

		outliner.setOptions( options );

		if ( editor.selected !== null ) {

			outliner.setValue( editor.selected.id );

		}

		if ( scene.fog ) {

			fogColor.setHexValue( scene.fog.color.getHex() );

			if ( scene.fog instanceof THREE.Fog ) {

				fogType.setValue( "Fog" );
				fogNear.setValue( scene.fog.near );
				fogFar.setValue( scene.fog.far );

			} else if ( scene.fog instanceof THREE.FogExp2 ) {

				fogType.setValue( "FogExp2" );
				fogDensity.setValue( scene.fog.density );

			}

		} else {

			fogType.setValue( "None" );

		}

		refreshFogUI();

	} );

	signals.objectSelected.add( function ( object ) {

		if ( ignoreObjectSelectedSignal === true ) return;

		outliner.setValue( object !== null ? object.id : null );

	} );

	return container;

}
