/**
 * Class: HS
 * Base Help Service class with global methods and variables, common for
 * all applications
 * 
 * (copy of hslayers base class version 1.0.2)
 *
 */
HS = {};

/**
 * Property: lang
 * Current language code in ISO (3 characters) format. Default null.
 */
HS.lang = null;

/**
 * Property: defaultLang
 * Default language code: "eng"
 */
HS.defaultLang = "eng";

/**
 * Property: allLangsSet
 * Do all possible libraries (openlayers, custom, ...) set their languages
 * settings?
 */
HS.allLangsSet = false;

/**
 * Property: Lang
 * Dictionary with various languages. e.g. HS.Lang["cze"], HS.Lang["eng"]
 * ...
 */
HS.Lang = {};

/**
 * Function: i18n
 * Translation function
 *
 * Parameters:
 * code - {String} language code, in which you want the translation. If
 * ommited (the usual case), current language is taken.
 * key - {String} key for string, you want to get translation for.
 *
 * Example setting the application language:
 * (code)
 * if (!HS.lang) {
 *     var lastLang = HS.getLastLangCode();
 *     if (!lastLang) {
 *         lastLang = "czech";
 *     }
 *     HS.setLang(lastLang);
 * }
 * (end)
 */
HS.i18n = function() {

    if (!HS.getLang()) {
        HS.setLang(this.defaultLang);
    }

    var trans = null;
    var KEY = null;
    if (typeof(arguments[0]) == typeof({})) {
        trans = arguments[0];
        KEY = arguments[1];
    }
    else {
        trans = HS.Lang;
        KEY = arguments[0];
    }

    // search the translation 
    var retString = "";
    for (var lang in trans) {
        if (lang == this.lang) {
            retString =  trans[this.lang][KEY];
        }
    }

    return (retString ? retString : KEY);
};

/**
 * Function: setLang
 * Set current language according to given code. If not available, "eng"
 * will be used. <setCookie> will  be called as well.
 *
 * Parameters:
 * code - {String} language code. Can be *any* form (e.g.
 *   "česky","cs","cze", ...). 
 * saveToCookie - {Boolean} , default: false
 *
 * Return:
 * {Boolean} it worked, or not
 */
HS.setLang = function(code, saveToCookie) {

    if (HS.allLangsSet == false) {
        
        var hsset = false;
        var olset = false;

        var hscode = null;
        var olcode = null;
        // get HS languega code
        for (var l in HS.langs) {
            breakthis = false;
            var keys = HS.langs[l];
            for (var i = 0; i < keys.length; i++) {
                if (keys[i] == code) {
                    hscode = l.split(";")[0];
                    olcode = this.getOLCode(hscode);
                    breakthis = true;
                    break;
                }
            }

            if (breakthis) { //found
                break;
            }
        }
        
        if (hscode == null) {
            hscode = "eng";
            olcode = "en";
        }

        // set lang
        this.lang = hscode;
        
        if (saveToCookie == true) {
            this.setCookie("lang",hscode);
        }

        hsset = true;

        try {
            OpenLayers.Lang.setCode(olcode);
            olset = true;
        } catch(e) {}

        if (olset && hsset) {
        }
    }
        
    return true;
};


/**
 * Function: getLang
 * Get current language code.
 *
 * Parameters:
 * type - {String} *2* *3* *"ol"*
 * 
 * Return:
 * code - {String} in 3 characters format
 */
HS.getLang = function(type) {

    if (!type) {
        type = 3;
    }

    if (!HS.lang) {
        return null;
    }
    else {
        return HS.getCodeFromLanguage(HS.lang,type);
    }
};

/**
 * Function: getLastLangCode
 * Get language code from URL or Cookie. URL first, if not found, cookie
 * last. If not found, null returned
 *
 * Returns:
 * null or {String} 3 characters code
 */
HS.getLastLangCode = function() {

    var code = null;
    /* parse link location */
    if (window.location.search.length > 0) {
        var search = window.location.search;
        var params = search.substr(1,search.length); /* without "?" */
        params = params.split("&"); 
        for (var i = 0; i < params.length; i++) {
            var param = params[i].split("=");

            /* language */
            if (param[0] == "lang") {
                code = HS.getCodeFromLanguage(param[1],3); 
            }
        }
    }

    if (!code) {
        try {
                code = HS.getCookie("lang");
                code = HS.getCodeFromLanguage(code);
        }
        catch(e) {}
    }
    
    return code;
};

/**
 * Function: getCodeFromLanguage
 * Get desired code 
 * Params:
 * code {String} anything, that identifies the language, from "eng" to * "cesky"
 * type {String} currenly: 2: en, 3: eng, "ol":  en
 */
