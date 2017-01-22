/**************************************
 * hs_dmap Help Service Remote Sensing
 * verze 1.2.0  
 * 19.9.2006
 *************************************/  

var limit = 5;
buttons = new Array();
lastBut = "";
currBut=-1;
var boxdim=2;
var HS_RESIZE=false;
var HS_RIGHT=200;
var HS_BOTTOM=100;
var HS_TIPSOFF=false;
var HS_DIGITS=6;
var HS_LENGTH=1.0;
var HS_AREA=0.0001;
var HS_ULENGTH="m";
var HS_UAREA="ha";
ttt=0;
hs_autoRedraw=0;
hs_msie=isMSIE();
var hs_im = "";

function elm(name){
  if(document.all) { return document.all[name];}
  else if(document.getElementById) return document.getElementById(name);
  else return document.layers[name];
}

function isMSIE(){
  agt=navigator.userAgent.toLowerCase();
  return((agt.indexOf('msie')!=-1) && (agt.indexOf('opera')==-1)&& (agt.indexOf("win")!=-1));
}

function Button(params){
  this.name=params[0];
  this.topo=params[3];
  this.prepocet=params[4];
  this.clickAction=params[5];
  if(params.length>6) this.mapAction=params[6];
  if(params.length>7) this.dblAction=params[7];
  if(params.length>8) this.rbAction=params[8];
}

function helpShow(s){
  bid = "helpbg";
  if(hs_msie) bid= "w"+bid;
  overlib("<div id='"+bid+"'>"+s+"</div>", HAUTO);
}

function olShow(s,obj){
  this.onmouseout=nd;
  var pom=obj.coords.split(" ");
  var sirka = document.mapserv.mapsize.value.split(" ");
  if((parseInt(sirka[0]) - parseInt(pom[0]))>220){x=-25; bid="bublina";}
  else{x=-188; bid='bublinal';}   
  if(hs_msie) bid= "w"+bid;
  overlib("<div id='"+bid+"'>"+s+"</div>", OFFSETX, x, OFFSETY, 5, ABOVE, BGCOLOR, '', FGCOLOR, '');
}

function addButton(name,picture,alt,topo,prepocet,cAction,mAction){
  last = buttons.length;
  buttons[last] = new Button(arguments);
  pom=alt.split("|");
  document.write("<a href=\"javascript:butt("+last+");\" class='abut' id='b_"+last+"'>");
  document.write("<img src='"+picture+"' onmouseover=\"helpShow('"+alt+"');\" onmouseout=\"nd();\"></a>");
}

function getButtonByName(n){
  for(i=0;i<buttons.length;i++) if(buttons[i].name==n) return i;
  return -1;
}

function butt(par){
  if(!par) par=0;
  if(canvas) canvas.clear();
  if (par!=currBut)lastBut=currBut;
  with (document){
    if(buttons[par].clickAction!=null) if(!buttons[par].clickAction()) return;
    if(currBut>-1) elm("b_"+currBut).className="abut";
    currBut = par;
    mapserv.butt.value=par;
    mapserv.target = "";
    elm("b_"+currBut).className="abutsel"; 
  }
  mapbox.boxdim=buttons[par].topo;
}    

function bEdit(){
  if (editLyr==""){alert(s_etheme); return false;}
  return true;
}

function bQuery(){
  elm("mapa_img").style.cursor="help";
  elm("mapa_box").style.cursor="help";
  document.mapserv.zoomdir.value=0;
  document.mapserv.mode.value="nquery"; 
  return true;
}

function bZoomIn(){
  elm("mapa_img").style.cursor="crosshair";
  elm("mapa_box").style.cursor="crosshair";
  document.mapserv.zoomdir.value=1;
  document.mapserv.mode.value="browse";
  return true;
}

function bZoomOut(){
  elm("mapa_img").style.cursor="crosshair";
  elm("mapa_box").style.cursor="crosshair";
  document.mapserv.zoomdir.value=-1;
  document.mapserv.mode.value="browse";
  return true;
}

function bMeasure(){
  elm("mapa_img").style.cursor="crosshair";
  elm("mapa_box").style.cursor="crosshair";
  var sour = document.mapserv.imgext.value.split(" ");
  var size = document.mapserv.mapsize.value.split(" ");
  mapbox.pxm = (sour[2]-sour[0])/size[0];
  mapbox.delka = 0;
  mapbox.aDelka = 0;
  mapbox.t=0;
  return true;
}

function bPan(){
  elm("mapa_img").style.cursor="move";
  elm("mapa_box").style.cursor="hand";
  document.mapserv.zoomdir.value=0;
  document.mapserv.mode.value="browse";
  return true;
}

function mSelPoly(){
  var o=mapbox;
  var s =o.getCoords();  
  if(s!=""){
    var pom = s.split(" ");
    document.mapserv.mapshape.value=s+" "+pom[0];
    document.mapserv.mode.value="nquery";
    document.mapserv.submit();
  }
}

