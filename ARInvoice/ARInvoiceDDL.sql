CREATE TABLE XXABC_AR_INV_LINES_STG
  (
    trx_header_id NUMBER,
	trx_line_id   NUMBER,
	line_number   NUMBER,
	inventory_item_id  NUMBER,
	description VARCHAR2(400),
	quantity_invoiced NUMBER,
	unit_selling_price NUMBER,
	uom_code VARCHAR2(15),
	line_type VARCHAR2(10), 
	 
    RECORD_NUM          NUMBER,
    STATUS              VARCHAR2(10),
    ERROR_MSG           VARCHAR2(300)
  ); 