HS.getCodeFromLanguage = function(code,type) {
    
    if (!type) {
        type = 3;
    }

    for (var l in HS.langs) {
        breakthis = false;
        var keys = HS.langs[l];
        for (var i = 0; i < keys.length; i++) {
            if (keys[i] == code) {
                codes = l.split(";");


                switch(type) {
                    case 2: return codes[2]; break;
                    case 3: return codes[0]; break;
                    case "ol": return codes[0]; break;
                    default: return "eng"; break;
                }
            }
        }
    }
    return null;
};

/**
 * Function: setCookie
 * Set the cookie of given name with given value.
 * Called from <setLang>
 *
 * Parameters:
 * c_name - {String}  name of the cookie
 * value - {String} value of the cookie
 * expiredays - {Integer} when it expires, default is never
 */
HS.setCookie = function(c_name,value,expiredays) {
    var exdate=new Date();
    exdate.setDate(exdate.getDate()+expiredays);
    document.cookie=c_name+ "=" +escape(value)+
    ((expiredays==null) ? "" : ";expires="+exdate.toGMTString());
};

/**
 * Function: getCookie
 * Get value of the cookie with given name. Used in <getLang>
 *
 * Parameters:
 * c_name - {String} name of the cookie
 * 
 * Returns:
 * {String} or ""
 */
HS.getCookie = function(c_name) {
    if (document.cookie.length>0) {
        c_start=document.cookie.indexOf(c_name + "=");
        if (c_start!=-1) { 
            c_start=c_start + c_name.length+1; 
            c_end=document.cookie.indexOf(";",c_start);
            if (c_end==-1) c_end=document.cookie.length;
            return unescape(document.cookie.substring(c_start,c_end));
        } 
    }
    return "";
};

/**
 * Property: langs
 * List of langue codes in various formats.
 */
HS.langs = {
	    "alb;sq;sq": ["sq", "alb", "albanian"],
	    "arm;hy;hy": ["hy","arm","hye","armenian"],
	    "aze;az;az": ["az","aze","azerbaijani"],
	    "bos;bos;bs": ["bs","bos","bosnian"],
	    "bul;bul;bg": ["bg","bul","bulgarian"],
	    "cze;cs-CZ;cs": ["cz","cze","cs-CZ","czech","cesky","cs"],
	    "dan;da;da": ["da","dan","danish"],
	    "dut;nl;nl": ["nl", "dut", "dutch"],
	    "eng;en;en": ["en","eng","english"],
	    "est;et;et": ["et", "est", "estonian"],
	    "fin;fi;fi": ["fi","fin","finnish"],
	    "fre;fr;fr": ["fr","fre","france"],
	    "ger;de-DE;de": ["de","ger","de-DE","deutsch"],
	    "gre;el;el": ["el", "gre", "greece"],
	    "hrv;hr;hr": ["hr", "hrv", "croatian"],
	    "hun;hu;hu": ["hu","hun"],
	    "ita;it;it": ["it","ita","italian"],
	    "lav;lv-LV;lv": ["lv","lav","lv-LV","latvian","latv"],
	    "lit;lt;lt": ["lt", "lit", "lithuanian"],  
	    "mkd;mk;mk": ["mk", "mkd", "macedonian"],
	    "nor;no;no": ["no", "nor", "norweign"],
	    "pol;pl;pl": ["pl","pol","polska"],
	    "por;pt;pt": ["pt","por","portugese"],
	    "rum;ro;ro": ["ro", "rum", "romanian"],
	    "nor;no;no": ["no","nor","norweign"],
	    "slo;sk-SK;sk": ["sk","svk","slo","slk","sk-SK","slovak"],
	    "slv;sl;sl": ["sl","slv"],
	    "spa;es;es": ["es","spa","spanish"],
	    "srp;sr;sr": ["sr", "srp", "serbian"],
	    "swe;sv;sv": ["sv","swe","swedish"],
	    "ukr;uk;uk": ["uk", "ukr", "ukrainian"]
	};

/**
 * Method: initLangs
 * Initialize <HS.Lang> property for all available languages
 */
HS.initLangs = function() {
    for (var lang in this.langs) {
        HS.Lang[lang.split(";")[0]] = {};
    }
};

HS.getOLCode = function(code) {
    for (var c in this.langs) {
        var codes = c.split(";");
        if (code == codes[0]){
            return (codes.length > 1 ? codes[1] : codes[0]);
        }
    }
    return "en";
};

/**
 * Function: setDefaultLanguage
 * Set derault value for this application and init langs. Use this method
 * for initial lanuage settings.
 */
HS.setDefaultLanguage = function() {
    var lastLang = HS.getLastLangCode();
    if (!lastLang) {
        lastLang = HS.defaultLang;
    }
    HS.setLang(lastLang);
};
HS.initLangs();
