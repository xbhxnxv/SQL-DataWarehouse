/*
--------------------------------------------------------------------------
DDL Script: Create Bronze Tables
--------------------------------------------------------------------------

Script Purpose:
This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
Run this script to re-define the DDL structure of 'bronze' Tables
--------------------------------------------------------------------------
*/
if object_id ('bronze.crm_cust_info','u') is not null
	drop table bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR (50),
	cst_lastname NVARCHAR (50),
	cst_material_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
go

if object_id('bronze.crm_prd_info','u') is not null
	drop table bronze.crm_prd_info;
go
create table bronze.crm_prd_info (
	prd_id			int,
	prd_key			nvarchar(50),
	prd_nm			nvarchar(50),
	prd_cost		int null,
	prd_line		nvarchar(50),
	prd_start_dt	datetime,
	prd_end_dt		datetime null
);
go


if object_id ('bronze.crm_sales_details','u') is not null
	drop table bronze.crm_cust_info;

go
CREATE TABLE bronze.crm_sales_details (
	sls_ord_num		nvarchar (50),
	sls_prd_key		nvarchar (50),
	sls_cust_id		int,
	sls_order_dt	int,
	sls_ship_dt		int,
	sls_due_dt		int,
	sls_sales		int,
	sls_quantity	int,
	sls_price		int
);
go


if object_id ('bronze.erp_loc_a101','u') is not null
	drop table bronze.crm_cust_info;
go

create table bronze.erp_loc_a101(
cid		nvarchar(50),
cntry	nvarchar(50)
);
go

if object_id ('bronze.erp_cust_az12','u') is not null
	drop table bronze.crm_cust_info;

create table bronze.erp_cust_az12(
id		nvarchar(50),
bdate	date,
gen		nvarchar(50)
);
go

if object_id ('bronze.erp_cat_g1v2','u') is not null
	drop table bronze.crm_cust_info;

create table bronze.erp__cat_g1v2(
	id			nvarchar(50),
	cat			nvarchar(50),
	subcat		nvarchar(50),
	maintenance nvarchar(50)
);
