-- ============================================================
-- Лабораторная работа: база данных хлебокомбината
-- Модель: 3NF
-- СУБД: PostgreSQL
-- ============================================================

CREATE TABLE units (
    unit_id SERIAL PRIMARY KEY,
    unit_name VARCHAR(50) NOT NULL,
    short_name VARCHAR(10) NOT NULL UNIQUE
);
COMMENT ON TABLE units IS 'Справочник единиц измерения продукции хлебокомбината.';

CREATE TABLE customers (
    customer_id BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    inn VARCHAR(12),
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(300),
    CONSTRAINT uq_customers_inn UNIQUE (inn)
);
COMMENT ON TABLE customers IS 'Клиенты хлебокомбината, оформляющие заявки на поставку продукции.';

CREATE TABLE employees (
    employee_id BIGSERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    position_name VARCHAR(100),
    phone VARCHAR(20)
);
COMMENT ON TABLE employees IS 'Сотрудники хлебокомбината, принимающие и обрабатывающие заявки.';

CREATE TABLE products (
    product_id BIGSERIAL PRIMARY KEY,
    product_code VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(200) NOT NULL,
    unit_id INTEGER NOT NULL,
    current_price NUMERIC(12,2) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_products_unit FOREIGN KEY (unit_id) REFERENCES units(unit_id),
    CONSTRAINT chk_product_price CHECK (current_price >= 0)
);
COMMENT ON TABLE products IS 'Справочник продукции, выпускаемой хлебокомбинатом.';

CREATE TABLE request_statuses (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE request_statuses IS 'Справочник возможных статусов заявки.';

CREATE TABLE requests (
    request_id BIGSERIAL PRIMARY KEY,
    request_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    status_id INTEGER NOT NULL,
    request_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivery_date DATE NOT NULL,
    delivery_address VARCHAR(300) NOT NULL,
    comment_text TEXT,
    CONSTRAINT fk_requests_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_requests_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_requests_status FOREIGN KEY (status_id) REFERENCES request_statuses(status_id),
    CONSTRAINT chk_delivery_date CHECK (delivery_date >= request_date::date)
);
COMMENT ON TABLE requests IS 'Заявки клиентов на поставку продукции хлебокомбината.';

CREATE TABLE request_items (
    request_item_id BIGSERIAL PRIMARY KEY,
    request_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity NUMERIC(12,3) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    CONSTRAINT fk_request_items_request FOREIGN KEY (request_id) REFERENCES requests(request_id) ON DELETE CASCADE,
    CONSTRAINT fk_request_items_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT chk_request_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_request_item_price CHECK (unit_price >= 0),
    CONSTRAINT uq_request_product UNIQUE (request_id, product_id)
);
COMMENT ON TABLE request_items IS 'Позиции заявок на поставку продукции.';

CREATE INDEX idx_products_unit ON products(unit_id);
CREATE INDEX idx_requests_customer ON requests(customer_id);
CREATE INDEX idx_requests_employee ON requests(employee_id);
CREATE INDEX idx_requests_status ON requests(status_id);
CREATE INDEX idx_request_items_request ON request_items(request_id);
CREATE INDEX idx_request_items_product ON request_items(product_id);

-- Тестовые данные
INSERT INTO units (unit_name, short_name) VALUES
('Штука', 'шт.'),
('Килограмм', 'кг'),
('Упаковка', 'уп.');

INSERT INTO request_statuses (status_name) VALUES
('Новая'),
('Принята'),
('В обработке'),
('Подтверждена'),
('Выполнена'),
('Отменена');

INSERT INTO products (product_code, product_name, unit_id, current_price) VALUES
('BRD-001', 'Хлеб Дарницкий', 1, 55.00),
('BRD-002', 'Батон нарезной', 1, 48.00),
('BUN-001', 'Булочка с маком', 1, 35.00);
