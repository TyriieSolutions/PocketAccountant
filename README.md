# PocketAccountant

**AI-powered financial companion for South Africans**

PocketAccountant is an all-in-one financial platform that combines full-spectrum bookkeeping, SARS-savvy tax intelligence, and automated mileage tracking in one intuitive platform. It acts like a private accountant in your pocket, learning your habits, automating the mundane, and giving you peace of mind through a simple chat interface.

## 🎯 Vision

To build the first AI-native financial companion that truly understands South Africans—empowering individuals, freelancers, and small businesses to take control of their finances with the guidance of a personal AI accountant.

## ✨ Key Features

### 1. Full Bookkeeping
- Double-entry ledger with Chart of Accounts
- Create, send, and track invoices with payment reminders
- Expense tracking with receipt scanning and auto-categorization
- Bank integration with auto-import and reconciliation
- Financial reports (P&L, Balance Sheet, Cash Flow)

### 2. AI-Powered Accounting Intelligence
- Natural language querying ("How much did I spend on fuel last month?")
- Smart categorization with 99.5% accuracy
- Anomaly detection for duplicate payments and fraud
- Cash flow forecasting and financial health scoring
- Conversational interface with your AI accountant

### 3. SARS & Tax Compliance
- SARS integration and eFiling connectivity
- Conversational tax assistant with step-by-step Q&A
- Tax return preparation with auto-fill from your books
- Real-time compliance monitoring and alerts
- EMP501 support for payroll compliance

### 4. AI-Powered Mileage Logbook
- Automatic trip detection with GPS
- Smart classification of business vs. personal trips
- SARS rates integration for claim calculations
- Route mapping and exportable reports
- Battery-efficient GPS sampling

### 5. AI-Powered Accounts Receivable Assistant
- Invoice matching with bank statement payments
- Payment prediction for late-paying customers
- Automated dunning emails with adaptive tone
- Customer credit scoring and DSO tracking

## 🏗️ Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Mobile App    │────▶│   n8n Server    │────▶│   DeepSeek API  │
│   (React Native)│     │ (Workflows)     │     │   (AI Engine)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                        │                        │
        │                        │                        │
        ▼                        ▼                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   PostgreSQL    │     │  Bank APIs      │     │  SARS eFiling   │
│   (Ledger)      │     │  (Stitch, etc.) │     │  (future)       │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## 🛠️ Technology Stack

| Component | Technology | Justification |
|-----------|------------|---------------|
| Workflow Engine | n8n (self-hosted) | Low-code, 400+ integrations, perfect for gluing services |
| AI/LLM | DeepSeek API | Cost-effective, strong reasoning, can be trained on SARS docs |
| Database | PostgreSQL (via Supabase or AWS RDS) | Robust, relational, handles double-entry accounting |
| Backend API | Node.js/Express | For custom logic n8n can't handle |
| Frontend | React (web) + React Native (mobile) | Code reuse across web and mobile |
| Mobile GPS | React Native Background Geolocation | Reliable background tracking |
| Bank Integration | n8n connectors to TrueLayer/Yapily/Stitch | SA-specific fintech APIs |
| Hosting | AWS Cape Town region | Compliance with POPIA and financial regulations |

## 🚀 Getting Started

### Prerequisites
- Docker Desktop
- Node.js (v18+)
- Git

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd PocketAccountant
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start the development environment**
   ```bash
   docker-compose up -d
   ```

4. **Access the services**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:3001
   - n8n Workflow Engine: http://localhost:5678
   - Adminer (Database UI): http://localhost:8080
   - PostgreSQL: localhost:5432

### Development Setup

1. **Backend Development**
   ```bash
   cd backend
   npm install
   npm run dev
   ```

2. **Frontend Development**
   ```bash
   cd frontend
   npm install
   npm start
   ```

3. **Mobile Development**
   ```bash
   cd mobile
   npm install
   # For iOS
   npx react-native run-ios
   # For Android
   npx react-native run-android
   ```

## 📁 Project Structure

```
PocketAccountant/
├── backend/           # Node.js/Express API
│   ├── src/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── services/
│   │   └── utils/
│   ├── package.json
│   └── Dockerfile
├── frontend/          # React web application
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   └── styles/
│   ├── package.json
│   └── Dockerfile
├── mobile/           # React Native mobile app
│   ├── src/
│   │   ├── components/
│   │   ├── screens/
│   │   ├── navigation/
│   │   └── services/
│   ├── package.json
│   └── app.json
├── workflows/        # n8n workflow exports
├── docker/           # Docker configurations
│   └── postgres/
│       └── init.sql
├── docs/            # Documentation
├── ProjectDocumentation/ # Project documentation
└── docker-compose.yml
```

## 🔧 Development Workflow

### Phase 1: MVP (Months 1-2)
- Core bookkeeping with manual entry
- AI categorization of transactions
- SARS Q&A chatbot
- Basic invoice generation

### Phase 2: Mileage & AR Assistant (Months 3-4)
- Mobile app with GPS tracking
- Automated mileage logbook
- Accounts receivable automation
- Payment matching and reminders

### Phase 3: SARS Integration (Months 5-6)
- SARS eFiling integration
- Tax return preparation
- Compliance monitoring
- Advanced tax features

### Phase 4: Polish & Scale (Month 7+)
- Visual dashboards
- Document intelligence
- White-label for accountants
- Multi-currency support

## 🔐 Security & Compliance

- **Data Sovereignty**: All data stored in AWS Cape Town region (af-south-1)
- **Encryption**: AES-256 encryption at rest and TLS 1.3 in transit
- **Authentication**: JWT with MFA for higher tiers
- **Compliance**: POPIA compliant with audit trails
- **AI Explainability**: All AI decisions logged with confidence scores

## 📊 Database Schema

The database uses a double-entry accounting system with the following core tables:
- `users` - User accounts and profiles
- `accounts` - Chart of accounts
- `transactions` - Financial transactions
- `transaction_entries` - Double-entry journal entries
- `invoices` - Customer invoices
- `trips` - Mileage tracking data
- `tax_records` - SARS tax filings
- `ai_conversations` - AI chat history
- `audit_logs` - System audit trail

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is proprietary. All rights reserved.

## 📞 Contact & Support

For support, feature requests, or partnership inquiries:
- Email: support@pocketaccountant.co.za
- Website: https://pocketaccountant.co.za (coming soon)

## 🙏 Acknowledgments

- SARS for public documentation
- DeepSeek for AI capabilities
- Stitch for South African bank integrations
- The open-source community for amazing tools

---

**Built with ❤️ for South Africans**