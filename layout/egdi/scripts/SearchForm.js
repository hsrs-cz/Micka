/*
* Search form class
*
*/
SearchForm = function(a,b){
	$.cookie.json = true;
	var result = "";	
	_this = this;
    var baseURL = (window.location.pathname.replace('/'+HS.getLang(2)+'/','/'));
    $('.md-hide').hide();
	/**
	* Collect the queryables and fires the search
	*/
	this.search = function(run){
        //console.log('search', run);
        if(run !== 1) return false;
        $("#wait").show();
		result = "";
		var type = $("#res-type").val();
		if(type=='data') {
			result = '(type=dataset OR type=series OR type=noGeographicDataset OR type=tile)';
		}
		else addVal('type', "#res-type");
        var t = $('#fulltext').val();
        if(t){
            var where = $("input[name='whereText']:checked").attr('id');
            switch (where){
                case 'wh1': 
                    addVal('Title', "#fulltext", true); break;
                case 'wh2': 
                    if(result) result += ' AND ';
                    result += "(Title like '*"+t+"*' OR Abstract like '*"+t+"*')";
                    break;
                default:  
                    addVal('FullText', "#fulltext"); break;
            }
        }
		addVal('TopicCategory', "#topic");
		addVal('ServiceType', "#stype");
		addVal('Subject', "#inspire");
		addVal('Denominator', "#denominator");
		addVal('OrganisationName', "#contact");
		addVal('MetadataContact', "#mdcontact");
        addVal('IsPublic', "#md-status");
        addVal('Subject', "#kw-2");
        addVal2('Subject', "#gemet", "text");
        addVal2('Subject', "#1ge", "text");
        addVal('MetadataCountry', "#country");
        addVal('server', "#harvest");
		var bbox = _this.overMap.getBBox();
		if(bbox) {
			if(result) result +=" AND ";
			result += "BBOX='" + bbox.join(' ');
            if($('#inside').prop( "checked" )) result += ' 1';
            result += "'";
		}
        if($('#md-inspire').prop( "checked" )){
            if(result) result +=" AND ";
            result += "HierarchyLevelName='http://geoportal.gov.cz/inspire'";
        }
        if($('#md-my').prop( "checked" )){
            if(result) result +=" AND ";
            result += "MdCreator='"+user+"'";
        }
        if($('#md-egdi').prop( "checked" )){
            if(result) result +=" AND ";
            result += "HierarchyLevelName='http://egdi.geus.dk'";
        }
		var sort = $('#sort').val() + ':' + $('#sortdir').val();
		window.location = "?query=" + encodeURIComponent(result) + '&sortby='+sort + '&t=' + (Date.now()/1000|0) +'#results';
	}
	
	function processResults(data, opts){
		var data = $.map(data.results, function(rec) {
			return { text: rec.name, id: rec.id, title: rec.desc, parent: rec.parentId };
		})
		return { results: data }
	}

	function templateResult(data){
		return $( '<div class="sel2-level'+ data.level +'">' + data.text +'</div>' );
	}
	
	function changeType(type){
        $('.md-hide').hide();                            
		switch(type){
			case 'service':
				$("#panel-stype").show();
				break;
			case 'data':
			case 'dataset':
			case 'series':
				$("#panel-topic").show();
				$("#panel-denominator").show();
				break;
            case 'featureCatalogue':
                $("#panel-inspire").hide();
                break;
            default:
		}
	}
	
	// submit form on enter in fulltext field
	$('#fulltext').keypress(function(e) {
		if (e.which == '13') {
			_this.search(1);
		}
	});

   $('#res-type').select2({
		theme: 'bootstrap',
		allowClear: true,
		placeholder: 'Typ zdroje',
		minimumResultsForSearch: Infinity
	})
    .on('select2:select', this.search).on('select2:unselect', function(e){
        $('#res-type').val(null);
        _this.search()
    });
	
	$('#res-type').on('select2:close', function(e){
		changeType(e.target.value);
        //_this.search();
	});
	
	/*$('#kw-2').select2({
		ajax: {
			url: baseURL + '/registry_client/?uri=http://inspire.ec.europa.eu/codelist/EndusePotentialValue&lang=cs',
			dataType: 'json',
			//processResults: processResults, 
			delay: 200,            
			cache: true
	   },
	   templateResult: templateResult,
	   theme: 'bootstrap',
	   allowClear: true
	})
    .on('select2:select', this.search).on('select2:unselect', this.search);
    */
	
    /*$('#gemet').select2({
		ajax: {
			url: baseURL + '/registry_client/proxy.php?url=http://gemet.bnhelp.cz/thesaurus/getConceptsMatchingRegexByThesaurus?',
			dataType: 'json',
            data: function (params) {
                console.log(params);
                var query = {
                    //thesaurus_uri: 'http://www.eionet.europa.eu/gemet/concept/',
                    thesaurus_uri: 'http://www.onegeology-europe.eu/concept/',
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
	
    var oneGeology = new GemetClient({
        url: baseURL + 'registry_client/proxy.php?url=http://gemet.bnhelp.cz/thesaurus/',
        thesaurusUri: 'http://www.onegeology-europe.eu/concept/',
        lang: HS.getLang(2),
        el: '#1ge',
        minChars: 1, 
        showTree: true,
        scope: this,
        onClose: function(){
            this.search();
        }
    });

    var gemet = new GemetClient({
        url: baseURL + 'registry_client/proxy.php?url=https://www.eionet.europa.eu/gemet/',
        thesaurusUri: 'http://www.eionet.europa.eu/gemet/concept/',
        lang: HS.getLang(2),
        el: '#gemet',
        minChars: 1, 
        showTree: true,
        scope: this,
        onClose: function(){
            this.search();
        }
    });
    
	/*$("#contact").select2({
		ajax: {
			url: 'suggest',
			dataType: 'json',
			data: function(params){
				return {
					q: params.term,
					type: 'org'
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
		maxSelectionLength: 1
	})
    .on('select2:select', this.search).on('select2:unselect', this.search);*/
    
	$("#mdcontact").select2({
		ajax: {
			url: 'suggest',
			dataType: 'json',
			data: function(params){
				return {
					q: params.term,
					type: 'mdorg'
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
		maxSelectionLength: 1
	})
    .on('select2:select select2:unselect', this.search);
    
	$("#denominator").select2({
		ajax: {
			url: 'suggest',
			dataType: 'json',
			data: function(params){
				return {
					q: params.term,
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
		maxSelectionLength: 1
	})
    .on('select2:select select2:unselect', this.search);
    
	$("#inspire").select2({
		ajax: {
			url: baseURL + 'registry_client/?uri=http://inspire.ec.europa.eu/theme&lang='+HS.getLang(2),
			dataType: 'json', 
			delay: 200,            
			cache: true
	   },
	   templateResult: templateResult,
	   theme: 'bootstrap',
	   language: HS.getLang(2),
	   allowClear: true
	   
	})
    .on('select2:select select2:unselect', this.search);
        
    $("#topic").select2({
		ajax: {
			url: 'suggest/mdlists',
			dataType: 'json',
			data: function(params){
				return {
					query: params.term,
					type: 'topicCategory',
                    request: 'getValues',
					lang: lang3
				};
			},
			cache: true
		}, 
		language: HS.getLang(2),
		allowClear: true,
		theme: 'bootstrap'
	})
    .on('select2:select select2:unselect', this.search);
    
    $("#stype").select2({
		ajax: {
			url: 'suggest/mdlists',
			dataType: 'json',
			data: function(params){
				return {
					query: params.term,
					type: 'serviceType',
                    request: 'getValues',
					lang: lang3
				};
			},
			cache: true
		}, 
		language: HS.getLang(2),
		allowClear: true,
		theme: 'bootstrap'
	})    
    .on('select2:select select2:unselect', this.search);

	$("#md-status").select2({
		data: [
            //{id: -1, text: HS.i18n('pending')},
            {id:  0, text: HS.i18n('private')},
            {id:  1, text: HS.i18n('public')}
            //,{id:  2, text: HS.i18n('for portal')}
	   ],
	   //templateResult: templateResult,
	   theme: 'bootstrap',
	   language: HS.getLang(2),
	   allowClear: true
	   
	})
    .on('select2:select select2:unselect', this.search);
    
	$("#country").select2({
		ajax: {
			url: 'suggest',
			dataType: 'json',
			data: function(params){
				return {
					q: params.term,
					type: 'mdcountry',
					lang: lang3
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
		theme: 'bootstrap'
	})
    .on('select2:select select2:unselect', this.search);

	$("#harvest").select2({
		ajax: {
			url: 'suggest',
			dataType: 'json',
			data: function(params){
				return {
                    q: params.term,
                    type: 'harvestFrom'
				};
			},
			/*rocessResults: function(data, page){
				return {
					results: $.map(data.records, function(rec) {
						return { text: rec.value, id: rec.value };
					})  
				}    
			},*/
			cache: true
		}, 
		language: HS.getLang(2),
		allowClear: true,
		theme: 'bootstrap'
	})
    .on('select2:select select2:unselect', this.search);
    
    $("#sort").select2({ minimumResultsForSearch: Infinity, allowClear: false});
	$("#sortdir").select2({ minimumResultsForSearch: Infinity, allowClear: false});
	$('#sort').on('select2:close', function(e){ _this.search(); });
	$('#sortdir').on('select2:close', function(e){ _this.search(); });
    $('#inside').on('change', function(e){ _this.search(); });
    $('#md-inspire').on('change', function(e){ _this.search(); });
    $('#md-my').on('change', function(e){ _this.search(); });
    $('#md-egdi').on('change', function(e){ _this.search(); });
        
	this.overMap = new OverMap({
        drawBBOX: true, handler: function(g){
            _this.search();
        }
    });
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
            else if ($(o).prop('type')=='checkbox' || $(o).prop('type')=='radio'){
                data[o.id] = $(o).prop('checked');
            }   
			else {
				if(o.id) data[o.id] = $(o).val();
			}
		});
		data['map'] = _this.overMap.getState();
		$.cookie('micka', data); 
		return false;				
	}
	
	/*
	* Read the search parametres from the cookie
	*/
	this.readCookie = function (){
		var data = $.cookie('micka');
		var f = null;
		if(data) $.each(data, function(field, d){
			if(field=='map'){
				_this.overMap.setState(d);
			}
			else {
				f = $("#"+field);
                if(f){
                    if (f.prop('type')=='checkbox') { f.prop('checked', d); }
                    else if(typeof d == 'string') { f.val(d); }
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
            v[i] = v[i].replace("'", "\\\'");
			if(like) v[i] = key +" like '*"+v[i]+"*'";
			else v[i] = key +"='"+v[i]+"'";
		}
		if (v.length>1) result += '(' + v.join(' OR ') + ')';
		else result += v[0];
	}
	
    var addVal2 = function(key, s,  attrib, like){
		if($(s).is(':hidden')) return;
		var data = $(s).select2('data');
		if(!data || data.length==0) return;
		if(result) result += " AND ";
        var v = new Array();
		for(i in data){
			if(like) v.push(key +" like '*"+data[i][attrib]+"*'");
			else v.push(key +"='"+data[i][attrib]+"'");
		}
		if (v.length>1) result += '(' + v.join(' OR ') + ')';
		else result += v[0];
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
        $(':checkbox').prop( "checked", false );
        this.search(1);
	}

}
