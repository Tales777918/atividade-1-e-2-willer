CREATE TABLE IF NOT EXISTS contas (
    id SERIAL PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    saldo NUMERIC(10, 2) NOT NULL DEFAULT 0.00
);

CREATE TABLE IF NOT EXISTS movimentacoes (
    id SERIAL PRIMARY KEY,
    conta_id INT NOT NULL REFERENCES contas(id) ON DELETE CASCADE,
    tipo VARCHAR(1) NOT NULL CHECK (tipo IN ('C', 'D')),
    valor NUMERIC(10, 2) NOT NULL CHECK (valor > 0),
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_atualiza_saldo_conta()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo = 'C' THEN
        UPDATE contas 
        SET saldo = saldo + NEW.valor 
        WHERE id = NEW.conta_id;
    ELSIF NEW.tipo = 'D' THEN
        UPDATE contas 
        SET saldo = saldo - NEW.valor 
        WHERE id = NEW.conta_id;
    END IF;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'A conta com ID % não foi encontrada.', NEW.conta_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_atualiza_saldo ON movimentacoes;

CREATE TRIGGER trg_atualiza_saldo
AFTER INSERT ON movimentacoes
FOR EACH ROW
EXECUTE FUNCTION fn_atualiza_saldo_conta();




INSERT INTO contas (cliente, saldo) VALUES ('João Silva', 500.00);

INSERT INTO movimentacoes (conta_id, tipo, valor) VALUES (1, 'D', 150.00);

INSERT INTO movimentacoes (conta_id, tipo, valor) VALUES (1, 'C', 200.00);

SELECT * FROM contas WHERE id = 1;


SELECT * FROM movimentacoes WHERE conta_id = 1 ORDER BY data_movimentacao ASC;