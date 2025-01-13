Create or replace package BODY XXABC_AR_INV_IMP_UTILS
 IS
  
--Method to validate staging data for AR Invoice  
   PROCEDURE VALIDATE_DATA 
   IS
     CURSOR C_HDR IS SELECT * FROM XXABC_AR_INV_HDR_STG_ONKAR ; 
     CURSOR C_LINES IS SELECT * FROM XXABC_AR_INV_LINES_STG_ONKAR ; 
   BEGIN
   --Validation for Header Data
       FOR REC IN C_HDR
       LOOP
       
     IF rec.trx_currency is null THEN
           UPDATE XXABC_AR_INV_HDR_STG_ONKAR 
           SET STATUS='E' , ERROR_MSG = ERROR_MSG ||' Invalid Curr'
           WHERE trx_header_id=rec.trx_header_id;
     END IF; 
       
     IF rec.term_id  is null THEN
           UPDATE XXABC_AR_INV_HDR_STG_ONKAR   
           SET STATUS='E' , ERROR_MSG = ERROR_MSG ||' Invalid Pay Terms'
           WHERE trx_header_id=rec.trx_header_id;
     END IF ; 
         
         
       END LOOP;
   
      --Validation for Lines Data
       FOR  REC IN C_LINES
       LOOP
          NULL ; 
       END LOOP;
       
   END VALIDATE_DATA; 
 
 --Method to invoke public API 
PROCEDURE IMPORT_DATA(ERRBUF  OUT VARCHAR2, RETCODE OUT VARCHAR2)
   IS
  L_HDR_ERR_CNT NUMBER;
  L_LINES_ERR_CNT NUMBER ; 
    
  l_return_status         varchar2(1);
  l_msg_count             number;
  l_msg_data              varchar2(2000);
  l_batch_source_rec     ar_invoice_api_pub.batch_source_rec_type;
  l_trx_header_tbl        ar_invoice_api_pub.trx_header_tbl_type;
  l_trx_lines_tbl         ar_invoice_api_pub.trx_line_tbl_type;
  l_trx_dist_tbl          ar_invoice_api_pub.trx_dist_tbl_type;
  l_trx_salescredits_tbl  ar_invoice_api_pub.trx_salescredits_tbl_type;
  
  l_cust_trx_id           number;
  l_customer_trx_id   number;
   l_cnt   number;
   l_err_msg varchar2(1000);
   l_inv_number VARCHAr2(50);
   l_line_cnt number;
   
   l_org_id number; 
   
      BEGIN
      --MO_GLOBAL.SET_POLICY_CONTEXT('S',204);
      
        --Call the validate data to validate staging table data
        VALIDATE_DATA; 
        
        SELECT COUNT(*) INTO L_HDR_ERR_CNT
        FROM XXABC_AR_INV_HDR_STG_ONKAR
         WHERE STATUS='E'; 
        
      SELECT COUNT(*) INTO L_LINES_ERR_CNT 
      FROM XXABC_AR_INV_LINES_STG_ONKAR
         WHERE STATUS='E'; 
         
         IF( L_HDR_ERR_CNT >0 or L_LINES_ERR_CNT >0 ) THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Issue with staging table data,
             Plese recheck and reload');
              retcode := 2;
              errbuf:= 'Data Issue Please Recheck';
              commit;
         END IF ; 
  
  --Populate Table Type Values
    --header data
    l_cnt := 1 ; 
  for rec in (select * from XXABC_AR_INV_HDR_STG_ONKAR) 
        LOOP
  l_batch_source_rec.batch_source_id := -1;
  l_trx_header_tbl(1).trx_header_id  :=  rec.trx_header_id;
  l_trx_header_tbl(1).trx_date       :=  sysdate;
  l_trx_header_tbl(1).trx_currency   :=  rec.trx_currency;
  l_trx_header_tbl(1).cust_trx_type_id :=  rec.cust_trx_type_id;
  l_trx_header_tbl(1).bill_to_customer_id := rec.bill_to_customer_id;
  l_trx_header_tbl(1).term_id    :=  rec.term_id;
  l_trx_header_tbl(1).finance_charges  :=  rec.finance_charges;
  l_trx_header_tbl(1).status_trx   :=  rec.status_trx;
  l_trx_header_tbl(1).printing_option :=  rec.printing_option;
 
 l_cnt :=l_cnt+1 ; 
      
    --lines data
   l_line_cnt :=1;
   
   for rec_lines in ( select * from XXABC_AR_INV_LINES_STG_ONKAR lines
     WHERE lines.trx_header_id=rec.trx_header_id) 
   LOOP
     l_trx_lines_tbl(l_line_cnt).trx_header_id :=  rec_lines.trx_header_id;
        l_trx_lines_tbl(l_line_cnt).trx_line_id   :=  rec_lines.trx_line_id;
       l_trx_lines_tbl(l_line_cnt).line_number   :=  rec_lines.line_number;
        l_trx_lines_tbl(l_line_cnt).inventory_item_id  := NULL;
        l_trx_lines_tbl(l_line_cnt).description :=  rec_lines.description;
       l_trx_lines_tbl(l_line_cnt).quantity_invoiced   :=  rec_lines.quantity_invoiced;
       l_trx_lines_tbl(l_line_cnt).unit_selling_price :=  rec_lines.unit_selling_price;   
       l_trx_lines_tbl(l_line_cnt).uom_code    :=  NULL;
       l_trx_lines_tbl(l_line_cnt).line_type   :=  rec_lines.line_type;
       l_line_cnt:=l_line_cnt+1;
   END LOOP; 
   
   --Invoking Public API
   
   --Here we call the API to create Invoice with the stored values

    AR_INVOICE_API_PUB.create_single_invoice(
    p_api_version           =>1.0,
    p_init_msg_list         =>NULL,
    p_commit                =>NULL,
    p_batch_source_rec      => l_batch_source_rec,
    p_trx_header_tbl        => l_trx_header_tbl,
    p_trx_lines_tbl         => l_trx_lines_tbl,
    p_trx_dist_tbl          => l_trx_dist_tbl,
    p_trx_salescredits_tbl  => l_trx_salescredits_tbl,
    x_customer_trx_id       => l_customer_trx_id,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data); 
   
    fnd_file.put_line(fnd_file.log,'Created:'||l_msg_data||l_return_status);
 
   SELECT count(*)
