CREATE OR REPLACE package  body XXABC_GL_INTERFACE_UTLS

is
PROCEDURE LOAD_GL_INTERFACE
 IS
 BEGIN
   
   insert into gl_interface 
   (      STATUS,       LEDGER_ID,       USER_JE_SOURCE_NAME,
      USER_JE_CATEGORY_NAME,       ACCOUNTING_DATE,       CURRENCY_CODE,
      DATE_CREATED,       CREATED_BY,    
      SEGMENT1,    SEGMENT2,       SEGMENT3,       SEGMENT4,      SEGMENT5,       
      ACTUAL_FLAG,  ENTERED_DR,       ENTERED_CR,       GROUP_ID         
) 
select       STATUS,       LEDGER_ID,       USER_JE_SOURCE_NAME,
      USER_JE_CATEGORY_NAME,       ACCOUNTING_DATE,       CURRENCY_CODE,
      DATE_CREATED,       CREATED_BY,    
      SEGMENT1,    SEGMENT2,       SEGMENT3,       SEGMENT4,      SEGMENT5,       
      ACTUAL_FLAG,  ENTERED_DR,       ENTERED_CR,       GROUP_ID         
 from XXABC_GL_INTF_STG
 WHERE VALIDATION_STATUS IS NULL;
   
   UPDATE XXABC_GL_INTF_STG
   SET VALIDATION_STATUS='P'
   ;
   
   COMMIT;
   
   
 END LOAD_GL_INTERFACE;
 
PROCEDURE IMPORT_JOURNAL_PROC
(
    errbuf  VARCHAR2,
    retcode VARCHAR2 ) 
IS 
   l_conc_id          NUMBER;
   l_int_run_id       NUMBER;
   l_access_set_id    NUMBER;
   l_org_id           NUMBER := fnd_profile.value('ORG_ID');
   l_sob_id           NUMBER := fnd_profile.value('GL_SET_OF_BKS_ID'); --LEDGER_ID
   l_user_id          NUMBER := fnd_profile.value('USER_ID');
   l_resp_id          NUMBER := fnd_profile.value('RESP_ID');
   l_resp_app_id      NUMBER := fnd_profile.value('RESP_APPL_ID');
 

BEGIN

 --CALL Load GL Interface to load into GL_INTERFACE table
 
 LOAD_GL_INTERFACE();
 
   fnd_global.apps_initialize
   (
      user_id       => l_user_id       --User Id
      ,resp_id      => l_resp_id       --Responsibility Id
      ,resp_appl_id => l_resp_app_id   --Responsibility Application Id
   );
 
   mo_global.set_policy_context('S',l_org_id);
 
   SELECT   gl_journal_import_s.NEXTVAL
     INTO   l_int_run_id
     FROM   dual;
 
   SELECT   access_set_id
   INTO   l_access_set_id
     FROM   gl_access_sets
    WHERE   name = 'Vision Operations (USA)' ;
 
   INSERT INTO gl_interface_control
   (
      je_source_name
      ,interface_run_id
      ,status
      ,set_of_books_id
      ,group_id
   )
   VALUES
   (
      'Manual'
      ,l_int_run_id
      ,'S'
      ,l_sob_id
      ,12345
   );
  
  commit;
  
   l_conc_id := fnd_request.submit_request
                   ( application   => 'SQLGL'
                    ,program       => 'GLLEZL'
                    ,description   => NULL
                    ,start_time    => SYSDATE
                    ,sub_request   => FALSE
                    ,argument1     => l_int_run_id    --interface run id
                    ,argument2     => l_access_set_id --data access set_id
                    ,argument3     => 'N'             --post to suspense
                    ,argument4     => NULL            --from date
                    ,argument5     => NULL            --to date
                    ,argument6     => 'N'             --summary mode
                    ,argument7     => 'N'             --import DFF
                    ,argument8     => 'Y'             --backward mode
                   );
 
   COMMIT;
 
   fnd_file.PUT_LINE(fnd_file.log,'GL Import Submitted. Request Id : '||l_conc_id);
 
EXCEPTION
   WHEN OTHERS THEN
 
   fnd_file.PUT_LINE(fnd_file.log,'Error while submitting the GL Import Program.');
   fnd_file.PUT_LINE(fnd_file.log,'Error : '||SQLCODE||'-'||SUBSTR(SQLERRM,1,200));
END IMPORT_JOURNAL_PROC;



END XXABC_GL_INTERFACE_UTLS; 
/
EXIT;