function mQuery(){
  if(mapbox.x1==mapbox.x2)document.mapserv.imgxy.value=mapbox.x1+" "+mapbox.y1;
  else{
    mapbox.orderCoords();
    document.mapserv.imgbox.value=mapbox.x1+" "+mapbox.y1+" "+mapbox.x2+" "+mapbox.y2;
  }
  waitserv();
  document.mapserv.submit();
}

function bPin(){
  document.mapserv.img.style.cursor="crosshair";
  return true;
}

function mPin(){
  with(document.mapserv){
    pins.value = document.mapserv.pin.value;
    pin.value=x2world(mapbox.x1)+" "+y2world(mapbox.y1);
  }
  refreshmap();
  return true;
}

function mPan(){
  var x = x2world(mapbox.x1);
  var y = y2world(mapbox.y1);
  if(mapbox.x1==mapbox.x2){
    var factor = Math.pow(document.mapserv.zoomsize.value,document.mapserv.zoomdir.value);
    zoomToPoint(x,y, factor);
  }  
  else{
    var pom=document.mapserv.imgext.value.split(" ");
    var dx=x-(x2world(mapbox.x2));
    var dy=y-(y2world(mapbox.y2));
    document.mapserv.imgext.value=(parseFloat(pom[0])+dx)+" "+(parseFloat(pom[1])+dy)+" "+(parseFloat(pom[2])+dx)+" "+(parseFloat(pom[3])+dy);
    adjustExtent();
    if(HS_STATIC) swapImage(); 
    else refreshmap();
  }
}

function zoomToPoint(mapx, mapy, factor){
  var rozsah = document.mapserv.imgext.value.split(" ");
  var dx = (rozsah[2]-rozsah[0])/factor/2;
  var dy = (rozsah[3]-rozsah[1])/factor/2;
  rozsah[0] = mapx - dx;
  rozsah[1] = mapy - dy;
  rozsah[2] = mapx + dx;
  rozsah[3] = mapy + dy;
  document.mapserv.imgext.value = rozsah[0]+' '+rozsah[1]+' '+rozsah[2]+' '+rozsah[3];
  if(HS_STATIC) swapImage();     
  else refreshmap();
}

function mZoom(){
  if(mapbox.x1==mapbox.x2) mPan();
  else{
    mapbox.orderCoords();
    var rozsah = document.mapserv.mapsize.value.split(" ");
    if (document.mapserv.zoomdir.value == "-1"){
      var mer = Math.max(Math.abs((mapbox.x2-mapbox.x1)/rozsah[0]), Math.abs((mapbox.y2-mapbox.y1)/rozsah[1]));
      zoomToPoint(x2world((mapbox.x2+mapbox.x1)/2), y2world((mapbox.y2+mapbox.y1)/2), mer);
    } 
    else{
      document.mapserv.imgext.value=x2world(mapbox.x1)+" "+y2world(mapbox.y2)+" "+x2world(mapbox.x2)+" "+y2world(mapbox.y1);
      adjustExtent();
      if(HS_STATIC) swapImage();     
      else refreshmap();
    }  
  }  
}

function mZoomIn(){
  document.mapserv.zoomdir.value = 1;
  mZoom();
  document.mapserv.zoomdir.value = 0;
}

function mZoomOut(){
  document.mapserv.zoomdir.value = -1;
  mZoom();
  document.mapserv.zoomdir.value = 0;
}

function mSelect(){
  refreshmap();
}

function adjustRect(mapsize, mapext, buffer){ 
  if(buffer) var bFactor = buffer/100+1.0; else bFactor=1; 
  var x = (parseFloat(mapext[2]) + parseFloat(mapext[0]))/2;
  var y = (parseFloat(mapext[3]) + parseFloat(mapext[1]))/2;
  if((Math.abs(y)<90)&&(epsg==4326)) var xyRatio = Math.cos(y/180*Math.PI); else xyRatio = 1; // pouze pro WGS84
  var cellsize = Math.max(Math.abs((mapext[2]-mapext[0])/(mapsize[0]-1))*xyRatio, Math.abs((mapext[3]-mapext[1])/(mapsize[1]-1)))/2*bFactor;
  var rozsah = new Array(4);
  rozsah[0] = x - mapsize[0]*cellsize/xyRatio;
  rozsah[1] = y - mapsize[1]*cellsize;
  rozsah[2] = parseFloat(x) + mapsize[0]*cellsize/xyRatio;
  rozsah[3] = parseFloat(y) + mapsize[1]*cellsize;
  return [rozsah[0],rozsah[1],rozsah[2],rozsah[3]];
}

