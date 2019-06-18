/******************************
 * MICKA 6.010
 * 2019-04-18
 * javascript
 * Help Service Remote Sensing  
******************************/

MD_COLLAPSE = "fa-caret-down";
MD_EXPAND   = "fa-caret-right";
MD_EXTENT_PRECISION = 1000;
var md_mapApp = getBbox;
var md_pageOffset = 0;
var messages = {};
var confirmLeave = false;
var initialExtent = [12.09, 48.55, 18.86, 51.06]; // TODO - to config
var thesActivated = false;

var micka = {};

String.prototype.trim = function() { return this.replace(/^\s+|\s+$/, ''); };

var eventParser = {
	getEvent: function(e){
		if (!e) e = window.event;
		return e;
	},
		
	getEventTarget: function(e) {
		if (!this.getEvent(e).target) this.getEvent(e).target = this.getEvent(e).srcElement;
		return this.getEvent(e).target;
	},
	
	eraseEvent: function(e) {
		if (e) e.stopPropagation()
    else	window.event.cancelBubble = true;
	},
	
	stopEvent: function(e){
		if(e.preventDefault){
			e.preventDefault();
			e.stopPropagation();
		}
    else e.returnValue = false;
	}
}

function md_getSimilar(obj, str){
  var elementy = obj.childNodes;
  var elSim = new Array();
  var pm = "";
  for(var i=0;i<elementy.length;i++) if(elementy[i].id){
    var pom = elementy[i].id.split("_");
    if(pom[0]==str) elSim.push(elementy[i]);
  } 
  return elSim;
}

function md_pridej(obj, clone){
    var dold = obj.parentNode;
    var dnew=dold.cloneNode(true);
    var dalsi = dold.nextSibling;
    if(dalsi==null) dold.parentNode.appendChild(dnew); 
    else dold.parentNode.insertBefore(dnew,dalsi);
    var pom = dold.id.split("_");
    var elementy = md_getSimilar(dold.parentNode, pom[0]);
    if(!clone) md_removeDuplicates(dnew);
    for(var i=0;i<elementy.length;i++) {
        if(i<10) md_setName(elementy[i], pom[0]+"_0"+i+"_");
        else md_setName(elementy[i], pom[0]+"_"+i+"_");
    }
    if(!clone){
        // --- vycisteni ---
        var nody = flatNodes(dnew, "INPUT");
        for(var i=0;i<nody.length;i++) if(nody[i].type=="text") nody[i].value = "";

        nody = flatNodes(dnew, "SELECT");
        for(var i=0;i<nody.length;i++) nody[i].selectedIndex=0;

        nody = flatNodes(dnew, "TEXTAREA");
        for(var i=0;i<nody.length;i++) nody[i].value="";
    }
    var d = getMyNodes(dnew, "DIV");
    if(d[0]) d[0].style.display='block';

    d = getMyNodes(dnew, "I");
    if(d[0]) $(d[0]).addClass(MD_COLLAPSE).removeClass(MD_EXPAND);

    window.scrollBy(0,dold.clientHeight);
    return dnew;
}


function md_removeDuplicates(obj){
  if(obj.hasChildNodes()){
    var i=0;
    while(i<obj.childNodes.length){
      var smazano = 0;
      if(obj.childNodes[i].nodeName=="DIV"){
        if(obj.childNodes[i].id){
          var pom=obj.childNodes[i].id.split("_");
          var podobne = md_getSimilar(obj, pom[0]);
          if(podobne.length>1){
            smazano=1;
            for(var j=1;j<podobne.length;j++){ 
              obj.removeChild(podobne[j]); 
            }
          } 
        }
        if(smazano==0) md_removeDuplicates(obj.childNodes[i]);
      }
      i++; 
    }
  }
}

function md_setName(obj, id){
  var re = RegExp(obj.id, "g");
  var inputs = flatNodes(obj, "INPUT");
  for(var i=0;i<inputs.length;i++){
	  if (inputs[i].type=="radio"){ 
		  inputs[i].name = 'RB_'+id;
	  }
	  else inputs[i].name = inputs[i].name.replace(re,id);
  }
  var inputs = flatNodes(obj, "SELECT");
  for(var i=0;i<inputs.length;i++){
    inputs[i].name = inputs[i].name.replace(re,id);
  }
  var inputs = flatNodes(obj, "TEXTAREA");
  for(var i=0;i<inputs.length;i++){
    inputs[i].name = inputs[i].name.replace(re,id);
  }
  var inputs = flatNodes(obj, "A");
  for(var i=0;i<inputs.length;i++){
    inputs[i].href = inputs[i].href.replace(re,id);
  }
  obj.id = id;
}

function md_smaz(obj){
  if(!confirm(HS.i18n('Delete') + " ?")) return;
  var toDel = obj.parentNode;
  var cont = toDel.parentNode;
  var pom = toDel.id.split("_");
  var elementy = md_getSimilar(cont, pom[0]);
  if(elementy.length>1) cont.removeChild(toDel);
  var elementy = md_getSimilar(cont, pom[0]);
  for(var i=0;i<elementy.length;i++) {
      if(i<10) md_setName(elementy[i], pom[0]+"_0"+i+"_");
      else md_setName(elementy[i], pom[0]+"_"+i+"_");
  }
}


function md_unload(e){
  	if(document.getElementById("md_inpform") && confirmLeave){  
  		return messages.leave + ' ?';
  	}
}

function elementInViewport(el) {
    var rect = el.getBoundingClientRect()

    return (
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= window.innerHeight &&
        rect.right <= window.innerWidth 
    )
}

function checkMenu(){
  //var a = document.getElementsByTagName('a');
  //for(i=0;i<a.length;i++) a[i].onclick=md_unload;
}

function elm(name){
  if(document.getElementById) return document.getElementById(name);
  else if(document.all) return document.all[name];
  else return document.layers[name];
}


function md_scroll(el){
  if(typeof el == 'string'){
	  var el = document.getElementById(el) || document.getElementById(el.replace('ins', 'V'));
  }
  if(el){
	  var e = el;
	  var h = document.getElementsByTagName('NAV')[0].offsetHeight;

	  while(e=e.parentNode){
		  if(e.tagName=='BODY') break;
		  if(e.style.display=='none'){
			  e.style.display='block';
		  }
	  }
	  el.scrollIntoView(true);
		if(el.getBoundingClientRect().y && el.getBoundingClientRect().y < h){
				window.scrollBy(0, -h-10);
		}
		else if(el.getBoundingClientRect().top < h){
				window.scrollBy(0, -h-10);
		}  
	  el.parentNode.style.background="#FFBBBB"; //TODO do stylu
	  setTimeout(function(){
		  el.parentNode.style.background="";
		  }, 1000);
  }
}

function md_expand(obj){
  var rf = flatNodes(obj.parentNode.parentNode,'INPUT');
  if(!rf.length) rf = [rf];
  for(var i=0;i<rf.length;i++){
   	if((rf[i].type=='radio')&&(obj.name=rf[i].name)){
   	  var d = rf[i].parentNode.childNodes;
   	  for(var j=0;j<d.length;j++){
   	    if(d[j].nodeName=='DIV'){
        	if(rf[i]==obj){ 
        	 	var toClose = d[j]; 
        	}
        	else if(d[j].style.display!='none') {
                var data = '';
                var inputs = flatNodes(d[j],'INPUT');
                for(var k=0; k<inputs.length; k++) if(inputs[k].type=='text') data += inputs[k].value;
                var selects = flatNodes(d[j],'SELECT');
                for(var k=0; k<selects.length; k++) data += selects[k].value;
                var texts = flatNodes(d[j],'TEXTAREA');
                for(var k=0; k<texts.length; k++) data += texts[k].value;
                if(data){
                    var c = window.confirm(HS.i18n('Delete') + " ?");
                    if(!c){ 
                        rf[i].click();
                        return false;
                    }	
                    for(var k=0; k<inputs.length; k++) if(inputs[k].type=="text") inputs[k].value = "";
                    for(var k=0; k<texts.length; k++)  texts[k].value = "";
                    for(var k=0; k<selects.length; k++) selects[k].selectedIndex=0;  	    	
                }  	
                d[j].style.display='none';
        	}
        }
      }	  
    }
  }
  toClose.style.display='block';
  return false;
}

