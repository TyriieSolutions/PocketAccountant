-- PocketAccountant Database Initialization Script
-- This script creates the core database schema for the PocketAccountant application

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE account_type AS ENUM ('asset', 'liability', 'equity', 'income', 'expense');
CREATE TYPE transaction_type AS ENUM ('debit', 'credit');
CREATE TYPE invoice_status AS ENUM ('draft', 'sent', 'paid', 'overdue', 'cancelled');
CREATE TYPE trip_purpose AS ENUM ('business', 'personal', 'mixed');
CREATE TYPE user_tier AS ENUM ('free', 'lite', 'smart', 'ultra', 'partner');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    tier user_tier DEFAULT 'free',
    business_name VARCHAR(255),
    tax_number VARCHAR(50),
    vat_number VARCHAR(50),
    address JSONB,
    settings JSONB DEFAULT '{}',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Create index on email for faster lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_tier ON users(tier);

-- Accounts table (Chart of Accounts)
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_account_id UUID REFERENCES accounts(id),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    description TEXT,
    type account_type NOT NULL,
    currency VARCHAR(3) DEFAULT 'ZAR',
    opening_balance DECIMAL(15,2) DEFAULT 0,
    current_balance DECIMAL(15,2) DEFAULT 0,
    is_system_account BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, code)
);

-- Create indexes for accounts
CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_accounts_type ON accounts(type);
CREATE INDEX idx_accounts_parent ON accounts(parent_account_id);

-- Transactions table (Double-entry accounting)
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_date DATE NOT NULL,
    description TEXT NOT NULL,
    reference VARCHAR(255),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'ZAR',
    category VARCHAR(100),
    subcategory VARCHAR(100),
    is_reconciled BOOLEAN DEFAULT FALSE,
    reconciled_date DATE,
    bank_reference VARCHAR(255),
    receipt_url TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Transaction entries (for double-entry accounting)
CREATE TABLE transaction_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id),
    entry_type transaction_type NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for transactions
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_category ON transactions(category);
CREATE INDEX idx_transaction_entries_transaction ON transaction_entries(transaction_id);
CREATE INDEX idx_transaction_entries_account ON transaction_entries(account_id);

-- Invoices table
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    invoice_number VARCHAR(100) NOT NULL,
    customer_id UUID,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255),
    customer_address JSONB,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status invoice_status DEFAULT 'draft',
    total_amount DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'ZAR',
    notes TEXT,
    terms TEXT,
    line_items JSONB NOT NULL,
    pdf_url TEXT,
    sent_at TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, invoice_number)
);

-- Create indexes for invoices
CREATE INDEX idx_invoices_user_id ON invoices(user_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
CREATE INDEX idx_invoices_customer ON invoices(customer_email);

-- Trips table (for mileage tracking)
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    start_location VARCHAR(255),
    end_location VARCHAR(255),
    start_latitude DECIMAL(10,8),
    start_longitude DECIMAL(11,8),
    end_latitude DECIMAL(10,8),
    end_longitude DECIMAL(11,8),
    distance_km DECIMAL(10,2),
    purpose trip_purpose NOT NULL,
    business_percentage INTEGER DEFAULT 100,
    notes TEXT,
    route_data JSONB,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for trips
CREATE INDEX idx_trips_user_id ON trips(user_id);
CREATE INDEX idx_trips_start_time ON trips(start_time);
CREATE INDEX idx_trips_purpose ON trips(purpose);

-- SARS tax records table
CREATE TABLE tax_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tax_year INTEGER NOT NULL,
    form_type VARCHAR(50) NOT NULL, -- ITR12, VAT201, EMP501, etc.
    status VARCHAR(50) DEFAULT 'draft', -- draft, submitted, assessed, paid
    submission_date DATE,
    assessment_date DATE,
    due_date DATE,
    total_income DECIMAL(15,2),
    total_expenses DECIMAL(15,2),
    taxable_income DECIMAL(15,2),
    tax_payable DECIMAL(15,2),
    tax_paid DECIMAL(15,2),
    document_url TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, tax_year, form_type)
);

-- Create indexes for tax records
CREATE INDEX idx_tax_records_user_id ON tax_records(user_id);
CREATE INDEX idx_tax_records_tax_year ON tax_records(tax_year);
CREATE INDEX idx_tax_records_status ON tax_records(status);

-- AI conversation history table
CREATE TABLE ai_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID NOT NULL DEFAULT uuid_generate_v4(),
    query TEXT NOT NULL,
    response TEXT NOT NULL,
    context JSONB DEFAULT '{}',
    model VARCHAR(100),
    tokens_used INTEGER,
    response_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for AI conversations
CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX idx_ai_conversations_session ON ai_conversations(session_id);
CREATE INDEX idx_ai_conversations_created ON ai_conversations(created_at);