function adjustExtent(){
  var rozsah = adjustRect(document.mapserv.mapsize.value.split(" "), document.mapserv.imgext.value.split(" "));
  document.mapserv.imgext.value = rozsah[0]+' '+rozsah[1]+' '+rozsah[2]+' '+rozsah[3];
}
/*function adjustExtent(){ 
  var rozsah = document.mapserv.imgext.value.split(" ");
  var mapsize = document.mapserv.mapsize.value.split(" ");
  var x = (parseFloat(rozsah[2]) + parseFloat(rozsah[0]))/2;
  var y = (parseFloat(rozsah[3]) + parseFloat(rozsah[1]))/2;
  if((Math.abs(y)<90)&&(epsg==4326)) var xyRatio = Math.cos(y/180*Math.PI); else xyRatio = 1; // pouze pro WGS84
  cellsize = Math.max(Math.abs((rozsah[2]-rozsah[0])/(mapsize[0]-1))*xyRatio, Math.abs((rozsah[3]-rozsah[1])/(mapsize[1]-1)))/2;
  rozsah[0] = x - mapsize[0]*cellsize/xyRatio;
  rozsah[1] = y - mapsize[1]*cellsize;
  rozsah[2] = parseFloat(x) + mapsize[0]*cellsize/xyRatio;
  rozsah[3] = parseFloat(y) + mapsize[1]*cellsize;
  document.mapserv.imgext.value = rozsah[0]+' '+rozsah[1]+' '+rozsah[2]+' '+rozsah[3];
}*/

function x2world(x){
  var sour = document.mapserv.imgext.value.split(" ");
  var size = document.mapserv.mapsize.value.split(" ");
  return (x*(sour[2]-sour[0])/size[0]+parseFloat(sour[0]));
}

function y2world(y){
  var sour = document.mapserv.imgext.value.split(" ");
  var size = document.mapserv.mapsize.value.split(" ");
  return (parseFloat(sour[3])-y/size[1]*(sour[3]-sour[1]));
}

function waitserv(){
  pom=elm("wait");
  if(pom!=null) pom.style.visibility='visible';
}

function hsStart(Q, velobr){
  if(HS_RESIZE == true){
    eventHandler.addEvent(window,'resize',changeSize,false);
    var pom=velobr.split(" ");
    setSize();
    /*if(window.innerWidth) mapWidth = window.innerWidth-HS_RIGHT; 
    else mapWidth = document.body.clientWidth-HS_RIGHT;  */  
    if(Math.abs(pom[0]-mapWidth)>20) refreshmap(); 
  } 
  eventHandler.addEvent(elm("mapa"),'mousedown',mapbox.mdown,false);
  canvas = new jsGraphics("mapa0");
  canvas.setColor("red");
  canvas.setStroke(2);
  //eventHandler.addEvent(elm("mapa"),'dblclick',mapbox.dclick,false);
  //document.addEventListener('dblclick',mapbox.dclick,false);
  if(elm("refmap")) eventHandler.addEvent(elm("refmap"),'mousedown',mapbox.mdown,false);
  if(HS_TIPSOFF){
	  imgmap = document.getElementsByTagName('AREA');
    for (i=0; i<imgmap.length; i++) eventHandler.addEvent(imgmap[i],'mousedown',mapbox.mdown,false);  
  }  
}

function hsOnLoad(){
  if(elm("wait")!=null) elm("wait").style.visibility='hidden';
}

function openfindwin(thefile){
  document.mapserv.target = "";
  fwin = window.open(thefile, "hledac", "width=300,height=400,toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,copyhistory=no");
}

/*function clearpin(){
  with(document.mapserv){
    if(pin) pin.value = "";
    if(pins) pins.value = "";
  }
  refreshmap();
}
*/
function refclick(){
  document.mapserv.target = "";
  waitserv();
}

function vyrez(V){
  document.mapserv.target = "";
  window.focus();
  document.mapserv.imgext.value=V;
  adjustExtent();
  document.mapserv.mode.value = "browse";
  document.mapserv.scale.value="";
  if(HS_STATIC) swapImage()     
  else{
    waitserv();
    document.mapserv.submit();
  }
}

function refreshmap(){
  if(HS_RESIZE) setSize();
  document.mapserv.target = "";
  document.mapserv.mode.value = "browse";
  waitserv();
  document.mapserv.layers.value=lyrs();
  document.mapserv.scale.value="";
  document.mapserv.submit();
}

function changeSize(){
  clearTimeout(ttt);
  ttt = setTimeout("refreshmap()",400);
}

function pagebar(lyr,page){
  var pag=page.split("|");
  if(pag[1]==1) return;
  if(pag[0]=='') pag[0]='1';
  var s=s_page+" ";
  var url=this.location+"";
  if(url.indexOf("page_"+lyr)<0)url+="&page_"+lyr+"="+pag[0];
  for(var i=1;i<=pag[1];i++){
    if(i==pag[0]) s += "<b>"+i+"</b> ";
    else s+="<a href='"+url.replace("page_"+lyr+"="+pag[0],"page_"+lyr+"="+i)+"'>"+i+"</a> "; 
  }
  document.write(s);
}

