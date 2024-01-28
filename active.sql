drop table if exists unspent;
create temporary table unspent as
select txid, txix
  from marlowe.contracttxout
except
select txoutid, txoutix
  from chain.txin
;

drop table if exists active;
create temporary table active as
select encode(txid, 'hex') || '#' || cast(txix as varchar)
  from marlowe.createtxout
  inner join unspent
    using (txid, txix)
union
select encode(createtxid, 'hex') || '#' || cast(createtxix as varchar)
  from marlowe.applytx
  inner join unspent
    on (applytx.txid, applytx.outputtxix) = (unspent.txid, unspent.txix)
order by 1
;

select count(*) from marlowe.createtxout;
select count(*) from active;

\copy active to active.list
