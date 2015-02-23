busdash = {}

busdash.stringifyMVJ = (j) ->
	mvj = j.MonitoredVehicleJourney
	recordedAt = moment(j.recordedAtTime)
	doc = parseFloat(mvj.MonitoredCall.Extensions.Distances.DistanceFromCall)
	fem = (Math.max(10000 - doc, 1000) / 5000)
	s = """
	<div class='busJourney #{status}' style="font-size: #{fem}em">
		<div class='PublishedLineName'>#{ mvj.PublishedLineName }</div>
		<div class='PresentableDistance'>#{ mvj.MonitoredCall.Extensions.Distances.PresentableDistance }</div>
		<div class="DistanceFromCall">#{ mvj.MonitoredCall.Extensions.Distances.DistanceFromCall }m away</div>
		<div class='ProgressRate'>#{ mvj.ProgressRate }</div>
		<div class='RecordedAtTime'>Checked: #{ recordedAt.fromNow() }</div>
	</div>
	"""
	return s

busdash.printMSVS = (msvs) ->
	_.each msvs, (msv) ->
		$('<div />').html(busdash.stringifyMVJ(msv)).appendTo '#buses'

busdash.writeStopStatusForBus = (STOP_ID, BUSNAMES) ->

	$.ajax
		url: 'http://bustime.mta.info/api/where/stop/MTA_' + STOP_ID + '.json?key=' + settings.apikey,
		jsonp: 'callback'
		dataType: 'jsonp'
		success: (data) ->
			$("<div/>").html(data.data.name).appendTo("#stopname") 

	$.ajax
		url: 'http://bustime.mta.info/api/siri/stop-monitoring.json?key=' + settings.apikey + '&OperatorRef=MTA&MonitoringRef=' + STOP_ID,
		jsonp: 'callback'
		dataType: 'jsonp'
		success: (data) ->
			validMSVs = _.filter(data.Siri.ServiceDelivery.StopMonitoringDelivery[0].MonitoredStopVisit, (msv) ->
				console.log msv
				return msv.MonitoredVehicleJourney.PublishedLineName in BUSNAMES
			)
			busdash.printMSVS(validMSVs)
			return
	return

$(document).ready ->
	busdash.writeStopStatusForBus settings.stop_id, settings.buses

	setTimeout ->
		window.location.reload(1);
	, 30000