function setSize(){
  if(window.innerWidth){
    mapWidth = window.innerWidth-HS_RIGHT; 
    mapHeight = window.innerHeight-HS_BOTTOM; 
  }
  else if (document.documentElement && document.documentElement.clientHeight){
    mapWidth = document.documentElement.clientWidth-HS_RIGHT;
    mapHeight = document.documentElement.clientHeight-HS_BOTTOM;
  }   
  else {
    mapWidth = document.body.clientWidth-HS_RIGHT; 
    mapHeight = document.body.clientHeight-HS_BOTTOM; 
  }  
  if(mapWidth<300)mapWidth=300;
  if(mapHeight<100)mapHeight=100;
  document.mapserv.mapsize.value=mapWidth+" "+mapHeight;
}

function move(fx, fy){
  ext = document.mapserv.imgext.value.split(" ");
  x1 = parseFloat(ext[0]);
  y1 = parseFloat(ext[1]);
  x2 = parseFloat(ext[2]);
  y2 = parseFloat(ext[3]);
  dx = (x2-x1)*fx*0.8;
  dy = (y2-y1)*fy*0.8;
  s = (x1+dx)+" "+(y1+dy)+" "+(x2+dx)+" "+(y2+dy);
  vyrez(s);
}

function mLength(){
  if(mapbox.delka>0) elm("myStatus").innerHTML=s_length+": "+(mapbox.delka).toPrecision(HS_DIGITS)+" "+HS_ULENGTH;
}

function mArea(){
  if(mapbox.vx.length>1) elm("myStatus").innerHTML=s_area+": "+(mapbox.plocha()*o.pxm*o.pxm*HS_AREA).toPrecision(HS_DIGITS)+" "+HS_UAREA;
}

/*function objekty(e){
  //alert(eventParser.getEventTarget(e).name);
  return true;
}*/

function swapImage(){
  //document.getElementById('wait').style.display='block';
  waitserv();
  if(canvas) canvas.clear();
  var mapsize = document.mapserv.mapsize.value.split(" ");
  var wmsURL = wms+"&SRS=EPSG:"+epsg+"&BBOX="+document.mapserv.imgext.value.replace(/ /g, ",")+"&width="+mapsize[0]+"&height="+mapsize[1]; 
  var obr =  document.getElementById("mapa_img");
  hs_im = new Image();
  hs_im.src = wmsURL;
  waitFor();
}

function waitFor(){
  if(!hs_im.complete){
    imgWait=setTimeout('waitFor()', 150);
  }
  else{
    var obr =  document.getElementById("mapa_img");
    obr.src = hs_im.src;
    hsOnLoad();
    obr.style.left = 0;
    obr.style.top = 0; 
  }
}

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
		if((e)&&(e.stopPropagation)) e.stopPropagation();
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

var eventHandler = {
	addEvent : function(elm,evtType,evtFn,set) {
		if (document.addEventListener) {
			if ((elm == window) && window.opera){
				elm = document;
			} 
			elm.addEventListener(evtType,evtFn,set);
		} else {
			elm.attachEvent('on' + evtType,evtFn);
		}
	},
	removeEvent : function(elm,evtType,evtFn,set) {
		if (document.addEventListener) {
			if ((elm == window) && window.opera){
				elm = document;
			} 
			elm.removeEventListener(evtType,evtFn,set);
		} else {
			elm.detachEvent('on' + evtType,evtFn);
		}
	}
}

