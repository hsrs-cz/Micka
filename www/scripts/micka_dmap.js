// JavaScript Document

function mRect(ext){
  if(ext){
    var pom = ext.split(" ");
    var s = pom[0]+" "+pom[1]+","+pom[2]+" "+pom[3];
  }
  else {
    mapbox.orderCoords();
    mapbox.draw();
    var s = x2world(mapbox.x1)+" "+y2world(mapbox.y2)+","+x2world(mapbox.x2)+" "+y2world(mapbox.y1);
  }
  if(epsg=='4326'){
    if(parent.getFindBbox) parent.getFindBbox(s);
    else opener.md_mapApp(s,false);
  }
  else {
    ajax.get("/mapserv/php/transform.php?request=getProjected&mapcoords="+s+"&srs=EPSG:"+epsg+"&srsout=EPSG:4326", null, getBBoxRes, true);
  }
}


function getBBoxRes(s){
  if(parent.getFindBbox) parent.getFindBbox(s.responseText);
  else opener.md_mapApp(s.responseText, false);
  return false;
}

function mPoly(){
  var s = mapbox.getCoords();
  if(epsg=='4326'){
    if(!parent.getFindBbox) opener.md_mapApp(s, true);
  }
  else ajax.get("/mapserv/php/transform.php?request=getProjected&mapcoords="+s+"&srs=EPSG:"+epsg+"&srsout=EPSG:4326", null, getBPolyRes, true);
}

function getBPolyRes(s){
  if(!parent.getFindBbox) opener.md_mapApp(s.responseText, true);
  return false;  
}

function drawExtent(id, wms, mapsize, mapext, buffer){
  if(!mapext[0]) return false;
  var ext = adjustRect(mapsize,mapext,buffer);
  //var wmsURL = wms+"&REQUEST=GetMap&SRS=EPSG:"+epsg+"&BBOX="+ext[0]+","+ext[1]+","+ext[2]+","+ext[3]+"&WIDTH="+mapsize[0]+"&HEIGHT="+mapsize[1];
  var wmsURL = wms+"&REQUEST=GetMap&SRS=EPSG:"+epsg+"&BBOX="+ext[0]+","+ext[1]+","+ext[2]+","+ext[3]+"&WIDTH="+mapsize[0]+"&HEIGHT="+mapsize[1];
  document.write("<div id='"+id+"' style='position:relative'><img src='"+wmsURL+"' width='"+mapsize[0]+"' height='"+mapsize[1]+"'></div>");
  var x1 = Math.round((mapext[0]-ext[0])/(ext[2]-ext[0])*mapsize[0])-1;
  var y1 = Math.round((ext[3]-mapext[3])/(ext[3]-ext[1])*mapsize[1])-1;
  var x2 = Math.round((mapext[2]-ext[0])/(ext[2]-ext[0])*mapsize[0])-1;
  var y2 = Math.round((ext[3]-mapext[1])/(ext[3]-ext[1])*mapsize[1])-1;

  var jg = new jsGraphics(id);
  jg.setColor("#0000FF");
  jg.setStroke(3);
  jg.drawRect(x1, y1, x2-x1, y2-y1);
  jg.paint();
}

function drawWKT(id, wms, mapsize, mapext, wkt, buffer){
  if(!mapext[0]) return false;
  var ext = adjustRect(mapsize,mapext,buffer);
  var wmsURL = wms+"&REQUEST=GetMap&SRS=EPSG:"+epsg+"&BBOX="+ext[0]+","+ext[1]+","+ext[2]+","+ext[3]+"&WIDTH="+mapsize[0]+"&HEIGHT="+mapsize[1];
  document.write("<div id='"+id+"' style='position:relative'><img src='"+wmsURL+"' width='"+mapsize[0]+"' height='"+mapsize[1]+"'></div>");
  var jg = new jsGraphics(id);
  jg.setColor("#0000FF");
  jg.setStroke(3);

  if(wkt!=''){
    var wktArray=wkt.split("(");
    for(var i=2;i<wktArray.length;i++){
      var x = new Array();
      var y = new Array();
      var item = wktArray[i].substr(0, wktArray[i].indexOf(")"));
      item = item.split(",");
      for(var j=0;j<item.length;j++){
        var point = item[j].split(" ");
        x.push(Math.round((point[0]-ext[0])/(ext[2]-ext[0])*mapsize[0])-1);
        y.push(Math.round((ext[3]-point[1])/(ext[3]-ext[1])*mapsize[1])-1);
      }
      jg.drawPolygon(x,y);
    }
  }
  else{
    var x1 = Math.round((mapext[0]-ext[0])/(ext[2]-ext[0])*mapsize[0])-1;
    var y1 = Math.round((ext[3]-mapext[3])/(ext[3]-ext[1])*mapsize[1])-1;
    var x2 = Math.round((mapext[2]-ext[0])/(ext[2]-ext[0])*mapsize[0])-1;
    var y2 = Math.round((ext[3]-mapext[1])/(ext[3]-ext[1])*mapsize[1])-1;
    jg.drawRect(x1, y1, x2-x1, y2-y1);   
  }  
  jg.paint();
}
