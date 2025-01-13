DECLARE
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

BEGIN
       
  begin
    MO_GLOBAL.SET_POLICY_CONTEXT('S',204);
  end;
       
 fnd_global.apps_initialize(1318,50559,222);

  l_batch_source_rec.batch_source_id := -1;
  l_trx_header_tbl(1).trx_header_id  :=  9898;
  l_trx_header_tbl(1).trx_date       :=  sysdate;
  l_trx_header_tbl(1).trx_currency   :=  'USD';
  l_trx_header_tbl(1).cust_trx_type_id :=  1563;
  l_trx_header_tbl(1).bill_to_customer_id := 3347;
  l_trx_header_tbl(1).term_id    :=  1062;
  l_trx_header_tbl(1).finance_charges  :=  'N';
  l_trx_header_tbl(1).status_trx   :=  'OP';
  l_trx_header_tbl(1).printing_option :=  'NOT';
  --l_trx_header_tbl(1).reference_number :=  '1111';
  
  
  l_trx_lines_tbl(1).trx_header_id :=  9898;
  l_trx_lines_tbl(1).trx_line_id   :=  101;
 l_trx_lines_tbl(1).line_number   :=  1;
  l_trx_lines_tbl(1).inventory_item_id  := NULL;
  l_trx_lines_tbl(1).description :=  'Test Single Invoice Sreeram';
 l_trx_lines_tbl(1).quantity_invoiced   :=  3;
 l_trx_lines_tbl(1).unit_selling_price :=  10000;   
 l_trx_lines_tbl(1).uom_code    :=  NULL;
 l_trx_lines_tbl(1).line_type   :=  'LINE';
 
       
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
   
    dbms_output.put_line('Created:'||l_msg_data||l_return_status);

    IF l_return_status = fnd_api.g_ret_sts_error OR
       l_return_status = fnd_api.g_ret_sts_unexp_error THEN

        dbms_output.put_line(':'||l_return_status||':'||sqlerrm);
    Else
        dbms_output.put_line(''||l_return_status||':'||sqlerrm);
        If (ar_invoice_api_pub.g_api_outputs.batch_id IS NOT NULL) Then
            Dbms_output.put_line('Invoice(s) suceessfully created!') ;
            Dbms_output.put_line('Batch ID: ' || ar_invoice_api_pub.g_api_outputs.batch_id);
            Dbms_output.put_line('customer_trx_id: ' || l_cust_trx_id);
        Else
            Dbms_output.put_line(''||sqlerrm);
        End If;
    end if;
    

    
     IF l_return_status = fnd_api.g_ret_sts_error OR 
     l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    dbms_output.put_line('unexpected errors found!');
  ELSE
  
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

dbms_output.put_line ( 'Customer Trx id '|| l_customer_trx_id);     
dbms_output.put_line ( 'Customer Trx NUmber '|| l_inv_number);     
ELSE
select ERROR_MESSAGE 
into  l_err_msg
 from ar_trx_errors_gt where rownum=1;
dbms_output.put_line ( 'Transaction not Created, Please check ar_trx_errors_gt table :'||l_cnt||'  Error message:'|| l_err_msg); 
    
 END IF;
END IF;
       commit; 
End;

