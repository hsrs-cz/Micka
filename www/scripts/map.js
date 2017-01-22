micka.initMap=function(config){
	micka.extents = new Array();
	micka.mapfeatures = new ol.Collection();
	micka.flyr = new ol.layer.Vector({
		source: new ol.source.Vector({features: micka.mapfeatures}),
		style: new ol.style.Style({
			fill: new ol.style.Fill({
			    color: [0,0,0,0]
			}),
			stroke: new ol.style.Stroke({
			    color: '#3182BD',
			    width: 2
			}) 
	    })
	});

	micka.overmap = new ol.Map({
        target: "overmap",
        theme: null,
        layers: [
 			new ol.layer.Tile({	source: new ol.source.OSM() }),	                   
            micka.flyr
        ],
        view: new ol.View({
        	projection: 'EPSG:3857',
            center: [0,0], 
            zoom: 0
        })
    });
	
	// prochazi elementy
	var meta = document.getElementsByTagName("META");
	var ext = new Array();
	var tr = ol.proj.getTransform('EPSG:4326', 'EPSG:3857');
	
	// vezme z konfigu - ma prioritu
	if(config && config.polygon){
		ext = config.polygon.getGeometry().getExtent();
		config.polygon.setId('r-1');
		micka.flyr.getSource().addFeature(config.polygon);
	}
	else if(config && config.extent){
		ext = micka.addBBox(config.extent, "r-1");
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
						if(b[1]<-85) b[1] = -85;
						if(b[3]> 85) b[3] = 85;						
						ext = ol.extent.extend(micka.addBBox(b, "r-"+meta[i].getAttribute("id").split("-")[1]), ext);
					}
				}
			}
		}
	}

	// nastaveni rozsahu
	if(ext[0]){
		micka.overmap.getView().fit(ext, micka.overmap.getSize());
		micka.select = new ol.interaction.Select({
			multi: true,
			style: new ol.style.Style({
				fill: new ol.style.Fill({
				    color: [0,200,250,0.25]
				}),
				stroke: new ol.style.Stroke({
				    color: '#00E8FF',
				    width: 2
				}) 
		    })
		});
		micka.overmap.addInteraction(micka.select);
		micka.selFeatures = micka.select.getFeatures();
		micka.select.on('select', micka.hoverMap);
	}
	
	
	//-- pro LITE -- box
	if(config != undefined && config.edit == true){
		var dragBoxInteraction = new ol.interaction.DragBox({
	        condition: ol.events.condition.platformModifierKeyOnly,
	        code: 'AAA',
	        style: new ol.style.Style({
	          stroke: new ol.style.Stroke({
	            color: 'red',
	            width: 2
	          })
	        })
	    });
	
	    dragBoxInteraction.on('boxend', function(e) {
	        var g = e.target.getGeometry();
	        g.transform('EPSG:3857', 'EPSG:4326');
	        g = g.getExtent();
	        micka.mapfeatures.clear();
	        micka.addBBox(g, 'i-1');
	        if(config.handler){
	        	config.handler(g);
	        }
	        else { // TODO dat do samostatne fce - cfg ?
		        document.forms[0].xmin.value=g[0].toFixed(3);
		        document.forms[0].ymin.value=g[1].toFixed(3);
		        document.forms[0].xmax.value=g[2].toFixed(3);
		        document.forms[0].ymax.value=g[3].toFixed(3);
	        }
	    });
		micka.overmap.addInteraction(dragBoxInteraction);
	}
}

micka.addBBox = function(b, id){
	var g = new ol.geom.Polygon.fromExtent(b);
	g.transform('EPSG:4326', 'EPSG:3857');
	b = new ol.Feature({geometry: g	});
	b.setId(id);
	micka.flyr.getSource().addFeature(b);
	return g.getExtent();
}