function md_dexpand(obj){
    var o = getMyNodes(obj.parentNode, "DIV")[0];
    if(o){
        if(o.style.display!='none'){
            o.style.display='none';
            $(obj).removeClass(MD_COLLAPSE).addClass(MD_EXPAND);
        }  
        else {
            o.style.display='block'; 
            $(obj).removeClass(MD_EXPAND).addClass(MD_COLLAPSE);
        }
    }
}


function clickMenu(afterpost, target){
  var me = window;
  confirmLeave = false;
  md_pageOffset = 0;
  me.confirmLeave = false;
  var form = me.document.forms['md_inpform'];
  form.target = "";
  if(typeof(target) !== 'undefined'){
  	form.target = target;
  }
  form.afterpost.value=afterpost;
  // kontrola validity HTML5, pokud neni, ulozi se bez kontroly
  if(afterpost === "end" || afterpost === "save"){
  	if(!form.checkValidity || form.checkValidity()){
  		form.submit();
  	}
  	else {
  		for(f=0; f < form.elements.length; f++){
  			if(!form.elements[f].validity.valid){
  				md_scroll(form.elements[f]);
  				break;
  			}
  		}
  		//alert(HS.i18n('Please, fill mandatory elements'));
  	}
  }
  else form.submit();
}

function clickLink(package, target){
	if(package==-1){
		scroll(0,0);
	}
	document.forms['md_inpform'].target='';
 	document.forms['md_inpform'].nextpackage.value=package;
 	if(target){
 		document.forms['md_inpform'].target=target;
 	}	
    document.forms['md_inpform'].afterpost.value='edit';
 	document.forms['md_inpform'].submit();
}

function clickProfil(id_profil, id_package){
	confirmLeave = false;
	document.forms['md_inpform'].target='';
	if (id_profil > -1) {
		document.forms['md_inpform'].nextpackage.value=document.forms['md_inpform'].package.value;
		document.forms['md_inpform'].nextprofil.value = id_profil;
	}
	if (id_package > -1) {
		document.forms['md_inpform'].nextpackage.value = id_package;
		document.forms['md_inpform'].nextprofil.value = document.forms['md_inpform'].profil.value;
	}
    document.forms['md_inpform'].afterpost.value='edit';
	document.forms['md_inpform'].submit();
}

function selProfil(obj){
	confirmLeave = false;
	document.forms['md_inpform'].target='';
	//document.forms['md_inpform'].nextpackage.value=document.forms['md_inpform'].package.value;
	document.forms['md_inpform'].nextprofil.value=obj.value;
    document.forms['md_inpform'].afterpost.value='edit';
	document.forms['md_inpform'].submit();
}

function chVal(e){
  if(this.value=='') return true;
  if(this.className=='N'){
    if(isNaN(this.value)){
      alert('Bad number!');
      return false;
    }
    else return true;
  }
  else if(this.className=='D'){
    if(lang=='cze'){
      var r = /^(((0?[1-9]|[12][0-9]|3[01])\.)?((0?[1-9]|1[0-2])\.)?)((18|19|20|99)\d{2})$/
      var msg = 'Špatný formát data. Musí být RRRR nebo MM.RRRR nebo DD.MM.RRRR';      
    }  
    else //if(lang=='en')
    {
      var r = /^((18|19|20|99)\d{2})(-(0?[1-9]|1[0-2])(-(0?[1-9]|[12][0-9]|3[01]))?)?$/
      var msg = 'Bad date format: YYYY or YYYY-MM or YYYY-MM-DD allowed.';
    }
    if(r.exec(this.value)) return true;
    else{
      alert(msg);
      return false;
    }
  }

}

function chTextArea(e){
   if(this.value.length>2000){
	 alert('Maximum 2000 characters.');
	 this.value = this.value.substr(0, 2000);
	 return false;
   }
}

function start(){
    $.fn.datepicker.defaults.language=HS.getLang(2);
    $.fn.datepicker.defaults.todayHighlight = true;
    $.fn.datepicker.defaults.forceParse = false;
    if(lang=='cze') $.fn.datepicker.defaults.format = "dd.mm.yyyy";
    else $.fn.datepicker.defaults.format = "yyyy-mm-dd";
    
	var inpForm = document.getElementById("md_inpform");
	if(inpForm){
		confirmLeave = true;
		window.onbeforeunload = md_unload;
	}	 
	var inputs = document.getElementsByTagName("input");
	if(inputs.length>0) for(i=0;i<inputs.length;i++){
		//inputs[i].onkeyup=chVal;
		inputs[i].onblur=chVal;
	}
	var ta = document.getElementsByTagName("textarea");
	if(ta.length>0) for(i=0;i<ta.length;i++){
		ta[i].onkeyup=chTextArea;
		ta[i].change=chTextArea;
	}
	// parent metadata name 
	var parent = document.getElementById("50");
	if(parent && parent.value){
		$("#parent-text").html("...");
		$.ajax(baseUrl + "/csw/?format=json&query=" + encodeURIComponent("identifier="+parent.value))
        .done(function(data){
            $("#parent-text").html(data.title);
        });
	}
}

/* editovani */
function getMyNodes(epom, nodename){
  var newList = new Array();
  for(var i=0; i<epom.childNodes.length; i++){
    if(epom.childNodes[i].nodeName==nodename) newList.push(epom.childNodes[i]);
  }
  return newList;
}

function flatNodes(epom, nodename, theClassName){
	var newList = new Array();
	if(epom.hasChildNodes()){
		for(var i=0; i<epom.childNodes.length; i++){
			if(epom.childNodes[i].nodeName==nodename){
				if(theClassName == undefined || epom.childNodes[i].className.indexOf(theClassName)>-1){
					newList.push(epom.childNodes[i]);
				}	
			}	
			else {
				var pom = flatNodes(epom.childNodes[i], nodename, theClassName);
				for(var j=0; j<pom.length; j++) newList.push(pom[j]);
			}
		}
	}
	return newList;
}

function md_dexpand1(obj){
  var divs = flatNodes(obj, "DIV"); 
  var is = getMyNodes(obj, "I");
  if(divs.length>1) divs[1].style.display='block';
  if(is.length>0) {
      $(is[0]).addClass(MD_COLLAPSE).removeClass(MD_EXPAND);
  }
}

function kontakt(obj,type){
    md_elem=obj.parentNode;
    md_partyType=type;
    md_dexpand1(md_elem);
    $("#md-dialog").modal();
    $('#md-content').load(baseUrl+'/suggest/mdcontacts');
}

function kontakt1(id, osoba, org, org_en, fce, fce_en, phone, fax, ulice, mesto, admin, psc, zeme, email, url, adrId){
	var inputs = flatNodes(md_elem, "INPUT"); 
    // TODO temp hack 
    if(inputs[0].id > 10000){
        dc_kontakt1(osoba, org, fce, phone, fax, ulice, mesto, admin, psc, zeme, email, url);
        $("#md-dialog").modal('hide');
        return;
    }
	var selects = flatNodes(md_elem, "SELECT");
	for(i=0;i<inputs.length;i++){
		var v = inputs[i];
		var num = v.id.substr(0,4);
		//angl. organizace navíc
		if(v.id=="3760eng"){
			 v.value = org_en;
		}
		else if(v.id=="3770eng"){
			 v.value = fce_en;
		}
		else if(v.id=="7001"){
	        v.value = id;
	    }
        else if(v.id=='3750uri'){
            v.value = id;
        }
	    else switch(num){
			case '3750': v.value = osoba; break;
			case '3760': v.value = org; break;
			case '3770': v.value = fce; break;
			case '4080': v.value = phone; break;
			case '4090': v.value = fax; break;
			case '3810': v.value = ulice; break;
			case '3820': v.value = mesto; break;
			case '3830': v.value = admin; break;
			case '3840': v.value = psc; break;
			case '3850': v.value = zeme; break;
			case '3860': v.value = email; break;
			case '3970': v.value = url; break;
			case '3801': if(adrId) v.value = adrId; break;
		}
	}
	if(md_partyType!=null){
		for(i=0;i<selects.length;i++) if(selects[i].id=='3791'){
			selects[i].value = md_partyType; 
			break;
		}
	}
	$("#md-dialog").modal('hide');
}

