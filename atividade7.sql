create table produtos(
 id serial primary key,
 nome varchar(100) not null,
 estoque_atual int not null
 );

 create table itens_venda(
 id serial primary key,
 produto_id int references produtos(id),
 quantidade_vendida int not null,
 data_venda timestamp default current_timestamp
 );


 create or replace function fn_processa_baixa_estoque()
 returns trigger as $$
 declare	
 v_estoque_atual int;
 v_nome_produto varchar(100);
 begin
 select estoque_atual, nome into v_estoque_atual, v_nome_produto
 from produtos
 where id = new.produto_id;

 if not found then
 raise exception 'produto com ID % não encontrado!', new.produto_id;
 end if;
 if v_estoque_atual < new.quantidade_vendida then
 raise exception 'estoque insuficiente para o produto "%". disponivel: %, solicitado: %',
 v_nome_produto, v_estoque_atual, new.quatidade_vendida;
 end if;

 update produtos
 set estoque_atual = estoque_atual - new.quantidade_vendida
 where id = new.produto_Id;
 return new;
 end;
 $$ language plpgsql;

 CREATE TRIGGER trg_baixa_estoque_venda
 BEFORE INSERT ON itens_venda
 FOR EACH ROW
 EXECUTE FUNCTION fn_processa_baixa_estoque();