// JavaScript Document
var mickaURL = '..'; //FIXME - remove?
var currentObj = null;

if(!String.trim) String.prototype.trim = function() { return this.replace(/^\s+|\s+$/, ''); };

var lite = {
    init: function(){
        $('[data-tooltip="tooltip"]').tooltip();
        $('.sel2').select2({
            escapeMarkup: function(markup) { return markup; },
            templateResult: function (d) {
                if(d.level && d.level==1) return '<span class="sel2-level1">'+d.text+'</span>';
                else return d.text; 
            }
        });
        $('.sel2').on('select2:select', {self: this}, this.onSelect);
        $('.sel2').on('select2:unselect', {self: this}, this.onSelect);
        $('.person').on('select2:select', this.changePerson);
        this.createDuplicate();
        $.fn.datepicker.defaults.language=HS.getLang(2);
        $.fn.datepicker.defaults.todayHighlight = true;
        $.fn.datepicker.defaults.forceParse = false;
        if(lang=='cze') $.fn.datepicker.defaults.format = "dd.mm.yyyy";
        else $.fn.datepicker.defaults.format = "yyyy-mm-dd";
        this.processParent();
        this.processFc();
        var self = this;
        $('.sel2:required').each(function(e){
            self.setMandatory(this);
        });
    },
    
    cswResults: function(data, page){
        return {
            results: $.map(data.records, function(rec) {
                return {id: rec.id, text: rec.title, title: rec.abstract};
            })  
        }    
    },

    processParent(){
        var id = $("#parent-identifier").data("val");
        var me = this;
        var processResult = function(data){
            var rec = (data && data.records[0]) ? [{id:data.records[0].id, text:data.records[0].title}] : [];
            $("#parent-identifier").select2({
                data: rec,
                ajax: {
                    url: baseUrl+'/suggest/metadata?lang='+lang,
                    dataType: 'json',
                    processResults: me.cswResults,
                    cache: false
                },
                language: HS.getLang(2),
                allowClear: true,
                theme: 'bootstrap',
                maxSelectionLength: 1           
            });
            $("#parent-identifier").trigger('change');
        };
        if(id){
            $.ajax({
                url: baseUrl+'/suggest/metadata?lang='+lang+'&id='+id,
                dataType: 'json' 
            })
            .done(processResult);
        }
        else processResult(false);
    },
    
    processFc(){
        var id = $("#fcat").data("val");
        var me = this;
        var processResult = function(data){
            var rec = data ? [{id:data.records[0].id, text:data.records[0].title}] : [];
            $("#fcat").select2({
                data: rec,
                ajax: {
                    url: baseUrl+'/suggest/metadata?lang='+lang+'&res=fc',
                    dataType: 'json',
                    processResults: me.cswResults,
                    cache: false
                },
                language: HS.getLang(2),
                allowClear: true,
                theme: 'bootstrap',
                maxSelectionLength: 1           
            });
            $("#fcat").trigger('change');
            $("#fcat").on('change.select2', function (e) {
                $("#featureTypes").val(null);
                $("#featureTypes").select2({
                    ajax: {
                        url: baseUrl+'/suggest?lang='+lang+'&type=featureType&id='+$("#fcat").val(),
                        dataType: 'json',
                        processResults: me.cswResults,
                        cache: true
                    }
                });
                $("#featureTypes").select2('open');
            });
        };
        if(id){
            $.ajax({
                url: baseUrl+'/suggest/metadata?lang='+lang+'&id='+id,
                dataType: 'json' 
            })
            .done(processResult);
        }
        else processResult();
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
        // erase content for first group
        else {
            $(toDel).find('input').val('');
            var sel  = $(toDel).find('.sel2');
            $(sel).removeClass("select2-hidden-accessible");
            $(sel).parent().children('span').remove();
            $(sel).val('');
            $(sel).select2();
        }	
    },
    
    // fills the contact information
    changePerson: function(e){
        var data = e.params.data;
        var parent = $(e.target).parent().parent().parent();
        $(e.target).parent().children('.hperson').val(data.person);
        // if gets data from predefined list
        var o;
        if(data.person){
            for(var l in data.organisation){
                o = $(parent).find('input[name*="organisationName"]', '.'+l);
                if(o) $(o).val(data.organisation[l]);
                o = $(parent).find('input[name*="function"]', '.'+l);
                if(o) $(o).val(data.org_function[l]);
            }
            $(parent).find('input[name*="deliveryPoint"]').val(data.point);
            $(parent).find('input[name*="city"]').val(data.city);
            $(parent).find('input[name*="postalCode"]').val(data.postcode);
            $(parent).find('input[name*="country"]').val(data.country);
            $(parent).find('input[name*="www"]').val(data.url);
            $(parent).find('input[name*="email"]').val(data.email);
            $(parent).find('input[name*="phone"]').val(data.phone);
        }
    },
    
    changeExtent: function(e){
        var bbox = e.params.data.id.split('|')[1].split(" ");
        $('#xmin').val(bbox[0]);
        $('#ymin').val(bbox[1]);
        $('#xmax').val(bbox[2]);
        $('#ymax').val(bbox[3]);
        micka.mapfeatures.clear();
        var ext = micka.addBBox(bbox, 'i-1');
        micka.overmap.getView().fit(ext, micka.overmap.getSize());
    },
    
    changeServiceType: function(e){
        if(e.params.data.id=='other') $('#IOS').show();
        else $('#IOS').hide();
    },
    
    onSelect: function(e){
        var self = e.data.self;
        self.setMandatory(e.target);
        switch (e.target.id){
            case 'serviceType-sel':
                self.changeServiceType(e);
                break;
            case 'extentId-sel':
                self.changeExtent(e);
                break;
            default:
        }
    },
    
    setMandatory: function(target){
        if($(target).prop('required')){
            if($(target).val()){
                $(target.parentNode).find('.select2-selection').removeClass('micka-req');
            }
            else {
                $(target.parentNode).find('.select2-selection').addClass('micka-req');
            }
        }
    }
    
}