function thes(obj){
    $("#md-keywords").modal(); 
    if(mds==10) $("#inspire-service-wrap").show();
    md_elem = obj.parentNode;
    md_dexpand1(md_elem);
    if(thesActivated) return;
    thesActivated = true;
    var theAjax = null;
    var thes = {};
    
    var gemet = new GemetClient({
        url: baseUrl + '/registry_client/proxy.php?url=http://www.eionet.europa.eu/gemet/',
        lang: HS.getLang(2),
        el: '#gemet',
        showTree: true
    });
   
    thes['inspire'] = $("#inspire").select2({
		ajax: {
			url: baseUrl + '/suggest/mdlists',
			dataType: 'json',
			data: function(params){
				return {
					query: params.term,
					type: 'inspireKeywords',
                    request: 'getValues',
					lang: HS.getLang(3)
				};
            }
	   },
	   theme: 'bootstrap',
	   language: HS.getLang(2),
	   allowClear: true
	});    

    thes['inspire-service'] = $("#inspire-service").select2({
		ajax: {
			url: baseUrl + '/suggest/mdlists',
			dataType: 'json',
			data: function(params){
				return {
					query: params.term,
					type: 'serviceKeyword',
                    request: 'getValues',
					lang: HS.getLang(3)
				};
            },
			cache: false
	   },
	   theme: 'bootstrap',
	   language: HS.getLang(2),
	   allowClear: true
	});    

    thes['cgs'] = $("#cgs").select2({
		ajax: {
			url: baseUrl + '/suggest/mdlists',
			dataType: 'json',
			data: function(params){
				return {
					query: params.term,
					type: 'cgsThemes',
                    request: 'getValues',
					lang: HS.getLang(3)
				};
			},
			cache: false
		}, 
		language: HS.getLang(2),
		allowClear: true,
		theme: 'bootstrap'
	});
  
    $('#thes-gemet-ok').on('click', function(){
        gemet.process(langs.split('|'), function(data){
            console.log(data);
            fromThesaurus({ //TODO take from thesaurus client
                thesName: 'GEMET - Concepts, version 3.1',
                thesDate: (HS.getLang(3)=='cze') ? '20.07.2012' : '2012-07-20',
                thesUri: data.uri.substr(0, data.uri.lastIndexOf("/")),
                uri: data.uri,
                terms: data.labels
            });
            $("#md-keywords").modal('hide');
            return;
        });
    });

    $('#thes-inspire-ok').on('click', function(){ localThes("#inspire", "inspireKeywords"); });
    $('#thes-geology-ok').on('click', function(){ localThes("#cgs", "cgsThemes"); });
    $('#thes-inspire-service-ok').on('click', function(){ localThes("#inspire-service", "serviceKeyword"); });
    
    function localThes(element, type){
        var uri = $(element).select2('data')[0].uri;
        var url =baseUrl + '/suggest/mdlists?type='+type+'&request=getValue&code='+uri;
        $.ajax({url: url})
        .done(function(data){
            if(data.results && data.results[0]){ 
                fromThesaurus({
                    thesName: data.thesaurus.langs,
                    thesDate: data.thesaurus.date,
                    thesUri: data.results[0].uri.substr(0,data.results[0].uri.lastIndexOf("/")),
                    uri: data.results[0].uri,
                    terms: data.results[0].langs
                });
                $("#md-keywords").modal('hide');
                return;
            }
        })
    }
    
}

function fromThesaurus(data){
    if(!md_elem) return false;
    var last = -1;
    var vyplneno=0;
    var mainLang = $("#30").val();
    var thesName = data.thesName;
    if(typeof thesName === 'object') thesName = data.thesName[mainLang];
    
	var currThesNode = null;
	var inputs = flatNodes(md_elem, "INPUT"); 
	var selects = flatNodes(md_elem, "SELECT"); 
  	for(i=0;i<inputs.length;i++){
	    if(inputs[i].id == '3600'+data.thesUri || inputs[i].id=='3600'+mainLang){
	    	if(inputs[i].value==''){
	    	  	var currThesNode = md_elem;
	    		break;
	    	}
	    }
	}
  	if(!currThesNode){
	  	var inp2 = flatNodes(md_elem.parentNode, "INPUT");
	  	for(i=0;i<inp2.length;i++){
	  		if(inp2[i].id=='3600uri'){
	  			if((inp2[i].value)==data.thesUri){
	  				currThesNode = inp2[i].parentNode.parentNode.parentNode;
                    break;
	  			}
	  		}
	  		else if(inp2[i].id=='3600'+mainLang){
	  			if((inp2[i].value)==thesName){
	  				currThesNode = inp2[i].parentNode.parentNode.parentNode;
                    break;
	  			}
	  		}
		}
  	}
	if(!currThesNode){
		if(!confirm(HS.i18n('Add new thesaurus')+'?')) return;
		var currThesNode = md_pridej(flatNodes(md_elem, "A")[1]);
	}
	var inputs = flatNodes(currThesNode, "INPUT"); 
	var selects = flatNodes(currThesNode, "SELECT"); 
	
  //fill the thesaurus
  for(i=0;i<inputs.length;i++){
	  var ll = langs.split("|"); 
	  for(var j in ll){
		  if(inputs[i].id=='3600'+ll[j]) {
              if((typeof thesName === 'object' && thesName[ll[j]])){
                  inputs[i].value = thesName[ll[j]];
              }
              else inputs[i].value = thesName;
          }
		  else if(inputs[i].id=='530'+ll[j]){
			  last = i;
			  if(inputs[i].value!="") vyplneno++;
		  }
	  } 
      if(inputs[i].id=='3940') inputs[i].value = data.thesDate; 
      else if(inputs[i].id=='3600uri'){
          inputs[i].value = data.thesUri;
      }
  } 
  // fill the kewords
  if(vyplneno>0){
    var d = md_pridej(inputs[last]);
    inputs = flatNodes(d, "INPUT");
    if(!elementInViewport(d)){
    	d.scrollIntoView(false);
    }	
  } 
  // if terms are available
  if(data.terms){
	  for(i=0;i<inputs.length;i++){
		  for(var l in data.terms) if(inputs[i].id=='530'+l){
			  inputs[i].value=data.terms[l];
		  }
	  }
  }
  // if URI is available
  if(data.uri) {
	  for(i=0;i<inputs.length;i++){
		  if(inputs[i].id=='530uri'){
			  inputs[i].value=data.uri; 
			  break;
		  } 
	  }
  }
  for(i=0;i<selects.length;i++){
    if(selects[i].id=='3950') selects[i].selectedIndex=2; // publication
  }
}

//verze2
function thes1(thesaurus, term_id, langs, terms, date, tdate){
  if(!md_elem) return false;
  var langs=langs.split(",");
  var terms=terms.split(",");
  var inputs = flatNodes(md_elem, "INPUT"); 
  var selects = flatNodes(md_elem, "SELECT"); 
  var last = -1;
  var vyplneno=0;
  for(i=0;i<inputs.length;i++){
    if(inputs[i].id=='ftext'){ // ve vyhled. formulari
      for(j=0;j<langs.length;j++){
        if(langs[j]==lang){
          inputs[i].value += terms[j]+" ";
          break;
        }
      } 
      return;
    }  
    //zadavani
    else if(inputs[i].id=='3600') inputs[i].value=thesaurus; 
    else if(inputs[i].id=='3940') inputs[i].value=date; 
    else {
      //blank value check
      for(j=0;j<langs.length;j++) if(inputs[i].id=='530'+langs[j]){
        last = i;
        if(inputs[i].value!="") vyplneno++;
      }
    } 
  }
  if(vyplneno>0){
     var d = md_pridej(inputs[last]);
     inputs = flatNodes(d, "INPUT");
     if(!elementInViewport(d)){
     	d.scrollIntoView(false);
     }	
  }  
  for(i=0;i<inputs.length;i++)
    for(j=0;j<langs.length;j++) if(inputs[i].id=='530'+langs[j]){
      inputs[i].value=terms[j];
  }
  for(i=0;i<selects.length;i++){
    if(selects[i].id=='3951') selects[i].selectedIndex=tdate;
  }
}

