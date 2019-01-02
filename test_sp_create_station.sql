EXEC sp_create_station @name = 'Somwhere near the first location',  @location=1; -- Should return 50200 since the location was not created
EXEC sp_create_station @name = 'Somwhere in Italy',  @lat=11.7161095, @long=11.7161095, @station_desc = 'Are you not Entertained?'; -- Should return 50201 since a new location was created and linked to the station
EXEC sp_create_station @name = 'Should return an Error'; -- Should return 50203 since no location was given
EXEC sp_create_station @name = 'Nowhere',  @location=11; -- Should return 50204 since the location with ID=11 does not exist
EXEC sp_create_station @name = 'Somwhere in Italy',  @lat=11.7161095, @long=11.7161095; -- Should return 20205 since the a station with same name already exists
