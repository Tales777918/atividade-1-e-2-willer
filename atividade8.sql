 create table projetos(
id serial primary key,
nome_projeto varchar (200) not null,
status varchar(20) default 'em andamento' 

create table tarefas(
id serial primary key,
projeto_id int references projetos(id),
descricao varchar(200),
status varchar(200) default 'pendente'
);

create or replace function fn_cancelamento_projeto()
returns trigger as $$
begin
if  new.status = 'cancelado' and old.status is distinct from 'cancelado' then

update tarefas
set status = 'cancelada'
where produto_id = new.id and status = 'pendente';

end if;

return new;
end;
$$ language plpgsql;

create trigger trg_cancelamento_projeto_tarefa
after update on projetos
for each row
execute function fn_cancelamento_projeto()