function fc(obj){
    var html = '<select id="parent-select"></select><div id="fc-features"></div></div>';
    micka.window(obj, HS.i18n('Select record'), html, '<button id="fc-confirm" class="btn btn-primary">OK</button>');
    md_dexpand1(obj.parentNode);
    $("#parent-select").select2({
        ajax: {
            url: baseUrl + '/csw/?format=application/json&elementsetname=full&lang='+lang,
            dataType: 'json',
            delay: 300,
            data: function(params){
                q = "type='featureCatalogue'";
                if(params.term) q += " and Title like '"+ params.term + "*'";
                return {
                    query: q
                };
            },
            processResults: function(data, page){
                return {
                    results: $.map(data.records, function(rec) {
                        return { id: rec.id, text: rec.title, title: rec.abstract, f: rec.features, d: rec.date, titles: rec.titles };
                    })  
                }    
            },
            cache: false
        },
        language: HS.getLang(2),
        allowClear: true,
        theme: 'bootstrap',
        allowHtml: true,
        maxSelectionLength: 1
    });
    $("#parent-select").on('select2:select',function(e){
        var data = e.params.data
        var html = '';
        for(i in data.f){
            html += '<div><input type="checkbox" name="'+ data.f[i].name+'"> ' + data.f[i].name+'</div>';
        }
        $('#fc-features').html(html);
        $('#fc-confirm').on('click', function(){
            var ff = [];
            $('#fc-features input:checked').each(function(i){
                ff.push(this.name);
            })
            fc1({uuid: data.id, titles: data.title, date: data.d, dateType: 'revision'}, ff);
            $("#md-dialog").modal('hide');
        });
    });
  
}

function fc1(fcObj, lyrlist){
    var inputs = flatNodes(md_elem, "INPUT"); 
    var selects = flatNodes(md_elem, "SELECT");
    var fList = new Array();
    //--- fc identification
    for(var i=0; i<inputs.length; i++){
        var v = inputs[i];
        if(v.id.substr(0,4)=='3600'){ 
            v.value = '';
            for(var lang in fcObj.titles){
                if(lang && v.id==('3600'+lang)) v.value = fcObj.titles[lang];
            }
        }   
        else switch(v.id){
          case '2370': fList.push(v); break;
          case '2070': v.value = fcObj.uuid; break;
          case '3940': if(fcObj.date && fcObj.date[0]) v.value = fcObj.date; break;
        }
    }
    for(var i=0;i<selects.length;i++){
        var v = selects[i];
        if(v.id == '3950' && fcObj.date[0]) v.value = fcObj.dateType;	    
    }
    //--- features
    for(var i=1;i<fList.length;i++){ 
        fList[i].parentNode.parentNode.removeChild(fList[i].parentNode);
    }	
    var f = fList[0];
    f.value=lyrlist[0];
    var inputs = getMyNodes(f.parentNode, "INPUT");
    for(var i=1;i<lyrlist.length;i++)if(lyrlist[i]!=""){
        var d = md_pridej(inputs[0]);
        inputs = getMyNodes(d, "INPUT"); 
        inputs[0].value=lyrlist[i]; 
    }

}

/*function closeDialog(obj){
	if(obj) $(obj).parent().remove();
	else $('#md_dialog').remove();
}*/

function cover(obj){
    html = '<label>'+HS.i18n('Percent')+'</label><input id="cover-perc" class="form-control" type="number" required="required" min="0" max="100" value="100"/>'
			+'<label>km2:</label><input type="number" id="cover-km" class="form-control" required="required" value="78866"/>'
			+'<label>'+HS.i18n('Description')+'</label><input id="cover-desc" class="form-control" value="Pokrytí území ČR">'
            +'<label>'+HS.i18n('Description')+' - EN</label><input id="cover-desc-en" class="form-control" value="Coverage of CR territory"/>'
			+'</div><div class="modal-footer"><button type="button" class="btn btn-primary" onClick="cover1();">OK</button></div>';       
    micka.window(obj, HS.i18n('Area coverage'), html);
}

function cover1(){
	var divs = flatNodes(md_elem.parentNode, "DIV");
	var toClone = null;
	for(var i=0;i<divs.length;i++){
		if(divs[i].id=='2078_0_'){
			toClone = divs[i];
			md_dexpand1(divs[i]);
			var divs2 = flatNodes(flatNodes(divs[i], "DIV")[0],"DIV");
			md_dexpand1(divs2[0]);
		}	
		else if (divs[i].id=='2078_1_') toClone = null;
	}
	if(toClone){
		var a = flatNodes(toClone, "A");
		md_pridej(a[0]);
	}
	var inputs = flatNodes(md_elem.parentNode, "INPUT");
	for(var i=0;i<inputs.length;i++){
		if(inputs[i].id=='1000') inputs[i].value='Pokrytí';	
		else if(inputs[i].id=='2070') inputs[i].value='CZ-COVERAGE';
		else if(inputs[i].id=='1020cze') {
			inputs[i].value=$('#cover-desc').val();
		}	
		else if(inputs[i].id=='1020eng') {
			inputs[i].value=$('#cover-desc-en').val();
		}	
		else if(inputs[i].id=='1020uri') {
			inputs[i].value='https://publications.europa.eu/resource/authority/country/CZE';
		}	
		else if(inputs[i].id=='30020' && inputs[i].name.indexOf('2078_0_2101')>0) inputs[i].value='http://geoportal.gov.cz/res/units.xml#percent';	
		else if(inputs[i].id=='1370' && inputs[i].name.indexOf('2078_0_2101')>0) inputs[i].value= $('#cover-perc').val();	
		else if(inputs[i].id=='30020' && inputs[i].name.indexOf('2078_1_2101')>0) inputs[i].value='http://geoportal.gov.cz/res/units.xml#km2';	
		else if(inputs[i].id=='1370' && inputs[i].name.indexOf('2078_1_2101')>0) inputs[i].value= $('#cover-km').val();	
	}
	$("#md-dialog").modal('hide');
	return false;
}

function formatSel2(data){
    var m = {dataset: 'map', service: 'gears', fc: 'sitemap', nonGeographicDataset: 'database', series: 'th', application: 'desktop'}
    return $('<span><span class="res-type '+data.t+'"><i class="fa fa-fw fa-lg fa-'+m[data.t]+'"/></span> '+data.text+'</span>');
}

function find_parent(obj){
    md_elem = obj.parentNode;
    $("#md-dialog").modal();
    var html = '<div class="panel-heading">'
    +'<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>'
    +'<h4>'+HS.i18n('Select record')+'</h4></div>';
    html += '<div class="modal-body"><select id="parent-select"></select></div></div>';       
    $("#md-content").html(html);
    $("#parent-select").select2({
        ajax: {
            url: baseUrl + '/csw/?elementsetname=brief&maxrecords=20&sortby=title&format=application/json&&lang='+lang,
            dataType: 'json',
            delay: 300,
            data: function(params){
                return {
                    query: params.term ? "Title like '"+ params.term + "*'" : ''
                };
            },
            processResults: function(data, page){
                return {
                    results: $.map(data.records, function(rec) {
                        return { id: rec.id, text: rec.title, title: rec.abstract, t: rec.type };
                    })  
                }    
            },
            cache: false
        },
        language: HS.getLang(2),
        allowClear: true,
        theme: 'bootstrap',
        templateResult: formatSel2,
        templateSelection: formatSel2,
        allowHtml: true,
        minimumInputLength: 1,
        maxSelectionLength: 1
    });
    $("#parent-select").on('select2:select',function(e){
        find_parent1({
            uuid: $("#parent-select").val(),
            title: $("#parent-select").text()
        });
        $("#md-dialog").modal('hide');
    });
}

