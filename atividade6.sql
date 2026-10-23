create table pedidos(
 id serial primary key,
 cliente varchar(200) not null,
 valor_total numeric(10, 2) not null default 0.00,
 data_criacao timestamp default current_timestamp
 );

 create table itens_pedido(
 id serial primary key,
 pedido_id int references pedidos(id),
 produto_nome varchar(200) not null,
 quantidade int not null,
 preco_unitario numeric(10, 2) not null
 );

 create or replace function fn_recalcula_total_pedido()
 returns trigger as $$
 declare 
 v_pedido_id INT;
 begin
 if
 (tg_op = 'delete') then
 v_pedido_id := old.pedido_id;
 else
 v_pedido_id := new.pedido_id;
 end if;
     update pedidos 
 set valor_total = coalesce((
 select sum(quantidade * preco_unitario)
 from itens_pedido
 where pedido_id = v_pedido_Id
 ), 0.00)
 where id = v_pedido_id;

 if (tg_op = 'delte') then
 return old;
 end if;
 return new;
 end;
 $$ language plpgsql;

 create trigger trg_atualiza_total_pedido
 after insert or update or delete on itens_pedido
 for each row
 execute function fn_recalcula_total_pedido();