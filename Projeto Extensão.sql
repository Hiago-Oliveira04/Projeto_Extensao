-- Criação do banco de dados
CREATE DATABASE "CONTROLE DE ESTOQUE AUTO FILM";

-- Conectar-se ao banco de dados
\c "CONTROLE DE ESTOQUE AUTO FILM";

-- Criação da tabela de produtos
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    quantidade INTEGER NOT NULL DEFAULT 0  -- Quantidade em metros
);

-- Criação da tabela de transações de estoque
CREATE TABLE transacoes (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER REFERENCES produtos(id) ON DELETE CASCADE,
    tipo VARCHAR(10) CHECK (tipo IN ('entrada', 'saida')),
    quantidade INTEGER NOT NULL,  -- Quantidade em metros
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Função para atualizar a quantidade de produtos após cada saída
CREATE OR REPLACE FUNCTION atualizar_quantidade_apos_saida()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo = 'saida' THEN
        UPDATE produtos
        SET quantidade = quantidade - NEW.quantidade
        WHERE id = NEW.produto_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação do trigger associado à função
CREATE TRIGGER atualizar_quantidade_trigger
AFTER INSERT ON transacoes
FOR EACH ROW
EXECUTE FUNCTION atualizar_quantidade_apos_saida();

-- Inserção de produtos com quantidades específicas em metros
INSERT INTO produtos (nome, descricao, quantidade)
VALUES 
    ('Película Térmica', 'Película térmica de alta qualidade, 120 metros', 120),
    ('Película de Controle Solar', 'Película para controle solar, 90 metros', 90),
    ('Película Estética', 'Película estética decorativa, 28 metros', 28);

-- Inserção de transações de entrada (em metros)
INSERT INTO transacoes (produto_id, tipo, quantidade)
VALUES
    (1, 'entrada', 50),   -- Película Térmica
    (2, 'entrada', 90),   -- Película de Controle Solar
    (3, 'entrada', 40);   -- Película Estética

-- Inserção de transações de saída (em metros)
INSERT INTO transacoes (produto_id, tipo, quantidade)
VALUES
    (1, 'saida', 10),    -- Película Térmica
    (2, 'saida', 58),    -- Película de Controle Solar 
    (3, 'saida', 5);     -- Película Estética

-- Consulta para verificar todos os produtos com saldo atual em metros
SELECT 
    p.id,
    p.nome,
    p.descricao,
    p.quantidade AS quantidade_atual
FROM produtos p;