function find_parent1(data){
	var code = md_elem.id.substring(0,4);
	switch(code){
	    // pro zavisle zdroje - pro sluzby (operatesOn)
		case '5120':
		case '1151':			
		    var inputs = flatNodes(md_elem, "INPUT");
		    for(var i=0;i<inputs.length;i++){
		        if(data.idCode){
		        	if(inputs[i].id.substr(0,4)=='3600'){ 
		        		if(data.idNameSpace.substr(0,4)=="http") inputs[i].value=data.idNameSpace+"#"+data.idCode;
		        		else inputs[i].value= data.idNameSpace+":"+data.idCode;
		        	} 
		        }
		      	if(inputs[i].id.substr(0,4)=='3600') inputs[i].value=data.title;
		      	else if(inputs[i].id.substr(0,4)=='3601') inputs[i].value=data.title;
		      	else if(inputs[i].id.substr(0,4)=='6001') inputs[i].value=data.uuid;
		      	else if(inputs[i].id.substr(0,4)=='3002'){
		      		var cid = (code=='1151') ? '#cit-' : '#_';
		      		inputs[i].value= baseUrl + '/csw/?SERVICE=CSW&VERSION=2.0.2&REQUEST=GetRecordById&OUTPUTSCHEMA=http://www.isotc211.org/2005/gmd&ID='+data.uuid+cid+data.uuid;
		      	}	
		    }
		    return false;
		    break;
		// pro zavisle zdroje - pro sluzby (coupledResource) - nebude pouzito
		case '5902':
		    var inputs = flatNodes(md_elem, "INPUT");
		    for(var i=0;i<inputs.length;i++){
		      	if(inputs[i].id.substr(0,4)=='3600') inputs[i].value=data.title;
		      	else if(inputs[i].id.substr(0,4)=='3650') inputs[i].value=data.uuid;
		    }
		    return false;
		    break;
		default:	    
		  // pro ostatni
		  var inputs = flatNodes(md_elem, "INPUT");
		  for(var i=0;i<inputs.length;i++){
		    if(inputs[i].type=='text'){
                if(inputs[i].id.indexOf('uri')>-1){
                    inputs[i].value = baseUrl + '/record/xml/' + data.uuid;
                }
                else inputs[i].value=data.uuid;
		    }  
		  }
	}	  
	// pro importni formulare
	if(md_elem.id=='fill-rec') var txt = document.getElementById("fill-rec-txt");
	else if(md_elem.id=='fill-fc') var txt = document.getElementById("fill-fc-txt");
	// pro data
	else var txt = document.getElementById("parent-text");
	txt.innerHTML=data.title;
}

function find_fc(obj){
  md_elem = obj.parentNode;
  dialogWindow = openDialog("find", baseUrl+"/suggest/mdsearch?fc=1", ",width=500,height=500,scrollbars=yes"); 
  dialogWindow.focus();
}

function find_fc1(uuid, name){
  inputs = flatNodes(md_elem, "INPUT");
  for(var i=0;i<inputs.length;i++){
    if(inputs[i].type=='text') inputs[i].value=uuid;
    break;
  }  
  var txt = document.getElementById("parent_text");
  txt.innerHTML=name;
}

function Xfind_record(obj){
  md_elem = obj.parentNode;
  dialogWindow = openDialog("find", baseUrl+"/suggest/mdsearch", ",width=500,height=500,scrollbars=yes"); 
  dialogWindow.focus();
}

function roundBbox(bbox){
  for(var i=0;i<bbox.length;i++){
    pom = bbox[i].split(" ");
    bbox[i] = Math.round(pom[0]*MD_EXTENT_PRECISION)/MD_EXTENT_PRECISION+" "+Math.round(pom[1]*MD_EXTENT_PRECISION)/MD_EXTENT_PRECISION;
  }
  return bbox;
}

function getBbox(bbox, isPoly){
  if(md_elem==null)return false;
  var poly = flatNodes(md_elem, "TEXTAREA");
  if(poly)  poly=poly[0];
  var inputs = flatNodes(md_elem, 'INPUT');
  for(var i=0;i<inputs.length;i++){
    switch(inputs[i].id){
      case '3440': var x1 = inputs[i]; break;
      case '3450': var x2 = inputs[i]; break;
      case '3460': var y1 = inputs[i]; break;
      case '3470': var y2 = inputs[i]; break;
    }
  }
  var bbox1=roundBbox(bbox.split(","));
  if(isPoly){ // polygon
  	if(!poly){
      alert('polygon not defined in profile');
      return;
    } 
    var s = "";
    for(var i=0;i<bbox1.length;i++) s += ',' + bbox1[i];     
    poly.value = "MULTIPOLYGON((("+s.substr(1)+","+bbox1[0]+")))";
    inputs = flatNodes(poly.parentNode.parentNode.parentNode, "INPUT");
    for(var i=0;i<inputs.length; i++){
      if(inputs[i].type=="radio"){
        inputs[i].click();
        break;
      }  
    }
    //vymazani BBOX
    x1.value = '';
    x2.value = '';
    y1.value = '';
    y2.value = '';
  }
  else { // jen BBOX
    var pom = bbox.replace(/,/g, ' ').split(' ');
    for(var i=0;i<pom.length;i++) pom[i] = Math.round(pom[i]*MD_EXTENT_PRECISION)/MD_EXTENT_PRECISION;
    x1.value=pom[0];
    y1.value=pom[1];
    x2.value=pom[2];
    y2.value=pom[3];
    var e = getMyNodes(md_elem, "DIV");
    var r = flatNodes(e[0], "INPUT");
    r[0].click();
    //vymazani polygonu
    if(poly){
       poly.value = '';
    }    
  }
}

//traditional map interface
function mapa(obj){
	md_elem=obj.parentNode;
    var draw; // global so we can remove it later
    var features;
    var polygon = null;
    md_elem = obj.parentNode;
    $("#md-dialog").modal();
    $("#md-content").html(
        '<div class="panel-heading">'
        + '<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>'
        + '<h4>'+ HS.i18n('Set extent') +'</h4>'
        + '</div>' 
        + '<div class="modal-body"><div id="overmap" style="width:100%; height:300px;"></div>'
		+ '<div><a onclick="micka.fillExt(-180,-90,180,90)">'  + HS.i18n('World') + '</a> &nbsp;'
        +'<a onclick="micka.fillExt('+initialExtent+')">'  + HS.i18n('Initial') + '</a></div></div>');
    $("#md-dialog").on('hide.bs.modal', function (e) {
        $("#md-dialog").off('shown.bs.modal');
        $("#md-dialog").off('hide.bs.modal');
    });       
    $("#md-dialog").on('shown.bs.modal', function (e) {
        var input = flatNodes(md_elem,'INPUT', 'N');
        var ext = []; 
        // zpracovani polygonu
        var poly = flatNodes(md_elem,'TEXTAREA');
        if(poly.length>0 && poly[0].value != ""){
            var wkt = new ol.format.WKT();
            polygon = wkt.readFeature(poly[0].value, {dataProjection: 'EPSG:4326', featureProjection: 'EPSG:3857'});
        } 
        // zpracovani obdelniku
        else if(input[0].value){
            var y1 = parseFloat(input[2].value);
            var y2 = parseFloat(input[3].value);
            ext.push(parseFloat(input[0].value));
            ext.push(Math.max(-99,y1));
            ext.push(parseFloat(input[1].value));
            ext.push(Math.min(99,y2));
        }
        else {
            // asi docasu
            ext = initialExtent;
            input[0].value = ext[0];
            input[2].value = ext[1];
            input[1].value = ext[2];
            input[3].value = ext[3];
        }
        micka.overMap = new OverMap({
            edit: true,
            drawBBOX: true, 
            extent: ext,
            polygon: polygon,
            handler: function(g){
                if(!g) return;
                input[0].value = g[0].toFixed(3);
                input[2].value = g[1].toFixed(3);
                input[1].value = g[2].toFixed(3);
                input[3].value = g[3].toFixed(3);
                $("#md-dialog").modal('hide');
            }
        });
        micka.overMap.drawMetadata();
    });
}


function uploadFile(obj){
    md_elem = obj.parentNode.parentNode;
    $("#md-dialog").modal();
    $("#md-content").html('<div class="modal-body">not implemented yet...</div>');
}

function uploadFile1(fileURL){
  inputs = flatNodes(md_elem, "INPUT"); 
  for(var i=0;i<inputs.length;i++){
    if(inputs[i].id=='490'){ 
      inputs[i].value = fileURL; 
      break;
    }
  }
  window.focus();
}

function swapi(o){
    var pom=o.src.lastIndexOf(".");
    if(o.src.charAt(pom-1)=="_")o.src=o.src.substr(0,pom-1)+"."+o.src.substr(pom+1,10);
    else o.src=o.src.substr(0,pom)+"_."+o.src.substr(pom+1,10);
}

function formats(obj){
    md_elem = obj.parentNode;
    md_addMode = false;
    $("#md-dialog").modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=format&lang='+lang);
}

