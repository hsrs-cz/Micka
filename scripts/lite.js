// JavaScript Document
var mickaURL = '..';
var currentObj = null;

if(!String.trim) String.prototype.trim = function() { return this.replace(/^\s+|\s+$/, ''); };

var lite = {
    init: function(){
        $('[data-tooltip="tooltip"]').tooltip();
        $('.sel2').select2();
        this.createDuplicate();
        $.fn.datepicker.defaults.language=HS.getLang(2);
        $.fn.datepicker.defaults.todayHighlight = true;
        $.fn.datepicker.defaults.forceParse = false;
        if(lang=='cze') $.fn.datepicker.defaults.format = "dd.mm.yyyy";
        else $.fn.datepicker.defaults.format = "yyyy-mm-dd";

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
        var toDel = this.parentNode.parentNode.parentNode.parentNode;
        var cont = toDel.parentNode;
        // remove node
        if($(cont).children('fieldset').length>1){ 
            cont.removeChild(toDel);
        }
        // vymazani obsahu pro prvni
        else {
            $(toDel).find('input').val('');
            var sel  = $(toDel).find('.sel2');
            $(sel).removeClass("select2-hidden-accessible");
            $(sel).parent().children('span').remove();
            $(sel).val('');
            $(sel).select2();
        }	
    }

}

