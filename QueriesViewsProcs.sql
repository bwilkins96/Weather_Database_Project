-- BDAT 605: Database Principles
-- Maryville University
-- Benjamin Wilkins, 4/22/2023, UPDATED: 5/03/2023

/***************************************************************************
Weather database queries, views, and procedures for the final course project
***************************************************************************/

USE Weather;
GO

/*  Queries  */

-- Returns calculated temperature, id, and date/time of read
SELECT Readings.ReadingID, CAST(Temp AS varchar(10)) + ' ' + DegreeType AS TempRead, DateTime
FROM TemperatureReads JOIN Readings
	ON TemperatureReads.ReadingID = Readings.ReadingID
ORDER BY DegreeType DESC, ReadingID;


-- Returns total amount of precipitation, hours of precipitation, the average precipitation per hour,
-- a count of the number of readings, and recorders used, grouped by measurement type
SELECT MeasurementType, SUM(Amount) AS TotalPrecip, SUM(TimePeriodInHours) AS TotalHours,
	   (SUM(Amount) / SUM(TimePeriodInHours)) AS AvgPrecipPerHour, 
	   COUNT(DISTINCT Readings.ReadingID) AS TotalReadings, COUNT(DISTINCT RecorderID) AS NumRecorders
FROM PrecipitationReads JOIN Readings
	ON PrecipitationReads.ReadingID = Readings.ReadingID
GROUP BY MeasurementType
HAVING SUM(Amount) >= 15;
GO


/*  Views  */

-- View of WeatherStations table
CREATE OR ALTER VIEW WeatherStations_View
AS
SELECT StationID, Street + ', ' + City + ', ' + State + ' ' + Zip AS Address
FROM WeatherStations;
GO

-- View of Recorders table
-- Uses a union to return OnSite values as 'true' or 'false', as opposed to 1 or 0
CREATE OR ALTER VIEW Recorders_View
AS
	SELECT RecorderID, Type, 'true' AS Onsite, Coords
	FROM Recorders
	WHERE Onsite = 1
UNION
	SELECT RecorderID, Type, 'false' AS Onsite, Coords
	FROM Recorders
	WHERE Onsite = 0;
GO

-- View of readings table
CREATE OR ALTER VIEW Reading_View
AS
SELECT ReadingID, RecorderID, DateTime AS DateOfRead
FROM Readings;
GO

-- View of PrecipitationReads table
-- Combines amount and meaurement type to display formatted precipitation measurement
CREATE OR ALTER VIEW Precip_View
AS
SELECT ReadingID, CAST(Amount AS varchar(10)) + ' ' + MeasurementType AS Amount, 
	   PrecipType AS Type, TimePeriodInHours AS Hours 
FROM PrecipitationReads;
GO

-- View of TemperatureReads table
-- Combines temp and degree type to display formatted temperature measurement
CREATE OR ALTER VIEW Temp_View
AS
SELECT ReadingID, CAST(Temp AS varchar(10)) + ' ' + DegreeType AS Temp
FROM TemperatureReads;
GO

-- View of WindReads table
-- Combines speed and miles/kilometers per hour to display formatted wind measurement
CREATE OR ALTER VIEW Wind_View
AS
SELECT ReadingID, CAST(Speed AS varchar(10)) + ' ' + MilesOrKilometers + 'PH' AS Speed, Direction
FROM WindReads;
GO

-- View that joins HomeStations with WeatherStations and Recorders
-- Returns info about recorders and their home stations
-- Uses a union to return RecorderOnSite values as 'true' or 'false', as opposed to 1 or 0
CREATE OR ALTER VIEW HomeStations_View
AS
	SELECT Recorders.RecorderID, Type AS RecorderType, 'true' AS RecorderOnSite, Coords AS RecorderCoords,
		   WeatherStations.StationID, Street + ', ' + City + ', ' + State + ' ' + Zip AS StationAddress
	FROM WeatherStations JOIN HomeStations 
		ON WeatherStations.StationID = HomeStations.StationID
	JOIN Recorders
		ON HomeStations.RecorderID = Recorders.RecorderID
	WHERE OnSite = 1