Into      l_cnt
From ar_trx_errors_gt;

IF l_cnt = 0
THEN
    BEGIN
        SELECT trx_number INTO l_inv_number 
        FROM ra_customer_trx_all 
        WHERE customer_trx_id=l_customer_trx_id;
    EXCEPTION
    WHEN OTHERS THEN 
    NULL;
    END;
 END IF ; 
 
    fnd_file.put_line(fnd_file.log, 'Customer Trx NUmber '|| l_inv_number);  
    
    IF l_return_status = fnd_api.g_ret_sts_error OR
       l_return_status = fnd_api.g_ret_sts_unexp_error THEN

      fnd_file.put_line(fnd_file.log,':'||l_return_status||':'||sqlerrm);
    Else
        dbms_output.put_line(''||l_return_status||':'||sqlerrm);
        If (ar_invoice_api_pub.g_api_outputs.batch_id IS NOT NULL) Then
            fnd_file.put_line(fnd_file.log,'Invoice(s) suceessfully created!') ;
            fnd_file.put_line(fnd_file.log,'Batch ID: ' || ar_invoice_api_pub.g_api_outputs.batch_id);
            fnd_file.put_line(fnd_file.log,'customer_trx_id: ' || l_cust_trx_id);
        Else
            fnd_file.put_line(fnd_file.log,''||sqlerrm);
        End If;
    end if;
 
 --Clear the data fom record 
  l_trx_lines_tbl.delete ; 
  
   END LOOP; 
   
    
   END IMPORT_DATA; 
   
   
  
 END XXABC_AR_INV_IMP_UTILS; 