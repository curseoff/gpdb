\echo --start_ignore
drop external table domaintype_write_error;
drop external table domaintype_write;
drop external table readcty;
drop table errortable;
drop domain country_code CASCADE;
\echo --end_ignore

CREATE DOMAIN country_code char(2) NOT NULL;

create writable external table domaintype_write(id INT4, country country_code)location ('gphdfs://%HDFSaddr%/extwrite/domainDataType')format 'custom' (formatter='gphdfs_export');
insert into domaintype_write values (1,'US');
insert into domaintype_write values (2,'CH');
insert into domaintype_write values (3,'HK');
create readable external table readcty(id INT4, country country_code)location ('gphdfs://%HDFSaddr%/extwrite/domainDataType')format 'custom' (formatter='gphdfs_import') log errors into errortable segment reject limit 100;
select * from readcty order by id;

create writable external table domaintype_write_error(id INT4, text text)location ('gphdfs://%HDFSaddr%/extwrite/domainDataType')format 'custom' (formatter='gphdfs_export');
insert into domaintype_write_error values (3,'aaa');
select * from readcty order by id;

select relname,linenum,bytenum,errmsg,rawdata,rawbytes from errortable;