function formats1(data){
	var inputs = flatNodes(md_elem, "TEXTAREA");
	if(inputs.length>0){
	    for(var i in inputs){
	      	if(typeof(data)=="object"){
	      		var lang = inputs[i].name.substr(2,3);
	      		var f = data[lang].value;
	      		if(!f) continue;
	      	}
	      	else f = data;
	      	if(md_addMode)inputs[i].value += f; 
	      	else inputs[i].value = f;
	    }   
	}
	else{
	  	var inputs = flatNodes(md_elem, "INPUT");
        var lang;
	    for(var i=0;i<inputs.length;i++){
            lang = inputs[i].name.split('|')[1];
	      	if(inputs[i].type=='text' && inputs[i].className=='T'){
	        	if(typeof(data)=="object"){
                    if(data.value){
                        f = data.value;
                    }
                    else{
                        var f = false;
                        if(data[lang]){
                            f = data[lang];
                        }    
                        if(!f) continue;
                    }
	      		}
	      		else f = data;
                inputs[i].value = f;
	      	}
	    }
        // fill the publication date if present
        if(data.publication){
            var inputs = flatNodes(md_elem.parentNode, "INPUT");
            for(var i=0;i<inputs.length;i++){
                if(inputs[i].className=='D'){
                    inputs[i].value = data.publication;
                    break;
                }
            }
        }
	}
    $('#md-dialog').modal('hide');
}

function protocols(obj){
    md_elem = obj.parentNode;
    md_addMode = false;
    $('#md-dialog').modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=protocol&lang='+lang);
}

function specif(obj){
    md_elem = obj.parentNode;
    md_addMode = false;
    $('#md-dialog').modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=specifications&handler=specif1&multi=1&lang='+lang);
}

function specif1(f){
	var inputs = flatNodes(md_elem.parentNode.parentNode, "INPUT");
	for(var i=0;i<inputs.length;i++){
		v = inputs[i];
		for(var l in f){
			if(v.id=='3600'+l){
				v.value = f[l].name;
			}	
			if(v.id=='1310'+l){
				v.value = f[l].expl;
			}	
			else if(v.id=='3940') v.value = f[l].publication;
		}	
	}	
	var sels = flatNodes(md_elem.parentNode, "SELECT");
	for(var i=0;i<sels.length;i++){
		if(sels[i].id=='3950'){
			sels[i].value='publication';
		}
	}
	// pro kote
    if( document.forms[0].mdlang) var mainLang = document.forms[0].mdlang.value;
	var ta = flatNodes(md_elem.parentNode.parentNode, "TEXTAREA");
	for(var i in ta){
		if(ta[i].name.slice(-3)=='TXT') ta[i].value = f[mainLang].name;
		else ta[i].value =  f[ta[i].name.slice(-3)].name;
	}
	//checkFields();
}

function hlname(obj){
    md_elem = obj.parentNode;
    md_addMode = false;
    $('#md-dialog').modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=hlname&handler=hlname1&lang='+lang);
}

function hlname1(f){
	var inputs = flatNodes(md_elem, "INPUT");
	inputs[0].value = f.uri;
    inputs[1].value = f.uri;
    $('#md-dialog').modal('hide');
}

function fspec(obj){
	md_elem = obj.parentNode;
    $('#md-dialog').modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=inspireKeywords&handler=fspec1&multi=&lang='+lang);    
}

function fspec1(f){
	var inputs = flatNodes(md_elem, "INPUT");
    for(var i=0;i<inputs.length;i++){
        if(inputs[i].id.indexOf('uri')>-1){
            inputs[i].value = 'https://inspire.ec.europa.eu/id/document/tg/' + f.uri.substr(-2);
        }
        else inputs[i].value = 'INSPIRE Data Specification on ' + f.eng + ' - Guidelines';
    }
    $('#md-dialog').modal('hide');
}

function crs(obj){
	md_elem = obj.parentNode;
    var mdlang = $('#30').val();
    $('#md-dialog').modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=coordSys&handler=crs1&lang='+lang+'&mdlang='+mdlang);
}

function dName(obj){
    md_elem = obj.parentNode;
    md_addMode = false;
    $('#md-dialog').modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=linkageName&lang='+lang);
}

function crs1(f){
    var inputs = flatNodes(md_elem, "INPUT");
    for(var i=0;i<inputs.length;i++){
        v = inputs[i];
        switch(v.id){
          case '2070uri': v.value = f.uri; break; 
          case '2070':    v.value = f.xxx; break; 
        }     
    }
    $('#md-dialog').modal('hide');
}

function dc_kontakt(obj, type){
    md_elem=obj.parentNode;
    md_partyType=type;
    $("#md-dialog").modal();
    $('#md-content').load(baseUrl+'/suggest/mdcontacts/?mds=DC');
}

function dc_kontakt1(osoba, org, fce, phone, fax, ulice, mesto, admin, psc, zeme, email, url){
  var inputs = flatNodes(md_elem, "INPUT");
  var s = osoba;
  if(s!="") s+= ", ";
  s += org;
  s += ", "+mesto;
  if(zeme.trim()!="") s+= ", "+zeme.trim();
  inputs[0].value = s;   
}

function dc_coverage(obj){
  md_elem = obj.parentNode;
  md_mapApp = dc_coverage1;
  openDialog('micka_mapa','mickaMap.php', 'width=360,height=270');
}

function dc_coverage1(s, b){
  var inputs = flatNodes(md_elem, 'INPUT');
  bbox = roundBbox(s.split(','));
  pom1 = bbox[0].split(' ');
  pom2 = bbox[1].split(' ');
  inputs[2].value = "westlimit:"+ pom1[0]+"; southlimit:"+pom1[1]+"; eastlimit:"+pom2[0]+"; northlimit:"+pom2[1];
}

function dc_subject(obj){
  md_elem = obj.parentNode;
  dialogWindow = openDialog("kontakty", "md_thes.php?standard=DC", ",width=300,height=500,scrollbars=yes"); 
}

function dc_subject1(thesaurus, term_id, langs, terms, date, tdate){
  if(!md_elem) return false;
  langs=langs.split(",");
  terms=terms.split(",");
  var inputs = flatNodes(md_elem, "INPUT"); 
  for(var i=0;i<inputs.length;i++){
    for(var j=0;j<langs.length;j++){
      if(inputs[i].id==('10003'+langs[j])){
        inputs[i].value=terms[j];
        break;
      }    
    } 
  }   
}

function dc_format(obj){
  md_elem = obj.parentNode;
  md_addMode = false;
  dialogWindow = openDialog("kontakty", baseUrl+"/suggest/mdlists/?standard=DC&type=formats&lang="+lang, ",width=400,height=500,scrollbars=yes"); 
}

function md_gazet(obj){
  md_elem = obj.parentNode.parentNode;
  dialogWindow = openDialog("kontakty", baseUrl+"/suggest/mdgazcli", ",width=300,height=500,scrollbars=yes"); 
}

function md_gazet1(bbox, first){
  if(md_elem==null)return false;
  var poly = flatNodes(md_elem, "TEXTAREA");
  poly=poly[0];
  var inputs = flatNodes(md_elem, 'INPUT');
  for(var i=0;i<inputs.length;i++){
    switch(inputs[i].id){
      case '3440': var x1 = inputs[i]; break;
      case '3450': var x2 = inputs[i]; break;
      case '3460': var y1 = inputs[i]; break;
      case '3470': var y2 = inputs[i]; break;
    }
  }
  var bbox1=roundBbox(bbox.split(","));
  var s = "";
  if(first){ 
	  poly.value="";
	  inputs = flatNodes(poly.parentNode.parentNode.parentNode, "INPUT");
	  for(var i=0;i<inputs.length; i++){
	    if(inputs[i].type=="radio"){
	      inputs[i].click();
	      break;
	    }  
	  }
	  //vymazani BBOX
	  if(x1){
		  x1.value = '';
		  x2.value = '';
		  y1.value = '';
		  y2.value = '';
	  }
  }
  poly.value = poly.value.concat(bbox);

}

function importSelect(obj){
  var pom = document.getElementById('input_hide');
  if(obj.value.substr(0,4)=='ESRI') pom.style.display='';
  else pom.style.display='none';
  document.forms.newRecord.fc.value='';
  //document.getElementById('parent_text').innerHTML='';
}

