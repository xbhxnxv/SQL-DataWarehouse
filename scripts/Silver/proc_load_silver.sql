/*
--------------------------------------------------------------------------
Stored Procedure: Load Silver Layer (Bronze -> Silver)
--------------------------------------------------------------------------
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, Load) process to
  populate the 'silver' schema tables from the 'bronze' schema.
  Actions Performed:
    - Truncates the silver tables before loading.
    - Inserts transformed and cleansed data from bronze into silver.
Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.
  Usage Example:
  EXEC silver.load_silver;
--------------------------------------------------------------------------
*/

create or alter procedure silver.load_silver as
begin
	DECLARE
		@start_time DATETIME2,
		@end_time DATETIME2,
		@batch_start_time DATETIME2,
		@batch_end_time DATETIME2;

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=====================================';
		PRINT 'Loading Silver Layer';
		PRINT '=====================================';

		PRINT '=====================================';
		PRINT 'Loading CRM Tables';
		PRINT '=====================================';

--------------------------------------------------------------

		/*1. CUSTOMER*/
		print'--------------------------------'
		print'Loading data into silver.crm_cust_info'
		print'--------------------------------'

		set @start_time = getdate();
		print'>> truncating table silver.crm_cust_info'
		truncate table silver.crm_cust_info;

		print'>> inserting data into silver.crm_cust_info'
		insert into silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		select
			cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,		-- remove leading/trailing spaces
			trim(cst_lastname)  as cst_lastname,
			case
				when upper(trim(cst_marital_status)) = 'S' then 'Single'
				when upper(trim(cst_marital_status)) = 'M' then 'Married'
				else 'n/a'
			end as cst_marital_status,					-- normalize marital status to readable values
			case
				when upper(trim(cst_gndr)) = 'F' then 'Female'
				when upper(trim(cst_gndr)) = 'M' then 'Male'
				else 'n/a'
			end as cst_gndr,							-- normalize gender to readable values
			cst_create_date
		from (
			select
				*,
				row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
			from bronze.crm_cust_info
			where cst_id is not null
		) t
		where flag_last = 1;							-- keep only the most recent record per customer
		set @end_time = getdate();
		PRINT '>> load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
		print'............................................................'

-------------------------------------------------------------

		/*2. PRODUCT*/
		print'------------------------------------'
		print'Loading data into silver.crm_prd_info'
		print'....................................'

		set @start_time = getdate();
		print'>> truncating table silver.crm_prd_info'
		truncate table silver.crm_prd_info;

		print'>> inserting data into silver.crm_prd_info'
		insert into silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		select
			prd_id,
			replace(substring(prd_key, 1, 5), '-', '_') as cat_id,	-- derive category id (matches erp_px_cat_g1v2.id)
			substring(prd_key, 7, len(prd_key))         as prd_key,	-- derive product key used to join sales
			prd_nm,
			isnull(prd_cost, 0) as prd_cost,						-- default missing cost to 0
			case
				when upper(trim(prd_line)) = 'M' then 'Mountain'
				when upper(trim(prd_line)) = 'R' then 'Road'
				when upper(trim(prd_line)) = 'S' then 'Other Sales'
				when upper(trim(prd_line)) = 'T' then 'Touring'
				else 'n/a'
			end as prd_line,										-- map product line codes to descriptive values
			cast(prd_start_dt as date) as prd_start_dt,
			cast(
				lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) - 1
				as date
			) as prd_end_dt											-- end date = day before the next version's start date
		from bronze.crm_prd_info;
		set @end_time = getdate();
		PRINT '>> load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
		print'............................................................'