-- Audit log table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for audit logs
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);

-- Create system accounts for each new user
CREATE OR REPLACE FUNCTION create_system_accounts_for_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Create default system accounts for the new user
    INSERT INTO accounts (user_id, name, code, type, is_system_account, description)
    VALUES
        (NEW.id, 'Cash', '1000', 'asset', TRUE, 'Cash on hand'),
        (NEW.id, 'Bank Account', '1100', 'asset', TRUE, 'Primary bank account'),
        (NEW.id, 'Accounts Receivable', '1200', 'asset', TRUE, 'Money owed by customers'),
        (NEW.id, 'Inventory', '1300', 'asset', TRUE, 'Goods for sale'),
        (NEW.id, 'Equipment', '1400', 'asset', TRUE, 'Business equipment'),
        (NEW.id, 'Accounts Payable', '2000', 'liability', TRUE, 'Money owed to suppliers'),
        (NEW.id, 'Loans Payable', '2100', 'liability', TRUE, 'Business loans'),
        (NEW.id, 'Owner''s Equity', '3000', 'equity', TRUE, 'Owner''s investment'),
        (NEW.id, 'Retained Earnings', '3100', 'equity', TRUE, 'Accumulated profits'),
        (NEW.id, 'Sales Revenue', '4000', 'income', TRUE, 'Income from sales'),
        (NEW.id, 'Service Revenue', '4100', 'income', TRUE, 'Income from services'),
        (NEW.id, 'Cost of Goods Sold', '5000', 'expense', TRUE, 'Direct costs of sales'),
        (NEW.id, 'Advertising', '6000', 'expense', TRUE, 'Marketing and advertising'),
        (NEW.id, 'Rent', '6100', 'expense', TRUE, 'Office rent'),
        (NEW.id, 'Utilities', '6200', 'expense', TRUE, 'Electricity, water, internet'),
        (NEW.id, 'Salaries', '6300', 'expense', TRUE, 'Employee salaries'),
        (NEW.id, 'Travel', '6400', 'expense', TRUE, 'Business travel expenses'),
        (NEW.id, 'Vehicle Expenses', '6500', 'expense', TRUE, 'Fuel, maintenance, insurance');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create system accounts when a new user is created
CREATE TRIGGER create_system_accounts_trigger
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION create_system_accounts_for_user();

-- Function to update account balances
CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    -- Update account balance when transaction entries are added
    IF TG_OP = 'INSERT' THEN
        IF NEW.entry_type = 'debit' THEN
            UPDATE accounts 
            SET current_balance = current_balance + NEW.amount
            WHERE id = NEW.account_id;
        ELSE
            UPDATE accounts 
            SET current_balance = current_balance - NEW.amount
            WHERE id = NEW.account_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update account balances
CREATE TRIGGER update_account_balance_trigger
AFTER INSERT ON transaction_entries
FOR EACH ROW
EXECUTE FUNCTION update_account_balance();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at on all tables that have it
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_accounts_updated_at
BEFORE UPDATE ON accounts
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at
BEFORE UPDATE ON transactions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at
BEFORE UPDATE ON invoices
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trips_updated_at
BEFORE UPDATE ON trips
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tax_records_updated_at
BEFORE UPDATE ON tax_records
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Insert initial admin user (password: admin123 - change this in production!)
INSERT INTO users (email, password_hash, first_name, last_name, tier, email_verified)
VALUES (
    'admin@pocketaccountant.co.za',
    '$2b$10$YourHashedPasswordHere', -- Replace with actual bcrypt hash of 'admin123'
    'System',
    'Administrator',
    'ultra',
    TRUE
) ON CONFLICT (email) DO NOTHING;

-- Create a view for financial summary
CREATE VIEW financial_summary AS
SELECT 
    u.id as user_id,
    u.email,
    u.tier,
    COUNT(DISTINCT t.id) as total_transactions,
    COUNT(DISTINCT i.id) as total_invoices,
    SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) as total_income,
    SUM(CASE WHEN t.amount < 0 THEN ABS(t.amount) ELSE 0 END) as total_expenses,
    COUNT(DISTINCT tr.id) as total_trips,
    SUM(tr.distance_km) as total_business_km
FROM users u
LEFT JOIN transactions t ON u.id = t.user_id
LEFT JOIN invoices i ON u.id = i.user_id
LEFT JOIN trips tr ON u.id = tr.user_id AND tr.purpose = 'business'
GROUP BY u.id, u.email, u.tier;

-- Grant permissions (adjust as needed for your security model)
-- Note: In production, you'll want more granular permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pocketadmin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO pocketadmin;

COMMENT ON DATABASE pocketaccountant IS 'PocketAccountant - AI-powered financial companion for South Africans';