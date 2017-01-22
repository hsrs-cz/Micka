/**
 * Name: Gemetclient
 * Purpose: Graphical ExtJS-based JavaScript client for GEMET Thesaurus
 * Author: Stepan Kafka <kafka email cz>
 * Copyright: Help Service - Remote Sensing s.r.o 2009
 * URL: http://bnhelp.cz
 * Licence: GNU/LGPL v3
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * Class: ThesaurusReader 
 * Class to provide access to Gemet thesaurus with JSON interface and shows terms
 * date: 2008-08-15
 * version: 1.0 
 * extends: Ext.Panel
 * 
 * Parameters: 
 * config {object}
 *	possible values (key / value pair):
 *		handler - {String} - handler function (mandatory)
 *		appPath - {String} - application path (important for adressing app images etc.. If ommited, current directory is used) 
 *		url - {String} - address of gemet service - (optional, if ommited http://www.eionet.europa.eu/gemet/ is used)
 *		lang - {String} - interface/query language (default cze)
 *		outputLangs - {Array} - array of languages for output (default ['cze', 'eng'])
 *		separator - {String} -  to separate terms when whole path is returned (default ' > ')
 *		returnPath - {Boolean} - if full path is returned (default true)
 		proxy - {String} - proxy path (default: appPath+proxy.php?url=) 
 *      transl - {function} - function to provide i18n support. (default HS.i18n)
 *
 *  Example:
 *  (code)
 *  Ext.onReady(function(){
 *      ...
 *
 *      var thes = new ThesaurusReader({
 *          lang: HS.getLang(2),
 *          outputLangs: ['en','cs', 'fr', 'de'], 
 *          title: 'GEMET Thesaurus',
 *          separator: ' > ',
 *          returnPath: true,
 *          returnInspire: false,
 *          width: 300, height:400,
 *          layout: 'fit',
 *          handler: writeTerms
 *      });
 *      
 *      thes.render('thesDiv');
 *
 *      ...
 *  };
 *
 *  (end)
 */ 
