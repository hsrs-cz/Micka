var micka = {
    
    confirmURL: function(msg, url){
        if(window.confirm(msg)){
            window.location = url;
        }
    },
    
    showSubsets: function(){
        var target = $('#micka-subsets').get(0);
        var fid = $('#file-identifier').get(0).textContent;
        this._showSubsets(target, fid);
    },
    
    _showSubsets(target, fid){
        var that = this;
        $.get('../../csw/?REQUEST=GetRecords&FORMAT=application/json&query=ParentIdentifier%3D'+fid)
        .done(function(data){
            $(target).html('');
            for(var i=0;i<data.records.length;i++){
                $(target).append('<div><a href="'+data.records[i].id+'"><span class="res-type '+data.records[i].trida+'"></span>'+data.records[i].title+'</a></div>');
                $(target).append('<div style="margin-left:15px;" id="sub-'+data.records[i].id+'">loading....</div>');
                that._showSubsets($("#sub-"+data.records[i].id), data.records[i].id);
            }
        })            
    }
}