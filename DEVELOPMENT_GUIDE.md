# PocketAccountant Development Guide

## Quick Start for Developers

### Prerequisites
- Docker Desktop
- Node.js 18+ (for local development)
- Git

### Getting Started

1. **Clone the repository** (when available)
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
   - **n8n Workflow Engine**: http://localhost:5678
     - Default credentials: email `n8n@example.com`, password `password`
   - **Adminer (Database UI)**: http://localhost:8080
     - System: PostgreSQL
     - Server: `postgres`
     - Username: `pocketadmin`
     - Password: `changeme123` (or your POSTGRES_PASSWORD)
     - Database: `pocketaccountant`
   - **PostgreSQL Database**: `localhost:5433`
     - Username: `pocketadmin`
     - Password: `changeme123`

### Development Workflow

#### Backend Development
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

4. The backend API will be available at http://localhost:3001

#### Database Development
1. Access the database via Adminer at http://localhost:8080
2. Or use command line:
   ```bash
   docker exec -it pocketaccountant-postgres psql -U pocketadmin -d pocketaccountant
   ```

3. Run migrations (when available):
   ```bash
   cd backend
   npm run migrate:up
   ```

#### n8n Workflow Development
1. Access n8n at http://localhost:5678
2. Create workflows for:
   - Transaction categorization
   - SARS Q&A chatbot
   - Invoice generation
   - Payment matching
   - Mileage tracking

### Project Structure

```
PocketAccountant/
├── backend/           # Node.js/Express API
│   ├── src/
│   │   ├── controllers/   # Request handlers
│   │   ├── models/        # Database models
│   │   ├── routes/        # API routes
│   │   ├── services/      # Business logic
│   │   ├── utils/         # Utilities
│   │   ├── middleware/    # Express middleware
│   │   └── database/      # Database configuration
│   ├── package.json
│   └── Dockerfile
├── frontend/          # React web app (to be created)
├── mobile/           # React Native app (to be created)
├── workflows/        # n8n workflow exports
├── docker/           # Docker configurations
│   └── postgres/
│       └── init.sql  # Database initialization
├── docs/            # Documentation
├── ProjectDocumentation/ # Project documentation
├── docker-compose.yml
├── .env.example
└── README.md
```

### API Endpoints

The backend API provides the following endpoints:

- `GET /health` - Health check
- `GET /api-docs` - API documentation
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/users/profile` - Get user profile
- `GET /api/accounts` - List accounts
- `POST /api/transactions` - Create transaction
- `GET /api/transactions` - List transactions
- `POST /api/invoices` - Create invoice
- `POST /api/ai/chat` - AI chat endpoint
- `GET /api/tax/status` - Tax compliance status

### Database Schema

Key tables:
- `users` - User accounts
- `accounts` - Chart of accounts
- `transactions` - Financial transactions
- `transaction_entries` - Double-entry journal entries
- `invoices` - Customer invoices
- `trips` - Mileage tracking
- `tax_records` - SARS tax filings
- `ai_conversations` - AI chat history
- `audit_logs` - System audit trail

### Testing

#### Run tests:
```bash
cd backend
npm test
```

#### Run tests with coverage:
```bash
npm run test:coverage
```

#### Run specific test:
```bash
npm test -- --testNamePattern="auth"
```

### Code Quality

#### Linting:
```bash
cd backend
npm run lint
```

#### Formatting:
```bash
npm run format
```

#### Type checking (when TypeScript is added):
```bash
npm run type-check
```

### Deployment

#### Development deployment:
```bash
docker-compose up -d
```

#### Production deployment (future):
1. Build images:
   ```bash
   docker-compose -f docker-compose.prod.yml build
   ```

2. Deploy:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Troubleshooting

#### Common Issues:

1. **Port conflicts**:
   - Change ports in `docker-compose.yml` and `.env`

2. **Database connection issues**:
   - Check if PostgreSQL container is running: `docker-compose ps`
   - Verify credentials in `.env` file
   - Check logs: `docker-compose logs postgres`

3. **n8n not starting**:
   - Check logs: `docker-compose logs n8n`
   - Verify database connection in n8n settings

4. **Backend not starting**:
   - Check logs: `docker-compose logs backend` (when backend is added)
   - Verify dependencies: `npm install`

#### Logs:
- View all logs: `docker-compose logs`
- View specific service logs: `docker-compose logs [service-name]`
- Follow logs: `docker-compose logs -f`

### Next Steps

1. **Complete backend implementation**:
   - Implement authentication
   - Create API endpoints
   - Add database models

2. **Develop frontend**:
   - Set up React project
   - Create dashboard
   - Implement transaction entry

3. **Build n8n workflows**:
   - Transaction categorization
   - SARS Q&A chatbot
   - Invoice generation

4. **Develop mobile app**:
   - Set up React Native
   - Implement GPS tracking
   - Create mileage logbook

### Useful Commands

#### Docker commands:
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f

# View container status
docker-compose ps

# Execute command in container
docker-compose exec postgres psql -U pocketadmin -d pocketaccountant
```

#### Database commands:
```bash
# Access database
docker exec -it pocketaccountant-postgres psql -U pocketadmin -d pocketaccountant

# Backup database
docker exec pocketaccountant-postgres pg_dump -U pocketadmin pocketaccountant > backup.sql

# Restore database
docker exec -i pocketaccountant-postgres psql -U pocketadmin -d pocketaccountant < backup.sql
```

#### Development commands:
```bash
# Install backend dependencies
cd backend && npm install

# Start backend development server
cd backend && npm run dev

# Run tests
cd backend && npm test

# Run linter
cd backend && npm run lint
```

### Support

For issues or questions:
1. Check the troubleshooting guide in `ProjectDocumentation/DevImplementation/ErrorTroubleshooting.txt`
2. Review the implementation notes in `ProjectDocumentation/DevImplementation/ImplementationNotes.txt`
3. Check the step-by-step plan in `ProjectDocumentation/DevImplementation/ImplementationSteps.txt`

### Contributing

1. Create a feature branch
2. Make your changes
3. Write tests
4. Run linter and tests
5. Submit pull request