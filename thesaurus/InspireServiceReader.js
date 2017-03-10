var InspireServiceReader = function(config){
  this.handler = config.handler;
  this.lang = 'en';
  this.outputLangs= ['en'];
  if(config.lang=='cs') this.lang=config.lang;
  if(config.outputLangs) this.outputLangs=config.outputLangs;
  if(config.serviceUrl) this.serviceUrl = config.serviceUrl;
  else this.serviceUrl = '';
  
  Ext.define("MyLeaf", {
	    extend: 'Ext.data.Model',
        fields: ['id', 'name', 'text']
  });
  
  this.store = Ext.create('Ext.data.TreeStore', {
	  model: 'MyLeaf',
      proxy: {
          type: 'ajax',
          url: this.serviceUrl+'services.php',

          extraParams: {
        	  language: this.lang
              //isXml: true
          },
          reader: {
              type: 'json'
          }
      },
      sorters: [{
          property: 'leaf',
          direction: 'ASC'
      },{
          property: 'text',
          direction: 'ASC'
      }],
      root: {
          text: 'InspireServices',
          id: '0',
          expanded: false
      }
  });
  
  this.tree = new Ext.tree.TreePanel({
      layout: 'fit',
      useArrows: true,
      autoScroll: true,
      region: 'center',  
      rootVisible: true, 
      singleExpand: true,
      store: this.store
      //loader: new Ext.tree.TreeLoader({url:this.serviceUrl+'services.php', baseParams: {language: this.lang}})
  });
  

  this.selNode = function(node, rec, ite, idx){
    if(rec.isLeaf()){
      var output = {terms: {}, version:'ISO - 19119 geographic services taxonomy, 1.0, 2008'};
      for(var i=0;i<this.outputLangs.length;i++){
        output.terms[this.outputLangs[i]] =  rec.data.name;
      }  
      this.handler.call(config.scope, output);
    }
  }
  
  this.tree.on('itemclick', this.selNode, this);
  config.layout = 'border';
  config.items = [this.tree];

  InspireServiceReader.superclass.constructor.call(this,config);

}

Ext.extend(InspireServiceReader, Ext.Panel, {});

  
  /* HSLayers language definition */
  HS.Lang["cze"]["InspireServices"] = "Služby INSPIRE";
  HS.Lang["eng"]["InspireServices"] = "INSPIRE services";

  
