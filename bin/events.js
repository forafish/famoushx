(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var IMap = function() { };
IMap.__name__ = true;
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		return null;
	}
};
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
};
Reflect.isObject = function(v) {
	if(v == null) return false;
	var t = typeof(v);
	return t == "string" || t == "object" && v.__enum__ == null || t == "function" && (v.__name__ || v.__ename__) != null;
};
Reflect.deleteField = function(o,field) {
	if(!Object.prototype.hasOwnProperty.call(o,field)) return false;
	delete(o[field]);
	return true;
};
Reflect.copy = function(o) {
	var o2 = { };
	var _g = 0;
	var _g1 = Reflect.fields(o);
	while(_g < _g1.length) {
		var f = _g1[_g];
		++_g;
		Reflect.setField(o2,f,Reflect.field(o,f));
	}
	return o2;
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
Std["int"] = function(x) {
	return x | 0;
};
var Type = function() { };
Type.__name__ = true;
Type.getClass = function(o) {
	if(o == null) return null;
	if((o instanceof Array) && o.__enum__ == null) return Array; else return o.__class__;
};
Type.createInstance = function(cl,args) {
	var _g = args.length;
	switch(_g) {
	case 0:
		return new cl();
	case 1:
		return new cl(args[0]);
	case 2:
		return new cl(args[0],args[1]);
	case 3:
		return new cl(args[0],args[1],args[2]);
	case 4:
		return new cl(args[0],args[1],args[2],args[3]);
	case 5:
		return new cl(args[0],args[1],args[2],args[3],args[4]);
	case 6:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5]);
	case 7:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
	case 8:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
	default:
		throw "Too many arguments";
	}
	return null;
};
var famous = {};
famous.core = {};
famous.core.Context = function(container) {
	var _g = this;
	this.container = container;
	this._allocator = new famous.core.ElementAllocator(container);
	this._node = new famous.core.RenderNode();
	this._eventOutput = new famous.core.EventHandler();
	this._size = famous.core.Context._getElementSize(this.container);
	this._perspectiveState = new famous.transitions.Transitionable(0);
	this._perspective = null;
	this._nodeContext = { allocator : this._allocator, transform : famous.core.Transform.identity, opacity : 1, origin : famous.core.Context._originZeroZero, size : this._size};
	this._eventOutput.on("resize",function(_) {
		_g.setSize(famous.core.Context._getElementSize(_g.container));
	});
};
famous.core.Context.__name__ = true;
famous.core.Context._getElementSize = function(element) {
	return [element.clientWidth,element.clientHeight];
};
famous.core.Context.prototype = {
	getAllocator: function() {
		return this._allocator;
	}
	,add: function(obj) {
		return this._node.add(obj);
	}
	,migrate: function(container) {
		if(container == this.container) return;
		this.container = container;
		this._allocator.migrate(container);
	}
	,getSize: function() {
		return this._size;
	}
	,setSize: function(size) {
		if(size == null) size = famous.core.Context._getElementSize(this.container);
		this._size[0] = size[0];
		this._size[1] = size[1];
	}
	,update: function(contextParameters) {
		if(contextParameters != null) {
			if(contextParameters.transform != null) this._nodeContext.transform = contextParameters.transform;
			if(contextParameters.opacity != null) this._nodeContext.opacity = contextParameters.opacity;
			if(contextParameters.origin != null) this._nodeContext.origin = contextParameters.origin;
			if(contextParameters.align != null) this._nodeContext.align = contextParameters.align;
			if(contextParameters.size != null) this._nodeContext.size = contextParameters.size;
		}
		var perspective = this._perspectiveState.get();
		if(perspective != this._perspective) {
			if(perspective != null) this.container.style.perspective = perspective.toFixed() + "px"; else this.container.style.perspective = "";
			if(perspective != null) this.container.style.webkitPerspective = perspective.toFixed(); else this.container.style.webkitPerspective = "";
			this._perspective = perspective;
		}
		this._node.commit(this._nodeContext);
	}
	,getPerspective: function() {
		return this._perspectiveState.get();
	}
	,setPerspective: function(perspective,transition,callback) {
		return this._perspectiveState.set(perspective,transition,callback);
	}
	,emit: function(type,event) {
		return this._eventOutput.emit(type,event);
	}
	,on: function(type,handler) {
		return this._eventOutput.on(type,handler);
	}
	,removeListener: function(type,handler) {
		return this._eventOutput.removeListener(type,handler);
	}
	,pipe: function(target) {
		return this._eventOutput.pipe(target);
	}
	,unpipe: function(target) {
		return this._eventOutput.unpipe(target);
	}
	,__class__: famous.core.Context
};
famous.core._DynamicMap = {};
famous.core._DynamicMap.DynamicMap_Impl_ = function() { };
famous.core._DynamicMap.DynamicMap_Impl_.__name__ = true;
famous.core._DynamicMap.DynamicMap_Impl_._new = function() {
	return { };
};
famous.core._DynamicMap.DynamicMap_Impl_.set = function(this1,key,value) {
	this1[key] = value;
};
famous.core._DynamicMap.DynamicMap_Impl_.get = function(this1,key) {
	return this1[key];
};
famous.core._DynamicMap.DynamicMap_Impl_.exists = function(this1,key) {
	return Object.prototype.hasOwnProperty.call(this1,key);
};
famous.core._DynamicMap.DynamicMap_Impl_.remove = function(this1,key) {
	return Reflect.deleteField(this1,key);
};
famous.core._DynamicMap.DynamicMap_Impl_.keys = function(this1) {
	return Reflect.fields(this1);
};
famous.core._DynamicMap.DynamicMap_Impl_.copy = function(this1) {
	return Reflect.copy(this1);
};
famous.core.ElementAllocator = function(container) {
	if(container == null) container = window.document.createDocumentFragment();
	this.container = container;
	this.detachedNodes = new haxe.ds.StringMap();
	this.nodeCount = 0;
};
famous.core.ElementAllocator.__name__ = true;
famous.core.ElementAllocator.prototype = {
	migrate: function(container) {
		var oldContainer = this.container;
		if(container == oldContainer) return;
		if(js.Boot.__instanceof(oldContainer,DocumentFragment)) container.appendChild(oldContainer); else while(oldContainer.hasChildNodes()) container.appendChild(oldContainer.removeChild(oldContainer.firstChild));
		this.container = container;
	}
	,allocate: function(type) {
		type = type.toLowerCase();
		if(!this.detachedNodes.exists(type)) {
			var v = [];
			this.detachedNodes.set(type,v);
			v;
		}
		var nodeStore = this.detachedNodes.get(type);
		var result;
		if(nodeStore.length > 0) result = nodeStore.pop(); else {
			result = window.document.createElement(type);
			this.container.appendChild(result);
		}
		this.nodeCount++;
		return result;
	}
	,deallocate: function(element) {
		var nodeType = element.nodeName.toLowerCase();
		var nodeStore = this.detachedNodes.get(nodeType);
		nodeStore.push(element);
		this.nodeCount--;
	}
	,getNodeCount: function() {
		return this.nodeCount;
	}
	,__class__: famous.core.ElementAllocator
};
famous.core.EventHandleable = function() { };
famous.core.EventHandleable.__name__ = true;
famous.core.EventHandleable.prototype = {
	__class__: famous.core.EventHandleable
};
famous.inputs = {};
famous.inputs.GenericSync = function(syncs,options) {
	this._eventInput = new famous.core.EventHandler();
	this._eventOutput = new famous.core.EventHandler();
	famous.core.EventHandler.setInputHandler(this,this._eventInput);
	famous.core.EventHandler.setOutputHandler(this,this._eventOutput);
	this._syncs = { };
	if(syncs != null) this.addSync(syncs);
	if(options != null) this.setOptions(options);
};
famous.inputs.GenericSync.__name__ = true;
famous.inputs.GenericSync.register = function(syncObject) {
	var _g = 0;
	var _g1 = Reflect.fields(syncObject);
	while(_g < _g1.length) {
		var key = _g1[_g];
		++_g;
		if(famous.inputs.GenericSync.registry[key] != null) {
			if(famous.inputs.GenericSync.registry[key] == syncObject[key]) return; else throw "this key is registered to a different sync class";
		} else famous.inputs.GenericSync.registry[key] = syncObject[key];
	}
};
famous.inputs.GenericSync.__super__ = famous.core.EventHandleable;
famous.inputs.GenericSync.prototype = $extend(famous.core.EventHandleable.prototype,{
	setOptions: function(options) {
		var _g = 0;
		var _g1 = Reflect.fields(this._syncs);
		while(_g < _g1.length) {
			var key = _g1[_g];
			++_g;
			this._syncs[key].setOptions(options);
		}
	}
	,pipeSync: function(key) {
		var sync = this._syncs[key];
		this._eventInput.pipe(sync);
		sync.pipe(this._eventOutput);
	}
	,unpipeSync: function(key) {
		var sync = this._syncs[key];
		this._eventInput.unpipe(sync);
		sync.unpipe(this._eventOutput);
	}
	,_addSingleSync: function(key,options) {
		if(famous.inputs.GenericSync.registry[key] == null) return;
		var value = Type.createInstance(famous.inputs.GenericSync.registry[key],[options]);
		this._syncs[key] = value;
		this.pipeSync(key);
	}
	,addSync: function(syncs) {
		if((syncs instanceof Array) && syncs.__enum__ == null) {
			var _syncs = syncs;
			var _g = 0;
			while(_g < _syncs.length) {
				var sync = _syncs[_g];
				++_g;
				this._addSingleSync(sync);
			}
		} else if(Reflect.isObject(syncs)) {
			var _g1 = 0;
			var _g11 = Reflect.fields(syncs);
			while(_g1 < _g11.length) {
				var key = _g11[_g1];
				++_g1;
				this._addSingleSync(key,syncs[key]);
			}
		}
	}
	,__class__: famous.inputs.GenericSync
});
famous.inputs.MouseSync = function(options) {
	this.options = Reflect.copy(famous.inputs.MouseSync.DEFAULT_OPTIONS);
	if(options != null) this.setOptions(options);
	this._eventInput = new famous.core.EventHandler();
	this._eventOutput = new famous.core.EventHandler();
	famous.core.EventHandler.setInputHandler(this,this._eventInput);
	famous.core.EventHandler.setOutputHandler(this,this._eventOutput);
	this._eventInput.on("mousedown",$bind(this,this._handleStart));
	this._eventInput.on("mousemove",$bind(this,this._handleMove));
	this._eventInput.on("mouseup",$bind(this,this._handleEnd));
	if(this.options.propogate) this._eventInput.on("mouseleave",$bind(this,this._handleLeave)); else this._eventInput.on("mouseleave",$bind(this,this._handleEnd));
	this._payload = { delta : null, position : null, velocity : null, clientX : null, clientY : null, offsetX : null, offsetY : null};
	this._position = null;
	this._prevCoord = null;
	this._prevTime = null;
};
famous.inputs.MouseSync.__name__ = true;
famous.inputs.MouseSync.prototype = {
	_clearPayload: function() {
		var payload = this._payload;
		payload.delta = null;
		payload.position = null;
		payload.velocity = null;
		payload.clientX = null;
		payload.clientY = null;
		payload.offsetX = null;
		payload.offsetY = null;
	}
	,_handleStart: function(event) {
		event.preventDefault();
		this._clearPayload();
		var x = event.clientX;
		var y = event.clientY;
		this._prevCoord = [x,y];
		this._prevTime = new Date().getTime();
		if(this.options.direction != null) this._position = 0; else this._position = [0,0];
		var payload = this._payload;
		payload.position = this._position;
		payload.clientX = x;
		payload.clientY = y;
		payload.offsetX = event.offsetX;
		payload.offsetY = event.offsetY;
		this._eventOutput.emit("start",payload);
	}
	,_handleMove: function(event) {
		if(this._prevCoord == null) return;
		var prevCoord = this._prevCoord;
		var prevTime = this._prevTime;
		var x = event.clientX;
		var y = event.clientY;
		var currTime = new Date().getTime();
		var diffX = x - prevCoord[0];
		var diffY = y - prevCoord[1];
		if(this.options.rails) {
			if(Math.abs(diffX) > Math.abs(diffY)) diffY = 0; else diffX = 0;
		}
		var diffTime = Math.max(currTime - prevTime,famous.inputs.MouseSync.MINIMUM_TICK_TIME);
		var velX = diffX / diffTime;
		var velY = diffY / diffTime;
		var scale = this.options.scale;
		var nextVel;
		var nextDelta;
		if(this.options.direction == famous.inputs.MouseSync.DIRECTION_X) {
			nextDelta = scale * diffX;
			nextVel = scale * velX;
			this._position += nextDelta;
		} else if(this.options.direction == famous.inputs.MouseSync.DIRECTION_Y) {
			nextDelta = scale * diffY;
			nextVel = scale * velY;
			this._position += nextDelta;
		} else {
			nextDelta = [scale * diffX,scale * diffY];
			nextVel = [scale * velX,scale * velY];
			this._position[0] += nextDelta[0];
			this._position[1] += nextDelta[1];
		}
		var payload = this._payload;
		payload.delta = nextDelta;
		payload.position = this._position;
		payload.velocity = nextVel;
		payload.clientX = x;
		payload.clientY = y;
		payload.offsetX = event.offsetX;
		payload.offsetY = event.offsetY;
		this._eventOutput.emit("update",payload);
		this._prevCoord = [x,y];
		this._prevTime = currTime;
	}
	,_handleEnd: function(event) {
		if(this._prevCoord == null) return;
		this._eventOutput.emit("end",this._payload);
		this._prevCoord = null;
		this._prevTime = null;
	}
	,_handleLeave: function(event) {
		var _g = this;
		if(this._prevCoord == null) return;
		var boundMove = null;
		var boundEnd = null;
		boundMove = function(event1) {
			_g._handleMove(event1);
		};
		boundEnd = function(event2) {
			_g._handleEnd(event2);
			window.document.removeEventListener("mousemove",boundMove);
			window.document.removeEventListener("mouseup",boundEnd);
		};
		window.document.addEventListener("mousemove",boundMove);
		window.document.addEventListener("mouseup",boundEnd);
	}
	,getOptions: function() {
		return this.options;
	}
	,setOptions: function(options) {
		if(options.direction != null) this.options.direction = options.direction;
		if(options.rails != null) this.options.rails = options.rails;
		if(options.scale != null) this.options.scale = options.scale;
		if(options.propogate != null) this.options.propogate = options.propogate;
	}
	,__class__: famous.inputs.MouseSync
};
famous.inputs.TouchSync = function(options) {
	this.options = Reflect.copy(famous.inputs.TouchSync.DEFAULT_OPTIONS);
	if(options != null) this.setOptions(options);
	this._eventOutput = new famous.core.EventHandler();
	this._touchTracker = new famous.inputs.TouchTracker();
	famous.core.EventHandler.setOutputHandler(this,this._eventOutput);
	famous.core.EventHandler.setInputHandler(this,this._touchTracker);
	this._touchTracker.on("trackstart",$bind(this,this._handleStart));
	this._touchTracker.on("trackmove",$bind(this,this._handleMove));
	this._touchTracker.on("trackend",$bind(this,this._handleEnd));
	this._payload = { delta : null, position : null, velocity : null, clientX : null, clientY : null, count : 0, touch : null};
	this._position = null;
};
famous.inputs.TouchSync.__name__ = true;
famous.inputs.TouchSync.__super__ = famous.core.EventHandleable;
famous.inputs.TouchSync.prototype = $extend(famous.core.EventHandleable.prototype,{
	_clearPayload: function() {
		var payload = this._payload;
		payload.position = null;
		payload.velocity = null;
		payload.clientX = null;
		payload.clientY = null;
		payload.count = null;
		payload.touch = null;
	}
	,_handleStart: function(data) {
		this._clearPayload();
		if(this.options.direction != null) this._position = 0; else this._position = [0,0];
		var payload = this._payload;
		payload.count = data.count;
		payload.touch = data.identifier;
		this._eventOutput.emit("start",payload);
	}
	,_handleMove: function(data) {
		var history = data.history;
		var currHistory = history[history.length - 1];
		var prevHistory = history[history.length - 2];
		var prevTime = prevHistory.timestamp;
		var currTime = currHistory.timestamp;
		var diffX = currHistory.x - prevHistory.x;
		var diffY = currHistory.y - prevHistory.y;
		if(this.options.rails) {
			if(Math.abs(diffX) > Math.abs(diffY)) diffY = 0; else diffX = 0;
		}
		var diffTime = Math.max(currTime - prevTime,famous.inputs.TouchSync.MINIMUM_TICK_TIME);
		var velX = diffX / diffTime;
		var velY = diffY / diffTime;
		var scale = this.options.scale;
		var nextVel;
		var nextDelta;
		if(this.options.direction == famous.inputs.TouchSync.DIRECTION_X) {
			nextDelta = scale * diffX;
			nextVel = scale * velX;
			this._position += nextDelta;
		} else if(this.options.direction == famous.inputs.TouchSync.DIRECTION_Y) {
			nextDelta = scale * diffY;
			nextVel = scale * velY;
			this._position += nextDelta;
		} else {
			nextDelta = [scale * diffX,scale * diffY];
			nextVel = [scale * velX,scale * velY];
			this._position[0] += nextDelta[0];
			this._position[1] += nextDelta[1];
		}
		var payload = this._payload;
		payload.delta = nextDelta;
		payload.velocity = nextVel;
		payload.position = this._position;
		payload.clientX = data.x;
		payload.clientY = data.y;
		payload.count = data.count;
		payload.touch = data.identifier;
		this._eventOutput.emit("update",payload);
	}
	,_handleEnd: function(data) {
		var nextVel;
		if(this.options.direction != null) nextVel = 0; else nextVel = [0,0];
		var history = data.history;
		var count = data.count;
		if(history.length > 1) {
			var currHistory = history[history.length - 1];
			var prevHistory = history[history.length - 2];
			var prevTime = prevHistory.timestamp;
			var currTime = currHistory.timestamp;
			var diffX = currHistory.x - prevHistory.x;
			var diffY = currHistory.y - prevHistory.y;
			if(this.options.rails) {
				if(Math.abs(diffX) > Math.abs(diffY)) diffY = 0; else diffX = 0;
			}
			var diffTime = Math.max(currTime - prevTime,famous.inputs.TouchSync.MINIMUM_TICK_TIME);
			var velX = diffX / diffTime;
			var velY = diffY / diffTime;
			var scale = this.options.scale;
			if(this.options.direction == famous.inputs.TouchSync.DIRECTION_X) nextVel = scale * velX; else if(this.options.direction == famous.inputs.TouchSync.DIRECTION_Y) nextVel = scale * velY; else nextVel = [scale * velX,scale * velY];
		}
		var payload = this._payload;
		payload.velocity = nextVel;
		payload.clientX = data.x;
		payload.clientY = data.y;
		payload.count = count;
		payload.touch = data.identifier;
		this._eventOutput.emit("end",payload);
	}
	,setOptions: function(options) {
		if(options.direction != null) this.options.direction = options.direction;
		if(options.rails != null) this.options.rails = options.rails;
		if(options.scale != null) this.options.scale = options.scale;
	}
	,getOptions: function() {
		return this.options;
	}
	,__class__: famous.inputs.TouchSync
});
famous.inputs.ScrollSync = function(options) {
	this.options = Reflect.copy(famous.inputs.ScrollSync.DEFAULT_OPTIONS);
	if(options != null) this.setOptions(options);
	this._eventInput = new famous.core.EventHandler();
	this._eventOutput = new famous.core.EventHandler();
	famous.core.EventHandler.setInputHandler(this,this._eventInput);
	famous.core.EventHandler.setOutputHandler(this,this._eventOutput);
	this._eventInput.on("mousewheel",$bind(this,this._handleMove));
	this._eventInput.on("wheel",$bind(this,this._handleMove));
	this._payload = { delta : null, position : null, velocity : null, slip : true, clientX : null, clientY : null, offsetX : null, offsetY : null};
	if(this.options.direction == null) this._position = [0,0]; else this._position = 0;
	this._prevTime = null;
	this._prevVel = null;
	this._inProgress = false;
	this._loopBound = false;
};
famous.inputs.ScrollSync.__name__ = true;
famous.inputs.ScrollSync.prototype = {
	_newFrame: function(event) {
		if(this._inProgress && new Date().getTime() - this._prevTime > this.options.stallTime) {
			if(this.options.direction == null) this._position = [0,0]; else this._position = 0;
			this._inProgress = false;
			var finalVel;
			if(Math.abs(this._prevVel) >= this.options.minimumEndSpeed) finalVel = this._prevVel; else finalVel = 0;
			var payload = this._payload;
			payload.position = this._position;
			payload.velocity = finalVel;
			payload.slip = true;
			this._eventOutput.emit("end",payload);
		}
	}
	,_handleMove: function(event) {
		event.preventDefault();
		if(!this._inProgress) {
			this._inProgress = true;
			var payload = this._payload;
			payload.slip = true;
			payload.position = this._position;
			payload.clientX = event.clientX;
			payload.clientY = event.clientY;
			payload.offsetX = event.offsetX;
			payload.offsetY = event.offsetY;
			this._eventOutput.emit("start",payload);
			if(!this._loopBound) {
				famous.core.Engine.on("prerender",$bind(this,this._newFrame));
				this._loopBound = true;
			}
		}
		var currTime = new Date().getTime();
		var prevTime;
		if(this._prevTime != null) prevTime = this._prevTime; else prevTime = currTime;
		var diffX;
		if(event.wheelDeltaX != null) diffX = event.wheelDeltaX; else diffX = -event.deltaX;
		var diffY;
		if(event.wheelDeltaY != null) diffY = event.wheelDeltaY; else diffY = -event.deltaY;
		if(event.deltaMode == 1) {
			diffX *= this.options.lineHeight;
			diffY *= this.options.lineHeight;
		}
		if(this.options.rails) {
			if(Math.abs(diffX) > Math.abs(diffY)) diffY = 0; else diffX = 0;
		}
		var diffTime = Math.max(currTime - prevTime,famous.inputs.ScrollSync.MINIMUM_TICK_TIME);
		var velX = diffX / diffTime;
		var velY = diffY / diffTime;
		var scale = this.options.scale;
		var nextVel;
		var nextDelta;
		if(this.options.direction == famous.inputs.ScrollSync.DIRECTION_X) {
			nextDelta = scale * diffX;
			nextVel = scale * velX;
			this._position += nextDelta;
		} else if(this.options.direction == famous.inputs.ScrollSync.DIRECTION_Y) {
			nextDelta = scale * diffY;
			nextVel = scale * velY;
			this._position += nextDelta;
		} else {
			nextDelta = [scale * diffX,scale * diffY];
			nextVel = [scale * velX,scale * velY];
			this._position[0] += nextDelta[0];
			this._position[1] += nextDelta[1];
		}
		var payload1 = this._payload;
		payload1.delta = nextDelta;
		payload1.velocity = nextVel;
		payload1.position = this._position;
		payload1.slip = true;
		this._eventOutput.emit("update",payload1);
		this._prevTime = currTime;
		this._prevVel = nextVel;
	}
	,getOptions: function() {
		return this.options;
	}
	,setOptions: function(options) {
		if(options.direction != null) this.options.direction = options.direction;
		if(options.minimumEndSpeed != null) this.options.minimumEndSpeed = options.minimumEndSpeed;
		if(options.rails != null) this.options.rails = options.rails;
		if(options.scale != null) this.options.scale = options.scale;
		if(options.stallTime != null) this.options.stallTime = options.stallTime;
	}
	,__class__: famous.inputs.ScrollSync
};
famous.core.EventEmitter = function() {
	this.listeners = new haxe.ds.StringMap();
	this._owner = this;
};
famous.core.EventEmitter.__name__ = true;
famous.core.EventEmitter.prototype = {
	emit: function(type,event) {
		var handlers = this.listeners.get(type);
		if(handlers != null) {
			var _g = 0;
			while(_g < handlers.length) {
				var fn = handlers[_g];
				++_g;
				fn.apply(this._owner,[event]);
			}
		}
		return this;
	}
	,on: function(type,handler) {
		if(!this.listeners.exists(type)) {
			var v = [];
			this.listeners.set(type,v);
			v;
		}
		var index;
		var _this = this.listeners.get(type);
		index = HxOverrides.indexOf(_this,handler,0);
		if(index < 0) this.listeners.get(type).push(handler);
		return this;
	}
	,addListener: function(type,handler) {
		return this.on(type,handler);
	}
	,removeListener: function(type,handler) {
		var index;
		var _this = this.listeners.get(type);
		index = HxOverrides.indexOf(_this,handler,0);
		if(index >= 0) this.listeners.get(type).splice(index,1);
		return this;
	}
	,bindThis: function(owner) {
		this._owner = owner;
	}
	,__class__: famous.core.EventEmitter
};
famous.core.EventHandler = function() {
	famous.core.EventEmitter.call(this);
	this.downstream = [];
	this.downstreamFn = [];
	this.upstream = [];
	this.upstreamListeners = new haxe.ds.StringMap();
};
famous.core.EventHandler.__name__ = true;
famous.core.EventHandler.setInputHandler = function(object,handler) {
	object.trigger = handler.trigger;
	if(handler.subscribe != null && handler.unsubscribe != null) {
		object.subscribe = handler.subscribe.bind(handler);
		object.unsubscribe = handler.unsubscribe.bind(handler);
	}
};
famous.core.EventHandler.setOutputHandler = function(object,handler) {
	handler.bindThis(object);
	object.pipe = handler.pipe.bind(handler);
	object.unpipe = handler.unpipe.bind(handler);
	object.on = handler.on.bind(handler);
	object.addListener = object.on.bind(handler);
	object.removeListener = handler.removeListener.bind(handler);
};
famous.core.EventHandler.__super__ = famous.core.EventEmitter;
famous.core.EventHandler.prototype = $extend(famous.core.EventEmitter.prototype,{
	emit: function(type,event) {
		famous.core.EventEmitter.prototype.emit.call(this,type,event);
		var _g = 0;
		var _g1 = this.downstream;
		while(_g < _g1.length) {
			var ds = _g1[_g];
			++_g;
			if(ds.trigger != null) ds.trigger(type,event);
		}
		var _g2 = 0;
		var _g11 = this.downstreamFn;
		while(_g2 < _g11.length) {
			var fn = _g11[_g2];
			++_g2;
			fn(type,event);
		}
		return this;
	}
	,trigger: function(type,event) {
		return this.emit(type,event);
	}
	,pipe: function(target) {
		if(Reflect.isFunction(target.subscribe)) return target.subscribe(this);
		var downstreamCtx;
		if(Reflect.isFunction(target)) downstreamCtx = this.downstreamFn; else downstreamCtx = this.downstream;
		var index;
		var x = target;
		index = HxOverrides.indexOf(downstreamCtx,x,0);
		if(index < 0) downstreamCtx.push(target);
		if(Reflect.isFunction(target)) target("pipe",null); else if(target.trigger) target.trigger("pipe",null);
		return target;
	}
	,unpipe: function(target) {
		if(Reflect.isFunction(target.unsubscribe)) return target.unsubscribe(this);
		var downstreamCtx;
		if(Reflect.isFunction(target)) downstreamCtx = this.downstreamFn; else downstreamCtx = this.downstream;
		var index;
		var x = target;
		index = HxOverrides.indexOf(downstreamCtx,x,0);
		if(index >= 0) {
			downstreamCtx.splice(index,1);
			if(Reflect.isFunction(target)) target("unpipe",null); else if(target.trigger) target.trigger("unpipe",null);
			return target;
		} else return null;
	}
	,on: function(type,handler) {
		famous.core.EventEmitter.prototype.on.call(this,type,handler);
		if(!this.upstreamListeners.exists(type)) {
			var upstreamListener = (function(f,a1) {
				return function(a2) {
					return f(a1,a2);
				};
			})($bind(this,this.trigger),type);
			this.upstreamListeners.set(type,upstreamListener);
			upstreamListener;
			var _g = 0;
			var _g1 = this.upstream;
			while(_g < _g1.length) {
				var h = _g1[_g];
				++_g;
				h.on(type,upstreamListener);
			}
		}
		return this;
	}
	,subscribe: function(source) {
		var index;
		var x = source;
		index = HxOverrides.indexOf(this.upstream,x,0);
		if(index < 0) {
			this.upstream.push(source);
			var $it0 = this.upstreamListeners.keys();
			while( $it0.hasNext() ) {
				var type = $it0.next();
				source.on(type,this.upstreamListeners.get(type));
			}
		}
		return this;
	}
	,unsubscribe: function(source) {
		var index;
		var x = source;
		index = HxOverrides.indexOf(this.upstream,x,0);
		if(index >= 0) {
			this.upstream.splice(index,1);
			var $it0 = this.upstreamListeners.keys();
			while( $it0.hasNext() ) {
				var type = $it0.next();
				source.removeListener(type,this.upstreamListeners.get(type));
			}
		}
		return this;
	}
	,__class__: famous.core.EventHandler
});
famous.core.OptionsManager = function(value) {
	this._value = value;
	this.eventOutput = null;
};
famous.core.OptionsManager.__name__ = true;
famous.core.OptionsManager.patchObject = function(source,datas) {
	var manager = new famous.core.OptionsManager(source);
	var _g = 0;
	while(_g < datas.length) {
		var data = datas[_g];
		++_g;
		manager.patch(data);
	}
	return source;
};
famous.core.OptionsManager.prototype = {
	_createEventOutput: function() {
		this.eventOutput = new famous.core.EventHandler();
		this.eventOutput.bindThis(this);
		famous.core.EventHandler.setOutputHandler(this,this.eventOutput);
	}
	,patch: function(datas) {
		var myState = this._value;
		var _g = 0;
		while(_g < datas.length) {
			var data = datas[_g];
			++_g;
			var _g1 = 0;
			var _g2 = Reflect.fields(data);
			while(_g1 < _g2.length) {
				var k = _g2[_g1];
				++_g1;
				var b = js.Boot.__instanceof([1,2],{ });
				if(Object.prototype.hasOwnProperty.call(myState,k) && (data[k] != null && js.Boot.__instanceof(data[k],{ })) && (myState[k] != null && js.Boot.__instanceof(myState[k],{ }))) {
					var value = Reflect.copy(myState[k]);
					myState[k] = value;
					this.key(k).patch(data[k]);
					if(this.eventOutput) this.eventOutput.emit("change",{ id : k, value : this.key(k).value()});
				} else this.set(k,data[k]);
			}
		}
		return this;
	}
	,setOptions: function(datas) {
		this.patch([datas]);
	}
	,key: function(identifier) {
		var result = new famous.core.OptionsManager(Reflect.field(this._value,identifier));
		if(!Reflect.isObject(result) || (result._value instanceof Array) && result._value.__enum__ == null) result._value = { };
		return result;
	}
	,get: function(key) {
		return Reflect.field(this._value,key);
	}
	,getOptions: function(key) {
		return this.get(key);
	}
	,set: function(key,value) {
		var originalValue = this.get(key);
		this._value[key] = value;
		if(this.eventOutput != null && value != originalValue) this.eventOutput.emit("change",{ id : key, value : value});
		return this;
	}
	,value: function() {
		return this._value;
	}
	,on: function(type,handler) {
		this._createEventOutput();
		return this.on(type,handler);
	}
	,removeListener: function(type,handler) {
		this._createEventOutput();
		return this.removeListener(type,handler);
	}
	,pipe: function(target) {
		this._createEventOutput();
		return this.pipe(target);
	}
	,unpipe: function(target) {
		this._createEventOutput();
		return this.unpipe(target);
	}
	,__class__: famous.core.OptionsManager
};
famous.core.Engine = function() { };
famous.core.Engine.__name__ = true;
famous.core.Engine.step = function() {
	var currentTime = new Date().getTime();
	if(famous.core.Engine.frameTimeLimit > 0 && currentTime - famous.core.Engine.lastTime < famous.core.Engine.frameTimeLimit) return;
	var i = 0;
	famous.core.Engine.frameTime = currentTime - famous.core.Engine.lastTime;
	famous.core.Engine.lastTime = currentTime;
	famous.core.Engine.eventHandler.emit("prerender");
	var _g = 0;
	var _g1 = famous.core.Engine.nextTickQueue;
	while(_g < _g1.length) {
		var tick = _g1[_g];
		++_g;
		tick();
	}
	famous.core.Engine.nextTickQueue.splice(0,famous.core.Engine.nextTickQueue.length);
	while(famous.core.Engine.deferQueue.length > 0 && new Date().getTime() - currentTime < famous.core.Engine.MAX_DEFER_FRAME_TIME) (famous.core.Engine.deferQueue.shift())();
	var _g2 = 0;
	var _g11 = famous.core.Engine.contexts;
	while(_g2 < _g11.length) {
		var c = _g11[_g2];
		++_g2;
		c.update();
	}
	famous.core.Engine.eventHandler.emit("postrender");
};
famous.core.Engine.loop = function(arg) {
	if(famous.core.Engine.options.runLoop) {
		famous.core.Engine.step();
		window.requestAnimationFrame(famous.core.Engine.loop);
	} else famous.core.Engine.loopEnabled = false;
	return true;
};
famous.core.Engine.handleResize = function(event) {
	var _g = 0;
	var _g1 = famous.core.Engine.contexts;
	while(_g < _g1.length) {
		var c = _g1[_g];
		++_g;
		c.emit("resize");
	}
	famous.core.Engine.eventHandler.emit("resize");
};
famous.core.Engine.pipe = function(target) {
	if(Reflect.isFunction(target.subscribe)) return target.subscribe({ emit : famous.core.Engine.emit, on : famous.core.Engine.on, addListener : null, removeListener : famous.core.Engine.removeListener}); else return famous.core.Engine.eventHandler.pipe(target);
};
famous.core.Engine.unpipe = function(target) {
	if(Reflect.isFunction(target.unsubscribe)) return target.unsubscribe({ emit : famous.core.Engine.emit, on : famous.core.Engine.on, addListener : null, removeListener : famous.core.Engine.removeListener}); else return famous.core.Engine.eventHandler.unpipe(target);
};
famous.core.Engine.on = function(type,handler) {
	if(!famous.core.Engine.eventForwarders.exists(type)) {
		var v = (function(f,a1) {
			return function(a2) {
				return f(a1,a2);
			};
		})(($_=famous.core.Engine.eventHandler,$bind($_,$_.emit)),type);
		famous.core.Engine.eventForwarders.set(type,v);
		v;
		if(window.document.body != null) window.document.body.addEventListener(type,famous.core.Engine.eventForwarders.get(type)); else famous.core.Engine.nextTick((function(f1,a11,a21) {
			return function() {
				return f1(a11,a21);
			};
		})(function(type1,forwarder) {
			window.document.body.addEventListener(type1,forwarder);
		},type,famous.core.Engine.eventForwarders.get(type)));
	}
	return famous.core.Engine.eventHandler.on(type,handler);
};
famous.core.Engine.emit = function(type,event) {
	return famous.core.Engine.eventHandler.emit(type,event);
};
famous.core.Engine.removeListener = function(type,handler) {
	return famous.core.Engine.eventHandler.removeListener(type,handler);
};
famous.core.Engine.getFPS = function() {
	return 1000 / famous.core.Engine.frameTime;
};
famous.core.Engine.setFPSCap = function(fps) {
	famous.core.Engine.frameTimeLimit = Math.floor(1000 / fps);
};
famous.core.Engine.getOptions = function(key) {
	return famous.core.Engine.optionsManager.get(key);
};
famous.core.Engine.setOptions = function(options) {
	return famous.core.Engine.optionsManager.patch([options]);
};
famous.core.Engine.createContext = function(el) {
	var needMountContainer = false;
	if(el == null) {
		el = window.document.createElement(famous.core.Engine.options.containerType);
		el.classList.add(famous.core.Engine.options.containerClass);
		needMountContainer = true;
	}
	var context = new famous.core.Context(el);
	famous.core.Engine.registerContext(context);
	if(needMountContainer) famous.core.Engine.nextTick(function() {
		window.document.body.appendChild(el);
		context.emit("resize");
	});
	return context;
};
famous.core.Engine.registerContext = function(context) {
	famous.core.Engine.contexts.push(context);
	return context;
};
famous.core.Engine.nextTick = function(fn) {
	famous.core.Engine.nextTickQueue.push(fn);
};
famous.core.Engine.defer = function(fn) {
	famous.core.Engine.deferQueue.push(fn);
};
famous.core.Entity = function() { };
famous.core.Entity.__name__ = true;
famous.core.Entity.get = function(id) {
	return famous.core.Entity.entities[id];
};
famous.core.Entity.set = function(id,entity) {
	famous.core.Entity.entities[id] = entity;
};
famous.core.Entity.register = function(entity) {
	var id = famous.core.Entity.entities.length;
	famous.core.Entity.set(id,entity);
	return id;
};
famous.core.Entity.unregister = function(id) {
	famous.core.Entity.set(id,null);
};
famous.core.Modifier = function(options) {
	this._opacityGetter = null;
	this._transformGetter = null;
	this._opacityGetter = null;
	this._originGetter = null;
	this._alignGetter = null;
	this._sizeGetter = null;
	this._legacyStates = { };
	this._output = { transform : famous.core.Transform.identity, opacity : 1, origin : null, align : null, size : null, target : null};
	if(options != null) {
		if(options.transform != null) this.transformFrom(options.transform);
		if(options.opacity != null) this.opacityFrom(options.opacity);
		if(options.origin != null) this.originFrom(options.origin);
		if(options.align != null) this.alignFrom(options.align);
		if(options.size != null) this.sizeFrom(options.size);
	}
};
famous.core.Modifier.__name__ = true;
famous.core.Modifier.prototype = {
	transformFrom: function(transform) {
		if(Reflect.isFunction(transform)) this._transformGetter = transform; else if(Reflect.isObject(transform) && transform.get != null) this._transformGetter = transform.get.bind(transform); else {
			this._transformGetter = null;
			this._output.transform = transform;
		}
		return this;
	}
	,opacityFrom: function(opacity) {
		if(Reflect.isFunction(opacity)) this._opacityGetter = opacity; else if(Reflect.isObject(opacity) && opacity.get != null) this._opacityGetter = opacity.get.bind(opacity); else {
			this._opacityGetter = null;
			this._output.opacity = opacity;
		}
		return this;
	}
	,originFrom: function(origin) {
		if(Reflect.isFunction(origin)) this._originGetter = origin; else if(Reflect.isObject(origin) && origin.get != null) this._originGetter = origin.get.bind(origin); else {
			this._originGetter = null;
			this._output.origin = origin;
		}
		return this;
	}
	,alignFrom: function(align) {
		if(Reflect.isFunction(align)) this._alignGetter = align; else if(Reflect.isObject(align) && align.get != null) this._alignGetter = align.get.bind(align); else {
			this._alignGetter = null;
			this._output.align = align;
		}
		return this;
	}
	,sizeFrom: function(size) {
		if(Reflect.isFunction(size)) this._sizeGetter = size; else if(size.get != null) this._sizeGetter = size.get.bind(size); else {
			this._sizeGetter = null;
			this._output.size = size;
		}
		return this;
	}
	,setTransform: function(transform,transition,callback) {
		if(transition != null || this._legacyStates.transform != null) {
			if(this._legacyStates.transform == null) this._legacyStates.transform = new famous.transitions.TransitionableTransform(this._output.transform);
			if(this._transformGetter == null) this.transformFrom(this._legacyStates.transform);
			this._legacyStates.transform.set(transform,transition,callback);
			return this;
		} else return this.transformFrom(transform);
	}
	,setOpacity: function(opacity,transition,callback) {
		if(transition != null || this._legacyStates.opacity != null) {
			if(this._legacyStates.opacity == null) this._legacyStates.opacity = new famous.transitions.Transitionable(this._output.opacity);
			if(this._opacityGetter == null) this.opacityFrom(this._legacyStates.opacity);
			return this._legacyStates.opacity.set(opacity,transition,callback);
		} else return this.opacityFrom(opacity);
	}
	,setOrigin: function(origin,transition,callback) {
		if(transition != null || this._legacyStates.origin != null) {
			if(this._legacyStates.origin == null) this._legacyStates.origin = new famous.transitions.Transitionable(this._output.origin != null?this._output.origin:[0,0]);
			if(this._originGetter == null) this.originFrom(this._legacyStates.origin);
			this._legacyStates.origin.set(origin,transition,callback);
			return this;
		} else return this.originFrom(origin);
	}
	,setAlign: function(align,transition,callback) {
		if(transition != null || this._legacyStates.align != null) {
			if(this._legacyStates.align == null) this._legacyStates.align = new famous.transitions.Transitionable(this._output.align != null?this._output.align:[0,0]);
			if(this._alignGetter == null) this.alignFrom(this._legacyStates.align);
			this._legacyStates.align.set(align,transition,callback);
			return this;
		} else return this.alignFrom(align);
	}
	,setSize: function(size,transition,callback) {
		if(size != null && (transition != null || this._legacyStates.size != null)) {
			if(this._legacyStates.size == null) this._legacyStates.size = new famous.transitions.Transitionable(this._output.size != null?this._output.size:[0,0]);
			if(this._sizeGetter == null) this.sizeFrom(this._legacyStates.size);
			this._legacyStates.size.set(size,transition,callback);
			return this;
		} else return this.sizeFrom(size);
	}
	,halt: function() {
		if(this._legacyStates.transform != null) this._legacyStates.transform.halt();
		if(this._legacyStates.opacity != null) this._legacyStates.opacity.halt();
		if(this._legacyStates.origin != null) this._legacyStates.origin.halt();
		if(this._legacyStates.align != null) this._legacyStates.align.halt();
		if(this._legacyStates.size != null) this._legacyStates.size.halt();
		this._transformGetter = null;
		this._opacityGetter = null;
		this._originGetter = null;
		this._alignGetter = null;
		this._sizeGetter = null;
	}
	,getTransform: function() {
		return this._transformGetter();
	}
	,getFinalTransform: function() {
		if(this._legacyStates.transform) return this._legacyStates.transform.getFinal(); else return this._output.transform;
	}
	,getOpacity: function() {
		return this._opacityGetter();
	}
	,getOrigin: function() {
		return this._originGetter();
	}
	,getAlign: function() {
		return this._alignGetter();
	}
	,getSize: function() {
		if(this._sizeGetter != null) return this._sizeGetter(); else return this._output.size;
	}
	,_update: function() {
		if(this._transformGetter != null) this._output.transform = this._transformGetter();
		if(this._opacityGetter != null) this._output.opacity = this._opacityGetter();
		if(this._originGetter != null) this._output.origin = this._originGetter();
		if(this._sizeGetter != null) this._output.size = this._sizeGetter();
	}
	,modify: function(target) {
		this._update();
		this._output.target = target;
		return this._output;
	}
	,__class__: famous.core.Modifier
};
famous.core.RenderNode = function(object) {
	this._object = null;
	this._child = null;
	this._hasMultipleChildren = false;
	this._isRenderable = false;
	this._isModifier = false;
	this._resultCache = new haxe.ds.IntMap();
	this._prevResults = new haxe.ds.IntMap();
	this._childResult = null;
	if(object != null) this.set(object);
};
famous.core.RenderNode.__name__ = true;
famous.core.RenderNode.prototype = {
	add: function(child) {
		var childNode;
		if(js.Boot.__instanceof(child,famous.core.RenderNode)) childNode = child; else childNode = new famous.core.RenderNode(child);
		if((this._child instanceof Array) && this._child.__enum__ == null) this._child.push(childNode); else if(this._child != null) {
			this._child = [this._child,childNode];
			this._hasMultipleChildren = true;
			this._childResult = [];
		} else this._child = childNode;
		return childNode;
	}
	,get: function() {
		if(this._object != null) return this._object; else if(this._hasMultipleChildren) return null; else if(this._child) return this._child.get(); else return null;
	}
	,set: function(child) {
		this._childResult = null;
		this._hasMultipleChildren = false;
		if(child.render != null) this._isRenderable = true; else this._isRenderable = false;
		if(child.modify != null) this._isModifier = true; else this._isModifier = false;
		this._object = child;
		this._child = null;
		if(js.Boot.__instanceof(child,famous.core.RenderNode)) return child; else return this;
	}
	,getSize: function() {
		var result = null;
		var target = this.get();
		if(target != null && target.getSize != null) result = target.getSize();
		if(result == null && this._child != null && this._child.getSize != null) result = this._child.getSize();
		return result;
	}
	,_applyCommit: function(spec,context,cacheStorage) {
		var result = famous.core.SpecParser.parseSpec(spec,context);
		var $it0 = result.keys();
		while( $it0.hasNext() ) {
			var id = $it0.next();
			var childNode = famous.core.Entity.get(id);
			var commitParams = result.get(id);
			commitParams.allocator = context.allocator;
			var commitResult = childNode.commit(commitParams);
			if(commitResult != null) this._applyCommit(commitResult,context,cacheStorage); else {
				cacheStorage.set(id,commitParams);
				commitParams;
			}
		}
	}
	,commit: function(context) {
		var $it0 = this._prevResults.keys();
		while( $it0.hasNext() ) {
			var id = $it0.next();
			if(this._resultCache.get(id) == null) {
				var object = famous.core.Entity.get(id);
				if(object.cleanup != null) object.cleanup(context.allocator);
			}
		}
		this._prevResults = this._resultCache;
		this._resultCache = new haxe.ds.IntMap();
		this._applyCommit(this.render(),context,this._resultCache);
	}
	,render: function() {
		if(this._isRenderable) return this._object.render();
		var result = null;
		if(this._hasMultipleChildren) {
			result = this._childResult;
			var children = this._child;
			var _g1 = 0;
			var _g = children.length;
			while(_g1 < _g) {
				var i = _g1++;
				result[i] = children[i].render();
			}
		} else if(this._child != null) result = this._child.render();
		if(this._isModifier) return this._object.modify(result); else return result;
	}
	,__class__: famous.core.RenderNode
};
famous.core.SpecParser = function() {
	this._originZeroZero = [0,0];
	this.result = new haxe.ds.IntMap();
};
famous.core.SpecParser.__name__ = true;
famous.core.SpecParser.parseSpec = function(spec,context) {
	return famous.core.SpecParser._instance.parse(spec,context);
};
famous.core.SpecParser._vecInContext = function(v,m) {
	return [v[0] * m[0] + v[1] * m[4] + v[2] * m[8],v[0] * m[1] + v[1] * m[5] + v[2] * m[9],v[0] * m[2] + v[1] * m[6] + v[2] * m[10]];
};
famous.core.SpecParser.prototype = {
	parse: function(spec,context) {
		this.reset();
		this._parseSpec(spec,context,famous.core.Transform.identity);
		return this.result;
	}
	,reset: function() {
		this.result = new haxe.ds.IntMap();
	}
	,_parseSpec: function(spec,parentContext,sizeContext) {
		var id;
		var target;
		var transform;
		var opacity;
		var origin;
		var align;
		var size;
		if(((spec | 0) === spec)) {
			id = spec;
			transform = parentContext.transform;
			if(parentContext.align != null) align = parentContext.align; else align = parentContext.origin;
			if(parentContext.size != null && parentContext.origin != null && (align[0] != null || align[1] != null)) {
				var alignAdjust = [align[0] * parentContext.size[0],align[1] * parentContext.size[1],0];
				transform = famous.core.Transform.thenMove(transform,famous.core.SpecParser._vecInContext(alignAdjust,sizeContext));
			}
			var v = { transform : transform, opacity : parentContext.opacity, origin : parentContext.origin != null?parentContext.origin:this._originZeroZero, align : parentContext.align != null?parentContext.align:parentContext.origin != null?parentContext.origin:this._originZeroZero, size : parentContext.size};
			this.result.set(id,v);
			v;
		} else if(spec == null) return; else if((spec instanceof Array) && spec.__enum__ == null) {
			var _g = 0;
			var _g1;
			_g1 = js.Boot.__cast(spec , Array);
			while(_g < _g1.length) {
				var i = _g1[_g];
				++_g;
				this._parseSpec(i,parentContext,sizeContext);
			}
		} else {
			target = spec.target;
			transform = parentContext.transform;
			opacity = parentContext.opacity;
			origin = parentContext.origin;
			align = parentContext.align;
			size = parentContext.size;
			var nextSizeContext = sizeContext;
			if(spec.opacity != null) opacity = parentContext.opacity * spec.opacity;
			if(spec.transform != null) transform = famous.core.Transform.multiply(parentContext.transform,spec.transform);
			if(spec.origin != null) {
				origin = spec.origin;
				nextSizeContext = parentContext.transform;
			}
			if(spec.align != null) align = spec.align;
			if(spec.size != null) {
				var parentSize = parentContext.size;
				size = [spec.size[0] != null?spec.size[0]:parentSize[0],spec.size[1] != null?spec.size[1]:parentSize[1]];
				if(parentSize != null) {
					if(align == null) align = origin;
					if(align != null && (align[0] != null || align[1] != null)) transform = famous.core.Transform.thenMove(transform,famous.core.SpecParser._vecInContext([align[0] * parentSize[0],align[1] * parentSize[1],0],sizeContext));
					if(origin != null && (origin[0] != null || origin[1] != null)) transform = famous.core.Transform.moveThen([-origin[0] * size[0],-origin[1] * size[1],0],transform);
				}
				nextSizeContext = parentContext.transform;
				origin = null;
				align = null;
			}
			this._parseSpec(target,{ transform : transform, opacity : opacity, origin : origin, align : align, size : size},nextSizeContext);
		}
	}
	,__class__: famous.core.SpecParser
};
famous.core.Surface = function(options) {
	this._size = null;
	this._origin = null;
	this._opacity = 1;
	this._matrix = null;
	this._dirtyClasses = [];
	this._contentDirty = true;
	this._sizeDirty = true;
	this._stylesDirty = true;
	this._classesDirty = true;
	this.elementClass = "famous-surface";
	this.elementType = "div";
	var _g = this;
	this.options = { };
	this.properties = { };
	this.content = "";
	this.classList = [];
	this.size = null;
	this._classesDirty = true;
	this._stylesDirty = true;
	this._sizeDirty = true;
	this._contentDirty = true;
	this._dirtyClasses = [];
	this._matrix = null;
	this._opacity = 1;
	this._origin = null;
	this._size = null;
	var eventForwarder = function(event) {
		_g.emit(event.type,event);
	};
	this.eventForwarder = eventForwarder;
	this.eventHandler = new famous.core.EventHandler();
	this.eventHandler.bindThis(this);
	this.id = famous.core.Entity.register(this);
	if(options != null) this.setOptions(options);
	this._currTarget = null;
};
famous.core.Surface.__name__ = true;
famous.core.Surface._formatCSSTransform = function(m) {
	m[12] = Math.round(m[12] * famous.core.Surface.devicePixelRatio) / famous.core.Surface.devicePixelRatio;
	m[13] = Math.round(m[13] * famous.core.Surface.devicePixelRatio) / famous.core.Surface.devicePixelRatio;
	var result = "matrix3d(";
	var _g = 0;
	while(_g < 15) {
		var i = _g++;
		if(m[i] < 0.000001 && m[i] > -0.000001) result += "0,"; else result += m[i] + ",";
	}
	result += m[15] + ")";
	return result;
};
famous.core.Surface._formatCSSOrigin = function(origin) {
	return 100 * origin[0] + "% " + 100 * origin[1] + "%";
};
famous.core.Surface._xyNotEquals = function(a,b) {
	if(a != null && b != null) return a[0] != b[0] || a[1] != b[1]; else return a != b;
};
famous.core.Surface.prototype = {
	on: function(type,fn) {
		if(this._currTarget != null) this._currTarget.addEventListener(type,this.eventForwarder);
		this.eventHandler.on(type,fn);
	}
	,removeListener: function(type,fn) {
		this.eventHandler.removeListener(type,fn);
	}
	,emit: function(type,event) {
		if(event != null && event.origin == null) event.origin = this;
		var handled = this.eventHandler.emit(type,event);
		if(handled != null && event != null && event.stopPropagation != null) event.stopPropagation();
		return handled;
	}
	,pipe: function(target) {
		return this.eventHandler.pipe(target);
	}
	,unpipe: function(target) {
		return this.eventHandler.unpipe(target);
	}
	,render: function() {
		return this.id;
	}
	,setProperties: function(properties) {
		var _g = 0;
		var _g1 = Reflect.fields(properties);
		while(_g < _g1.length) {
			var n = _g1[_g];
			++_g;
			var value = Reflect.field(properties,n);
			this.properties[n] = value;
		}
		this._stylesDirty = true;
	}
	,getProperties: function() {
		return this.properties;
	}
	,addClass: function(className) {
		if(HxOverrides.indexOf(this.classList,className,0) < 0) {
			this.classList.push(className);
			this._classesDirty = true;
		}
	}
	,removeClass: function(className) {
		var i = HxOverrides.indexOf(this.classList,className,0);
		if(i >= 0) {
			this._dirtyClasses.push(this.classList.splice(i,1)[0]);
			this._classesDirty = true;
		}
	}
	,setClasses: function(classList) {
		var removal = [];
		var _g = 0;
		var _g1 = this.classList;
		while(_g < _g1.length) {
			var clazz = _g1[_g];
			++_g;
			if(HxOverrides.indexOf(classList,clazz,0) < 0) removal.push(clazz);
		}
		var _g2 = 0;
		while(_g2 < removal.length) {
			var clazz1 = removal[_g2];
			++_g2;
			this.removeClass(clazz1);
		}
		var _g3 = 0;
		while(_g3 < classList.length) {
			var clazz2 = classList[_g3];
			++_g3;
			this.addClass(clazz2);
		}
	}
	,getClassList: function() {
		return this.classList;
	}
	,setContent: function(content) {
		if(this.content != content) {
			this.content = content;
			this._contentDirty = true;
		}
	}
	,getContent: function() {
		return this.content;
	}
	,setOptions: function(options) {
		if(options.size != null) this.setSize(options.size);
		if(options.classes != null) this.setClasses(options.classes);
		if(options.properties != null) this.setProperties(options.properties);
		if(options.content != null) this.setContent(options.content);
	}
	,_addEventListeners: function(target) {
		var $it0 = this.eventHandler.listeners.keys();
		while( $it0.hasNext() ) {
			var k = $it0.next();
			target.addEventListener(k,this.eventForwarder);
		}
	}
	,_removeEventListeners: function(target) {
		var $it0 = this.eventHandler.listeners.keys();
		while( $it0.hasNext() ) {
			var k = $it0.next();
			target.removeEventListener(k,this.eventForwarder);
		}
	}
	,_cleanupClasses: function(target) {
		var _g = 0;
		var _g1 = this._dirtyClasses;
		while(_g < _g1.length) {
			var clazz = _g1[_g];
			++_g;
			target.classList.remove(clazz);
		}
		this._dirtyClasses = [];
	}
	,_applyStyles: function(target) {
		var _g = 0;
		var _g1 = Reflect.fields(this.properties);
		while(_g < _g1.length) {
			var k = _g1[_g];
			++_g;
			target.style[k] = this.properties[k];
		}
	}
	,_cleanupStyles: function(target) {
		var _g = 0;
		var _g1 = Reflect.fields(this.properties);
		while(_g < _g1.length) {
			var k = _g1[_g];
			++_g;
			target.style[k] = "";
		}
	}
	,setup: function(allocator) {
		var target = allocator.allocate(this.elementType);
		if(this.elementClass != null) {
			if((this.elementClass instanceof Array) && this.elementClass.__enum__ == null) {
				var clazzes = this.elementClass;
				var _g = 0;
				while(_g < clazzes.length) {
					var clazz = clazzes[_g];
					++_g;
					target.classList.add(clazz);
				}
			} else target.classList.add(this.elementClass);
		}
		target.style.display = "";
		this._addEventListeners(target);
		this._currTarget = target;
		this._stylesDirty = true;
		this._classesDirty = true;
		this._sizeDirty = true;
		this._contentDirty = true;
		this._matrix = null;
		this._opacity = null;
		this._origin = null;
		this._size = null;
	}
	,commit: function(context) {
		if(this._currTarget == null) this.setup(context.allocator);
		var target = this._currTarget;
		var matrix = context.transform;
		var opacity = context.opacity;
		var origin = context.origin;
		var size = context.size;
		if(this._classesDirty) {
			this._cleanupClasses(target);
			var classList = this.getClassList();
			var _g = 0;
			while(_g < classList.length) {
				var clazz = classList[_g];
				++_g;
				target.classList.add(clazz);
			}
			this._classesDirty = false;
		}
		if(this._stylesDirty) {
			this._applyStyles(target);
			this._stylesDirty = false;
		}
		if(this._contentDirty) {
			this.deploy(target);
			this.eventHandler.emit("deploy");
			this._contentDirty = false;
		}
		if(this.size != null) {
			var origSize = size;
			size = [this.size[0],this.size[1]];
			if(size[0] == null && origSize[0] != 0) size[0] = origSize[0];
			if(size[1] == null && origSize[1] != 0) size[1] = origSize[1];
		}
		if(Math.isNaN(size[0])) size[0] = target.clientWidth;
		if(Math.isNaN(size[1])) size[1] = target.clientHeight;
		if(famous.core.Surface._xyNotEquals(this._size,size)) {
			if(this._size == null) this._size = [0,0];
			this._size[0] = size[0];
			this._size[1] = size[1];
			this._sizeDirty = true;
		}
		if(matrix == null && this._matrix != null) {
			this._matrix = null;
			this._opacity = 0;
			famous.core.Surface._setInvisible(target);
			return;
		}
		if(this._opacity != opacity) {
			this._opacity = opacity;
			if(opacity >= 1) target.style.opacity = "0.999999"; else if(opacity == null) target.style.opacity = "null"; else target.style.opacity = "" + opacity;
		}
		if(famous.core.Surface._xyNotEquals(this._origin,origin) || famous.core.Transform.notEquals(this._matrix,matrix) || this._sizeDirty) {
			if(matrix == null) matrix = famous.core.Transform.identity;
			this._matrix = matrix;
			var aaMatrix = matrix;
			if(origin != null) {
				if(this._origin == null) this._origin = [0,0];
				this._origin[0] = origin[0];
				this._origin[1] = origin[1];
				aaMatrix = famous.core.Transform.thenMove(matrix,[-this._size[0] * origin[0],-this._size[1] * origin[1],0]);
				famous.core.Surface._setOrigin(target,origin);
			}
			famous.core.Surface._setMatrix(target,aaMatrix);
		}
		if(this._sizeDirty != null) {
			if(this._size != null) {
				if(this.size != null && Math.isNaN(this.size[0])) target.style.width = ""; else target.style.width = this._size[0] + "px";
				if(this.size != null && Math.isNaN(this.size[1])) target.style.height = ""; else target.style.height = this._size[1] + "px";
			}
			this._sizeDirty = false;
		}
	}
	,cleanup: function(allocator) {
		var i = 0;
		var target = this._currTarget;
		this.eventHandler.emit("recall");
		this.recall(target);
		target.style.display = "none";
		target.style.width = "";
		target.style.height = "";
		this._size = null;
		this._cleanupStyles(target);
		var classList = this.getClassList();
		this._cleanupClasses(target);
		var _g = 0;
		while(_g < classList.length) {
			var clazz = classList[_g];
			++_g;
			target.classList.remove(clazz);
		}
		if(this.elementClass != null) {
			if((this.elementClass instanceof Array) && this.elementClass.__enum__ == null) {
				var clazzes = this.elementClass;
				var _g1 = 0;
				while(_g1 < clazzes.length) {
					var clazz1 = clazzes[_g1];
					++_g1;
					target.classList.remove(clazz1);
				}
			} else target.classList.remove(this.elementClass);
		}
		this._removeEventListeners(target);
		this._currTarget = null;
		allocator.deallocate(target);
		famous.core.Surface._setInvisible(target);
	}
	,deploy: function(target) {
		var content = this.getContent();
		if(js.Boot.__instanceof(content,Node)) {
			while(target.hasChildNodes()) target.removeChild(target.firstChild);
			target.appendChild(content);
		} else target.innerHTML = content;
	}
	,recall: function(target) {
		var df = window.document.createDocumentFragment();
		while(target.hasChildNodes()) df.appendChild(target.firstChild);
		this.setContent(df);
	}
	,getSize: function(actual) {
		if(actual) return this._size; else if(this.size != null) return this.size; else return this._size;
	}
	,setSize: function(size) {
		if(size != null) this.size = [size[0],size[1]]; else this.size = null;
		this._sizeDirty = true;
	}
	,__class__: famous.core.Surface
};
famous.core.Transform = function() { };
famous.core.Transform.__name__ = true;
famous.core.Transform.multiply4x4 = function(a,b) {
	return [a[0] * b[0] + a[4] * b[1] + a[8] * b[2] + a[12] * b[3],a[1] * b[0] + a[5] * b[1] + a[9] * b[2] + a[13] * b[3],a[2] * b[0] + a[6] * b[1] + a[10] * b[2] + a[14] * b[3],a[3] * b[0] + a[7] * b[1] + a[11] * b[2] + a[15] * b[3],a[0] * b[4] + a[4] * b[5] + a[8] * b[6] + a[12] * b[7],a[1] * b[4] + a[5] * b[5] + a[9] * b[6] + a[13] * b[7],a[2] * b[4] + a[6] * b[5] + a[10] * b[6] + a[14] * b[7],a[3] * b[4] + a[7] * b[5] + a[11] * b[6] + a[15] * b[7],a[0] * b[8] + a[4] * b[9] + a[8] * b[10] + a[12] * b[11],a[1] * b[8] + a[5] * b[9] + a[9] * b[10] + a[13] * b[11],a[2] * b[8] + a[6] * b[9] + a[10] * b[10] + a[14] * b[11],a[3] * b[8] + a[7] * b[9] + a[11] * b[10] + a[15] * b[11],a[0] * b[12] + a[4] * b[13] + a[8] * b[14] + a[12] * b[15],a[1] * b[12] + a[5] * b[13] + a[9] * b[14] + a[13] * b[15],a[2] * b[12] + a[6] * b[13] + a[10] * b[14] + a[14] * b[15],a[3] * b[12] + a[7] * b[13] + a[11] * b[14] + a[15] * b[15]];
};
famous.core.Transform.multiply = function(a,b) {
	return [a[0] * b[0] + a[4] * b[1] + a[8] * b[2],a[1] * b[0] + a[5] * b[1] + a[9] * b[2],a[2] * b[0] + a[6] * b[1] + a[10] * b[2],0,a[0] * b[4] + a[4] * b[5] + a[8] * b[6],a[1] * b[4] + a[5] * b[5] + a[9] * b[6],a[2] * b[4] + a[6] * b[5] + a[10] * b[6],0,a[0] * b[8] + a[4] * b[9] + a[8] * b[10],a[1] * b[8] + a[5] * b[9] + a[9] * b[10],a[2] * b[8] + a[6] * b[9] + a[10] * b[10],0,a[0] * b[12] + a[4] * b[13] + a[8] * b[14] + a[12],a[1] * b[12] + a[5] * b[13] + a[9] * b[14] + a[13],a[2] * b[12] + a[6] * b[13] + a[10] * b[14] + a[14],1];
};
famous.core.Transform.thenMove = function(m,t) {
	if(t[2] == null) t[2] = 0;
	return [m[0],m[1],m[2],0,m[4],m[5],m[6],0,m[8],m[9],m[10],0,m[12] + t[0],m[13] + t[1],m[14] + t[2],1];
};
famous.core.Transform.moveThen = function(v,m) {
	if(v[2] == null) v[2] = 0;
	var t0 = v[0] * m[0] + v[1] * m[4] + v[2] * m[8];
	var t1 = v[0] * m[1] + v[1] * m[5] + v[2] * m[9];
	var t2 = v[0] * m[2] + v[1] * m[6] + v[2] * m[10];
	return famous.core.Transform.thenMove(m,[t0,t1,t2]);
};
famous.core.Transform.translate = function(x,y,z) {
	if(z == null) z = 0;
	return [1,0,0,0,0,1,0,0,0,0,1,0,x,y,z,1];
};
famous.core.Transform.thenScale = function(m,s) {
	return [s[0] * m[0],s[1] * m[1],s[2] * m[2],0,s[0] * m[4],s[1] * m[5],s[2] * m[6],0,s[0] * m[8],s[1] * m[9],s[2] * m[10],0,s[0] * m[12],s[1] * m[13],s[2] * m[14],1];
};
famous.core.Transform.scale = function(x,y,z) {
	if(z == null) z = 1;
	return [x,0,0,0,0,y,0,0,0,0,z,0,0,0,0,1];
};
famous.core.Transform.rotateX = function(theta) {
	var cosTheta = Math.cos(theta);
	var sinTheta = Math.sin(theta);
	return [1,0,0,0,0,cosTheta,sinTheta,0,0,-sinTheta,cosTheta,0,0,0,0,1];
};
famous.core.Transform.rotateY = function(theta) {
	var cosTheta = Math.cos(theta);
	var sinTheta = Math.sin(theta);
	return [cosTheta,0,-sinTheta,0,0,1,0,0,sinTheta,0,cosTheta,0,0,0,0,1];
};
famous.core.Transform.rotateZ = function(theta) {
	var cosTheta = Math.cos(theta);
	var sinTheta = Math.sin(theta);
	return [cosTheta,sinTheta,0,0,-sinTheta,cosTheta,0,0,0,0,1,0,0,0,0,1];
};
famous.core.Transform.rotate = function(phi,theta,psi) {
	var cosPhi = Math.cos(phi);
	var sinPhi = Math.sin(phi);
	var cosTheta = Math.cos(theta);
	var sinTheta = Math.sin(theta);
	var cosPsi = Math.cos(psi);
	var sinPsi = Math.sin(psi);
	var result = [cosTheta * cosPsi,cosPhi * sinPsi + sinPhi * sinTheta * cosPsi,sinPhi * sinPsi - cosPhi * sinTheta * cosPsi,0,-cosTheta * sinPsi,cosPhi * cosPsi - sinPhi * sinTheta * sinPsi,sinPhi * cosPsi + cosPhi * sinTheta * sinPsi,0,sinTheta,-sinPhi * cosTheta,cosPhi * cosTheta,0,0,0,0,1];
	return result;
};
famous.core.Transform.rotateAxis = function(v,theta) {
	var sinTheta = Math.sin(theta);
	var cosTheta = Math.cos(theta);
	var verTheta = 1 - cosTheta;
	var xxV = v[0] * v[0] * verTheta;
	var xyV = v[0] * v[1] * verTheta;
	var xzV = v[0] * v[2] * verTheta;
	var yyV = v[1] * v[1] * verTheta;
	var yzV = v[1] * v[2] * verTheta;
	var zzV = v[2] * v[2] * verTheta;
	var xs = v[0] * sinTheta;
	var ys = v[1] * sinTheta;
	var zs = v[2] * sinTheta;
	var result = [xxV + cosTheta,xyV + zs,xzV - ys,0,xyV - zs,yyV + cosTheta,yzV + xs,0,xzV + ys,yzV - xs,zzV + cosTheta,0,0,0,0,1];
	return result;
};
famous.core.Transform.aboutOrigin = function(v,m) {
	var t0 = v[0] - (v[0] * m[0] + v[1] * m[4] + v[2] * m[8]);
	var t1 = v[1] - (v[0] * m[1] + v[1] * m[5] + v[2] * m[9]);
	var t2 = v[2] - (v[0] * m[2] + v[1] * m[6] + v[2] * m[10]);
	return famous.core.Transform.thenMove(m,[t0,t1,t2]);
};
famous.core.Transform.skew = function(phi,theta,psi) {
	return [1,0,0,0,Math.tan(psi),1,0,0,Math.tan(theta),Math.tan(phi),1,0,0,0,0,1];
};
famous.core.Transform.perspective = function(focusZ) {
	return [1,0,0,0,0,1,0,0,0,0,1,-1 / focusZ,0,0,0,1];
};
famous.core.Transform.getTranslate = function(m) {
	return [m[12],m[13],m[14]];
};
famous.core.Transform.inverse = function(m) {
	var c0 = m[5] * m[10] - m[6] * m[9];
	var c1 = m[4] * m[10] - m[6] * m[8];
	var c2 = m[4] * m[9] - m[5] * m[8];
	var c4 = m[1] * m[10] - m[2] * m[9];
	var c5 = m[0] * m[10] - m[2] * m[8];
	var c6 = m[0] * m[9] - m[1] * m[8];
	var c8 = m[1] * m[6] - m[2] * m[5];
	var c9 = m[0] * m[6] - m[2] * m[4];
	var c10 = m[0] * m[5] - m[1] * m[4];
	var detM = m[0] * c0 - m[1] * c1 + m[2] * c2;
	var invD = 1 / detM;
	var result = [invD * c0,-invD * c4,invD * c8,0,-invD * c1,invD * c5,-invD * c9,0,invD * c2,-invD * c6,invD * c10,0,0,0,0,1];
	result[12] = -m[12] * result[0] - m[13] * result[4] - m[14] * result[8];
	result[13] = -m[12] * result[1] - m[13] * result[5] - m[14] * result[9];
	result[14] = -m[12] * result[2] - m[13] * result[6] - m[14] * result[10];
	return result;
};
famous.core.Transform.transpose = function(m) {
	return [m[0],m[4],m[8],m[12],m[1],m[5],m[9],m[13],m[2],m[6],m[10],m[14],m[3],m[7],m[11],m[15]];
};
famous.core.Transform._normSquared = function(v) {
	if(v.length == 2) return v[0] * v[0] + v[1] * v[1]; else return v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
};
famous.core.Transform._norm = function(v) {
	return Math.sqrt(famous.core.Transform._normSquared(v));
};
famous.core.Transform._sign = function(n) {
	if(n < 0) return -1; else return 1;
};
famous.core.Transform.interpret = function(M) {
	var x = [M[0],M[1],M[2]];
	var sgn = famous.core.Transform._sign(x[0]);
	var xNorm = famous.core.Transform._norm(x);
	var v = [x[0] + sgn * xNorm,x[1],x[2]];
	var mult = 2 / famous.core.Transform._normSquared(v);
	if(mult >= Math.POSITIVE_INFINITY) return { translate : famous.core.Transform.getTranslate(M), rotate : [0,0,0], scale : [0,0,0], skew : [0,0,0]};
	var Q1 = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
	Q1[0] = 1 - mult * v[0] * v[0];
	Q1[5] = 1 - mult * v[1] * v[1];
	Q1[10] = 1 - mult * v[2] * v[2];
	Q1[1] = -mult * v[0] * v[1];
	Q1[2] = -mult * v[0] * v[2];
	Q1[6] = -mult * v[1] * v[2];
	Q1[4] = Q1[1];
	Q1[8] = Q1[2];
	Q1[9] = Q1[6];
	var MQ1 = famous.core.Transform.multiply(Q1,M);
	var x2 = [MQ1[5],MQ1[6]];
	var sgn2 = famous.core.Transform._sign(x2[0]);
	var x2Norm = famous.core.Transform._norm(x2);
	var v2 = [x2[0] + sgn2 * x2Norm,x2[1]];
	var mult2 = 2 / famous.core.Transform._normSquared(v2);
	var Q2 = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
	Q2[5] = 1 - mult2 * v2[0] * v2[0];
	Q2[10] = 1 - mult2 * v2[1] * v2[1];
	Q2[6] = -mult2 * v2[0] * v2[1];
	Q2[9] = Q2[6];
	var Q = famous.core.Transform.multiply(Q2,Q1);
	var R = famous.core.Transform.multiply(Q,M);
	var remover = famous.core.Transform.scale(R[0] < 0?-1:1,R[5] < 0?-1:1,R[10] < 0?-1:1);
	R = famous.core.Transform.multiply(R,remover);
	Q = famous.core.Transform.multiply(remover,Q);
	var result = { translate : [0,0,0], rotate : [0,0,0], scale : [0,0,0], skew : [0,0,0]};
	result.translate = famous.core.Transform.getTranslate(M);
	result.rotate = [Math.atan2(-Q[6],Q[10]),Math.asin(Q[2]),Math.atan2(-Q[1],Q[0])];
	if(result.rotate[0] != 0) {
		result.rotate[0] = 0;
		result.rotate[2] = Math.atan2(Q[4],Q[5]);
	}
	result.scale = [R[0],R[5],R[10]];
	result.skew = [Math.atan2(R[9],result.scale[2]),Math.atan2(R[8],result.scale[2]),Math.atan2(R[4],result.scale[0])];
	if(Math.abs(result.rotate[0]) + Math.abs(result.rotate[2]) > 1.5 * Math.PI) {
		result.rotate[1] = Math.PI - result.rotate[1];
		if(result.rotate[1] > Math.PI) result.rotate[1] -= 2 * Math.PI;
		if(result.rotate[1] < -Math.PI) result.rotate[1] += 2 * Math.PI;
		if(result.rotate[0] < 0) result.rotate[0] += Math.PI; else result.rotate[0] -= Math.PI;
		if(result.rotate[2] < 0) result.rotate[2] += Math.PI; else result.rotate[2] -= Math.PI;
	}
	return result;
};
famous.core.Transform.average = function(M1,M2,t) {
	if(t == null) t = 0.5; else t = t;
	var specM1 = famous.core.Transform.interpret(M1);
	var specM2 = famous.core.Transform.interpret(M2);
	var specAvg = { translate : [0,0,0], rotate : [0,0,0], scale : [0,0,0], skew : [0,0,0]};
	var _g = 0;
	while(_g < 3) {
		var i = _g++;
		specAvg.translate[i] = (1 - t) * specM1.translate[i] + t * specM2.translate[i];
		specAvg.rotate[i] = (1 - t) * specM1.rotate[i] + t * specM2.rotate[i];
		specAvg.scale[i] = (1 - t) * specM1.scale[i] + t * specM2.scale[i];
		specAvg.skew[i] = (1 - t) * specM1.skew[i] + t * specM2.skew[i];
	}
	return famous.core.Transform.build(specAvg);
};
famous.core.Transform.build = function(spec) {
	var scaleMatrix = famous.core.Transform.scale(spec.scale[0],spec.scale[1],spec.scale[2]);
	var skewMatrix = famous.core.Transform.skew(spec.skew[0],spec.skew[1],spec.skew[2]);
	var rotateMatrix = famous.core.Transform.rotate(spec.rotate[0],spec.rotate[1],spec.rotate[2]);
	return famous.core.Transform.thenMove(famous.core.Transform.multiply(famous.core.Transform.multiply(rotateMatrix,skewMatrix),scaleMatrix),spec.translate);
};
famous.core.Transform.equals = function(a,b) {
	return !famous.core.Transform.notEquals(a,b);
};
famous.core.Transform.notEquals = function(a,b) {
	if(a == b) return false;
	if(!(a != null && b != null)) return true;
	return !(a != null && b != null) || a[12] != b[12] || a[13] != b[13] || a[14] != b[14] || a[0] != b[0] || a[1] != b[1] || a[2] != b[2] || a[4] != b[4] || a[5] != b[5] || a[6] != b[6] || a[8] != b[8] || a[9] != b[9] || a[10] != b[10];
};
famous.core.Transform.normalizeRotation = function(rotation) {
	var result = rotation.slice(0);
	if(result[0] == Math.PI * 0.5 || result[0] == -Math.PI * 0.5) {
		result[0] = -result[0];
		result[1] = Math.PI - result[1];
		result[2] -= Math.PI;
	}
	if(result[0] > Math.PI * 0.5) {
		result[0] = result[0] - Math.PI;
		result[1] = Math.PI - result[1];
		result[2] -= Math.PI;
	}
	if(result[0] < -Math.PI * 0.5) {
		result[0] = result[0] + Math.PI;
		result[1] = -Math.PI - result[1];
		result[2] -= Math.PI;
	}
	while(result[1] < -Math.PI) result[1] += 2 * Math.PI;
	while(result[1] >= Math.PI) result[1] -= 2 * Math.PI;
	while(result[2] < -Math.PI) result[2] += 2 * Math.PI;
	while(result[2] >= Math.PI) result[2] -= 2 * Math.PI;
	return result;
};
famous.examples = {};
famous.examples.surfaces = {};
famous.examples.surfaces.ImageSurfaceTest = function() { };
famous.examples.surfaces.ImageSurfaceTest.__name__ = true;
famous.examples.surfaces.ImageSurfaceTest.main = function() {
	var mainCtx = famous.core.Engine.createContext();
	var image = new famous.surfaces.ImageSurface({ size : [200,200]});
	image.setContent("images/famous_logo.png");
	mainCtx.add(new famous.core.Modifier({ origin : [.5,.5]})).add(image);
};
famous.inputs.TouchTracker = function(selective) {
	this.selective = selective;
	this.touchHistory = new haxe.ds.IntMap();
	this.eventInput = new famous.core.EventHandler();
	this.eventOutput = new famous.core.EventHandler();
	famous.core.EventHandler.setInputHandler(this,this.eventInput);
	famous.core.EventHandler.setOutputHandler(this,this.eventOutput);
	this.eventInput.on("touchstart",$bind(this,this._handleStart));
	this.eventInput.on("touchmove",$bind(this,this._handleMove));
	this.eventInput.on("touchend",$bind(this,this._handleEnd));
	this.eventInput.on("touchcancel",$bind(this,this._handleEnd));
	this.eventInput.on("unpipe",$bind(this,this._handleUnpipe));
};
famous.inputs.TouchTracker.__name__ = true;
famous.inputs.TouchTracker.prototype = {
	_timestampTouch: function(touch,event,history) {
		return { x : touch.clientX, y : touch.clientY, identifier : touch.identifier, timestamp : new Date().getTime(), count : event.touches.length, history : history};
	}
	,_handleStart: function(event) {
		var _g = 0;
		var _g1 = event.changedTouches;
		while(_g < _g1.length) {
			var touch = _g1[_g];
			++_g;
			var data = this._timestampTouch(touch,event,null);
			this.eventOutput.emit("trackstart",data);
			if(!this.selective && this.touchHistory.get(touch.identifier) == null) this.track(data);
		}
	}
	,_handleMove: function(event) {
		var _g = 0;
		var _g1 = event.changedTouches;
		while(_g < _g1.length) {
			var touch = _g1[_g];
			++_g;
			var history = this.touchHistory.get(touch.identifier);
			if(history != null) {
				var data = this._timestampTouch(touch,event,history);
				this.touchHistory.get(touch.identifier).push(data);
				this.eventOutput.emit("trackmove",data);
			}
		}
	}
	,_handleEnd: function(event) {
		var _g = 0;
		var _g1 = event.changedTouches;
		while(_g < _g1.length) {
			var touch = _g1[_g];
			++_g;
			var history = this.touchHistory.get(touch.identifier);
			if(history != null) {
				var data = this._timestampTouch(touch,event,history);
				this.eventOutput.emit("trackend",data);
				this.touchHistory.remove(touch.identifier);
			}
		}
	}
	,_handleUnpipe: function(event) {
		var $it0 = this.touchHistory.keys();
		while( $it0.hasNext() ) {
			var k = $it0.next();
			var history = this.touchHistory.get(k);
			this.eventOutput.emit("trackend",{ x : history[history.length - 1].x, y : history[history.length - 1].y, identifier : history[history.length - 1].identifier, timestamp : new Date().getTime(), count : 0, history : history});
			this.touchHistory.remove(k);
		}
	}
	,track: function(data) {
		var v = [data];
		this.touchHistory.set(data.identifier,v);
		v;
	}
	,__class__: famous.inputs.TouchTracker
};
famous.math = {};
famous.math.Utilities = function() { };
famous.math.Utilities.__name__ = true;
famous.math.Utilities.clamp = function(value,range) {
	return Math.max(Math.min(value,range[1]),range[0]);
};
famous.math.Utilities.$length = function(array) {
	var distanceSquared = 0;
	var _g = 0;
	while(_g < array.length) {
		var a = array[_g];
		++_g;
		distanceSquared += a * a;
	}
	return Math.sqrt(distanceSquared);
};
famous.math.Utilities.toFixed = function(x,precision) {
	var prec = Math.pow(10,precision);
	return (x * prec | 0) / prec;
};
famous.surfaces = {};
famous.surfaces.ImageSurface = function(options) {
	famous.core.Surface.call(this,options);
	this.elementType = "img";
	this._imageUrl = null;
};
famous.surfaces.ImageSurface.__name__ = true;
famous.surfaces.ImageSurface.__super__ = famous.core.Surface;
famous.surfaces.ImageSurface.prototype = $extend(famous.core.Surface.prototype,{
	setContent: function(imageUrl) {
		this._imageUrl = imageUrl;
		this._contentDirty = true;
	}
	,deploy: function(target) {
		if(this._imageUrl != null) target.src = this._imageUrl; else target.src = "";
	}
	,recall: function(target) {
		target.src = "";
	}
	,__class__: famous.surfaces.ImageSurface
});
famous.transitions = {};
famous.transitions.MultipleTransition = function(method) {
	this.method = method;
	this._instances = [];
	this.state = [];
};
famous.transitions.MultipleTransition.__name__ = true;
famous.transitions.MultipleTransition.prototype = {
	get: function() {
		var _g1 = 0;
		var _g = this._instances.length;
		while(_g1 < _g) {
			var i = _g1++;
			this.state[i] = this._instances[i].get();
		}
		return this.state;
	}
	,set: function(endState,transition,callback) {
		var _allCallback = famous.utilities.Utility.after(endState.length,callback);
		var _g1 = 0;
		var _g = endState.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(this._instances[i] == null) this._instances[i] = Type.createInstance(this.method,[]);
			this._instances[i].set(endState[i],transition,_allCallback);
		}
	}
	,reset: function(startState) {
		var _g1 = 0;
		var _g = startState.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(this._instances[i] == null) this._instances[i] = Type.createInstance(this.method,[]);
			this._instances[i].reset(startState[i]);
		}
	}
	,__class__: famous.transitions.MultipleTransition
};
famous.transitions.Transitionable = function(start) {
	this.currentAction = null;
	this.actionQueue = [];
	this.callbackQueue = [];
	this.id = famous.transitions.Transitionable.transitionId++;
	this.state = 0;
	this.velocity = null;
	this._callback = null;
	this._engineInstance = null;
	this._currentMethod = null;
	this.set(start);
};
famous.transitions.Transitionable.__name__ = true;
famous.transitions.Transitionable.registerMethod = function(name,engineClass) {
	if(!famous.transitions.Transitionable.transitionMethods.exists(name)) {
		famous.transitions.Transitionable.transitionMethods.set(name,engineClass);
		engineClass;
		return true;
	} else return false;
};
famous.transitions.Transitionable.unregisterMethod = function(name) {
	if(famous.transitions.Transitionable.transitionMethods.exists(name)) {
		famous.transitions.Transitionable.transitionMethods.remove(name);
		return true;
	} else return false;
};
famous.transitions.Transitionable.prototype = {
	_loadNext: function() {
		if(this._callback != null) {
			var callback = this._callback;
			this._callback = null;
			callback();
		}
		if(this.actionQueue.length <= 0) {
			this.set(this.get());
			return;
		}
		this.currentAction = this.actionQueue.shift();
		this._callback = this.callbackQueue.shift();
		var method = null;
		var endValue = this.currentAction[0];
		var transition = this.currentAction[1];
		if(js.Boot.__instanceof(transition,Dynamic) && transition.method != null) {
			method = transition.method;
			if(typeof(method) == "string") {
				var key = method;
				method = famous.transitions.Transitionable.transitionMethods.get(key);
			}
		} else method = famous.transitions.TweenTransition;
		if(this._currentMethod != method) {
			if(!Reflect.isObject(endValue) || method.SUPPORTS_MULTIPLE == true || endValue.length <= Std["int"](method.SUPPORTS_MULTIPLE)) {
				var a = 1;
				this._engineInstance = Type.createInstance(method,[]);
			} else {
				var b = 1;
				this._engineInstance = new famous.transitions.MultipleTransition(method);
			}
			this._currentMethod = method;
		}
		this._engineInstance.reset(this.state,this.velocity);
		if(this.velocity != null) transition.velocity = this.velocity;
		this._engineInstance.set(endValue,transition,$bind(this,this._loadNext));
	}
	,set: function(endState,transition,callback) {
		if(transition == null || transition == false) {
			this.reset(endState);
			if(callback != null) callback();
			return this;
		}
		var action = [endState,transition];
		this.actionQueue.push(action);
		this.callbackQueue.push(callback);
		if(this.currentAction == null) this._loadNext();
		return this;
	}
	,reset: function(startState,startVelocity) {
		this._currentMethod = null;
		this._engineInstance = null;
		this.state = startState;
		this.velocity = startVelocity;
		this.currentAction = null;
		this.actionQueue = [];
		this.callbackQueue = [];
	}
	,delay: function(duration,callback) {
		this.set(this._engineInstance.get(),{ duration : duration, curve : function() {
			return 0;
		}},callback);
	}
	,get: function(timestamp) {
		if(this._engineInstance != null) {
			if(this._engineInstance.getVelocity != null) this.velocity = this._engineInstance.getVelocity();
			this.state = this._engineInstance.get(timestamp);
		}
		return this.state;
	}
	,isActive: function() {
		return this.currentAction != null;
	}
	,halt: function() {
		this.set(this.get());
	}
	,__class__: famous.transitions.Transitionable
};
famous.transitions.TransitionableTransform = function(transform) {
	this._final = famous.core.Transform.identity.slice(0);
	this.translate = new famous.transitions.Transitionable([0,0,0]);
	this.rotate = new famous.transitions.Transitionable([0,0,0]);
	this.skew = new famous.transitions.Transitionable([0,0,0]);
	this.scale = new famous.transitions.Transitionable([1,1,1]);
	if(transform != null) this.set(transform);
};
famous.transitions.TransitionableTransform.__name__ = true;
famous.transitions.TransitionableTransform.prototype = {
	_build: function() {
		return famous.core.Transform.build({ translate : this.translate.get(), rotate : this.rotate.get(), skew : this.skew.get(), scale : this.scale.get()});
	}
	,setTranslate: function(translate,transition,callback) {
		this.translate.set(translate,transition,callback);
		this._final = this._final.slice(0);
		this._final[12] = translate[0];
		this._final[13] = translate[1];
		if(translate[2] != null) this._final[14] = translate[2];
		return this;
	}
	,setScale: function(scale,transition,callback) {
		this.scale.set(scale,transition,callback);
		this._final = this._final.slice(0);
		this._final[0] = scale[0];
		this._final[5] = scale[1];
		if(scale[2] != null) this._final[10] = scale[2];
		return this;
	}
	,setRotate: function(eulerAngles,transition,callback) {
		this.rotate.set(eulerAngles,transition,callback);
		this._final = this._build();
		this._final = famous.core.Transform.build({ translate : this.translate.get(), rotate : eulerAngles, scale : this.scale.get(), skew : this.skew.get()});
		return this;
	}
	,setSkew: function(skewAngles,transition,callback) {
		this.skew.set(skewAngles,transition,callback);
		this._final = famous.core.Transform.build({ translate : this.translate.get(), rotate : this.rotate.get(), scale : this.scale.get(), skew : skewAngles});
		return this;
	}
	,set: function(transform,transition,callback) {
		this._final = transform;
		var components = famous.core.Transform.interpret(transform);
		var _callback;
		if(callback != null) _callback = famous.utilities.Utility.after(4,callback); else _callback = null;
		this.translate.set(components.translate,transition,_callback);
		this.rotate.set(components.rotate,transition,_callback);
		this.skew.set(components.skew,transition,_callback);
		this.scale.set(components.scale,transition,_callback);
		return this;
	}
	,get: function() {
		if(this.isActive()) return this._build(); else return this._final;
	}
	,getFinal: function() {
		return this._final;
	}
	,isActive: function() {
		return this.translate.isActive() || this.rotate.isActive() || this.scale.isActive() || this.skew.isActive();
	}
	,halt: function() {
		this._final = this.get();
		this.translate.halt();
		this.rotate.halt();
		this.skew.halt();
		this.scale.halt();
	}
	,__class__: famous.transitions.TransitionableTransform
};
famous.transitions.TweenTransition = function(options) {
	this.options = Reflect.copy(famous.transitions.TweenTransition.DEFAULT_OPTIONS);
	if(options != null) this.setOptions(options);
	this._startTime = 0;
	this._startValue = 0;
	this._updateTime = 0;
	this._endValue = 0;
	this._curve = null;
	this._duration = 0;
	this._active = false;
	this._callback = null;
	this.state = 0;
	this.velocity = null;
};
famous.transitions.TweenTransition.__name__ = true;
famous.transitions.TweenTransition.registerCurve = function(curveName,curve) {
	if(famous.transitions.TweenTransition.registeredCurves.get(curveName) == null) {
		famous.transitions.TweenTransition.registeredCurves.set(curveName,curve);
		curve;
		return true;
	} else return false;
};
famous.transitions.TweenTransition.unregisterCurve = function(curveName) {
	if(famous.transitions.TweenTransition.registeredCurves.get(curveName) != null) {
		famous.transitions.TweenTransition.registeredCurves.remove(curveName);
		return true;
	} else return false;
};
famous.transitions.TweenTransition.getCurve = function(curveName) {
	var curve = famous.transitions.TweenTransition.registeredCurves.get(curveName);
	if(curve != null) return curve; else throw "curve not registered";
};
famous.transitions.TweenTransition.getCurves = function() {
	return famous.transitions.TweenTransition.registeredCurves;
};
famous.transitions.TweenTransition.customCurve = function(v1,v2) {
	if(v1 == null) v1 = v1; else v1 = 0;
	if(v2 == null) v2 = v2; else v2 = 0;
	return function(t) {
		return v1 * t + (-2 * v1 - v2 + 3) * t * t + (v1 + v2 - 2) * t * t * t;
	};
};
famous.transitions.TweenTransition.prototype = {
	_interpolate: function(a,b,t) {
		return (1 - t) * a + t * b;
	}
	,_clone: function(obj) {
		if(Reflect.isObject(obj)) {
			if((obj instanceof Array) && obj.__enum__ == null) {
				var result = Type.createInstance(Type.getClass(obj),[]);
				var _g1 = 0;
				var _g = obj.length;
				while(_g1 < _g) {
					var ii = _g1++;
					result.push(obj[ii]);
				}
				return result;
			} else return Type.createInstance(Type.getClass(obj),[]);
		} else return obj;
	}
	,_normalize: function(transition,defaultTransition) {
		var result = { curve : defaultTransition.curve};
		if(defaultTransition.duration != null) result.duration = defaultTransition.duration;
		if(defaultTransition.speed != null) result.speed = defaultTransition.speed;
		if(Reflect.isObject(transition)) {
			if(transition.duration != null) result.duration = transition.duration;
			if(transition.curve != null) result.curve = transition.curve;
			if(transition.speed != null) result.speed = transition.speed;
		}
		if(typeof(result.curve) == "string") result.curve = famous.transitions.TweenTransition.getCurve(result.curve);
		return result;
	}
	,setOptions: function(options) {
		if(options.curve != null) this.options.curve = options.curve;
		if(options.duration != null) this.options.duration = options.duration;
		if(options.speed != null) this.options.speed = options.speed;
	}
	,set: function(endValue,transition,callback) {
		if(transition == null) {
			this.reset(endValue);
			if(callback != null) callback();
			return;
		}
		this._startValue = this._clone(this.get());
		transition = this._normalize(transition,this.options);
		if(transition.speed != null && transition.speed > 0) {
			if((this._startValue instanceof Array) && this._startValue.__enum__ == null) {
				var startValue = this._startValue;
				var variance = 0;
				var _g = 0;
				while(_g < startValue.length) {
					var i = startValue[_g];
					++_g;
					variance += (endValue[i] - startValue[i]) * (endValue[i] - startValue[i]);
				}
				transition.duration = Math.sqrt(variance) / transition.speed;
			} else {
				var startValue1 = this._startValue;
				transition.duration = Math.abs(endValue - startValue1) / transition.speed;
			}
		}
		this._startTime = new Date().getTime();
		this._endValue = this._clone(endValue);
		this._startVelocity = this._clone(transition.velocity);
		this._duration = transition.duration;
		this._curve = transition.curve;
		this._active = true;
		this._callback = callback;
	}
	,reset: function(startValue,startVelocity) {
		if(startVelocity == null) startVelocity = 0;
		if(startValue == null) startValue = 0;
		if(this._callback != null) {
			var callback = this._callback;
			this._callback = null;
			callback();
		}
		this.state = this._clone(startValue);
		this.velocity = this._clone(startVelocity);
		this._startTime = 0;
		this._duration = 0;
		this._updateTime = 0;
		this._startValue = this.state;
		this._startVelocity = this.velocity;
		this._endValue = this.state;
		this._active = false;
	}
	,getVelocity: function() {
		return this.velocity;
	}
	,get: function(timestamp) {
		this.update(timestamp);
		return this.state;
	}
	,_calculateVelocity: function(current,start,curve,duration,t) {
		var velocity;
		var eps = 1e-7;
		var speed = (curve(t) - curve(t - eps)) / eps;
		if((current instanceof Array) && current.__enum__ == null) {
			velocity = [];
			var _g1 = 0;
			var _g = current.length;
			while(_g1 < _g) {
				var i = _g1++;
				if(typeof(current[i]) == "number") velocity[i] = speed * (current[i] - start[i]) / duration; else velocity[i] = 0;
			}
		} else {
			var _current = current;
			var _start = start;
			velocity = speed * (_current - _start) / duration;
		}
		return velocity;
	}
	,_calculateState: function(start,end,t) {
		var state;
		if((start instanceof Array) && start.__enum__ == null) {
			state = [];
			var _g1 = 0;
			var _g = start.length;
			while(_g1 < _g) {
				var i = _g1++;
				if(typeof(start[i]) == "number") state[i] = this._interpolate(start[i],end[i],t); else state[i] = start[i];
			}
		} else {
			var _start = start;
			var _end = end;
			state = this._interpolate(_start,_end,t);
		}
		return state;
	}
	,update: function(timestamp) {
		if(!this._active) {
			if(this._callback != null) {
				var callback = this._callback;
				this._callback = null;
				callback();
			}
			return;
		}
		if(timestamp == null) timestamp = new Date().getTime();
		if(this._updateTime >= timestamp) return;
		this._updateTime = timestamp;
		var timeSinceStart = timestamp - this._startTime;
		if(timeSinceStart >= this._duration) {
			this.state = this._endValue;
			this.velocity = this._calculateVelocity(this.state,this._startValue,this._curve,this._duration,1);
			this._active = false;
		} else if(timeSinceStart < 0) {
			this.state = this._startValue;
			this.velocity = this._startVelocity;
		} else {
			var t = timeSinceStart / this._duration;
			this.state = this._calculateState(this._startValue,this._endValue,this._curve(t));
			this.velocity = this._calculateVelocity(this.state,this._startValue,this._curve,this._duration,t);
		}
	}
	,isActive: function() {
		return this._active;
	}
	,halt: function() {
		this.reset(this.get());
	}
	,__class__: famous.transitions.TweenTransition
};
famous.utilities = {};
famous.utilities.Utility = function() { };
famous.utilities.Utility.__name__ = true;
famous.utilities.Utility.after = function(count,callback) {
	var counter = count;
	return function() {
		counter--;
		if(counter == 0) callback();
	};
};
famous.utilities.Utility.loadURL = function(url,callback) {
	var xhr = new XMLHttpRequest();
	var onreadystatechange = function(_) {
		if(xhr.readyState == 4) {
			if(callback != null) callback(xhr.responseText);
		}
	};
	xhr.onreadystatechange = onreadystatechange;
	xhr.open("GET",url);
	xhr.send();
};
famous.utilities.Utility.createDocumentFragmentFromHTML = function(html) {
	var element = window.document.createElement("div");
	element.innerHTML = html;
	var result = window.document.createDocumentFragment();
	while(element.hasChildNodes()) result.appendChild(element.firstChild);
	return result;
};
var haxe = {};
haxe.ds = {};
haxe.ds.IntMap = function() {
	this.h = { };
};
haxe.ds.IntMap.__name__ = true;
haxe.ds.IntMap.__interfaces__ = [IMap];
haxe.ds.IntMap.prototype = {
	set: function(key,value) {
		this.h[key] = value;
	}
	,get: function(key) {
		return this.h[key];
	}
	,remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return HxOverrides.iter(a);
	}
	,__class__: haxe.ds.IntMap
};
haxe.ds.StringMap = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = true;
haxe.ds.StringMap.__interfaces__ = [IMap];
haxe.ds.StringMap.prototype = {
	set: function(key,value) {
		this.h["$" + key] = value;
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty("$" + key);
	}
	,remove: function(key) {
		key = "$" + key;
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,__class__: haxe.ds.StringMap
};
var js = {};
js.Boot = function() { };
js.Boot.__name__ = true;
js.Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else return o.__class__;
};
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i1;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js.Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str2 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str2.length != 2) str2 += ", \n";
		str2 += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str2 += "\n" + s + "}";
		return str2;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
};
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js.Boot.__interfLoop(js.Boot.getClass(o),cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js.Boot.__cast = function(o,t) {
	if(js.Boot.__instanceof(o,t)) return o; else throw "Cannot cast " + Std.string(o) + " to " + Std.string(t);
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i1) {
	return isNaN(i1);
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
famous.core.Context._originZeroZero = [0,0];
famous.inputs.GenericSync.DIRECTION_X = 0;
famous.inputs.GenericSync.DIRECTION_Y = 1;
famous.inputs.GenericSync.DIRECTION_Z = 2;
famous.inputs.GenericSync.registry = { };
famous.inputs.MouseSync.DIRECTION_X = 0;
famous.inputs.MouseSync.DIRECTION_Y = 1;
famous.inputs.MouseSync.MINIMUM_TICK_TIME = 8;
famous.inputs.MouseSync.DEFAULT_OPTIONS = { direction : null, rails : false, scale : 1, propogate : true};
famous.inputs.TouchSync.DIRECTION_X = 0;
famous.inputs.TouchSync.DIRECTION_Y = 1;
famous.inputs.TouchSync.MINIMUM_TICK_TIME = 8;
famous.inputs.TouchSync.DEFAULT_OPTIONS = { direction : null, rails : false, scale : 1};
famous.inputs.ScrollSync.DIRECTION_X = 0;
famous.inputs.ScrollSync.DIRECTION_Y = 1;
famous.inputs.ScrollSync.MINIMUM_TICK_TIME = 8;
famous.inputs.ScrollSync.DEFAULT_OPTIONS = { direction : null, minimumEndSpeed : Math.POSITIVE_INFINITY, rails : false, scale : 1, stallTime : 50, lineHeight : 40};
famous.core.Engine.contexts = new Array();
famous.core.Engine.nextTickQueue = new Array();
famous.core.Engine.deferQueue = new Array();
famous.core.Engine.lastTime = new Date().getTime();
famous.core.Engine.frameTimeLimit = Math.floor(16.666666666666668);
famous.core.Engine.loopEnabled = true;
famous.core.Engine.eventForwarders = new haxe.ds.StringMap();
famous.core.Engine.eventHandler = new famous.core.EventHandler();
famous.core.Engine.options = { containerType : "div", containerClass : "famous-container", fpsCap : null, runLoop : true};
famous.core.Engine.optionsManager = new famous.core.OptionsManager(famous.core.Engine.options);
famous.core.Engine.MAX_DEFER_FRAME_TIME = 10;
famous.core.Engine._staticInitLoop = (function($this) {
	var $r;
	window.requestAnimationFrame(famous.core.Engine.loop);
	$r = null;
	return $r;
}(this));
famous.core.Engine._staticInitListeners = (function($this) {
	var $r;
	window.addEventListener("resize",famous.core.Engine.handleResize,false);
	famous.core.Engine.handleResize();
	$r = null;
	return $r;
}(this));
famous.core.Engine._staticInitGenericSync = (function($this) {
	var $r;
	famous.inputs.GenericSync.register({ mouse : famous.inputs.MouseSync, touch : famous.inputs.TouchSync, scroll : famous.inputs.ScrollSync});
	$r = null;
	return $r;
}(this));
famous.core.Engine._staticInitOptionManager = (function() {
	famous.core.Engine.optionsManager.on("change",function(data) {
		if(data.id == "fpsCap") famous.core.Engine.setFPSCap(data.value); else if(data.id == "runLoop") {
			if(!famous.core.Engine.loopEnabled && data.value != null) {
				famous.core.Engine.loopEnabled = true;
				window.requestAnimationFrame(famous.core.Engine.loop);
			}
		}
	});
	return null;
})();
famous.core.Entity.entities = [];
famous.core.SpecParser._instance = new famous.core.SpecParser();
famous.core.Surface.devicePixelRatio = window.devicePixelRatio != null?window.devicePixelRatio:1;
famous.core.Surface.usePrefix = window.document.createElement("div").style.webkitTransform != null;
famous.core.Surface._setMatrix = window.navigator.userAgent.toLowerCase().indexOf("firefox") > -1?function(element,matrix) {
	element.style.zIndex = matrix[14] * 1000000 | 0 | 0;
	element.style.transform = famous.core.Surface._formatCSSTransform(matrix);
}:famous.core.Surface.usePrefix?function(element1,matrix1) {
	element1.style.webkitTransform = famous.core.Surface._formatCSSTransform(matrix1);
}:function(element2,matrix2) {
	element2.style.transform = famous.core.Surface._formatCSSTransform(matrix2);
};
famous.core.Surface._setOrigin = famous.core.Surface.usePrefix?function(element,origin) {
	element.style.webkitTransformOrigin = famous.core.Surface._formatCSSOrigin(origin);
}:function(element1,origin1) {
	element1.style.transformOrigin = famous.core.Surface._formatCSSOrigin(origin1);
};
famous.core.Surface._setInvisible = famous.core.Surface.usePrefix?function(element) {
	element.style.webkitTransform = "scale3d(0.0001,0.0001,1)";
	element.style.opacity = 0;
}:function(element1) {
	element1.style.transform = "scale3d(0.0001,0.0001,1)";
	element1.style.opacity = 0;
};
famous.core.Transform.precision = 1e-6;
famous.core.Transform.identity = [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1];
famous.core.Transform.inFront = [1,0,0,0,0,1,0,0,0,0,1,0,0,0,1e-3,1];
famous.core.Transform.behind = [1,0,0,0,0,1,0,0,0,0,1,0,0,0,-1e-3,1];
famous.transitions.MultipleTransition.SUPPORTS_MULTIPLE = true;
famous.transitions.Transitionable.transitionMethods = new haxe.ds.StringMap();
famous.transitions.Transitionable.transitionId = 0;
famous.transitions.TweenTransition.Curves = { linear : function(t) {
	return t;
}, easeIn : function(t1) {
	return t1 * t1;
}, easeOut : function(t2) {
	return t2 * (2 - t2);
}, easeInOut : function(t3) {
	if(t3 <= 0.5) return 2 * t3 * t3; else return -2 * t3 * t3 + 4 * t3 - 1;
}, easeOutBounce : function(t4) {
	return t4 * (3 - 2 * t4);
}, spring : function(t5) {
	return (1 - t5) * Math.sin(6 * Math.PI * t5) + t5;
}};
famous.transitions.TweenTransition.SUPPORTS_MULTIPLE = true;
famous.transitions.TweenTransition.DEFAULT_OPTIONS = { curve : famous.transitions.TweenTransition.Curves.linear, duration : 500, speed : 0};
famous.transitions.TweenTransition.registeredCurves = new haxe.ds.StringMap();
famous.transitions.TweenTransition._staticInitDefaultCuves = (function($this) {
	var $r;
	famous.transitions.TweenTransition.registerCurve("linear",famous.transitions.TweenTransition.Curves.linear);
	famous.transitions.TweenTransition.registerCurve("easeIn",famous.transitions.TweenTransition.Curves.easeIn);
	famous.transitions.TweenTransition.registerCurve("easeOut",famous.transitions.TweenTransition.Curves.easeOut);
	famous.transitions.TweenTransition.registerCurve("easeInOut",famous.transitions.TweenTransition.Curves.easeInOut);
	famous.transitions.TweenTransition.registerCurve("easeOutBounce",famous.transitions.TweenTransition.Curves.easeOutBounce);
	famous.transitions.TweenTransition.registerCurve("spring",famous.transitions.TweenTransition.Curves.spring);
	$r = null;
	return $r;
}(this));
famous.utilities.Utility.Direction = { X : 0, Y : 1, Z : 2};
famous.examples.surfaces.ImageSurfaceTest.main();
})();

//# sourceMappingURL=events.js.map