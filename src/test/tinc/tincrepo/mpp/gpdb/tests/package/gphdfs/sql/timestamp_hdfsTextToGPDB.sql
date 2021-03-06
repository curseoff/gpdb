\echo --start_ignore
drop external table timestamp_heap;
drop external table timestamp_readhdfs_mapreduce;
drop external table timestamp_readhdfs_mapred;
drop external table timestamp_readhdfs_mapreduce_blockcomp;
drop external table timestamp_readhdfs_mapreduce_recordcomp;
drop external table timestamp_readhdfs_mapred_blockcomp;
drop external table timestamp_readhdfs_mapred_recordcomp;
\echo --end_ignore

create readable external table timestamp_heap(datatype_timestamp varchar,xcount_timestamp bigint, col1_timestamp timestamp,col2_timestamp timestamp, col3_timestamp timestamp, nullcol_timestamp timestamp) location ('gpfdist://%localhost%:%gpfdistPort%/timestamp.txt')format 'TEXT';

\!%cmdstr% -DcompressionType=none javaclasses/TestHadoopIntegration mapreduce Mapreduce_mapper_TextIn /plaintext/timestamp.txt /mapreduce/timestamp 
create readable external table timestamp_readhdfs_mapreduce(like timestamp_heap) location ('gphdfs://%HADOOP_HOST%/mapreduce/timestamp')format 'custom' (formatter='gphdfs_import');

\!%cmdstr% -DcompressionType=none javaclasses/TestHadoopIntegration mapred Mapred_mapper_TextIn /plaintext/timestamp.txt /mapred/timestamp
create readable external table timestamp_readhdfs_mapred(like timestamp_readhdfs_mapreduce) location ('gphdfs://%HADOOP_HOST%/mapred/timestamp')format 'custom' (formatter='gphdfs_import');

select count(*) from timestamp_readhdfs_mapreduce;
select count(*) from timestamp_readhdfs_mapred;

select * from timestamp_readhdfs_mapreduce order by xcount_timestamp limit 10;
select * from timestamp_readhdfs_mapred order by xcount_timestamp limit 10;

(select * from timestamp_readhdfs_mapreduce except select * from timestamp_readhdfs_mapred) union (select * from timestamp_readhdfs_mapred except select * from timestamp_readhdfs_mapreduce);

\!%cmdstr% -DcompressionType=block javaclasses/TestHadoopIntegration mapreduce Mapreduce_mapper_TextIn /plaintext/timestamp.txt /mapreduce/blockcomp/timestamp
create readable external table timestamp_readhdfs_mapreduce_blockcomp(like timestamp_readhdfs_mapreduce) location ('gphdfs://%HADOOP_HOST%/mapreduce/blockcomp/timestamp')format 'custom' (formatter='gphdfs_import');

\!%cmdstr% -DcompressionType=block javaclasses/TestHadoopIntegration mapred Mapred_mapper_TextIn /plaintext/timestamp.txt /mapred/blockcomp/timestamp
create readable external table timestamp_readhdfs_mapred_blockcomp(like timestamp_readhdfs_mapreduce) location ('gphdfs://%HADOOP_HOST%/mapred/blockcomp/timestamp')format 'custom' (formatter='gphdfs_import');


(select * from timestamp_readhdfs_mapreduce_blockcomp except select * from timestamp_readhdfs_mapred_blockcomp) union (select * from timestamp_readhdfs_mapred_blockcomp except select * from timestamp_readhdfs_mapreduce_blockcomp);

\!%cmdstr% -DcompressionType=record javaclasses/TestHadoopIntegration mapreduce Mapreduce_mapper_TextIn /plaintext/timestamp.txt /mapreduce/recordcomp/timestamp
create readable external table timestamp_readhdfs_mapreduce_recordcomp(like timestamp_readhdfs_mapreduce) location ('gphdfs://%HADOOP_HOST%/mapreduce/recordcomp/timestamp')format 'custom' (formatter='gphdfs_import');

\!%cmdstr% -DcompressionType=record javaclasses/TestHadoopIntegration mapred Mapred_mapper_TextIn /plaintext/timestamp.txt /mapred/recordcomp/timestamp
create readable external table timestamp_readhdfs_mapred_recordcomp(like timestamp_readhdfs_mapreduce) location ('gphdfs://%HADOOP_HOST%/mapred/recordcomp/timestamp')format 'custom' (formatter='gphdfs_import');


(select * from timestamp_readhdfs_mapreduce_recordcomp except select * from timestamp_readhdfs_mapred_recordcomp) union (select * from timestamp_readhdfs_mapred_recordcomp except select * from timestamp_readhdfs_mapreduce_recordcomp);

(select * from timestamp_readhdfs_mapreduce_recordcomp except select * from timestamp_readhdfs_mapred_blockcomp) union (select * from timestamp_readhdfs_mapred_blockcomp except select * from timestamp_readhdfs_mapreduce_recordcomp);

(select * from timestamp_readhdfs_mapreduce except select * from timestamp_readhdfs_mapred_recordcomp) union (select * from timestamp_readhdfs_mapred_recordcomp except select * from timestamp_readhdfs_mapreduce);

(select * from timestamp_readhdfs_mapreduce except select * from timestamp_heap) union (select * from timestamp_heap except select * from timestamp_readhdfs_mapreduce);