//---objekt mapBox---
var mapbox = {
  dole: false,
  limit: 3,
  pocx: 0,
  pocy: 0,
  boxdim: 2,
  xmax: 0,
  ymax: 0,
  x1: 0,
  x2: 0,
  y1: 0,
  y2: 0,
  delka: 0,
  aDelka: 0,
  pxm: 0,
  vx: Array(),
  vy: Array(),
  target: null,
  box: null,
  img: null,
  g: null,
  mbutton: null,
  t:0,

  getStyle: function(obj,styleProp){
	  if (window.getComputedStyle) s = window.getComputedStyle(obj,'').getPropertyValue(styleProp);
	  else if (obj.currentStyle) s = eval('obj.currentStyle.' + styleProp);
	  return s;
  },

  getPos: function(obj){
    var x=0; var y=0;
    if (obj.offsetParent){
    	while (obj.offsetParent){
    	  if(obj.currentStyle){
          bwidth = obj.currentStyle.borderWidth;
    	    bwidth=parseInt(bwidth.replace("px", ""));
    	  }  
    	  else bwidth=0;
        if(!bwidth)bwidth=0;
    		x += obj.offsetLeft+bwidth;
    		y += obj.offsetTop+bwidth;
    		obj = obj.offsetParent;
    	}
    }
    else if (obj.offsetLeft){
      x += obj.offsetLeft;
      y += obj.offsetTop;
    }
    else if (obj.x || obj.y){
    	x += obj.x;
    	y += obj.y;
    }	
    return [x,y];
  },
  
  init: function(obj){
    var o=mapbox;   
    if(obj.id=="ref_box") obj=elm("ref_img");
    else if((obj.id=='')||(obj==o)) obj=elm("mapa_img"); 
    if(obj.id=="ref_img") o.boxdim=2;
    pom = o.getPos(obj);
    o.img=obj;
    o.pocx = pom[0];
    o.pocy = pom[1];
    o.xmax = parseInt(o.img.width);
    o.ymax = parseInt(o.img.height);
    if(o.xmax==0) o.xmax=parseInt(o.img.style.width);
    if(o.ymax==0) o.ymax=parseInt(o.img.style.height);
    pom = o.img.id.split("_");
    o.box = elm(pom[0]+"_box"); 
  },
  
  mdown: function(e){
    o=mapbox;
    if(!e) e=window.event;
    if(e.button) o.mbutton = e.button;
    else if(e.which) o.mbutton = e.which;
    o.init(eventParser.getEventTarget(e));
    if (e.pageX || e.pageY)	{
		  o.x2 = e.pageX - o.pocx;
		  o.y2 = e.pageY - o.pocy;
	  }
    else{
  	  o.x2 = e.clientX + document.body.scrollLeft-o.pocx;
	    o.y2 = e.clientY + document.body.scrollTop -o.pocy; 
    }
    o.dole = true;
    o.x1 = o.x2;
    o.y1 = o.y2;
    if(HS_TIPSOFF==true) elm('mapa_img').useMap=''; //odstraneni usemap
    if(o.vx.length==0){
      eventHandler.addEvent(document,'mouseup',mapbox.mup,false);
      eventHandler.addEvent(document,'mousemove',mapbox.mmove,false);
      if(o.boxdim>2){
        canvas.clear();
        canvas1 = new jsGraphics("mapa1");
        canvas1.setColor("red");
      }
    }  
    nd();
    eventParser.stopEvent(e);
    return false;
  },

  mmove: function(e){
    o=mapbox; 
    if(!e) e=window.event;
    if (e.pageX || e.pageY)	{
		  o.x2 = e.pageX - o.pocx;
		  o.y2 = e.pageY - o.pocy;
	  }
    else{
  	  o.x2 = e.clientX + document.body.scrollLeft-o.pocx;
  	  o.y2 = e.clientY + document.body.scrollTop-o.pocy; 
    }
    if (o.dole == true){
      elm('mapa_img').useMap='';
      if (o.x2 < 0) o.x2 = 0;
      else if (o.x2 > o.xmax) o.x2 = o.xmax;
      if (o.y2 < 0) o.y2 = 0;
      else if (o.y2 > o.ymax) o.y2 = o.ymax;
      if(o.boxdim==1){
        o.x1=o.x2;
        o.y1=o.y2;
        o.box.style.visibility='hidden';
      }
      else if(o.boxdim==-1){
        o.img.style.left=(o.x2-o.x1)+"px";
        o.img.style.top=(o.y2-o.y1)+"px";
      }
      else if(o.boxdim==2) o.draw();    
    }
    if((o.boxdim>2)&&(o.vx.length>0)){
      canvas1.clear();
      var x = o.vx[o.vx.length-1];
      var y = o.vy[o.vy.length-1];
      canvas1.drawLine(o.x2, o.y2, x, y); 
      if(o.boxdim==5) canvas1.drawLine(o.x2, o.y2, o.vx[0], o.vy[0]); 
      canvas1.paint();     
      o.aDelka = Math.sqrt((o.x2-x)*(o.x2-x)+(o.y2-y)*(o.y2-y))*o.pxm*HS_LENGTH;
      if(o.boxdim==3) if(elm("myStatus")) elm("myStatus").innerHTML=o.aDelka.toPrecision(HS_DIGITS)+" / "+(o.delka+o.aDelka).toPrecision(HS_DIGITS);
      else elm("myStatus").innerHTML=(o.plocha()*o.pxm*o.pxm*HS_AREA).toPrecision(HS_DIGITS);
    }
    eventParser.stopEvent(e);
  },
 
  mup: function(e){
    var o=mapbox;
    o.dole = false;
    if(o.img.name=='ref') { hsFromRefmap(); return;}   
    if(o.boxdim<3){ 
      eventHandler.removeEvent(document,'mouseup',mapbox.mup,false);
      eventHandler.removeEvent(document,'mousemove',mapbox.mmove,false);
      if ((Math.abs(o.x2-o.x1)<o.limit) && (Math.abs(o.y2-o.y1)<o.limit)){o.x1=o.x2; o.y1=o.y2}
      if(buttons[currBut].mapAction!=null) buttons[currBut].mapAction();
      eventParser.stopEvent(e);
    }  
    else{ 
      d = new Date();      
      if((d.getTime() - o.t)<300){
        eventHandler.removeEvent(document,'mouseup',mapbox.mup,false);
        eventHandler.removeEvent(document,'mousemove',mapbox.mmove,false);
        if(buttons[currBut].mapAction!=null) buttons[currBut].mapAction();
        o.vx = Array();
        o.vy = Array();
        eventParser.stopEvent(e);
        bMeasure();
        return;
      }
      else{
        if(o.vx.length>0) canvas.drawLine(o.x2, o.y2, o.vx[o.vx.length-1], o.vy[o.vy.length-1]);
        o.delka += o.aDelka;
        o.vx.push(o.x2);
        o.vy.push(o.y2);
      }
      o.t =  d.getTime();     
      canvas.paint();
    }
  },
/*  
  dclick: function(e){
    var o=mapbox;
    alert('dbl');
    eventHandler.removeEvent(document,'mouseup',mapbox.mup,false);
    eventHandler.removeEvent(document,'mousemove',mapbox.mmove,false);
    //eventHandler.removeEvent(document,'dblclick',mapbox.dclick,true);
    //if(buttons[currBut].dblAction) buttons[currBut].dblAction();
    o.x1=o.x2; o.y1=o.y2;
    mZoomIn();
    canvas.clear();
    o.vx = Array();
    o.vy = Array();
    eventParser.stopEvent(e);
    elm("myStatus").innerHTML += e.type+"("+e.srcElement.id+") ";      
    //bMeasure(); //reset prostøedí
  },
*/
  draw: function(){
    var o=mapbox;
    tl=0;  //doresit
    if(o.x2 >= o.x1) o.box.style.left = o.x1-1+"px";  
    else o.box.style.left = o.x2+"px";  
    if(o.y2 >= o.y1) o.box.style.top = o.y1-1+"px";
    else  o.box.style.top = o.y2+"px";  
    o.box.style.width = Math.abs(o.x2 - o.x1) - (tl*2)+"px";  
    o.box.style.height = Math.abs(o.y2 - o.y1) - (tl*2)+"px";  
    o.box.style.visibility='visible';
  },
  
  orderCoords: function(){
    if (o.x1 > o.x2){pom=o.x1; o.x1=o.x2; o.x2=pom;}
    if (o.y1 > o.y2){pom=o.y1; o.y1=o.y2; o.y2=pom;}   
  },
  
  plocha: function(){
    var area = 0;
    var o=mapbox;
    if (o.vx.length > 1){
      var j = o.vx.length-1;
      for (var i=0;i<j;i++){    
        area += (o.vx[i]-o.vx[i+1])*(o.vy[i]+o.vy[i+1]);
      }  
      area += (o.vx[j]-o.x2)*(o.y2+o.vy[j]);
      area += (o.x2-o.vx[0])*(o.y2+o.vy[0]);
    }
    return(Math.abs(area)/2);
  },
  
  getCoords: function() {
    var s="";
    for(var i=0; i<(mapbox.vx.length); i++){
      s += ","+x2world(o.vx[i])+" "+y2world(o.vy[i]);
    }
    return s.substr(1);
  }

  
} //---konec mapbox

