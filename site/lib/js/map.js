//OpenLayers.ProxyHost = "/cgi-bin/proxy.cgi?url=";
function init(){
        
    
    zoomPoint = new OpenLayers.LonLat(15.235,50.038);
    gZoomPoint = zoomPoint.transform(new OpenLayers.Projection("EPSG:4326"),new OpenLayers.Projection("EPSG:900913"));
    
    
    options = {
        
        controls:[
        new OpenLayers.Control.LayerSwitcher(),     
        new OpenLayers.Control.PanZoomBar(),       
        //new OpenLayers.Control.MousePosition(),    
        new OpenLayers.Control.KeyboardDefaults(), 
        new OpenLayers.Control.Navigation()        
        ],
        allOverlays:true,
        projection: new OpenLayers.Projection("EPSG:900913")        //map projection is set to Google Mercator
    }
    map = new OpenLayers.Map( 'map',options); 

    katastr = new OpenLayers.Layer.WMS( 
        "Katastr ČÚZK",
        "http://services.cuzk.cz/wms/wms.asp?", 
        {
            layers:"dalsi_p_mapy,hranice_parcel,obrazy_parcel,parcelni_cisla,omp,RST_KMD,RST_KN", //more layers from one URL must be separated by comma 
            transparent:true
        }
        );
    cleneni = new OpenLayers.Layer.WMS( 
        "Správní členění ČR",
        "http://geoportal.cuzk.cz/WMS_SPH_PUB/service.svc/get?", 
        {
            layers:"GT_SPH_OBEC,GT_SPH_OKRES,GT_SPH_KRAJ,GP_SPH_OBEC,GP_SPH_OKRES,GP_SPH_OKRES_G,GP_SPH_KRAJ,GP_SPH_KRAJ_G,GP_SPH_STAT", //more layers from one URL must be separated by comma 
            transparent:true
        },{
            singleTile: true
        }
        ); 
            
    obce = new OpenLayers.Layer.WMS( 
        "ku obce",
        "lib/php/proxy.php?http://geoportal.cuzk.cz/WMS_SPH_PUB/service.svc/get?", 
        //"http://geoportal.cuzk.cz/WMS_SPH_PUB/service.svc/get?", 
        {
            layers:"GP_SPH_KU", //more layers from one URL must be separated by comma 
            transparent:true
        },{
            singleTile: true
        }
        );

    gsat = new OpenLayers.Layer.Google(     //new google layer
        "Google Satellite",     //name
        {
            type: google.maps.MapTypeId.SATELLITE,
            numZoomLevels: 20
        }
        ); 
            
    map.addLayers([gsat,katastr,obce, cleneni]);
    
    gsat.mapObject.setTilt(0);      //disable 45 degrees images, must be after addLayer(googleLayer)

    map.setCenter( gZoomPoint,8); 
    //console.log(map)
    //
    ////////////////////////////////////////kn
    Proj4js.defs["EPSG:102067"] = "+title=Krovak +proj=krovak +lat_0=49.5 +lon_0=42.5 +alpha=30.28813972222222 +k=0.9999 +x_0=0 +y_0=0 +ellps=bessel +pm=ferro +units=m +towgs84=570.8,85.7,462.8,4.998,1.587,5.261,3.56 +czech +no_defs";
    
    kn_vector = new OpenLayers.Layer.Vector("Katastr dotaz", {
        displayInLayerSwitcher:false
    });
    map.addLayer(kn_vector);
    
    
    OpenLayers.Control.Click = OpenLayers.Class(OpenLayers.Control, {                
        defaultHandlerOptions: {
            'single': true,
            'double': false,
            'pixelTolerance': 0,
            'stopSingle': false,
            'stopDouble': false
        },

        initialize: function(options) {
            this.handlerOptions = OpenLayers.Util.extend(
            {}, this.defaultHandlerOptions
                );
            OpenLayers.Control.prototype.initialize.apply(
                this, arguments
                ); 
            this.handler = new OpenLayers.Handler.Click(
                this, {
                    'click': this.trigger
                }, this.handlerOptions
                );
        }, 

        trigger: function(e) {
                
              
            
            var lonlat = map.getLonLatFromPixel(e.xy);
            
            kn_vector.removeAllFeatures();
            point = new OpenLayers.LonLat(lonlat.lon,lonlat.lat);
            var point2 = new OpenLayers.Geometry.Point(point.lon,point.lat);
            kn_vector.addFeatures([
                new OpenLayers.Feature.Vector(point2,{},
                {
                    externalGraphic: 'img/marker.png',
                    graphicWidth: 50, 
                    graphicHeight: 50, 
                    graphicYOffset: -50
                })
                ]);
                
                
        }
    });
 
 
    click = new OpenLayers.Control.Click();
    map.addControl(click);
        
 
    ////////////////////////////////////////////////kn dotaz
    var selectFeature = new OpenLayers.Control.SelectFeature(
        [kn_vector],
        {
            id: 'selectControl',
            onSelect: function(e){
                //    window.open("http://nahlizenidokn.cuzk.cz/MapaIdentifikace.aspx?&x="+x+"&y="+y);
                y = e.geometry.y;
                x = e.geometry.x;
                var point = new OpenLayers.LonLat(x,y);
                var  wgsLonLat = point.transform(new OpenLayers.Projection("EPSG:900913"), new OpenLayers.Projection("EPSG:102067"));
                window.open("http://nahlizenidokn.cuzk.cz/MapaIdentifikace.aspx?&x="+Math.round(-wgsLonLat.lon)+"&y="+Math.round(-wgsLonLat.lat));
            }
        });    
    map.addControl(selectFeature);
    selectFeature.activate();
    //////////////////////////////////////////kn konec
    

    
    //////////////////////gfi
    //kontrola, zda existuje soubor na serveru
    var nazevKu
        
    function checkKu(ku){
            
        console.log("ok");
        $.ajax({
            type: 'GET',
            url:'lib/php/checkku.php?ku='+ku,
            success: function(bool){
                if(bool=="true")
                {
                    $("#table").find("input,button,textarea,select").removeAttr("disabled");
                    $("#ku").html(ku);
                    $("#nazevku").html(nazevKu);
                }
                else{
                    $("#ku").html("neidentifikováno")
                    $("#nazevku").html("neidentifikováno");
                }
            },
            async: false
        });        
    };
    
    //konec kontroly
    
    var info = new OpenLayers.Control.WMSGetFeatureInfo({
        title: 'Identify features by clicking',
        layers:[obce],
        infoFormat: "text/xml",
        queryVisible: true,
        eventListeners: {
            getfeatureinfo: function(event) {
                //pokud byl jiz jednou zobrazen vystup, tak jej skreje
                $("#output").hide() 
                    
                nazevKuXML = $(event.text).find("Attribute").filter(function() {
                    return $(this).attr('Name')=="NAZEV_KU";
                });

                myXML = $(event.text).find("Attribute").filter(function() {
                    nazevKu = $(this).attr('Name')=="NAZEV_KU";
                    return $(this).attr('Name')=="KOD_KU";
                        
                });

                nazevKu = nazevKuXML.text();
                checkKu(myXML.text());
            }
        }
    });
        
    map.addControl(info);
        
    map.events.register('zoomend', this, function (event) {
        if (map.zoom > 12){
            info.activate();
            click.activate();
        }else {
            info.deactivate();
            click.deactivate();
        //$("#infoDiv").html("Pro označení katastrálního území musíte být více připlíženi.");
        }
        
    
    })
        
        
        
        
        
    var geocoder = new google.maps.Geocoder();
        
    this.aaa = "aaaaaaa"
    this.search = function(address) {
        geocoder.geocode( {
            'address': address,
            'region':'cs'
        }, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                //alert("okres "+ results[0].address_components[1].long_name)
                var point = new OpenLayers.LonLat(results[0].geometry.location.lng(),results[0].geometry.location.lat());
                point.transform(new OpenLayers.Projection("EPSG:4326"),new OpenLayers.Projection("EPSG:900913"));
                map.setCenter(point,"15");
          
                //cuzk(results[0].geometry.location.lng(),results[0].geometry.location.lat());
            
                kn_vector.removeAllFeatures();
    
                var point2 = new OpenLayers.Geometry.Point(point.lon,point.lat);
                kn_vector.addFeatures([
                    new OpenLayers.Feature.Vector(point2,{},
                    {
                        externalGraphic: 'img/marker.png',
                        graphicWidth: 50, 
                        graphicHeight: 50, 
                        graphicYOffset: -50
                    })
                    ]);
                console.log(map.getPixelFromLonLat(point));
                info.request(map.getPixelFromLonLat(point));
     
            } else {
                alert("Geocode was not successful for the following reason: " + status);
            }
        });
        return false;    
    }

    $('#areainfo').append($('<table/>',{
        style:"border:1px",
        id:"table"
    })
    .append($('<tr/>',{})
        .append($('<td/>',{}).append('Katastrální území:'))
        .append($('<td/>',{
            id:"nazevku"
        }).append("neidentifikováno")))
                
    .append($('<tr/>',{})
        .append($('<td/>',{}).append('Číslo k.ú.:'))
        .append($('<td/>',{
            id:"ku"
        }).append("neidentifikováno")))
                
    .append($('<tr/>',{}).append(' '))
                
        .append($('<tr/>',{})
            .append($('<td/>',{}).append('Formát'))
            .append($('<td/>',{})
                .append($("<select/>",{
                    id:'format'
                })
                .append($("<option/>",{
                    value:"shp"
                }).append('Shapefile'))
                    .append($("<option/>",{
                        value:"dxf"
                    }).append('DXF'))
                    .append($("<option/>",{
                        value:"kml"
                    }).append('KML'))
                    .append($("<option/>",{
                        value:"gml"
                    }).append('GML'))
                    )))
            
        .append($('<tr/>',{})
            .append($('<td/>',{}).append('Souř. sys.'))
            .append($('<td/>',{})
                .append($("<select/>",{
                    id:'osrs'
                })
                .append($("<option/>",{
                    value:"4326"
                }).append('WGS84/EPSG:4326'))
                    .append($("<option/>",{
                        value:"5514"
                    }).append('JTSK/EPSG:102067(5514)'))
                    )))
                
        .append($('<tr/>',{})
            .append($('<td/>',{}).append($("<input/>",{
                id:"export",
                type:"button",
                value:"Exportovat"
            }))))
                
        .append($('<tr/>',{})
            .append($('<td/>',{}).append($("<img/>",{
                id:"status",
                src:"img/loader.gif",
                style:"display:none"
            }))))
                
        .append($('<tr/>',{})
            .append($('<td/>',{}).append($("<a/>",{
                id:"output",
                href:"",
                style:"display:none"  
            }).append($("<img/>",{
                src:"img/zip_icon.png",
                width:"50px"
            })).append($("<p/>",{}).append("Stáhnout data"))
                )))
               
                
        ).append($('<div/>',{
        id:"infoDiv"
    }));
        
    //pri nacteni bude vse disabled
    $("#table").find("input,button,textarea,select").attr("disabled", "disabled");
        
    //////////////////////////////odeslani pozadavku na API
    $("#export").click(function(){
            
        $.ajax({
            type: 'GET',
            url:"../lib/trFile/trFile.php?ku="+$("#ku").html()+"&isrs=5514&osrs=" + $("#osrs").val() + "&format=" + $("#format").val(),
            beforeSend:function(){
                $("#status").css("display","block");
                $("#export").hide();
                $("#output").hide();
                    
                    
                    
            },
            success: function(data){
                //$("#export").css("display","block");
                $("#export").show();
                $("#status").css("display","none");
                $("#output").css("display","block");
                $("#output").show();
                var href = location.href
                
                var href2 = href.substr(0, href.lastIndexOf("/"));
                var href3 = href2.substr(0, href2.lastIndexOf("/"));
                var href4 = href3 +"/data"+ data;
                console.log(href4);
                $("#output").attr("href",href4);
                    
            //window.open(data);
            },
            async: true
        }); 
        return false;
    })
        
}