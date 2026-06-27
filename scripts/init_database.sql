/*

Create Database and Schemas

Script Purpose:
This script creates a new database named 'DataWarehouse' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.
WARNING:
Running this script will drop the entire 'DataWarehouse' database if it exists. All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
If Exists (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
Begin
  ALTER database Datawarehouse set single_user with rollback immediate;
  drop database datawarehouse;
end;
go

--Create Database 'WareHouse'

use master;

create database datawarehouse

use datawarehouse;

create schema bronze;
go
create schema silver;
go
create schema gold;
go
