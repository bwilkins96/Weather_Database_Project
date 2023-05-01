-- BDAT 605: Database Principles
-- Maryville University
-- Benjamin Wilkins, 4/13/2023, UPDATED: 5/01/2023

/*******************************************************************
Creates the Weather database and tables for the final course project
*******************************************************************/

USE Master;
GO

IF DB_ID('Weather') IS NOT NULL
	DROP DATABASE Weather;
GO

CREATE DATABASE Weather;
GO

USE Weather;
GO

CREATE TABLE WeatherStations (
	StationID int PRIMARY KEY IDENTITY,
	Street varchar(50) NOT NULL,
	City varchar(40) NOT NULL,
	[State] char(2) NOT NULL,
	Zip varchar(10) NOT NULL
);

CREATE TABLE Recorders (
	RecorderID int PRIMARY KEY IDENTITY,
	[Type] varchar(40) NOT NULL,
	OnSite bit NOT NULL DEFAULT 1,
	Coords varchar(40) NOT NULL
);

CREATE TABLE HomeStations (
	StationID int REFERENCES WeatherStations( StationID ),
	RecorderID int REFERENCES Recorders( RecorderID )
);

CREATE TABLE Readings (
	ReadingID int PRIMARY KEY IDENTITY,
	[DateTime] DateTime NOT NULL,
	RecorderID int REFERENCES Recorders( RecorderID )
);

CREATE TABLE TemperatureReads (
	TempID int PRIMARY KEY IDENTITY,
	Temp decimal(10, 4) NOT NULL,
	DegreeType char(1) NOT NULL CHECK(DegreeType IN ('F', 'C', 'K')),
	ReadingID int REFERENCES Readings( ReadingID )
);

CREATE TABLE PrecipitationReads (
	PrecipID int PRIMARY KEY IDENTITY,
	Amount decimal(10,4) NOT NULL,
	MeasurementType varchar(15) NOT NULL,
	PrecipType varchar(25) NOT NULL,
	TimePeriodInHours decimal(10,4),
	ReadingID int REFERENCES Readings( ReadingID )
);

CREATE TABLE WindReads (
	WindID int PRIMARY KEY IDENTITY,
	Speed decimal(10,4) NOT NULL,
	MilesOrKilometers char(1) NOT NULL CHECK(MilesOrKilometers IN ('M', 'K')),
	Direction varchar(2) NOT NULL,
	ReadingID int REFERENCES Readings( ReadingID )
);
GO

/*******************************************************************
               Inserts test data into the database
*******************************************************************/

INSERT INTO WeatherStations VALUES 
	('Dornestic', 'Pittsburgh', 'PA', '12345'),
	('Scenic Way', 'Pittsburgh', 'PA', '12345'),
	('Strawberry Ave', 'Pittsburgh', 'PA', '12345');

INSERT INTO Recorders VALUES
	('Temp', 1, '12.12345, 20.20202'),
	('Precip', 1, '20.20202, 12.12345'),
	('Wind', 1, '67.89101, 51.50505'),
	('Temp', 0, '51.50505, 67.89101');

INSERT INTO HomeStations VALUES 
	(1, 4), (2, 3), (3, 2), (3, 1);

INSERT INTO Readings VALUES
	(GETDATE(), 1), (GETDATE(), 4),
	(GETDATE(), 2), (GETDATE(), 2),
	(GETDATE(), 3), (GETDATE(), 3),
	(GETDATE(), 1), (GETDATE(), 4);

INSERT INTO TemperatureReads VALUES 
	(80.5, 'F', 1), (18.35, 'C', 2),
	(90.25, 'F', 7), (14.5, 'C', 8);
	
INSERT INTO PrecipitationReads VALUES
	(5, 'inch', 'rain', 10, 3),
	(10, 'inch', 'snow', 4, 4);

INSERT INTO WindReads VALUES
	(5, 'M', 'SW', 5), (15, 'K', 'N', 6);