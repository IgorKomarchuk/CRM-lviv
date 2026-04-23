-- =============================================
-- "Найкраща CRM в світі" — Database Schema v2
-- Всі 11 колонок з Excel + маркетплейси + телефонія
-- =============================================

-- 1. ТОВАРИ (Products) — основна таблиця
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    code_1c VARCHAR(100),                  -- Колонка 1: Код 1С
    sku VARCHAR(100) UNIQUE NOT NULL,      -- Колонка 2: Артикул
    name_ua VARCHAR(255) NOT NULL,         -- Колонка 3: Номенклатура
    name_pl VARCHAR(255),                  -- Назва (польська)
    category VARCHAR(100),
    
    -- Колонка 9: Собівартість за одиницю
    unit_cost_uah DECIMAL(12, 2),          -- Собівартість (грн)
    unit_cost_pln DECIMAL(12, 2),          -- Собівартість (zł)
    
    -- Колонка 10: Ціна продажу
    unit_price_uah DECIMAL(12, 2),         -- Ціна продажі (грн)
    unit_price_pln DECIMAL(12, 2),         -- Ціна продажі (zł)
    
    -- Колонка 11: Залишок
    stock_ua INTEGER DEFAULT 0,            -- Залишок UA (шт)
    stock_pl INTEGER DEFAULT 0,            -- Залишок PL (шт)
    stock_min_threshold INTEGER DEFAULT 5, -- Поріг для AI-сповіщення
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. АНАЛІТИКА ПРОДАЖІВ (Sales Analytics) — динамічні дані
-- Колонки 4-8 з Excel: кількість, виручка, собівартість, прибуток, рентабельність
CREATE TABLE sales_analytics (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    units_sold INTEGER DEFAULT 0,                -- Колонка 4: Кількість (Базових од.)
    total_revenue_with_vat DECIMAL(12, 2),       -- Колонка 5: Вартість продажу з ПДВ
    total_cost_with_vat DECIMAL(12, 2),          -- Колонка 6: Собівартість з ПДВ
    gross_profit_with_vat DECIMAL(12, 2),        -- Колонка 7: Валовий прибуток з ПДВ
    margin_percent DECIMAL(5, 2),                -- Колонка 8: Рентабельність % (з ПДВ)
    
    source VARCHAR(50),  -- Rozetka, Amazon, Prom, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. ЗАМОВЛЕННЯ (Orders)
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    external_id VARCHAR(100),
    source VARCHAR(50) NOT NULL,           -- Amazon, Rozetka, Prom, Allegro, OLX, Epicentr
    status VARCHAR(50) DEFAULT 'new',      -- new, processing, shipped, delivered, cancelled
    
    customer_id INTEGER REFERENCES customers(id),
    total_amount DECIMAL(12, 2),
    currency VARCHAR(3) DEFAULT 'UAH',
    
    manager_id INTEGER REFERENCES users(id),
    notes TEXT,
    
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. КЛІЄНТИ (Customers)
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(255),
    segment VARCHAR(50),                   -- opt (опт), retail (роздріб), marketplace
    region VARCHAR(10) DEFAULT 'UA',       -- UA або PL
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(12, 2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. ДЗВІНКИ (Calls) — UniTalk + Zadarmo
CREATE TABLE calls (
    id SERIAL PRIMARY KEY,
    provider VARCHAR(20) NOT NULL,         -- unitalk або zadarmo
    direction VARCHAR(10),                 -- inbound, outbound
    phone_number VARCHAR(50),
    customer_id INTEGER REFERENCES customers(id),
    manager_id INTEGER REFERENCES users(id),
    duration_seconds INTEGER,
    recording_url TEXT,
    status VARCHAR(20),                    -- answered, missed, voicemail
    call_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. КОРИСТУВАЧІ (Users) — ролі та доступи
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    role VARCHAR(20) NOT NULL,             -- admin, manager, warehouse
    region VARCHAR(10),                    -- UA, PL, або ALL
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. ЗАКУПІВЛІ (Purchase Orders)
CREATE TABLE purchase_orders (
    id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255),
    items_description TEXT,
    total_amount DECIMAL(12, 2),
    currency VARCHAR(3) DEFAULT 'UAH',
    status VARCHAR(50) DEFAULT 'draft',    -- draft, ordered, in_transit, delivered, delayed
    expected_date DATE,
    actual_date DATE,
    delay_count INTEGER DEFAULT 0,         -- Для AI: скільки разів затримував
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. МАРКЕТПЛЕЙС СИНХРОНІЗАЦІЯ
CREATE TABLE marketplace_sync (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    marketplace VARCHAR(50),               -- rozetka, prom, olx, epicentr, allegro, amazon
    external_sku VARCHAR(100),
    external_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    last_sync_at TIMESTAMP,
    sync_status VARCHAR(20) DEFAULT 'ok'   -- ok, error, pending
);

-- 9. AI АНАЛІТИКА (Логи висновків)
CREATE TABLE ai_insights (
    id SERIAL PRIMARY KEY,
    severity VARCHAR(20) NOT NULL,         -- critical, warning, recommendation
    title VARCHAR(255) NOT NULL,
    description TEXT,
    related_product_id INTEGER REFERENCES products(id),
    related_order_id INTEGER REFERENCES orders(id),
    is_resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. ЛОГИ ДІЙ (Audit Trail)
CREATE TABLE activity_log (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100),                   -- created_order, updated_price, deleted_product
    entity_type VARCHAR(50),               -- product, order, customer
    entity_id INTEGER,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