var ThesaurusReader = function(config){

	// -- predefined ---
	this.url   		= "http://www.eionet.europa.eu/gemet/";
	this.thesauri		= {};
	
  	this.narrower = "http://www.w3.org/2004/02/skos/core%23narrower";
	this.broader  = "http://www.w3.org/2004/02/skos/core%23broader";
	this.related  = "http://www.w3.org/2004/02/skos/core%23related";

	this.thesauriInit = {
	    'GEMET': {
	    	concept:    "http://www.eionet.europa.eu/gemet/concept/",
	    	theme:      "http://www.eionet.europa.eu/gemet/theme/",        
	    	group:   	"http://www.eionet.europa.eu/gemet/group/",
	    	supergroup: "http://www.eionet.europa.eu/gemet/supergroup/"
	    },
	   	'INSPIRE': {
	   	      url: 		 "http://www.eionet.europa.eu/gemet/",
	   		  concept:   "http://inspire.ec.europa.eu/theme/",
			  theme:     "http://inspire.ec.europa.eu/theme/",        
			  group:   	 null,
			  supergroup: null,
			  firstClick: true
		}
	};
	this.appPath	= "";

  if(config.appPath) this.appPath = config.appPath;
	this.proxy 		= this.appPath+"proxy.php?url=";
	this.lang 		= 'en';
	this.outputLangs = ['cs', 'en'];
	this.separator 	= "/";
	this.returnPath = true;
	this.autoTop = true;
	
	if(config.url) this.url = config.url; 
    if(config.proxy) this.proxy = config.proxy;
    if(config.lang) this.lang = config.lang;
 	if(config.outputLangs) this.outputLangs = config.outputLangs;
  	if(config.separator) this.separator = config.separator;
  	if(config.returnPath!='undefined') this.returnPath = config.returnPath;
  	this.handler = config.handler;
  	if(config.thesaurus){
  		for(thesName in config.thesaurus){
    		  if(config.thesaurus[thesName].url){
    			    this.thesauri[thesName] = config.thesaurus[thesName];
      		}
      		else {
      			  this.thesauri[thesName] = this.thesauriInit[thesName];
      		}	
    	}
  	}
  	else {
  		this.thesauri = this.thesauriInit;
  	}
  	    
    this.data=null;
    this.theMask = null; 
    this.status = 0;
    
	Ext.define('thesModel', {
	    extend: 'Ext.data.Model',
		  fields: [
     		{name: 'id', mapping: 'uri'}, 
     		{name: 'term', mapping: 'preferredLabel.string'},
     		{name: 'definition', mapping: 'definition'}
     	]
	});
    
    var termsStore = new Ext.data.Store({
    	model: "thesModel",
    	proxy: {
    		type: "ajax",
    		url: this.proxy,
    		extraParams: {url: ''},
        language: this.lang,
    		reader: {
            	root: 'results',
            	idProperty: 'term'
    		}
    	}
    });
    
    this.suggestionCfg = function(obj, o){
    	var conceptURI = this.thesauri[this.selectThes.value].concept;
    	var addr = this.thesauri[this.selectThes.value].url;
    	if(!addr) addr = this.url;
    	obj.proxy.extraParams.url = addr+"getConceptsMatchingRegexByThesaurus?thesaurus_uri="+conceptURI+"&language="+this.lang+"&regex="+escape(this.searchField.getValue());    
    };
    
    termsStore.on('beforeload', this.suggestionCfg, this, {});
    
    this.suggestionSelect = function(cbox, record){
    	var node = {data:{termId:record[0].data.id, text: record[0].data.term, data:{definition: record[0].data.definition}}};
    	this.getById(node);
    };

   this.searchField = new Ext.form.ComboBox({
      store: termsStore,
      width: 150,
      minChars: 3,
      displayField: 'term',
      listeners: {'select': this.suggestionSelect, scope: this},
       minLengtText: 'At least 3 characters...',
      //msgTarget: 'under',
      triggerClass:'x-form-search-trigger',
      obj: this 
    });
    
   
    this.showError = function(){
      Ext.Msg.alert('Error', 'Source not found at:' + this.url);
      this.theMask.hide();      
    };
   
    // draw response from thesaurus
    this.drawTerms = function(r, o){
      this.theMask.hide();
      var root = o.options.node;
      root.set("icon", "");
      if(r.responseText){
        try{
          var data = Ext.decode(r.responseText);
          if(data.results) this.drawBranch(root, data.results);
          root.expand();
        }
        catch(e){
        	alert('Data error: '+e.toString());
        }
      }
    };

    this.drawBranch = function(parentNode, data){
      var uri = this.thesauri[this.selectThes.value];
      for(var i=0;i<data.length;i++){
        if(data[i].uri.indexOf(uri.theme)>-1) var icon=this.appPath+'img/theme.gif';
        else if(data[i].uri.indexOf(uri.group)>-1) var icon=this.appPath+'img/group.gif';
        else var icon=this.appPath+'img/term.gif';
        parentNode.appendChild({
        	leaf: true,
            text: data[i].preferredLabel.string,
            termId: data[i].uri,
            data: data[i],
            icon: icon,
            cls: 'thes-link'
        });
      }        
    };

    /* empties tree structure */
    this.emptyTree = function(){
    	this.treePanel.store.getRootNode().removeAll();    
    };
    
    /* hide/unhide top toolbar */
    this.tbVisible = function(v){
    	var tb = this.treePanel.getDockedItems('toolbar[dock="top"]')[0];
        if(v) tb.show();
        else tb.hide();
    }
    

  /**
   * Runs thesaurus query by (sub)string. Ajax returns to drawTerms
   */     
    this.getByTerm = function(){
	  this.obj.emptyTree();
      this.obj.detailPanel.collapse();
      this.tbVisible(false);
      if(this.getValue().length < this.minLength) {
        Ext.Msg.alert(HS.i18n('Warning'), '&gt;= ' +this.minLength+' '+HS.i18n('characters required'));
        return false;
      }
      if(!this.obj.theMask) this.obj.theMask = new Ext.LoadMask(this, {});
      this.obj.theMask.show();
      this.obj.thesRoot.setText(HS.i18n('Found'));  
	    var conceptURI = this.obj.thesauri[this.obj.selectThes.value].concept; 
      Ext.Ajax.request({
        url: this.obj.prepareRequest("getConceptsMatchingRegexByThesaurus?thesaurus_uri="+conceptURI+"&language="+this.obj.lang+"&regex="+this.getValue()),
        //url: this.obj.prepareRequest("getConceptsMatchingKeyword?language="+this.obj.lang+"&search_mode=0&keyword="+this.getValue()),
        scope: this.obj,
        options: {node: this.obj.thesRoot},
        success: this.obj.drawTerms,
        failure: this.obj.showError
      });
    };

	/* NEW - Returnes top concepts for thesaurus */
	this.getTopConcepts = function(){
	  	var conceptURI = this.thesauri[this.selectThes.value].concept;
	  	this.emptyTree();
	    this.tbVisible(false);
	    this.detailPanel.update('');
	    this.detailPanel.collapse();
	    if(!this.theMask) this.theMask = new Ext.LoadMask(this, {});
	    this.theMask.show();
	    this.thesRoot.text= HS.i18n('Top concepts');
	    Ext.Ajax.request({
	      url: this.prepareRequest("getTopmostConcepts?thesaurus_uri="+conceptURI+"&language="+this.lang),
	      scope: this,
	      options: {node: this.treePanel.store.getRootNode()},
	      success: this.drawTerms,
	      failure: this.showError
	    });		
	};

  /**
   * getById
   * Runs thesaurus getRelatedConcepts by id. Ajax returns to drawTermsId
   */     
    this.getById = function(obj){
      if(!this.theMask) this.theMask = new Ext.LoadMask(this, {});
      this.data=obj.data.termId;
      //console.log(obj.data);
  	  this.emptyTree();
  	  this.tbVisible(true);
  	  //this.thesRoot.text = obj.data.text;
      var theTitle = this.treePanel.getDockedItems('toolbar[dock="top"]')[0].items.items[0];
      theTitle.setText("<span class='thes-term'><b>"+obj.data.text+"</b></span>");
      if(obj.data.definition){
        this.detailPanel.update(obj.data.definition.string);  
        this.detailPanel.expand();
      }
      else{
        this.detailPanel.update('');
        this.detailPanel.collapse();        
      }
      
      //---narrowser---
      var nt = this.treePanel.store.getRootNode().appendChild({
        text: HS.i18n("NT"), 
        termId: 'nt', 
        icon: 
        this.appPath+'img/indicator.gif'}
      );  
          
      Ext.Ajax.request({
        url: this.prepareRequest("getRelatedConcepts?concept_uri="+obj.data.termId+"&relation_uri="+this.narrower+"&language="+this.lang),
        scope: this,
        options: {node: nt},
        success: this.drawTerms,
        failure: this.showError
      });
      
      //---broader---
      var bt =this.treePanel.store.getRootNode().appendChild({
        text: HS.i18n("BT"), 
        termId: 'bt', 
        icon:this.appPath+'img/indicator.gif'}
      );
            
      Ext.Ajax.request({
        url: this.prepareRequest("getRelatedConcepts?concept_uri="+obj.data.termId+"&relation_uri="+this.broader+"&language="+this.lang),
        scope: this,
        options: {node: bt},
        success: this.drawTerms,
        failure: this.showError
      });
      
      //---relative---
      var rt = this.treePanel.store.getRootNode().appendChild({
        text: HS.i18n("RT"), 
        termId: 'rt', 
        icon:this.appPath+'img/indicator.gif'
      });
            
      Ext.Ajax.request({
        url: this.prepareRequest("getRelatedConcepts?concept_uri="+obj.data.termId+"&relation_uri="+this.related+"&language="+this.lang),
        scope: this,
        options: {node: rt},
        success: this.drawTerms,
        failure: this.showError
      });
      
      var th = this.treePanel.store.getRootNode().appendChild({
        text: HS.i18n("TH"), 
        termId: 'th', 
        icon:this.appPath+'img/indicator.gif'}
      );      
      
      Ext.Ajax.request({
        url: this.prepareRequest("getRelatedConcepts?concept_uri="+obj.data.termId+"&relation_uri=http://www.eionet.europa.eu/gemet/2004/06/gemet-schema.rdf%23theme&language="+this.lang),
        scope: this,
        options: {node: th},
        success: this.drawTerms,
        failure: this.showError
      });
      this.treePanel.store.getRootNode().expand();
    };
	
	/* adds proxy to URL */
    this.prepareRequest = function(arg){
      var url = this.thesauri[this.selectThes.value].url;
      if(!url) url = this.url; 
      url += arg;
      if(this.proxy) return this.proxy+escape(url);
      else return url;
    }; 
    
	/* returns selected term (all languages, with paths) */
	this.returnTerm = function(obj){
		if(obj.xtype != 'button') this.data=obj.data.termId;
	    this.theMask.show();
	    this.output = {terms:{}, uri:'', version:''};
		  this.status=0;
		  for(var i=0;i<this.outputLangs.length;i++){
			Ext.Ajax.request({
	          url: this.prepareRequest("getConcept?concept_uri="+this.data+"&language="+this.outputLangs[i]),
	          scope: this,
	          success: this.getConceptBack,
	          failure: this.showError
	      	});  
		  }
	}; 
	
	/* getConcept */
    this.getBroaderConcept = function(uri, lang){
      Ext.Ajax.request({
        url: this.prepareRequest("getRelatedConcepts?concept_uri="+uri+"&relation_uri="+this.broader+"&language="+lang),
        scope: this,
        success: this.getConceptBack,
        failure: this.showError
      });
    };
    
	/* getConcept */
    this.getConceptBack = function(r,o){
      if(r.responseText){
        try{
          var data = Ext.decode(r.responseText);
          data = data.results;
          if(!data.preferredLabel) {
          	for(var i=0;i<data.length;i++){
          	  if(data[i].uri.indexOf(this.thesauri[this.selectThes.value].concept)>-1){
          	    data = data[i];
          	    break;
          	  }  
          	}
          	if(!data.preferredLabel){
          	   this.finishTerm();
          	   return;
          	}
          }
          if(!this.output.terms[data.preferredLabel.language]){ 
          	this.output.terms[data.preferredLabel.language] = data.preferredLabel.string;
          	this.output.uri = data.uri;
          }	
          else this.output.terms[data.preferredLabel.language] = data.preferredLabel.string + this.separator + this.output.terms[data.preferredLabel.language];
          // the single thesaurus path setting is read
          if(typeof this.thesauri[this.selectThes.value].returnPath != 'undefined'){
              if(this.thesauri[this.selectThes.value].returnPath) {
                  this.getBroaderConcept(data.uri, data.preferredLabel.language);
              }
              else this.finishTerm();
          }
          // if paths is not found on the thesaurus level, overall config is used
          else if(this.returnPath){ 
              this.getBroaderConcept(data.uri, data.preferredLabel.language);
          }    
          else this.finishTerm();
        }
        catch(e){alert('Data error!');}
      }
      else{
        this.finishTerm();
      }   
    };
    
    /* When term is returned */ 
    this.finishTerm = function(){
      this.status++;
      if(this.status==this.outputLangs.length){
        Ext.Ajax.request({
	        url: this.prepareRequest("getAvailableThesauri"),
	        scope: this,
	        success: this.returnTerms,
	        failure: this.showError
      	});      
      }  
    };
    
    this.returnTerms = function(r,o){
    	var data = Ext.decode(r.responseText);
    	for(var i=0;i<data.results.length;i++){
    	  if(this.output.uri.indexOf(data.results[i].uri)>-1){
    	    this.output.version = data.results[i].version;
    	    break;
    	  }
    	}
    	this.theMask.hide();
        this.handler.call(config.scope, this.output);   	
    };
    
    this.onItemClick = function(view, rec, item, index, evt){
      if(rec.isLeaf()){
      	if(this.thesauri[this.selectThes.value].firstClick){
      		this.returnTerm(rec);
      	}
      	else {
      		this.getById(rec);
      	}
    	}
    }
    
    /******************** user interface definition *********************/
    this.detailPanel = new Ext.Panel({
      height: 100,
      region: 'south', 
      collapsed: true, 
      collapseMode: 'mini',
      autoScroll: true, 
      cls: 'thes-description', 
      split:true
    });
                  
    this.treePanel = new Ext.tree.TreePanel({
      layout: 'fit',
      useArrows: true,
      autoScroll: true,
      region: 'center', 
      fields: ['text', 'termId'], 
      tbar: ['.', '->', {
    	  xtype: 'button', text:HS.i18n("Use"), 
    	  icon:this.appPath+'img/drop-yes.gif', 
    	  cls:'x-btn-text-icon', 
    	  handler: this.returnTerm, scope:this}], 
      rootVisible: false,
      listeners: {
      	//'click': {this.getById, scope: this, id: data[i].termId}
  		'itemclick': {fn: this.onItemClick, scope: this}
      }
    }); 
     
    this.thesRoot = this.treePanel.store.getRootNode();
    
    var thes = new Array();
    for(th in this.thesauri) thes.push(th);  
    
    this.selectThes = new Ext.form.ComboBox({
      store: thes,
      //editable: false,
      width: 70,
      stateful: true,
      stateId: "thesaurus-selected",
      typeAhead: true,
      selectOnFocus:true,
      triggerAction: 'all',
      cls: 'thes-select',
      value: config.defaultThesaurus || thes[0],
      listeners: {
    		'change': {fn: function(){if(this.autoTop) this.getTopConcepts();}, scope: this}     
    		},
      mode:'local'
    });

    this.thesRoot = {
        draggable: true,
        allowChildren: true,
        leaf : false,
        singleClickExpand : true,
        text : '',
        cls: 'thes-root',
        expanded: true
      };

    this.tbVisible(false);
    
    this.treePanel.setRootNode(this.thesRoot);
        
    /*searchField.onTriggerClick = this.getByTerm;
    searchField.on('specialkey', function(f, e){
      if(e.getKey() == e.ENTER)  searchField.onTriggerClick();
    }, searchField);*/

    config.layout = 'border';
    config.tbar = [
    	this.selectThes, 
    	{handler: function(){this.getTopConcepts();}, 
    	 icon:this.appPath+'img/lightbulb.png', cls:'x-btn-icon',  tooltip: HS.i18n('Top concepts'),
    	 scope:this}, 
    	"-", 
    	HS.i18n("Search")+': ', 
    	this.searchField];
    config.items = [this.detailPanel, this.treePanel];
    
    ThesaurusReader.superclass.constructor.call(this,config); 
    
    this.on({afterrender: function(){if(this.autoTop) this.getTopConcepts();}, scope:this});


  };  
  
  Ext.extend(ThesaurusReader, Ext.Panel, {});
  
  