function clearForm(){
  var fields = document.getElementsByTagName("INPUT");
  for(var i=0; i<fields.length;i++) if(fields[i].type=='text')fields[i].value='';
  var selects = document.getElementsByTagName("SELECT");
  for(i=0; i<selects.length;i++) selects[i].selectedIndex=0; 
  var texareas = document.getElementsByTagName("TEXTAREA");
  for(i=0; i<texareas.length;i++) texareas[i].value=''; 
  if(document.getElementById('results'))document.getElementById('results').innerHTML='';
  return false;
}

//vyplneni labelu v seznamu kontaktu
function fillLabel(o){
  if(o.value!="") return;
  var label=(document.forms[0].person.value);
  var za = "";
  if (label!=""){
    var carka = label.lastIndexOf(",");
    if(carka>-1){za=label.substr(carka,99); label=label.substr(0,carka); }
    if(label.indexOf(" ")>-1){
      var jmena = label.split(" ");
      if(jmena.length>1){
        label = "";
        for(var i=jmena.length-1;i>=0;i--) label += jmena[i]+" ";
      }   
    }  
  }
  else label = document.forms[0].organisation.value;
  o.value=label+za;
}
 
function md_aform(obj,por,asnew){
  if(typeof(por) == 'undefined'){
    var pom = obj.parentNode.id.split('_');
    por = pom[1]; 
  }
  asnew = typeof(asnew) == 'undefined' ? 0 : asnew;
  var obsah = flatNodes(obj.parentNode, "DIV");
  if(obsah.length>0) var je = true;
  var el = document.getElementById('currentFeature');
  if(el){
    if(!window.confirm(messages.leave + ' ?')) return;
    var o = flatNodes(el.parentNode, "I");
    $(obj).addClass(MD_COLLAPSE).removeClass(MD_EXPAND); 
    el.parentNode.removeChild(el);
  } 
  if(je) return; 
  $(obj).addClass(MD_COLLAPSE).removeClass(MD_EXPAND);  
  var container = document.createElement("div");
  container.id = 'currentFeature';
  obj.parentNode.appendChild(container);
  var url = "?ak=inmda&recno="+md_recno+"&por="+por+"&asnew="+asnew;
  var ajax = new HTTPRequest;
  ajax.get(url, "", md_drawFeature, false); 
}

function md_drawFeature(r){
  if(r.readyState == 4){
	  var el = document.getElementById('currentFeature');
	  if(el){
		  el.innerHTML = r.responseText+"<iframe name='featureFrame' style='display:none'></iframe>";
      //window.scrollTo(0, el.parentNode.offsetTop);
      //fc_initForm();
	  }
  }  
  else {
	  if(el) el.innerHTML = "<img src='themes/default/img/indicator.gif'>";
  }
}
  
function refreshFeature(por, label){
  var el = document.getElementById('currentFeature');
  if(!el){
    alert('Error: element not found!');
    return false;
  }  
  var spans = flatNodes(el.parentNode, "SPAN");
  spans[0].innerHTML = label;
  var obrs = flatNodes(el.parentNode, "IMG");
  obrs[0].src = obrs[0].src.substring(0, obrs[0].src.lastIndexOf("/")+1) + MD_EXPAND; 
  el.parentNode.id="12_"+por;
  el.parentNode.removeChild(el);
}


function fc_getId(obj){
  if(!obj) return -1; 
  var pom = obj.parentNode.id.split('_');
  return pom[1];
}

function fc_new(obj){
  var por = fc_getId(obj);
  //por = typeof(obj) == 'undefined' ? -1 : por;
  var newDiv = document.createElement("div");
  newDiv.id = "12_-1";
  newDiv.innerHTML="<img id=\"PA__0_\" onclick=\"md_aform(this);\" src=\"themes/default/img/expand.gif\"/><span class='f'>???</span><a href=\"javascript:void(0);\" onclick=\"fc_new(this);\"><img src='img/copy.gif'></a> <input class=\"b\" type=\"button\" onclick=\"fc_smaz(this);\" value=\"-\"/>";
  var obj = document.getElementById("addF");
  obj.parentNode.insertBefore(newDiv,obj);
  md_aform(newDiv.firstChild,por,1);
}

function fc_smaz(obj){
  if(!confirm(HS.i18n('Delete') + ' ?')) return false;
  var por = obj.parentNode.id.split('_');
  var url = "?ak=mddela&recno="+md_recno+"&por="+por[1];
  var ajax = new HTTPRequest;
  ajax.get(url, "", fc_smaz1, false); 
  obj.parentNode.parentNode.removeChild(obj.parentNode); //pak presunout do fc_smaz1
}

function fc_smaz1(r){
  if(r.readyState == 4) {}
}

function fc_storno(){
  var el = document.getElementById('currentFeature');
  if(el){
    var obrs = flatNodes(el.parentNode, "IMG");
    obrs[0].src = obrs[0].src.substring(0, obrs[0].src.lastIndexOf("/")+1) + "MD_EXPAND"; 
    var pom = el.parentNode.id.split('_');
    if(pom[1]==-1)el.parentNode.parentNode.removeChild(el.parentNode);
    else el.parentNode.removeChild(el);
  }
}

function showMap(url){
  // TODO - do konfigurace
  var myURL = "http://geoportal.gov.cz/web/guest/map?wms="+url;
  //var myURL = "http://onegeology-europe.brgm.fr/geoportal/viewer.jsp?id=" + url; 
  //window.open(myURL, "wmswin", "width=550,height=700,dependent=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=yes,resizable=yes,copyhist=no");
  var w = window.open(myURL, "portal", "");
  w.focus();
}

function md_datePicker(id){
  monthArrayLong = new Array('1 / ', '2 / ', '3 / ', '4 / ', '5 / ', '6 / ', '7 /', '8 / ', '9 / ', '10 / ', '11 / ', '12 / ');
  datePickerClose = " X ";
  if(lang=='cze'){
    dayArrayShort = new Array('Ne', 'Po', 'Út', 'St', 'Čt', 'Pá', 'So');
    datePickerToday = "Dnes";
  	displayDatePicker(id,false,'dmy','.');
  }	 
  else{
    displayDatePicker(id,false,'ymd','-');
  }  
}

// for old INSPIRE standard
var md_constraint = function(obj){
    md_elem = obj.parentNode;
    md_addMode = false;
    $("#md-dialog").modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=accessCond&multi=1&lang='+lang);
 }

var oconstraint = function(obj){
    md_elem = obj.parentNode;
    md_addMode = false;
    $("#md-dialog").modal();
    if($(md_elem.parentNode).find('#700')[0].value=='otherRestrictions'){
        var type='limitationsAccess';
    }
    else {
        var type='accessCond';
    }
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type='+type+'&multi=1&lang='+lang);        
}

var md_serviceType = function(obj){
    md_elem = obj.parentNode;
    md_addMode = false;
    $("#md-dialog").modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=serviceType&lang='+lang);
}

var md_lineage = function(obj){
    md_elem = obj.parentNode;
    md_addMode = false;
    $("#md-dialog").modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=lineage&multi=1&lang='+lang);
}

var md_processStep = function(obj){
    md_elem = obj.parentNode;
    md_addMode = true;
    $("#md-dialog").modal();
    $('#md-content').load(baseUrl+'/suggest/mdlists/?type=steps&multi=1&lang='+lang);
}

micka.fillValues = function(listType, code, handler){
	$.get(baseUrl+"/suggest/mdlists/?request=getValues&type="+listType+"&id="+code)
	.done(function(data){
        if(handler) handler(data);
		else formats1(data);
        $("#md-dialog").modal('hide');
	})
}

/*var changeSort = function(id, ordid, constraint, lang, recs){
	var o = document.getElementById(id);
	if(!o) return;
	var ord = document.getElementById(ordid);
	if(!ord) return;
	window.location="index.php?service=CSW&request=GetRecords&format=text/html&query="+ constraint + "&LANGUAGE=" + lang + "&MAXRECORDS=" + recs +"&sortby=" +o.value+":"+ord.value;
}

var showLogin = function(){
	var f = document.getElementById("loginForm");
	if(f){
		if(f.style.display=="inline-block"){
			f.style.display="none";
		}
		else{
			f.style.display="inline-block";
		} 	
	}

}*/

