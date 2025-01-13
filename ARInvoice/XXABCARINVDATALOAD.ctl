LOAD DATA
INFILE '/oraAS/oracle/VIS/apps/apps_st/appl/fnd/12.0.0/bin/XXABC_INV_HDR_DATA.csv'
TRUNCATE INTO TABLE XXABC_AR_INV_HDR_STG
FIELDS TERMINATED BY','
OPTIONALLY ENCLOSED BY'"'
TRAILING NULLCOLS
(
trx_header_id       ,
trx_currency        ,
cust_trx_type_id    ,
bill_to_customer_id ,
term_id             ,
finance_charges     ,
status_trx          ,
printing_option     ,
trx_date          SYSDATE  ,
RECORD_NUM         SEQUENCE(MAX,1) ,
STATUS       
)