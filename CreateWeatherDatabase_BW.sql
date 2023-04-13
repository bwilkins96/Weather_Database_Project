-- BDAT 605: Database Principles
-- Maryville University
-- Benjamin Wilkins, 4/13/2023

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
	MeasurmentType varchar(15) NOT NULL,
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