var checkId = function(o){
	var nody = flatNodes(o.parentNode.parentNode, "INPUT");
	if(nody[0].value || nody[1].value){
        var q = encodeURIComponent("ResourceIdentifier="+nody[1].value);
		$.ajax({
            url: baseUrl + "/csw/?request=GetRecords&format=text/json&query="+q
        })
        .done(function(r){
            var uuid = document.forms[1].uuid.value;
            eval("var data="+r.responseText);
            var dup = 0;
            if(r.matched == 0 || (r.matched == 1 && r.records[0].id == uuid)){
                //o.className="id-ok";
                o.style.color = 'green';
            }
            else {
                //o.className="id-fail";
                o.style.color = 'red';
                alert("ID duplicity");
            }
        });
	}
}


var md_callBack = function(cb, uuid){
	if(cb.substring(0,6)=='opener'){
		var fn = cb.substring(7);
		ajax = new HTTPRequest;
		ajax.get("?ak=dummy&cb=", null, function(r){
			if(r.readyState == 4){
				if(!opener) {
					alert('Opener window is closed');
					return;
				}
				opener[fn](uuid);			
				window.close();
			}	
		}, false);
	}
}


var md_upload = function(obj, mime){
    var f=false;
	micka.window(obj,'Nahrát soubor', 
        '<div class="input-group">'
            +'<input id="file-info" type="text" class="form-control" readonly>'
            +'<label class="input-group-btn"><span class="btn btn-primary">Vyber<input name="f" type="file" style="display: none;"/></span></label>'
        +'</div>'
        +'<label> </label><div id="file-progress" class="progress" style="display:none"><div class="progress-bar bg-success" role="progressbar" style="width: 0%">0%</div></div>',
        '<button id="upload-confirm" class="btn btn-primary" disabled>OK</button>'
	);
    $(':file').on('change', function(e){
        f = $(this).get(0).files[0];
        var size = (f.size < 10000000) ? Math.round(f.size/1000) + ' kB' : Math.round(f.size/1000000) + ' MiB';
        $('#file-info').val(f.name + ' (' + size + ')');
        $('#upload-confirm').prop('disabled', false);
    });
    $('#upload-confirm').on('click', function(e){
        var form = new FormData();
        form.append("file", f, f.name);
        $('#file-progress').css({display:'block'});
        $.ajax({ 
            url: '?ak=md_upload', 
            data: form, 
            processData: false, 
            contentType: false, 
            type:"POST", 
            xhr: function(){
                var xhr = new window.XMLHttpRequest();
                var percent;
                var $p = $('#file-progress div');
                xhr.upload.addEventListener('progress', function(e){
                    if(e.lengthComputable){
                        percent = Math.round(e.loaded/e.total*100);
                        if(percent < 100){
                            $p.css('width', percent+'%').text(percent + '%');
                        }
                        else $p.css('width', percent+'%').text(HS.i18n('Processing')+'...');
                    }
                });
                return xhr;
            }
        })
        .done(function(result){
            var inp = flatNodes(md_elem.parentNode, 'INPUT');
            if(result) {
                inp[0].value = 'to be done...';//result;
                inp[1].value = 'http://services.cuzk.cz/registry/codelist/OnlineResourceProtocolValue/WWW:DOWNLOAD-1.0-http--download';
                inp[2].value = 'WWW:DOWNLOAD-1.0-http--download';
                $("#md-dialog").modal('hide');
            }
            else alert('Upload error');
        })
        return false;
    });
}

// pro lite verzi
micka.initMap=function(config){
    micka.overMap = new OverMap({
        edit: true,
        drawBBOX: true, 
        handler: function(g){
            if(g){
                $("#xmin").val(g[0].toFixed(3));
                $("#ymin").val(g[1].toFixed(3));
                $("#xmax").val(g[2].toFixed(3));
                $("#ymax").val(g[3].toFixed(3));
            }
            else {
                $("#xmin").val('');
                $("#ymin").val('');
                $("#xmax").val('');
                $("#ymax").val('');
            }
            return false;
        }
    });
	micka.overMap.drawMetadata(config.extent);
    // prevet map controls from submit
    $('.ol-control button').click(function(e){
        e.preventDefault();
    });

}

/*micka.hover = function(o){
	if(!micka.flyr) return;
	var div;
	micka.selFeatures.forEach(function(e,i,a){
		div = document.getElementById(a[i].getId());
		if(div){
			div.style.background=""; // TODO - nejak jinak
		}					
	}, micka);
	micka.selFeatures.clear();
	micka.select.un('select', micka.hoverMap);
	var f = micka.flyr.getSource().getFeatureById(o.id);
	if(f){
		micka.selFeatures.push(f);
	}
}

micka.unhover = function(o){
	if(!micka.selFeatures) return;
	micka.selFeatures.clear();
	micka.select.on('select', micka.hoverMap);
}

micka.hoverMap = function(e) {
	var hdr = document.getElementById('headBox');
	var div;
	if(!micka.hoverColor){
		var css = document.styleSheets.item(1).cssRules; // TODO nejak dynamicky
		for(var i in css){
			if(css.item(i).selectorText=='div.rec:hover') {
				micka.hoverColor = css.item(i).style.backgroundColor;
				break;
			}
		}
	}
	for(i in e.deselected){
		div = document.getElementById(e.deselected[i].getId());
		if(div){
			div.style.background=""; // TODO - nejak jinak
		}			
	}
	for(i in e.selected){
		div = document.getElementById(e.selected[i].getId());
		div.style.backgroundColor = micka.hoverColor;
		if(i==0){
			div.scrollIntoView(true);
			window.scrollBy(0,-hdr.offsetHeight-3);
		}	
	}
}

micka.unhoverMap = function(e) {
	var div = document.getElementById(e.element.getId());
	if(div){
		div.style.background=""; // TODO - nejak jinak
	}	
}*/

micka.fromGaz = function(b){
	var g = b.split(" ");
    document.forms[0].xmin.value = Math.round(g[0]*1000)/1000;
    document.forms[0].ymin.value = Math.round(g[1]*1000)/1000;
    document.forms[0].xmax.value = Math.round(g[2]*1000)/1000;
    document.forms[0].ymax.value = Math.round(g[3]*1000)/1000;
    checkBBox();
}

micka.window = function(obj, title, content, footer){
	md_elem = obj.parentNode;
    var html = '<div class="panel-heading">'
    +'<button type="button" class="close" data-dismiss="modal" aria-label="Close">'
    +'<span aria-hidden="true">&times;</span></button>'
    +'<h4>'+title+'</h4></div><div class="modal-body">'
    + content + '</div>';
    if(footer){
        html += '<div  class="modal-footer">'+footer+'</div>';
    }
    
    $("#md-dialog").modal();
    $("#md-content").html(html);
}

micka.duplicate = function(){
    var dold = this.parentNode;
    var dnew = dold.cloneNode(true);
    var dalsi = dold.nextSibling;
    if(dalsi==null) dold.parentNode.appendChild(dnew); 
    else dold.parentNode.insertBefore(dnew,dalsi);
    var pom = dold.id.split("_");
    var elementy = md_getSimilar(dold.parentNode, pom[0]);
    md_removeDuplicates(dnew);

    for(var i=0;i<elementy.length;i++) md_setName(elementy[i], pom[0]+"_"+i+"_");

    // --- vycisteni ---
    var nody = flatNodes(dnew, "INPUT");
    for(var i=0;i<nody.length;i++) if(nody[i].type=="text") nody[i].value = "";

    nody = flatNodes(dnew, "SELECT");
    for(var i=0;i<nody.length;i++) nody[i].selectedIndex=0;
    $(nody).removeClass("select2-hidden-accessible");
    $(nody).parent().children('span').remove();
    $(nody).select2();

    nody = flatNodes(dnew, "TEXTAREA");
    for(var i=0;i<nody.length;i++) nody[i].value="";

    var d = getMyNodes(dnew, "DIV");
    if(d[0]) d[0].style.display='block';

    window.scrollBy(0,dold.clientHeight);
    return dnew;
}

micka.fillExt = function(x1,y1,x2,y2){
    var input = flatNodes(md_elem,'INPUT', 'N');
    input[0].value = x1.toFixed(3);
    input[2].value = y1.toFixed(3);
    input[1].value = x2.toFixed(3);
    input[3].value = y2.toFixed(3);
    $("#md-dialog").modal('hide');
    return false;
}
