
is_transfer(leg::JourneyLeg) = leg.from_stop == leg.to_stop


function display_journey(journey::Journey)
    for leg in journey.legs
        println(display_leg(leg))
    end
end

function display_leg(leg::JourneyLeg)
    from_station = "$(leg.from_stop.station_name) sp.$(leg.from_stop.platform_code)"
    to_station = "$(leg.to_stop.station_name) sp.$(leg.to_stop.platform_code)"
    trip = "$(leg.trip.name)"
    arrival_time = "$(Dates.format(leg.arrival_time, dateformat"HH:MM"))"
    departure_time = "$(Dates.format(leg.departure_time, dateformat"HH:MM"))"
    return "$from_station ($departure_time)  to  $to_station ($arrival_time)  with  $trip"
end