function printMap(template){
  s='Mapa';
  url=location.href+'&map_web_template='+template+'&nazev='+s+'&mapsize=800+600&pagerecs=3000';
  //if(document.mapserv)url += '&mapext='+document.mapserv.imgext.value;
  w = window.open(url,'tisk');
  w.focus();
}

function zoomToScale(scale){
  document.mapserv.scale.value=scale;
  refreshmap();
}

function drawScales(currScale){
  idx=0;
  while(currScale>scales[idx])idx++;
  if((idx>0)&&((currScale-scales[idx-1])<(scales[idx]-currScale)))idx--;
  if(idx<(scales.length-1))document.write("<a href=\"javascript:zoomToScale("+scales[idx+1]+");\" class='abut1'><img src='themes/default/img/zoomout1.gif' onmouseover=\"helpShow('<b>Zmenšit</b>');\" onmouseout=\"nd();\"></a>");
  else document.write("<img src='themes/default/img/zoomout1.gif'>")
  for(i=scales.length-1;i>=0;i--){
    if(i==idx)img="1"; else img="0";
    document.write("<a href=\"javascript:zoomToScale("+scales[i]+");\"><img src='themes/default/img/scale"+img+".gif' border=0 title='1:"+scales[i]+"'></a>");
  }
  if(idx>0)document.write("<a href=\"javascript:zoomToScale("+scales[idx-1]+");\" class='abut1'><img src='themes/default/img/zoomin1.gif' onmouseover=\"helpShow('<b>Zvìtšit</b>');\" onmouseout=\"nd();\"></a>")
  else document.write("<img src='themes/default/img/zoomin1.gif'>")
}

