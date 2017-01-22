/*
* Search form class
*
*/
SearchForm = function(){
	$.cookie.json = true;
	var result = "";	
	_this = this;

	function processResults(data, opts){
		var data = $.map(data.suggestions, function(rec) {
			return { text: rec.name, id: rec.id, title: rec.desc, parent: rec.parentId };
		})
		return { results: data }
	}

	function templateResult(data){
		var level = data.parent ? 2 : 1; 
		return $( '<div class="hs-level'+ level +'">' + data.text +'</div>' );
	}
	
	function changeType(type){
		switch(type){
			case 'service':
			//case 'application':	
				$("#panel-topic").hide();
				$("#panel-denominator").hide();
				$("#panel-stype").show();
				break;
			case 'data':
			case 'dataset':
			case 'series':
				$("#panel-topic").show();
				$("#panel-denominator").show();
				$("#panel-stype").hide();
				break;
			default:
				$("#panel-topic").hide();
				$("#panel-denominator").hide();
				$("#panel-stype").hide();
		}		
	}
	
	// submit form on enter in fulltext field
	$('#fulltext').keypress(function(e) {
		if (e.which == '13') {
			_this.search();
		}
	});

   $('#res-type').select2({
		theme: 'bootstrap',
		allowClear: true,
		placeholder: 'Typ zdroje',
		minimumResultsForSearch: Infinity//,
		/*data: [
			{id: 'data', text: 'data'},
			{id: 'service', text: 'service'},
			{id: 'application', text: 'application'},
			{id: 'fc', text: 'feature catalogue'},
		]*/
	});
	
	$('#res-type').on('select2:close', function(e){
		changeType(e.target.value)
	});
	
	$('#kw-2').select2({
		ajax: {
			url: '/projects/kafka/registry_client/?uri=http://inspire.ec.europa.eu/codelist/EndusePotentialValue&lang=cs',
			dataType: 'json',
			processResults: processResults, 
			delay: 200,            
			cache: true
	   },
	   templateResult: templateResult,
	   theme: 'bootstrap',
	   allowClear: true
	});

	/*$('#gemet').select2({
		ajax: {
			url: '/projects/kafka/registry_client/proxy.php?url=http://gemet.bnhelp.cz/thesaurus/getConceptsMatchingRegexByThesaurus?',
			dataType: 'json',
           data: function (params) {
                console.log(params);
                var query = {
                    thesaurus_uri: 'http://www.eionet.europa.eu/gemet/concept/',
                    regex: encodeURI(params.term),
                    language: HS.getLang(2),
                    page: params.page
                 }
                return query;
            },
			//processResults: processResults, 
           processResults: function(data, page){
                return {
                    results: $.map(data, function(rec) {
                        return { text: rec.preferredLabel.string, id: rec.uri };
                    })  
                }    
            },
			delay: 200,  
			cache: false
	   },
        templateResult:	function (data){
        console.log(data);
            var level = data.parent ? 2 : 1; 
            return $( '<div class="hs-level'+ level +'">' + data.text +'</div>' );
        },

	   //templateResult: templateResult,
       minimumInputLength: 3,            
 		language: 'cs',
	   theme: 'bootstrap',
	   allowClear: true
	});*/
	
	$("#contact").select2({
		ajax: {
			url: 'suggest',
			dataType: 'json',
			data: function(params){
				return {
					query: params.term,
					type: 'organisation'
				};
			},
			processResults: function(data, page){
				return {
					results: $.map(data.records, function(rec) {
						return { text: rec.name, id: rec.name };
					})  
				}    
			},
			cache: true
		},
		language: HS.getLang(2),
		allowClear: true,
		theme: 'bootstrap',
		//tags:true,
		maxSelectionLength: 1
	});

	$("#denominator").select2({
		ajax: {
			url: 'suggest',
			dataType: 'json',
			data: function(params){
				return {
					query: params.term,
					type: 'denom'
				};
			},
			processResults: function(data, page){
				return {
					results: $.map(data.records, function(rec) {
						return { text: rec.value, id: rec.value };
					})  
				}    
			},
			cache: true
		},
		language: HS.getLang(2),
		allowClear: true,
		theme: 'bootstrap',
		//tags:true,
		maxSelectionLength: 1
	});

	$("#inspire").select2({
		ajax: {
			url: '/projects/kafka/registry_client/?uri=http://inspire.ec.europa.eu/theme&lang=cs',
			dataType: 'json',
			processResults: processResults, 
			delay: 200,            
			cache: true
	   },
	   templateResult: templateResult,
	   theme: 'bootstrap',
	   language: HS.getLang(2),
	   allowClear: true
	   
	});    
	
	 $("#topic").select2({
		ajax: {
			url: 'suggest',
			dataType: 'json',
			data: function(params){
				return {
					query: params.term,
					type: 'topics',
					lang: lang3
				};
			},
			processResults: function(data, page){
				return {
					results: $.map(data.records, function(rec) {
						return { text: rec.name, id: rec.id };
					})  
				}    
			},
			cache: true
		}, 
		language: HS.getLang(2),
		allowClear: true,
		theme: 'bootstrap'
	});
	
	 $("#stype").select2({
		ajax: {
			url: 'suggest',
			dataType: 'json',
			data: function(params){
				return {
					query: params.term,
					type: 'serviceType',
					lang: lang3
				};
			},
			processResults: function(data, page){
				return {
					results: $.map(data.records, function(rec) {
						return { text: rec.name, id: rec.name };
					})  
				}    
			},
			cache: true
		}, 
		language: HS.getLang(2),
		allowClear: true,
		theme: 'bootstrap'
	});

	$("#sort").select2({ minimumResultsForSearch: Infinity, allowClear: false});
	$("#sortdir").select2({ minimumResultsForSearch: Infinity, allowClear: false});
	
	this.overMap = new OverMap({drawBBOX: true});
	this.overMap.drawMetadata();
	
	/*
	* Save the search parametres to the cookie
	*/
	this.saveCookie = function (){
		var data = {};
		var el = null;
		$("#search-form input, #search-form select").each(function(i,o){
			if(o.nodeName=='SELECT'){
				data[o.id] = {};
				$el = $('#'+ o.id +' option:selected');
				if($el) $el.each(function(){
					data[o.id][$(this).val()] =  $(this).text();
				});				
			}
			else {
				if(o.id) data[o.id] = $(o).val();
			}
		});
		data['map'] = _this.overMap.getState();
		$.cookie('micka', data); 
		//console.log('save cookie', data)
		return false;				
	}
	
	/*
	* Read the search parametres from the cookie
	*/
	this.readCookie = function (){
		var data = $.cookie('micka');
		var f = null;
		//console.log('read cookie', data);
		if(data) $.each(data, function(field, d){
			if(field=='map'){
				_this.overMap.setState(d);
			}
			else {
				f = $("#"+field);
				if(typeof d == 'string'){ f.val(d); }
				else {
					if(f[0].length>0){
						var vals = [];
						$.each(d, function(k, v){ vals.push(k); });
						f.val(vals).trigger('change');
					}
					else {
						$.each(d, function(k, v){ f.append('<option selected value="'+k+'">'+v+'</option>');	});
					}
				}
				f.trigger('change.select2');
			}
		});
		changeType($('#res-type').val());
	}
	
	addVal = function(key, s, like){
		if($(s).is(':hidden')) return;
		var v = $(s).val();
		if(!v) return;
		if(typeof v=='string') v = [v]; 
		if(result) result += " AND ";
		for(i in v){
			if(like) v[i] = key +" like '*"+v[i]+"*'";
			else v[i] = key +"='"+v[i]+"'";
		}
		if (v.length>1) result += '(' + v.join(' OR ') + ')';
		else result += v[0];
	}
	
	/**
	* Collect the queryables and fires the search
	*/
	this.search = function(){
		result = "";
		var type = $("#res-type").val();
		if(type=='data') {
			result = '(type=dataset OR type=series OR type=noGeographicDataset OR type=tile)';
		}
		else addVal('type', "#res-type");
		addVal('AnyText', "#fulltext", true);
		addVal('TopicCategory', "#topic");
		addVal('ServiceType', "#stype");
		addVal('Subject', "#inspire");
		addVal('Denominator', "#denominator");
		addVal('OrganisationName', "#contact");
		var bbox = this.overMap.getBBox();
		if(bbox) {
			if(result) result +=" AND ";
			result += "BBOX='" + bbox.join(' ') + "'";
		}
		var sort = $('#sort').val() + ':' + $('#sortdir').val();
		//this.saveCookie();
		window.location = "?query=" + encodeURIComponent(result) + '&sort='+sort + '#results';
	}
	
	/**
	* Empty the search form
	*/
	this.clear = function(){
		$("#search-form input, #search-form select").each(function(i,o){
			if ($(o).attr('data-reset')=='default') {
				$(o).val(o.options[0].value).trigger('change.select2');
			}	
			else $(o).val('').trigger('change.select2');
		});
		this.overMap.clear();
	}

}
