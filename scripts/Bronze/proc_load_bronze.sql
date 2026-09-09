/*
--------------------------------------------------------------------------
Stored Procedure: Load Bronze Layer (Source -> Bronze)
--------------------------------------------------------------------------
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  -Truncates the bronze tables before loading data.
  -Uses the BULK INSERT command to load data from csv Files to bronze tables.
Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.
  Usage Example:
  EXEC bronze.load_bronze;
--------------------------------------------------------------------------
*/

create or alter procedure bronze.load_bronze as
begin
	DECLARE
    @start_time DATETIME2,
    @end_time DATETIME2,
    @batch_start_time DATETIME2,
    @batch_end_time DATETIME2;

	BEGIN TRY
    SET @batch_start_time = GETDATE();
    PRINT '=====================================';
    PRINT 'Loading Bronze Layer';
    PRINT '=====================================';


	PRINT '=====================================';
	PRINT 'Loading CRM Tables';
	PRINT '=====================================';

--------------------------------------------------------------

		/*1. CUSTOMER*/
		print'--------------------------------'
		print'Loading data into bronze.crm_cust_info'
		print'--------------------------------'

		set @start_time = getdate();
		print'>> truncating table bronze.crm_cust_info'
		truncate table bronze.crm_cust_info;

		print'>> inserting data into bronze.crm_cust_info'
		bulk insert bronze.crm_cust_info
		from 'C:\Users\ASUS\Desktop\me\SQL\MySQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with(
			firstrow = 2,
			fieldterminator=',',
			tablock
		);
		set @end_time = getdate();
		PRINT '>>load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';


		print'............................................................'
		--datediff- to calculate the differenct between two dates, returns day, months or years


-------------------------------------------------------------

		/*2.product*/

		print'------------------------------------'
		print'Loading data into bronze.crm_prd_info'
		print'....................................'

		print'>> truncating table bronze.crm_prd_info'
		truncate table bronze.crm_prd_info;

		print'>> inserting data into bronze.crm_prd_info'
		
		set @start_time = getdate();
		bulk insert bronze.crm_prd_info
		from 'C:\Users\ASUS\Desktop\me\SQL\MySQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with(
			firstrow = 2,/* this is used to tell that the first row is the header and we want to skip it*/
			fieldterminator=',',/* this is used to tell that comma means to sparate the columns in the csv file*/
			tablock/*Lock the entire table while importing data. this is used to tell that we want to lock the table while inserting the data*/
		);

		set @end_time = getdate();
		PRINT '>> load duration'+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) +' seconds';


----------------------------------------------------------------

		/*3.sales details*/

		print'........................................'
		print'Loading data into bronze.crm_sales_details'
		print'----------------------------------------'

		print'>> truncating table bronze.crm_sales_details'
		truncate table bronze.crm_sales_details;

		print'>> inserting data into bronze.crm_sales_details'
		
		set @start_time = getdate();
		bulk insert bronze.crm_sales_details
		from 'C:\Users\ASUS\Desktop\me\SQL\MySQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with(
			firstrow = 2,
			fieldterminator=',',
			tablock
		);

		set @end_time = getdate();
		print'>> load duration'+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) +' seconds';

----------------------------------------------------------------



	PRINT '=====================================';
	PRINT 'Loading ERP Tables';
	PRINT '=====================================';

		/* 4. CAT*/

		print'....................................'
		print'Loading data into bronze.erp_px_cat_g1v2'
		print'------------------------------------'

		print'>> truncating table bronze.erp_px_cat_g1v2'
		truncate table bronze.erp_px_cat_g1v2;

		print'>> inserting data into bronze.erp_px_cat_g1v2'

		SET @start_time = GETDATE();
		bulk insert bronze.erp_px_cat_g1v2
		from 'C:\Users\ASUS\Desktop\me\SQL\MySQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with(
			firstrow = 2,
			fieldterminator=',',
			tablock
		);

		SET @end_time = GETDATE();
		print'>> load duration'+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) +' seconds';
		
----------------------------------------------------------------

		/*5.CUST*/

		print'.....................................'
		print'Loading data into bronze.erp_cust_az12'
		print'-------------------------------------'

		print'>>truncating table bronze.erp_cust_az12'
		truncate table bronze.erp_cust_az12;

		print'>>inserting data into bronze.erp_cust_az12'
		
		set @start_time = getdate();
		bulk insert bronze.erp_cust_az12
		from'C:\Users\ASUS\Desktop\me\SQL\MySQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with(
			firstrow = 2,
			fieldterminator=',',
			tablock
		);

		set @end_time = getdate();
		print'>> load duration'+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) +' seconds';

----------------------------------------------------------------

		/*6. LOC*/

		print'.......................................'
		print'Loading data into bronze.erp_loc_a101'
		print'----------------------------------------'

		print'>>truncating table bronze.erp_loc_a101'
		truncate table bronze.erp_loc_a101;

		print'>>inserting data into bronze.erp_loc_a101'
		
		set @start_time = getdate();
		bulk insert bronze.erp_loc_a101
		from 'C:\Users\ASUS\Desktop\me\SQL\MySQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with(
			firstrow = 2,
			fieldterminator=',',
			tablock
		);

		set @end_time = getdate();
		print'>> load duration'+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) +' seconds';
		print'.......................................'

		SET @batch_end_time = GETDATE();

			PRINT '=====================================';
			PRINT 'Bronze Layer Loading Completed';
			PRINT 'Total Batch Duration: '
				  + CAST(DATEDIFF(SECOND,
								  @batch_start_time,
								  @batch_end_time) AS VARCHAR(10))
								  + ' seconds';


	end try
begin catch
	print'==============================='
	print'Error Occured while loading data into bronze tables'
	print'error number: ' + cast(error_number() as varchar(10));
	print'error message: ' + error_message();
	print'error number: ' + cast(error_state() as varchar(10));


	print'==============================='

end catch

end


/* USED TO EXECUTE THE WHOLE PRODECURE AT ONCE*/
exec bronze.load_bronze
/* to acces the procedure we can use the following command*/
execute bronze.load_bronze

-- use the following command to check the data in the tables
/*
select*
from bronze.erp_loc_a101;

select count(*) from bronze.erp_loc_a101*/
-- to check the data in the tables we can use the following command
--SELECT DB_NAME() AS current_database;

--track etl duration
-- helps to identify bottlenecks, optimize performance, and ensure timely data availability for analysis and reporting.
