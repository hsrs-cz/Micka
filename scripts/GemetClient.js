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
    // GEMET default
    var thesaurus_uri = params.thesaurusUri ? params.thesaurusUri : 'http://www.eionet.europa.eu/gemet/concept/'
    
    this.onThesChange = function (e) {
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
                d[1].children.push({id: data[i].uri, text: data[i].preferredLabel.string});
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
                    d[2].children.push({id: data[i].uri, text: data[i].preferredLabel.string});
                }
                $t.select2({
                    data: d,
                    allowClear: true,
                    theme: 'bootstrap',
                    minimumResultsForSearch: Infinity
                });
                $t.select2('open');
            });
        });
    };
    
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
        minimumInputLength: 3,
        language: lang,
        theme: 'bootstrap',
        allowClear: true 
    };
    
    $t.select2(defCfg);
    if(showTree){
        $t.on('select2:select', this.onThesChange);
    }
    // when clearing the field
    $t.on('select2:unselecting', function(e){
        e.stopPropagation();
        $t.select2().empty();
        $t.select2(defCfg);
    });
    
};

