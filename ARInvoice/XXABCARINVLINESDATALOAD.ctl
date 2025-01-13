LOAD DATA
INFILE '/oraAS/oracle/VIS/apps/apps_st/appl/fnd/12.0.0/bin/XXABC_INV_LINES_DATA.csv'
TRUNCATE INTO TABLE XXABC_AR_INV_LINES_STG
FIELDS TERMINATED BY','
OPTIONALLY ENCLOSED BY'"'
TRAILING NULLCOLS
(
trx_header_id       ,
trx_line_id,
line_number,
inventory_item_id    ,
description ,
quantity_invoiced             ,
unit_selling_price     ,
uom_code          ,
line_type     ,
STATUS       
)
 