function writescale(scale){
  if(!document.mapserv.scale) return;
  //pom = fParse(document.mapserv.imgext, " ");
  //theScale = Math.round((pom[2] - pom[0])/mapWidth/SCRF);
  gray(scale);
  theScale=Math.round(scale);
  theScale=theScale.toString();
  pos = 3;
  while(pos<theScale.length){
    theScale=theScale.substr(0,theScale.length-pos)+" "+theScale.substr(theScale.length-pos);
    pos +=4;
  }
  document.mapserv.scale.value = theScale;
}

function find(){
  document.mapserv.imgext.value="shape";
  refreshmap();
}

function gray(theScale){
  var lb = document.getElementsByTagName('span'); 
  if(lb){
    for(var i=0;i<lb.length;i++) if(lb[i].getAttribute('name')=="lab"){
      pom = lb[i].id.split(",");
      if(((pom[0]!="")&&(theScale<parseInt(pom[0])))||((pom[1]!="")&&(theScale>parseInt(pom[1])))) lb[i].className="LyrLabelG";
      else lb[i].className="LyrLabel";
    }
  }
  lb = document.getElementsByTagName('a'); 
  if(lb){
    for(var i=0;i<lb.length;i++) if(lb[i].getAttribute('name')=="lab"){
      pom = lb[i].id.split(",");
      if(((pom[0]!="")&&(theScale<parseInt(pom[0])))||((pom[1]!="")&&(theScale>parseInt(pom[1])))) lb[i].className="LyrLabelURLG";
      else lb[i].className="LyrLabelURL";
    }
  }
}

function rozbal(jmeno, o, c){
  obj = elm(jmeno);
  obj1 = elm(jmeno+'i');
  if(obj.style.display=="none"){
    obj.style.display="block";
    obj1.src = c;
  }
  else{
    obj.style.display="none";
    obj1.src = o;
  }
}

function myCheck(t){
  if((t!="")&&(t.checked)){
    lyr = document.mapserv.layer;
    for(i=0;i<lyr.length;i++){
      if(t.className==lyr[i].className)
        lyr[i].checked=false;
    }
    t.checked =true;
  }
  if(hs_autoRedraw > 0){
    clearTimeout(ttt);
    ttt = setTimeout("refreshmap()",hs_autoRedraw)   
  } 
}

function lyrs(){
  v = '';
  if(document.mapserv.layer){
    if((document.mapserv.layer.name=='layer')&&(document.mapserv.layer.checked))v = document.mapserv.layer.value;
    else for(i=0;i<document.mapserv.layer.length;i++)
      if(document.mapserv.layer[i].checked) v += document.mapserv.layer[i].value+" "; 
    return v+'x';
  }
  else return document.mapserv.layers;
}

function mapFrame(img, width, height){
  if(document.all) solich=2; else solich=0;
  var s = "<div id='mapframe' style='width:"+(width+24+solich)+"px; height:"+(height+24+solich)+"px;'>";

  s += "<div id='mapborder' style='width:"+(width+solich)+"px; height:"+(height+solich)+"px;'>";
  s +="<span class='sip' style='left:-10px;top:-10px; vertical-align:top;'><a href=\"javascript:move(-1,1);\"><img src='themes/default/img/lu.gif'></a></span>";
  s +="<span class='sip' style='left:50%;top:-12px;margin-left:-5px;'><a href=\"javascript:move(0,1)\"><img src='themes/default/img/up.gif'></a></span>";
  s +="<span class='sip' style='right:-10px;top:-10px;'><a href=\"javascript:move(1,1)\"><img src='themes/default/img/ru.gif'></a></span>";
  s +="<span class='sip' style='left:-10px;top:50%;margin-top:-5px;'><a href=\"javascript:move(-1,0)\"><img src='themes/default/img/left.gif'></a></span>";
  s +="<span class='sip' style='right:-10px;top:50%;margin-top:-4px;'><a href=\"javascript:move(1,0)\"><img src='themes/default/img/right.gif'></a></span>";
  s +="<span class='sip' style='left:-10px;bottom:-10px;'><a href=\"javascript:move(-1,-1)\"><img src='themes/default/img/ld.gif'></a></span>";
  s +="<span class='sip' style='left:50%;bottom:-12px;;margin-left:-5px;'><a href=\"javascript:move(0,-1)\"><img src='themes/default/img/down.gif'></a></span>";
  s +="<span class='sip' style='right:-10px;bottom:-10px;'><a href=\"javascript:move(1,-1)\"><img src='themes/default/img/rd.gif'></a></span>";

  s += "<div id='mapa' style='clip: rect(0px,"+width+"px,"+height+"px,0px); width:"+width+"px; height:"+height+"px;'>";
  s +="<img name='img' id='mapa_img' style='position:absolute; width:"+width+"px height:"+height+"px' src='"+img+"' usemap='#clickmap' ismap>";
  s += "<div id='mapa0' style='width:"+width+"px; height:"+height+"px;'>";
  s += "<div id='mapa1' style='width:"+width+"px; height:"+height+"px;'></div>";
  s += "<div id='mapa_box'></div></div>"; 
  s += "<span id='wait'><img src='themes/default/img/waitcz.gif'></span>";
  s +="</div></div>";
  document.write(s);
}

