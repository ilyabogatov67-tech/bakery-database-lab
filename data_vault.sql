-- ============================================================
-- Лабораторная работа: база данных хлебокомбината
-- Модель: Data Vault
-- СУБД: PostgreSQL
-- ============================================================

CREATE SCHEMA IF NOT EXISTS data_vault;

-- HUB
CREATE TABLE data_vault.hub_customer (
    customer_hk CHAR(32) PRIMARY KEY,
    customer_bk VARCHAR(50) NOT NULL UNIQUE,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);
COMMENT ON TABLE data_vault.hub_customer IS 'Hub клиентов. Хранит бизнес-ключ клиента.';

CREATE TABLE data_vault.hub_employee (
    employee_hk CHAR(32) PRIMARY KEY,
    employee_bk VARCHAR(50) NOT NULL UNIQUE,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);
COMMENT ON TABLE data_vault.hub_employee IS 'Hub сотрудников. Хранит бизнес-ключ сотрудника.';

CREATE TABLE data_vault.hub_product (
    product_hk CHAR(32) PRIMARY KEY,
    product_code VARCHAR(30) NOT NULL UNIQUE,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);
COMMENT ON TABLE data_vault.hub_product IS 'Hub продукции. Хранит бизнес-ключ продукции.';

CREATE TABLE data_vault.hub_request (
    request_hk CHAR(32) PRIMARY KEY,
    request_number VARCHAR(30) NOT NULL UNIQUE,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL
);
COMMENT ON TABLE data_vault.hub_request IS 'Hub заявок. Хранит бизнес-ключ заявки.';

-- LINK
CREATE TABLE data_vault.link_request_customer (
    request_customer_hk CHAR(32) PRIMARY KEY,
    request_hk CHAR(32) NOT NULL,
    customer_hk CHAR(32) NOT NULL,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT fk_lrc_request FOREIGN KEY (request_hk) REFERENCES data_vault.hub_request(request_hk),
    CONSTRAINT fk_lrc_customer FOREIGN KEY (customer_hk) REFERENCES data_vault.hub_customer(customer_hk),
    CONSTRAINT uq_link_request_customer UNIQUE (request_hk, customer_hk)
);
COMMENT ON TABLE data_vault.link_request_customer IS 'Связь между заявкой и клиентом.';

CREATE TABLE data_vault.link_request_employee (
    request_employee_hk CHAR(32) PRIMARY KEY,
    request_hk CHAR(32) NOT NULL,
    employee_hk CHAR(32) NOT NULL,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT fk_lre_request FOREIGN KEY (request_hk) REFERENCES data_vault.hub_request(request_hk),
    CONSTRAINT fk_lre_employee FOREIGN KEY (employee_hk) REFERENCES data_vault.hub_employee(employee_hk),
    CONSTRAINT uq_link_request_employee UNIQUE (request_hk, employee_hk)
);
COMMENT ON TABLE data_vault.link_request_employee IS 'Связь между заявкой и сотрудником.';

CREATE TABLE data_vault.link_request_product (
    request_product_hk CHAR(32) PRIMARY KEY,
    request_hk CHAR(32) NOT NULL,
    product_hk CHAR(32) NOT NULL,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(100) NOT NULL,
    CONSTRAINT fk_lrp_request FOREIGN KEY (request_hk) REFERENCES data_vault.hub_request(request_hk),
    CONSTRAINT fk_lrp_product FOREIGN KEY (product_hk) REFERENCES data_vault.hub_product(product_hk),
    CONSTRAINT uq_link_request_product UNIQUE (request_hk, product_hk)
);
COMMENT ON TABLE data_vault.link_request_product IS 'Связь между заявкой и продукцией.';

-- SATELLITE
CREATE TABLE data_vault.sat_customer (
    customer_hk CHAR(32) NOT NULL,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    load_end_datetime TIMESTAMP,
    customer_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(300),
    hash_diff CHAR(32),
    record_source VARCHAR(100) NOT NULL,
    PRIMARY KEY (customer_hk, load_datetime),
    CONSTRAINT fk_sat_customer FOREIGN KEY (customer_hk) REFERENCES data_vault.hub_customer(customer_hk)
);
COMMENT ON TABLE data_vault.sat_customer IS 'Описательные и исторические данные клиента.';

