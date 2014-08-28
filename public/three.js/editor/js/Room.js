// Generated by CoffeeScript 1.7.1
(function() {
  this.roomInit = function(editor) {
    var attachToGrid, config, createGrid, room;
    createGrid = function(room) {
      var drawLine, drawSquare, roomAdd, roomObj, wall, walls, _i, _len, _ref;
      roomObj = new THREE.Object3D();
      roomObj.id = 'room';
      walls = {
        ceil: [[0, 2], [room.width / 2, room.height / 2, room.depth / 2]],
        floor: [[0, 2], [room.width / 2, -room.height / 2, room.depth / 2]],
        left: [[0, 1], [room.width / 2, room.height / 2, room.depth / 2]],
        right: [[0, 1], [room.width / 2, room.height / 2, -room.depth / 2]],
        front: [[1, 2], [room.width / 2, room.height / 2, room.depth / 2]],
        back: [[1, 2], [-room.width / 2, room.height / 2, room.depth / 2]]
      };
      roomAdd = function(geometry, color) {
        return roomObj.add(new THREE.Line(geometry, new THREE.LineBasicMaterial({
          color: color
        }, THREE.LineStrip)));
      };
      drawLine = function(line, color) {
        var geometry;
        geometry = new THREE.Geometry();
        geometry.vertices = [new THREE.Vector3(line[0], line[1], line[2]), new THREE.Vector3(line[3], line[4], line[5])];
        return roomAdd(geometry, color);
      };
      drawSquare = function(square) {
        var a, b, color, end, i, line, x1, x2, y1, y2, z1, z2, _i, _results;
        _results = [];
        for (i = _i = 0; _i <= 1; i = ++_i) {
          a = square[0][i];
          b = square[0][Math.abs(i - 1)];
          end = -square[1][a];
          line = [square[1][0], square[1][1], square[1][2], square[1][0], square[1][1], square[1][2]];
          _results.push((function() {
            var _results1;
            _results1 = [];
            while (line[a] >= end) {
              if (line[a] % 100) {
                color = room.color1;
              } else {
                color = room.color2;
              }
              x1 = line[0];
              y1 = line[1];
              z1 = line[2];
              line[b] *= -1;
              x2 = line[0];
              y2 = line[1];
              z2 = line[2];
              drawLine([x1, y1, z1, x2, y2, z2], color);
              _results1.push(line[a] -= 10);
            }
            return _results1;
          })());
        }
        return _results;
      };
      _ref = room.walls;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        wall = _ref[_i];
        if (wall.on) {
          drawSquare(walls[wall.name]);
        }
      }
      return editor.scene.add(roomObj);
    };
    config = new Config();
    room = config.getKey('room');
    if (!((room != null) && (room.walls != null))) {
      room = {};
      room.width = prompt('Введите ширину комнаты (см)', 400);
      room.depth = prompt('Введите длину комнаты (см)', 600);
      room.height = prompt('Введите высоту комнаты (см)', 300);
      room.color1 = 0xffcccc;
      room.color2 = 0xff8888;
      room.walls = [
        {
          on: false,
          name: 'ceil'
        }, {
          on: true,
          name: 'floor'
        }, {
          on: true,
          name: 'left'
        }, {
          on: true,
          name: 'right'
        }, {
          on: false,
          name: 'front'
        }, {
          on: true,
          name: 'back'
        }
      ];
      config.setKey('room', room);
    }
    attachToGrid = config.getKey('attachToGrid');
    if (attachToGrid == null) {
      config.setKey('attachToGrid', false);
    }
    return createGrid(room);
  };

}).call(this);
