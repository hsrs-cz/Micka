// Gemet Client - thesaurus 

HS.Lang.cze['broader term'] = 'širší termín';
HS.Lang.cze['narrower terms'] = 'užší termníny';


var GemetClient = function(params){
    if(!params.url) {console.log('gemetClient params.url not defined.'); return; }
    var url = params.url; 
    if(!params.lang) {console.log('gemetClient params.lang not defined.'); return; }
    var lang = params.lang;
    if(!params.el) {console.log('gemetClient params.el not defined.'); return; }
    var $t = $(params.el);
    var showTree = params.showTree;
    var onClose = params.onClose;
    var scope = params.scope;
    
    // GEMET default
    var thesaurus_uri = params.thesaurusUri ? params.thesaurusUri : 'http://www.eionet.europa.eu/gemet/concept/';
    var minChars = (params.minChars != undefined) ? params.minChars : 3;
    var sel = 0;

	var templateResult = function(data){
		return $( '<div class="sel2-level'+ data.level +'">' + data.text +'</div>' );
	}
    
    this.onThesChange = function (e) {
        sel = 1;
        e.stopPropagation();
        var d = [
            e.params.data,
            {text: HS.i18n('broader term'), children: []}, 
            {text: HS.i18n('narrower terms'), children: []}
        ];
        $t.select2().empty();
        $.ajax({
            url: url + 'getRelatedConcepts?',
            context: this,
            data: {
                concept_uri: e.params.data.id,
                relation_uri: 'http://www.w3.org/2004/02/skos/core%23broader',
                language: lang
            }
        })
        .done(function(data){
            for(var i=0;i<data.length; i++){
                d[1].children.push({id: data[i].uri, text: data[i].preferredLabel.string, level: 1});
            }
            $.ajax({
                url: url + 'getRelatedConcepts?',
                context: this,
                data: {
                    concept_uri: e.params.data.id,
                    relation_uri: 'http://www.w3.org/2004/02/skos/core%23narrower',
                    language: lang
                }
            })
            .done(function(data){
                for(var i=0;i<data.length; i++){
                    d[2].children.push({id: data[i].uri, text: data[i].preferredLabel.string, level: 1});
                }
                $t.select2({
                    data: d,
                    allowClear: true,
                    theme: 'bootstrap',
                    minimumResultsForSearch: Infinity,
                    templateResult: templateResult
                });
                $t.select2('open');
            });
        });
    };
    
    this.onSelect = function(){
        sel = 0;
    }

    this.process = function(langs, handler){
        var terms = {};
        var l2 = null;
        var uri = $t.val();
        
        for(i in langs){
            l2 = HS.getCodeFromLanguage(langs[i],2);
            if(l2.length==2){
                $.ajax({
                    url: url + 'getConcept?concept_uri='+uri+'&language='+l2, 
                    context: {lang: langs[i]}
                })
                .done(function(data){
                    if(data.preferredLabel){
                        terms[this.lang] = data.preferredLabel.string;
                    }
                    else terms[this.lang] = "";
                    if(langs.length <= Object.keys(terms).length){
                        // call handler function
                        handler({
                            uri: uri,
                            labels: terms
                        })
                    }
                })
                .fail(function(data){
                    console.log('fail', data);
                })
            }
        }
    };
    
    var defCfg = {
        ajax: {
            url: url +'getConceptsMatchingRegexByThesaurus?',
            dataType: 'json',
            data: function (params) {
                var query = {
                    thesaurus_uri: thesaurus_uri,
                    regex: encodeURI(params.term),
                    language: lang,
                    page: params.page
                 }
                return query;
            },
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
        minimumInputLength: minChars,
        language: lang,
        theme: 'bootstrap',
        allowClear: true 
    };
    
    $t.select2(defCfg);
    if(showTree){
        $t.on('select2:selecting', this.onSelect);
        $t.on('select2:select', this.onThesChange);
    }
    // when clearing the field
    $t.on('select2:unselect', function(e){
        e.stopPropagation();
        $t.select2().empty();
        $t.select2(defCfg);
        onClose.call(scope);
    });
    
    $t.on('select2:close', function(d){
        if(sel==1 && onClose){
            onClose.call(scope);
        }
    });

};



var RegistryClient = function(params){
    if(!params.el) {console.log('RegistryClient params.el not defined.'); return false; }
    var $t = $(params.el);
    if(!$t) {console.log('RegistryClient params.el not found.'); return false; }
    var lang = params.lang ? params.lang : 'eng';
    if($t.attr('data-ajax--url')) {
        var url = $t.attr('data-ajax--url');
        $t.removeAttr('data-ajax--url');
    }
    else {
        if(!params.url) {console.log('RegistryClient params.url not defined.'); return; }
        if(!params.thesaurusUri) {console.log('RegistryClient params.thesaurusUri not defined.'); return; }
        if(!params.lang) {console.log('RegistryClient params.lang not defined.'); return; }
        var url = params.url + '?uri='+params.thesaurusUri+'&lang='+params.lang;
    }
    var format = params.format ? params.format : 'application/json';
    var showTree = params.showTree;
    var onClose = params.onClose;
    var scope = params.scope;
    var qSearch = params.qSearch;
    var qHierarchy = params.qHierarchy;
    var qLangs = params.qLangs;
    
    var minChars = (params.minChars != undefined) ? params.minChars : 3;
    var sel = 0;

	var templateResult = function(data){
		return $( '<div class="sel2-level'+ data.level +'">' + data.text +'</div>' );
	}
    
    this.onThesChange = function (e) {
        sel = 1;
        e.stopPropagation();
        let self = this;
        if(e.params.data.prepared){
            $t.select2(defCfg);
            return;
        }
        else{
            e.params.data.selected=false
            e.params.data.prepared=true;
            e.params.data.level='A';
            var d = [];
            for(const el of $t.select2('data')){
                if(el.id != e.params.data.id) {
                    el.level='H';
                    d.push(el);
                }
            }
            d.push(e.params.data);
            d.push({text: HS.i18n('broader term'), children: []});
            d.push({text: HS.i18n('narrower terms'), children: []});
        }
        $t.select2().empty();
        $.ajax({
            url: url,
            context: this,
            data: {
                id: e.params.data.id,
                request: 'hierarchy'
            }
        })
        .done(function(data){
            for(var i=0;i<data.results.length; i++){
                data.results[i].level=1;
                if(data.results[i].hierarchy=='b'){
                    d[d.length-2].children.push(data.results[i]);
                }
                else {
                    d[d.length-1].children.push(data.results[i]);
                }
            }
            $t.select2({
                data: d,
                allowClear: true,
                theme: 'bootstrap',
                minimumResultsForSearch: Infinity,
                templateResult: templateResult
            });
            $t.select2('open');
        });
    };
    
    this.onSelect = function(){
        sel = 0;
    }

    // TODO - zatim nevyresene
    this.process = function(langs, handler){
        var terms = {};
        var uri = $t.val();
        console.log(uri);
        $.ajax({
            url: url, 
            data: {
                uri: thesaurusUri,
                request: 'trasl',
                id: uri
            }
        })
        .done(function(data){
            for(var i=0; i<data.results.bindings.length; i++){
                terms[HS.getCodeFromLanguage(data.results.bindings[i].prefLabel['xml:lang'],3)] = data.results.bindings[i].prefLabel.value;
            }
            handler({
                uri: uri,
                labels: terms
            });
        })
        .fail(function(data){
            console.log('fail', data);
        });
    };
    
    var defCfg = {
        ajax: {
            url: url ,
            dataType: 'json',
            data: function (params) {
                var query = {
                    q: params.term/*,
                    uri: thesaurusUri*/
                }
                return query;
            },
            delay: 200,  
            cache: false
        },
        minimumInputLength: minChars,
        language: lang,
        theme: 'bootstrap',
        allowClear: true 
    };
    
    $t.select2(defCfg);
    if(showTree){
        $t.on('select2:selecting', this.onSelect);
        $t.on('select2:select', this.onThesChange);
    }
    // when clearing the field
    $t.on('select2:unselect', function(e){
        e.stopPropagation();
        $t.select2(defCfg);
        if(onClose) onClose.call(scope);
    });
    
    $t.on('select2:close', function(d){
        if(sel==1 && onClose){
            onClose.call(scope);
        }
    });

};
