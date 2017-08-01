// JavaScript Document
var mickaURL = '..';
var currentObj = null;

if(!String.trim) String.prototype.trim = function() { return this.replace(/^\s+|\s+$/, ''); };

var lite = {
    init: function(){
        $('[data-tooltip="tooltip"]').tooltip();
        $('.sel2').select2();
        this.createDuplicate();
        //micka.initMap({});
    },
    
    createDuplicate: function(){
        var dupl = $('.duplicate');
        $(dupl).empty(); 
        $(dupl).append('<span class="plus"><i class="fa fa-plus-square-o"></i></span>&nbsp;'
        + '<span class="minus"><i class="fa fa-minus-square-o"></i></span>');
        $('.plus').on('click',lite.duplicateNode);
        $('.minus').on('click',lite.removeNode);
    },
    
    duplicateNode: function(){
        var dold = this.parentNode.parentNode.parentNode.parentNode;
        var dnew = $(dold).clone(true, false);
        $(dnew).insertAfter(dold);
        var sel  = $(dnew).find('.sel2');
        $(sel).removeClass("select2-hidden-accessible");
        $(sel).parent().children('span').remove();
        $(sel).val('');
        $(dnew).find('input').val('');
        $(sel).select2();
        lite.createDuplicate();
        window.scrollBy(0,dold.clientHeight);
        return dnew;
    },
    
    removeNode: function(){
        if(!confirm("Smazat ?")) return;
        var toDel = this.parentNode.parentNode;
        var cont = toDel.parentNode;
        var pos = toDel.id.lastIndexOf("_");
        var pom = toDel.id.substring(0,pos);
        pos = pom.lastIndexOf("_");
        pom = pom.substring(0,pos);
        var elements = md_getSimilarNodes(cont, pom);
        // odstraneni elementu
        if(elements.length>1){ 
            cont.removeChild(toDel);
        }
        // vymazani obsahu pro prvni
        else {
            $(elements).find('input').val('');
            $(elements).find('select').val('');
        }	
        elements = md_getSimilarNodes(cont, pom[0]);
        for(var i=0;i<elements.length;i++) md_setName(elements[i], pom[0]+"_"+i+"_"); 
        checkFields();
    }



}