function hsMaximize(){
  document.mapserv.ver.value='max';
  HS_RESIZE=true;
  refreshmap();
}

function hsMinimize(){
  document.mapserv.ver.value='min';
  document.mapserv.mapsize.value="";
  HS_RESIZE=false;
  refreshmap();
}

function hsFromRefmap(){
  o=mapbox;
  o.orderCoords();
  pom=hs_initext.split(" ");
  minx=parseInt(pom[0]);
  miny=parseInt(pom[1]);
  maxx=parseInt(pom[2]);
  maxy=parseInt(pom[3]);
  width=maxx-minx;
  height=maxy-miny;
  if(o.x1==o.x2){
    pom=document.mapserv.imgext.value.split(" ");
    posx=(o.x1/o.xmax)*width+minx;
    posy=maxy-(o.y2/o.ymax)*height;
    width=(pom[2]-pom[0])/2;
    height=(pom[3]-pom[1])/2;
    document.mapserv.imgext.value=(posx-width)+" "+(posy-width)+" "+(posx+width)+" "+(posy+height);
  }  
  else document.mapserv.imgext.value=((o.x1/o.xmax)*width+minx)+" "+(maxy-(o.y2/o.ymax)*height)+" "+((o.x2/o.xmax)*width+minx)+" "+(maxy-(o.y1/o.ymax)*height);
  document.mapserv.imgbox.value='';
  document.mapserv.imgxy.value='';
  refreshmap();
}

function hsRefmap(){
  mapbox.init(elm("ref_img"));
  pom=hs_initext.split(" ");
  minx=parseInt(pom[0]);
  miny=parseInt(pom[1]);
  maxx=parseInt(pom[2]);
  maxy=parseInt(pom[3]);
  width=maxx-minx;
  height=maxy-miny;
  
  pom=document.mapserv.imgext.value.split(" ");
  minx1=parseInt(pom[0]);
  miny1=parseInt(pom[1]);
  maxx1=parseInt(pom[2]);
  maxy1=parseInt(pom[3]);
  mapbox.x1=(minx1-minx)/width*mapbox.xmax;
  mapbox.x2=(maxx1-minx)/width*mapbox.xmax;
  mapbox.y2=(maxy-miny1)/height*mapbox.ymax;
  mapbox.y1=(maxy-maxy1)/height*mapbox.ymax;
  if (mapbox.x1 < 0) mapbox.x1 = 0;
  if (mapbox.x2 > mapbox.xmax)mapbox.x2 = mapbox.xmax;
  if (mapbox.y1 < 0) mapbox.y1 = 0;
  if (mapbox.y2 > mapbox.ymax) mapbox.y2 = mapbox.ymax;
  mapbox.draw();
}

function clearSelection(){
  with(document.mapserv){
    if(document.mapserv.pin) pin.value = "";
    if(document.mapserv.pins) pins.value = "";
    savequery.value=2;
  }
  refreshmap();
}

function hsURL(){
  document.mapserv.mode.value='url';
  document.mapserv.layers.value=lyrs();
  document.mapserv.submit();
}

function hsHover(obj){
  pos=obj.src.lastIndexOf(".");
  if(pos) obj.src=obj.src.substr(0,pos)+"_"+obj.src.substr(pos);
}

function hsHoverOut(obj){
  pos=obj.src.indexOf("_.");
  obj.src=obj.src.substr(0,pos)+obj.src.substr(pos+1);
}

//---- pro formulare ----

function hsUp(s){
  var pom=s.split(" ");
  s = "";
  for(var i=0;i<pom.length;i++){
    s += " ("+pom[i].substr(0,1).toUpperCase()+"|"+pom[i].substr(0,1).toLowerCase()+")"+pom[i].substr(1).toLowerCase();
  }
  return s.substr(1);
}

function filter(fname){
  with(document.forms[fname]){
    qstring.value="/"+hsUp(dotaz.value)+"/";
  }
}

function setSelect(fname,qname){
  with(document.forms[fname]){
    if(dotaz.value.substr(0,1)=="[") dotaz.value='';
    for(var i=0;i<qitem.length;i++){
      if(qitem[i].value==qname) {
        qitem.selectedIndex=i;
        break;
      }
    }
  }
}
