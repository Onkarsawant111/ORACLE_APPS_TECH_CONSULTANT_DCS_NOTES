 --CREATE TABLE XXABC_GL_INTF_STG  as select * from gl_interface ; 
--update gl_interface 
--set user_je_source_name='Manual'
--;
select * from XXABC_GL_INTF_STG; 
--
--alter table XXABC_GL_INTF_STG  add (validation_status varchar2(5));

select * from XXABC_GL_INTF_STG; 


delete from XXABC_GL_INTF_STG; 
delete from gl_interface ; 

select * from gl_interface ; 

select * from XXABC_GL_INTF_STG; 
 

select * from gl_je_headers order by 1 desc;

insert into gl_interface select * from XXABC_GL_INTF_STG ; 
 
select * from gl_ledgers order by ledger_id ;
 
select * from gl_interface_control where je_source_name='Manual'; 

select * from gl_access_set_ledgers where ledger_id =1; 



select * from gl_interface_control where interface_Table_name='GL_INTERFACE'
and interface_Table_name is not null; 
