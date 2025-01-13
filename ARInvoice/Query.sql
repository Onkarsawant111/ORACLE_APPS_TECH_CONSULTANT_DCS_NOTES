--Sample Data for header
SELECT  
  trx_number,
  trx_date,
  cust_trx_type_id,
  bill_to_customer_id,
  term_id,
  finance_charges,
  status_trx,
  printing_option 
FROM ra_customer_trx_all
where rownum < 5
;

--delete from XXABC_AR_INV_HDR_STG;
--delete from XXABC_AR_INV_LINES_STG; 

select * from XXABC_AR_INV_LINES_STG; 

 SELECT * FROM XXABC_AR_INV_HDR_STG ;
 
 select * from ra_customer_trx_all order by creation_date desc; 
 
 select * from ra_customer_trx_lines_all order by creation_date desc;
 
 
 