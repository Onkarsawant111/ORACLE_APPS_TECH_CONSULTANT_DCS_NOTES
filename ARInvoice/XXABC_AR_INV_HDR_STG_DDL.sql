CREATE TABLE XXABC_AR_INV_HDR_STG
  (
    trx_header_id       NUMBER,
    trx_number          VARCHAR2(20) DEFAULT NULL,
    trx_date            DATE DEFAULT NULL,
    trx_currency        VARCHAR2(30) DEFAULT NULL,
    cust_trx_type_id    NUMBER DEFAULT NULL,
    bill_to_customer_id NUMBER DEFAULT NULL,
    term_id             NUMBER DEFAULT NULL,
    finance_charges     VARCHAR2(1) DEFAULT NULL,
    status_trx          VARCHAR2(30) DEFAULT NULL,
    printing_option     VARCHAR2(20) DEFAULT NULL,
    RECORD_NUM          NUMBER,
    STATUS              VARCHAR2(10),
    ERROR_MSG           VARCHAR2(300)
  ); 