UNION
	SELECT Recorders.RecorderID, Type AS RecorderType, 'false' AS RecorderOnSite, Coords AS RecorderCoords,
		   WeatherStations.StationID, Street + ', ' + City + ', ' + State + ' ' + Zip AS StationAddress
	FROM WeatherStations JOIN HomeStations 
		ON WeatherStations.StationID = HomeStations.StationID
	JOIN Recorders
		ON HomeStations.RecorderID = Recorders.RecorderID
	WHERE OnSite = 0;
GO


/*  Procedures / Functions  */

-- Returns data about max temperature readings, grouped by degree type
CREATE OR ALTER PROCEDURE sp_GetHottestReadData
AS
	SELECT Readings.ReadingID, CAST(Temp AS varchar(10)) + ' ' + DegreeType AS MaxTemp, Coords, DateTime
	FROM TemperatureReads JOIN Readings
		ON TemperatureReads.ReadingID = Readings.ReadingID
	JOIN Recorders
		ON Readings.RecorderID = Recorders.RecorderID
	WHERE Temp in (SELECT Max(Temp)
				   FROM TemperatureReads
				   GROUP BY DegreeType);
GO

-- Returns @Temp converted from @From to @To degrees
-- i.e. dbo.ConvertTemp(30.25, 'C', 'F') = 86.45 (in degrees fahrenheit)
CREATE OR ALTER FUNCTION ConvertTemp (@Temp decimal(10,4), @From char(1), @To char(1))
	RETURNS decimal(10,4)
BEGIN
	IF @From = @To                      
	-- attempting to convert between same degree type
		RETURN @Temp;

	DECLARE @NewTemp decimal(10,4)

	IF @From = 'C' and @To = 'K'
		SET @NewTemp = @Temp + 273.15;
	IF @From = 'K' and @To = 'C'
		SET @NewTemp = @Temp - 273.15;

	IF @From = 'F' and @To = 'C'
		SET @NewTemp = (5.0/9.0) * (@Temp - 32);
	IF @From = 'C' and @To = 'F'
		SET @NewTemp = (9.0/5.0 * @Temp) + 32;

	IF @From = 'K' and @To = 'F'
		SET @NewTemp = (9.0/5.0 * (@Temp - 273.15)) + 32;
	IF @From = 'F' and @To = 'K'
		SET @NewTemp = ((5.0/9.0) * (@Temp - 32)) + 273.15;

	RETURN @NewTemp;
END
GO

-- Returns data about max temperature reading, using the ConvertTemp function
CREATE OR ALTER PROCEDURE sp_GetHottestRead
AS
	SELECT Readings.ReadingID, CAST(Temp AS varchar(10)) + ' ' + DegreeType AS MaxTemp, Coords, DateTime
	FROM TemperatureReads JOIN Readings
		ON TemperatureReads.ReadingID = Readings.ReadingID
	JOIN Recorders
		ON Readings.RecorderID = Recorders.RecorderID
	WHERE dbo.ConvertTemp(Temp, DegreeType, 'C') = (SELECT Max(dbo.ConvertTemp(Temp, DegreeType, 'C'))
													FROM TemperatureReads);
GO


-- Uncomment below for testing
/*
SELECT * FROM WeatherStations_View;

SELECT * FROM Recorders_View;

SELECT * FROM Reading_View;

SELECT * FROM Precip_View;

SELECT * FROM Temp_View

SELECT * FROM Wind_View;

SELECT * FROM HomeStations_View;

EXEC sp_GetHottestReadData;

SELECT dbo.ConvertTemp(30.25, 'C', 'F') AS Result;  -- 86.4500

EXEC sp_GetHottestRead;
*/