----------------------------------------------------------------

		/*3. SALES DETAILS*/
		print'........................................'
		print'Loading data into silver.crm_sales_details'
		print'----------------------------------------'

		set @start_time = getdate();
		print'>> truncating table silver.crm_sales_details'
		truncate table silver.crm_sales_details;

		print'>> inserting data into silver.crm_sales_details'
		insert into silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		select
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case
				when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
				else cast(cast(sls_order_dt as varchar) as date)
			end as sls_order_dt,									-- convert integer yyyymmdd to date, invalid -> null
			case
				when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
				else cast(cast(sls_ship_dt as varchar) as date)
			end as sls_ship_dt,
			case
				when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
				else cast(cast(sls_due_dt as varchar) as date)
			end as sls_due_dt,
			case
				when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
					then sls_quantity * abs(sls_price)
				else sls_sales
			end as sls_sales,										-- recompute sales when missing or inconsistent
			sls_quantity,
			case
				when sls_price is null or sls_price <= 0
					then sls_sales / nullif(sls_quantity, 0)
				else sls_price
			end as sls_price										-- derive price when missing or invalid
		from bronze.crm_sales_details;
		set @end_time = getdate();
		PRINT '>> load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
		print'............................................................'

----------------------------------------------------------------

	PRINT '=====================================';
	PRINT 'Loading ERP Tables';
	PRINT '=====================================';

		/*4. ERP CUSTOMER*/
		print'.....................................'
		print'Loading data into silver.erp_cust_az12'
		print'-------------------------------------'

		set @start_time = getdate();
		print'>> truncating table silver.erp_cust_az12'
		truncate table silver.erp_cust_az12;

		print'>> inserting data into silver.erp_cust_az12'
		insert into silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		select
			case
				when cid like 'NAS%' then substring(cid, 4, len(cid))	-- strip 'NAS' prefix so cid matches crm cst_key
				else cid
			end as cid,
			case
				when bdate > getdate() then null						-- future birthdates are invalid
				else bdate
			end as bdate,
			case
				when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
				when upper(trim(gen)) in ('M', 'MALE') then 'Male'
				else 'n/a'
			end as gen												-- normalize gender values
		from bronze.erp_cust_az12;
		set @end_time = getdate();
		PRINT '>> load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
		print'............................................................'

----------------------------------------------------------------

		/*5. ERP LOCATION*/
		print'.......................................'
		print'Loading data into silver.erp_loc_a101'
		print'----------------------------------------'

		set @start_time = getdate();
		print'>> truncating table silver.erp_loc_a101'
		truncate table silver.erp_loc_a101;

		print'>> inserting data into silver.erp_loc_a101'
		insert into silver.erp_loc_a101 (
			cid,
			cntry
		)
		select
			replace(cid, '-', '') as cid,							-- normalize cid to match crm cst_key
			case
				when trim(cntry) = 'DE' then 'Germany'
				when trim(cntry) in ('US', 'USA') then 'United States'
				when trim(cntry) = '' or cntry is null then 'n/a'
				else trim(cntry)
			end as cntry											-- normalize / handle missing country codes
		from bronze.erp_loc_a101;
		set @end_time = getdate();
		PRINT '>> load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
		print'............................................................'

----------------------------------------------------------------

		/*6. ERP PRODUCT CATEGORY*/
		print'.......................................'
		print'Loading data into silver.erp_px_cat_g1v2'
		print'----------------------------------------'

		set @start_time = getdate();
		print'>> truncating table silver.erp_px_cat_g1v2'
		truncate table silver.erp_px_cat_g1v2;

		print'>> inserting data into silver.erp_px_cat_g1v2'
		insert into silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		select
			id,
			cat,
			subcat,
			maintenance											-- source already clean; loaded as-is
		from bronze.erp_px_cat_g1v2;
		set @end_time = getdate();
		PRINT '>> load duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR(10)) + ' seconds';
		print'............................................................'

		SET @batch_end_time = GETDATE();
		PRINT '=====================================';
		PRINT 'Silver Layer Loading Completed';
		PRINT 'Total Batch Duration: '
			  + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR(10))
			  + ' seconds';
		PRINT '=====================================';

	end try
begin catch
	print'==============================='
	print'Error Occured while loading data into silver tables'
	print'error number: ' + cast(error_number() as varchar(10));
	print'error message: ' + error_message();
	print'error state: ' + cast(error_state() as varchar(10));
	print'==============================='
end catch

end
go

/* Execute the procedure to load the silver layer */
exec silver.load_silver;