CREATE TABLE data_vault.sat_employee (
    employee_hk CHAR(32) NOT NULL,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    load_end_datetime TIMESTAMP,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    position_name VARCHAR(100),
    phone VARCHAR(20),
    hash_diff CHAR(32),
    record_source VARCHAR(100) NOT NULL,
    PRIMARY KEY (employee_hk, load_datetime),
    CONSTRAINT fk_sat_employee FOREIGN KEY (employee_hk) REFERENCES data_vault.hub_employee(employee_hk)
);
COMMENT ON TABLE data_vault.sat_employee IS 'Описательные и исторические данные сотрудника.';

CREATE TABLE data_vault.sat_product (
    product_hk CHAR(32) NOT NULL,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    load_end_datetime TIMESTAMP,
    product_name VARCHAR(200) NOT NULL,
    unit_name VARCHAR(50),
    current_price NUMERIC(12,2),
    is_active BOOLEAN,
    hash_diff CHAR(32),
    record_source VARCHAR(100) NOT NULL,
    PRIMARY KEY (product_hk, load_datetime),
    CONSTRAINT fk_sat_product FOREIGN KEY (product_hk) REFERENCES data_vault.hub_product(product_hk)
);
COMMENT ON TABLE data_vault.sat_product IS 'Описательные и исторические данные продукции.';

CREATE TABLE data_vault.sat_request (
    request_hk CHAR(32) NOT NULL,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    load_end_datetime TIMESTAMP,
    request_date TIMESTAMP NOT NULL,
    delivery_date DATE,
    delivery_address VARCHAR(300),
    request_status VARCHAR(50),
    comment_text TEXT,
    hash_diff CHAR(32),
    record_source VARCHAR(100) NOT NULL,
    PRIMARY KEY (request_hk, load_datetime),
    CONSTRAINT fk_sat_request FOREIGN KEY (request_hk) REFERENCES data_vault.hub_request(request_hk)
);
COMMENT ON TABLE data_vault.sat_request IS 'Описательные и исторические данные заявки.';

CREATE TABLE data_vault.sat_request_product (
    request_product_hk CHAR(32) NOT NULL,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    load_end_datetime TIMESTAMP,
    quantity NUMERIC(12,3) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    hash_diff CHAR(32),
    record_source VARCHAR(100) NOT NULL,
    PRIMARY KEY (request_product_hk, load_datetime),
    CONSTRAINT fk_sat_request_product FOREIGN KEY (request_product_hk) REFERENCES data_vault.link_request_product(request_product_hk),
    CONSTRAINT chk_sat_request_product_quantity CHECK (quantity > 0),
    CONSTRAINT chk_sat_request_product_price CHECK (unit_price >= 0)
);
COMMENT ON TABLE data_vault.sat_request_product IS 'Исторические данные по количеству и цене продукции в заявке.';

-- Тестовые данные
INSERT INTO data_vault.hub_customer (customer_hk, customer_bk, record_source)
VALUES (md5('7701234567'), '7701234567', 'ORDER_SYSTEM');

INSERT INTO data_vault.hub_request (request_hk, request_number, record_source)
VALUES (md5('REQ-2026-00001'), 'REQ-2026-00001', 'ORDER_SYSTEM');

INSERT INTO data_vault.link_request_customer (request_customer_hk, request_hk, customer_hk, record_source)
VALUES (
    md5(md5('REQ-2026-00001') || md5('7701234567')),
    md5('REQ-2026-00001'),
    md5('7701234567'),
    'ORDER_SYSTEM'
);

INSERT INTO data_vault.sat_customer (
    customer_hk, customer_name, phone, email, address, hash_diff, record_source
)
VALUES (
    md5('7701234567'),
    'ООО ХлебТорг',
    '+7 900 123-45-67',
    'info@hleb-torg.ru',
    'г. Москва, ул. Примерная, д. 10',
    md5('ООО ХлебТорг|+7 900 123-45-67|info@hleb-torg.ru'),
    'ORDER_SYSTEM'
);
