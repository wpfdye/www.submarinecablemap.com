window.SubmarineCable = {}

class SubmarineCable.Map
  
  @landing_points_table_id = "1y38C_S73_osEB-L60DiRS7JJFARw03SnYzVJtdg"
  @cables_table_id = "1pY5tMAMkf36aH-N2VvXPxnmjPblcQnONodZ32fk"
  
  @mapStyles: [
    {"featureType": "landscape","stylers": [{ "visibility": "on" },{ "color": "#d9d9d9" }]},
    {"featureType": "poi","stylers": [{ "visibility": "off" }]},
    {"featureType": "road","stylers": [{ "visibility": "off" }]},
    {"featureType": "transit","stylers": [{ "visibility": "off" }]},
    {"featureType": "administrative.locality","stylers": [{ "visibility": "off" }]},
    {"featureType": "administrative.neighborhood","stylers": [{ "visibility": "off" }]},
    {"featureType": "administrative.land_parcel","stylers": [{ "visibility": "off" }]},
    {"featureType": "administrative.country","elementType": "labels.text.fill","stylers": [{ "color": "#000000" },{ "visibility": "on" }]},
    {"featureType": "administrative.province","stylers": [{ "visibility": "off" }]},
    {"featureType": "water","elementType": "geometry.fill","stylers": [{ "color": "#ffffff" },{ "visibility": "on" }]},
    {"elementType": "labels.text.fill","stylers": [{ "color": "#808080" }]}
  ];
  
  showCables: () ->
    @cables = new google.maps.FusionTablesLayer
      query: {select: 'coordinates',from: SubmarineCable.Map.cables_table_id}
      styles: [{polylineOptions: {strokeOpacity: 1}}]
      suppressInfoWindows:true, 
      styleId: 2
    @cables.setMap(@gmap)
  
  showLandingPoints: () ->
    @landing_points = new google.maps.FusionTablesLayer
      query: {select: 'coordinates',from: SubmarineCable.Map.landing_points_table_id}
      suppressInfoWindows:true
      styleId: 2
    @landing_points.setMap(@gmap)
  
  selectCable: (id, desc, is_map_clicked = false) ->
    @infoBox.close()
    @cables.setOptions 
      styles: [
        { polylineOptions: {strokeOpacity: 0.1} }
        where: "id = '#{id}'", polylineOptions: { strokeColor: "#a81120", strokeOpacity: 1.0} 
      ]
      
    @landing_points.setQuery 
      select: 'coordinates'
      from: SubmarineCable.Map.landing_points_table_id
      where: "id IN (#{("'#{d.id}'"for d in desc).join()})"
    @boundMap(desc)

  selectCountry: (cables, latlons) ->
    @infoBox.close()
    @cables.setOptions 
      styles: [
        { polylineOptions: { strokeOpacity: 0.1 }}
        where: "cable_id IN (#{("#{d.cable_id}"for d in cables).join()})", polylineOptions: { strokeOpacity: 1.0 } 
      ]
    
    @landing_points.setQuery 
      select: 'coordinates'
      from: SubmarineCable.Map.landing_points_table_id
      where: "cable_id IN (#{("#{d.cable_id}"for d in cables).join()})"

    @boundMap(latlons)
    
  selectRfs: (data) ->
    @infoBox.close()
    @cables.setOptions 
      styles: [
        { polylineOptions: { strokeOpacity: 0.1 }}
        where: "rfs CONTAINS '#{data.rfs.toString()}'", polylineOptions: { strokeOpacity: 1.0 } 
      ]
    @landing_points.setQuery 
      select: 'coordinates'
      from: SubmarineCable.Map.landing_points_table_id
      where: "cable_id IN (#{("#{d.cable_id}"for d in data.cables).join()})"
  
  boundMap: (desc) ->
    bounds = new google.maps.LatLngBounds()
    for value in desc
      bounds.extend new google.maps.LatLng value.latlon.split(',')[0], value.latlon.split(',')[1]
    @gmap.fitBounds bounds
    if @gmap.getZoom() > 5
      @gmap.setZoom @gmap.getZoom() - 2

  selectLandingPoint: (name, latLng) ->
    @cables.setOptions({styles: [{ polylineOptions: {strokeOpacity: 1} }] });
    @landing_points.setQuery
      select: 'coordinates',
      from: SubmarineCable.Map.landing_points_table_id
      
    @infoBox.close()
    @gmap.panTo latLng 
    @infoBox.setContent "<div class=\"infoBoxContent\"><div class=\"infoBoxPointer\"></div>#{name}</span>"
    @infoBox.setPosition latLng
    @infoBox.open @gmap
  
  resetMap: () ->
    @cables.setOptions({ styles: [{ polylineOptions: { strokeOpacity: 1 }} ] })
    @landing_points.setQuery({select: 'coordinates',from: SubmarineCable.Map.landing_points_table_id})
    @infoBox.close()
    
  resetBounds: () ->
    @gmap.setZoom 2
    @gmap.setCenter new google.maps.LatLng(30.0,-30.0)
    
  setEvents: () ->
    # Map Event
    google.maps.event.addListener @gmap, 'click', (event) =>
      jQuery(location).attr('href',"#/")
  
    # Cable Event
    google.maps.event.addListener @cables, 'click', (event) => 
      jQuery(location).attr('href',"#/submarine-cable/#{event.row.id.value}")

    # LandingPoint Event
    google.maps.event.addListener @landing_points, 'click', (event) => 
      jQuery(location).attr('href',"#/landing-point/#{event.row.id.value}")

  constructor: (@element) ->
    @gmap = new google.maps.Map document.getElementById(@element), {
      zoom: 3,
      maxZoom: 8,
      minZoom: 2,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      styles: SubmarineCable.Map.mapStyles,
      center: new google.maps.LatLng(30.0,-30.0),
      streetViewControl: false,
      mapTypeControl: false
    }
    @infoBox = new InfoBox({closeBoxURL:"",alignBottom:true,pixelOffset:new google.maps.Size(-60,-15)})
    @showCables()
    @showLandingPoints()
    @setEvents()
    return this

