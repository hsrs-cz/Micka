
function OverMap(config){

	var _overmap = this;
	var hoverColor = null;
	this.extents = new Array();
	this.mapfeatures = new ol.Collection();
	this.searchfeatures = new ol.Collection();
    var s = new ol.source.Vector({features: this.mapfeatures})
	this.flyr = new ol.layer.Vector({
		source: s,
		style: new ol.style.Style({
			fill: new ol.style.Fill({
			    color: [0,0,0,0]
			}),
			stroke: new ol.style.Stroke({
			    color: '#3182BD', //TODO - configurable
			    width: 2
			}) 
	    })
	});
	
	this.searchLyr = new ol.layer.Vector({
		source: new ol.source.Vector({features: this.searchfeatures}),
		style: new ol.style.Style({
			fill: new ol.style.Fill({
			    color: [255,0,0,0.25] //TODO - configurable
			}),
			stroke: new ol.style.Stroke({
			    color: '#F00000', //TODO - configurable
			    width: 2
			}) 
	    })
	});

	
	this.getBBox = function(){
		if(_overmap.searchfeatures.getLength()==1){
			var g =_overmap.searchfeatures.item(0).getGeometry().clone();
			g.transform('EPSG:3857', 'EPSG:4326');
			g = g.getExtent();
			return g;
		}
	}	
	
	var createControl = function(opts){	
		var Control = function(options){
			var button = document.createElement('button');
			button.innerHTML = options.icon;
			button.addEventListener('click', options.handler, false);
			button.addEventListener('touchstart', options.handler, false);
			var el = document.createElement('div');
			el.className = 'ol-unselectable ol-control ' + options.className;
			el.title = opts.title;
			el.appendChild(button);
			ol.control.Control.call(this, {
			  element: el,
			  target: options.target
			});
		}
		ol.inherits(Control, ol.control.Control);
		return new Control(opts);
	}
	
	this.clear = function(){
		if(_overmap.searchfeatures) _overmap.searchfeatures.clear();
        if(_overmap.selFeatures) _overmap.selFeatures.clear();
        if(config.handler){
            config.handler(null);
        }
	}
	
	var drawBoxControl = createControl({
        icon: '<i class="fa fa-crop"></i>',
        title: HS.i18n('Draw bounding box'),
        className: 'bbox-control',
        handler: function(){
            _overmap.dragBoxInteraction.setActive(true);
        }
	});

	var eraseGeomControl = createControl({
        icon: '<i class="fa fa-close"></i>',
        title: HS.i18n('Clear graphics'),
        className: 'erase-control',
        handler: this.clear
	});

	var drawPolyControl = createControl({
        icon: 'P',
        className: 'poly-control',
        handler: function(){
            _overmap.drawPolyInteraction.setActive(true);
        }
	});

	var controls = [];
	if(config.drawBBOX){
		controls = [drawBoxControl,
		  //drawPolyControl,
		  eraseGeomControl];
	}
	
	this.map = new ol.Map({
		controls: ol.control.defaults({
          attributionOptions: /** @type {olx.control.AttributionOptions} */ ({
            collapsible: true
          })
        }).extend(controls),
        target: "overmap",
        theme: null,
        layers: [
 			new ol.layer.Tile({	source: new ol.source.OSM() }),	                   
            this.flyr,
			this.searchLyr
        ],
        view: new ol.View({
        	projection: 'EPSG:3857',
            center: [0,0], 
            zoom: 0
        })
    });
	
    var getHoverColor = function(){
        if(hoverColor){
            return hoverColor;
        }
        else {
            var css = document.styleSheets.item(6).cssRules; // TODO dynamic
            for(var i in css){
                if(css.item(i).selectorText=='div.recMap') {
                    return css.item(i).style.backgroundColor;
                    break;
                }
            }
    	}
    };
    
	this.dragBoxInteraction = new ol.interaction.DragBox({
        style: new ol.style.Style({
          stroke: new ol.style.Stroke({
            color: '#F00',
            width: 2
          })
        })
    });

	this.getState = function(){
		return {
			center: this.map.getView().getCenter(),
			zoom: this.map.getView().getZoom(),
			geom: this.getBBox()//this.searchfeatures.item(0).getGeometry().getExtent()
		}	
	}
	
	this.setState = function(data){
		//this.map.getView().setCenter(data.center);
		//this.map.getView().setZoom(data.zoom);
		if(data.geom) this.addBBox(data.geom, 'box-1');
	}
	
    this.dragBoxInteraction.on('boxend', function(e) {
		_overmap.dragBoxInteraction.setActive(false);
        var g = e.target.getGeometry().clone();
        g.transform('EPSG:3857', 'EPSG:4326');
        g = g.getExtent();
        _overmap.searchfeatures.clear();
        _overmap.addBBox(g, 'i-1');
        if(config.handler){
        	config.handler(g);
            return false;
        }
	}, this);
	this.dragBoxInteraction.setActive(false);
	this.map.addInteraction(this.dragBoxInteraction);

	this.drawPolyInteraction = new ol.interaction.Draw({
		features: _overmap.searchfeatures,
		type: 'Polygon'
	});

	
	this.drawPolyInteraction.on('drawend', function(e) {
		_overmap.drawPolyInteraction.setActive(false);
	}, this);
	
	this.drawPolyInteraction.setActive(false);
	this.map.addInteraction(this.drawPolyInteraction);
	
    this.drawExtent = function(b){
        if(!b || !b[0]) b = initialExtent;
        for(var i=0; i<b.length; i++){
            b[i] = parseFloat(b[i]);
        }
       	var g = new ol.geom.Polygon.fromExtent(b);
    	g.transform('EPSG:4326', 'EPSG:3857'); //TODO optimize
        var ext = g.getExtent();
        var s = _overmap.flyr.getSource();
        var extInteraction = new ol.interaction.Extent({
            extent: ext,
            condition: ol.events.condition.platformModifierKeyOnly,
            boxStyle: new ol.style.Style({
              stroke: new ol.style.Stroke({
                color: '#F00',
                width: 2
              })
            })
         });
        this.map.addInteraction(extInteraction);
        this.map.getView().fit(ext, this.map.getSize());
    }
    
	/* 
	* Draws metadata records extents to map
	*/
	this.drawMetadata = function(extent){
    	var meta = document.getElementsByTagName("META");
    	var ext = new Array();
    	var tr = ol.proj.getTransform('EPSG:4326', 'EPSG:3857');
    	//this.clear();
    	// vezme z konfigu - ma prioritu
        if(extent && extent[0]){
            ext = this.addBBox(extent, "r-1"); //, this.flyr);
        }
    	else if(config && config.polygon){
    		ext = config.polygon.getGeometry().getExtent();
    		config.polygon.setId('r-1');
    		this.flyr.getSource().addFeature(config.polygon);
    	}
    	else if(config && config.extent){
    		ext = this.addBBox(config.extent, "r-1", this.flyr);
    	}
    	else {
            
    		for(var i=0; i<meta.length; i++){
    			if(meta[i].getAttribute("itemprop")=="box"){
    				var b = meta[i].getAttribute("content").split(" ");
    				if(b && b.length==4){ 
    					for (var j=0; j<b.length; j++){		
    						b[j] = parseFloat(b[j]);
    					}
    					if(b[0]>=-180 && b[0]<=180){
    						if(b[1]<-89) b[1] = -89;
    						if(b[3]> 89) b[3] =  89;
    						ext = ol.extent.extend(this.addBBox(b, "r-"+meta[i].getAttribute("id").split("-")[1], this.flyr), ext);
    					}
    				}
    			}
    		}
    	}

    	// sets map extent
    	if(ext[0]){
    		this.map.getView().fit(ext, this.map.getSize());
    		this.select = new ol.interaction.Select({
    			multi: true,
				layers: [this.flyr],
    			style: new ol.style.Style({
    				fill: new ol.style.Fill({
    				    color: [0,200,250,0.25]
    				}),
    				stroke: new ol.style.Stroke({
    				    color: '#0080A0', //TODO to config
    				    width: 2
    				}) 
    		    })
    		});
    		this.map.addInteraction(this.select);
    		this.selFeatures = this.select.getFeatures();
    		this.selFeatures.on('add', this.hoverMap);
    		this.selFeatures.on('remove', this.unhoverMap);
    	}
 	}
	
	this.addBBox = function(b, id, lyr){
        for(var i=0; i<b.length; i++){
            b[i] = parseFloat(b[i]);
        }
        if(b[1]<-89.9) b[1] = -89.9;
        if(b[3]> 89.9) b[3] =  89.9;
    	var g = new ol.geom.Polygon.fromExtent(b);
    	g.transform('EPSG:4326', 'EPSG:3857'); //TODO optimize
    	b = new ol.Feature({geometry: g	});
    	b.setId(id);
		if(lyr) lyr.getSource().addFeature(b);
    	else this.searchLyr.getSource().addFeature(b);
    	return g.getExtent();
    }
            
	//when user click at the record list
    this.hover = function(o){
        $('div.rec').css('background-color', "");
        o.currentTarget.style.backgroundColor = getHoverColor();
		if(!_overmap.flyr) return;
		_overmap.selFeatures.clear();
		_overmap.selFeatures.un('add', _overmap.hoverMap);
		var f = _overmap.flyr.getSource().getFeatureById(o.currentTarget.id);
		if(f){
			_overmap.selFeatures.push(f);
		}
   		_overmap.selFeatures.on('add', _overmap.hoverMap);
	}
	
	// whn user click to map - hover the record list item
    this.hoverMap = function(e) {
    	var div = document.getElementById(e.element.getId());
    	if(div){
    		div.style.backgroundColor = getHoverColor();
    		div.scrollIntoView(true);
            window.scrollBy(0, -3); //FIXME
    	}	
    }

	this.unhoverMap = function(e) {
    	var div = document.getElementById(e.element.getId());
    	if(div){
    		div.style.background=""; // TODO - nejak jinak
    	}	
    }


	
} // class end	

    	
