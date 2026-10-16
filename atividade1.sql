
CREATE TABLE IF NOT EXISTS estoque (
    id SERIAL PRIMARY KEY,
    nome_item VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL DEFAULT 0
);


CREATE OR REPLACE FUNCTION fn_valida_estoque_minimo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantidade < 0 THEN
        RAISE EXCEPTION 'Operação cancelada! O item "%" não pode ter estoque negativo (Tentativa: % unidade(s)).', 
            NEW.nome_item, NEW.quantidade;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_valida_estoque ON estoque;

CREATE TRIGGER trg_valida_estoque
BEFORE INSERT OR UPDATE ON estoque
FOR EACH ROW
EXECUTE FUNCTION fn_valida_estoque_minimo();



INSERT INTO estoque (nome_item, quantidade) VALUES ('Teclado Mecânico', 10);

INSERT INTO estoque (nome_item, quantidade) VALUES ('Mouse Óptico', 0);

UPDATE estoque SET quantidade = 5 WHERE nome_item = 'Teclado Mecânico';

UPDATE estoque SET quantidade = -2 WHERE nome_item = 'Teclado Mecânico';

