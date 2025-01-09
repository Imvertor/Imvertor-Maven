


document.getElementsByTagName('body')[0].onload = function () {	

	if (typeof respecConfig == 'undefined' || respecConfig.specStatus == 'WV' || respecConfig.specStatus == 'wv') {
		if (document.respec) {		
			document.respec.ready.then(function () {
				
			
			  panZoomImg();	
			});
		}
		else {	   
			panZoomImg();		
		}
	}
}; 

function panZoomImg() {
	oImgInfo = document.getElementsByClassName('imageinfo');	
	for (i=0; i<oImgInfo.length; i++) {	
		polygons = null;
		
		if (oImgInfo[i].children[0].localName == 'img') {			
			img = oImgInfo[i].children[0];				
		}			
		else if (oImgInfo[i].children[0].localName == 'figure') {			
			img = oImgInfo[i].children[0].children[0];			
		}	
		
		if (oImgInfo[i].children[1] && oImgInfo[i].children[1].localName == 'map') {
			mapId = oImgInfo[i].children[1].attributes[0].nodeValue;	
		}
		else {
			mapId = img.attributes.usemap.value;				
		}
		
		//if (img.clientWidth < img.naturalWidth || img.clientHeight < img.naturalHeight)	{	 // check if image is geschaald
			mapHeight = img.clientHeight;
			mapWidth = img.clientWidth;		
			scaleX = img.clientWidth / img.naturalWidth;
			scaleY = img.clientHeight / img.naturalHeight;
			imgSrc = img.src;				
			
			if (oImgInfo[i].children[1] && oImgInfo[i].children[1].localName == 'map') { // check if imageMap exists
				oMapArea = oImgInfo[i].children[1].children;
				polygons = [];
				hrefs=[];
				for (j=0; j<oMapArea.length; j++) {		
					polygons[j] = scaleCoords(oMapArea[j].attributes[2].value, scaleX, scaleY);	
					hrefs[j] = oMapArea[j].attributes[3].value;	
				}		
				oImgInfo[i].removeChild(oImgInfo[i].children[0]); // remove map
			}
				oImgInfo[i].removeChild(oImgInfo[i].children[0]); // remove fig or img
			
			if (oImgInfo[i].children[0]) {
				oImgInfo[i].removeChild(oImgInfo[i].children[0]); 		
			}		

			map = [];					
			mapContainer = oImgInfo[i].appendChild(document.createElement("div"));
			mapContainer.setAttribute("id", mapId);
			mapContainer.setAttribute("class", 'panZoomImageMap');
			mapContainer.style.background = 'white';
			
			mapContainer.style.height = 0.9*mapHeight + 'px';
									
			mapContainer.style.width = 0.9*mapWidth + 'px';
			
			mapContainer.style.border = 'solid 1px grey';
			mapContainer.style.marginBottom = '25px';

			map[i] = L.map(mapId, {attributionControl: false, zoomControl: false, scrollWheelZoom: false}).setView([0, 0], 11);		

			imageOverlay = L.imageOverlay(imgSrc, map[i].getBounds()).addTo(map[i]);
			
			map[i].fitBounds(imageOverlay.getBounds());	
			mapContainer.style.height = mapHeight + 'px';
			mapContainer.style.width = mapWidth + 'px';	

			if (mapHeight < 170) {
				mapContainer.style.height = 170 + 'px'; // minimaal 170px hoog i.v.m. knoppen
			}
			if (mapWidth < 405) {
				mapContainer.style.width = 405 + 'px'; // minimaal 405 px breed i.v.m. knoppen
			}
		
			
			map[i].setView(imageOverlay.getCenter(), map[i].getZoom());
			
			L.Control.OpenWindow = L.Control.extend({
				options: {
					position: 'topright',
				},
				onAdd: function(map) {
					var el = L.DomUtil.create('div', 'leaflet-bar leaflet-control custom-control-openwindow');
					el.innerHTML = '<a class="leaflet-control-zoom-in" href="'+imgSrc+'" target="_blank" role="button" aria-label="Open window" aria-disabled="false"><span aria-hidden="true">&#8599;</span></a>';
					return el; 
				},
				onRemove: function(map) {
					// Nothing to do here
				}
			});

			L.control.openWindow = function(opts) {
				return new L.Control.OpenWindow(opts);
			}		
			
			L.control.openWindow({
				position: 'topright'
			}).addTo(map[i]);

			L.control.zoom({
				position: 'topright'
			}).addTo(map[i]);		
			
			L.Control.Refresh = L.Control.extend({
				options: {
					position: 'topright',
				},
				onAdd: function(map) {
					var el = L.DomUtil.create('div', 'leaflet-bar leaflet-control custom-control-refresh');
					el.innerHTML = '<a class="leaflet-control-zoom-in" href="#" onclick="return false;" title="Refresh" role="button" aria-label="Refresh" aria-disabled="false"><span aria-hidden="true">&#8635;</span></a>';
							
					el.children[0].onclick = function(e) {					
						mapDiv = e.srcElement.parentNode.parentNode.parentNode.parentNode.parentNode;			
						imgLayer = Object.values(map._layers)[0];
						bounds = imgLayer.getBounds();						
						map.fitBounds(bounds);
						return false;					
					};
					return el;
				},

				onRemove: function(map) {
					// Nothing to do here
				}
			});

			L.control.refresh = function(opts) {
				return new L.Control.Refresh(opts);
			}	
			
			L.control.refresh({
				position: 'topright'
			}).addTo(map[i]);
			
						
			// add polygons	
			if (polygons != null) {
				for (j=0; j<polygons.length; j++) {
					coords = polygons[j].split(',');
					minX = 0.9*coords[0], minY = 0.9*coords[1], maxX = 0.9*coords[2], maxY = 0.9*coords[3];
					
					c1 = map[i].containerPointToLatLng(L.point(minX, minY));
					c2 = map[i].containerPointToLatLng(L.point(maxX, maxY));						
					
					polygon = L.rectangle([c1, c2], {opacity:0, fillOpacity:0});			
					polygon.options.href = hrefs[j];						
					polygon.on('click', function(e) {
						window.location.href = e.target.options.href;				
					});						
					polygon.addTo(map[i]);
				}
			}
		//}
	}
}

function scaleCoords(oMapAreaCoords, scaleX, scaleY) {	
	let oMapAreaCoordsArr = oMapAreaCoords.split(',');
	let cMapAreaCoordsArr = [];	
	cMapAreaCoordsArr[0] = oMapAreaCoordsArr[0] * scaleX; // minX * scalefactorWidth
	cMapAreaCoordsArr[1] = oMapAreaCoordsArr[1] * scaleY; // minY * scalefactorHeight
	cMapAreaCoordsArr[2] = oMapAreaCoordsArr[2] * scaleX; // maxX * scalefactorWidth
	cMapAreaCoordsArr[3] = oMapAreaCoordsArr[3] * scaleY; // maxY * scalefactorHeight
	return cMapAreaCoordsArr.join(',');	
}
 