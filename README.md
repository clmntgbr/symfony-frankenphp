# Symfony FrankenPHP Template

A production-ready Symfony template powered by [FrankenPHP](https://frankenphp.dev) and [Caddy](https://caddyserver.com/), featuring API Platform, PostgreSQL, RabbitMQ, and modern PHP development tools.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Available Commands](#available-commands)
- [Configuration](#configuration)
- [Features](#features)
- [Security](#security)
- [Production Deployment](#production-deployment)
- [TLS Certificates](#tls-certificates)
- [License](#license)

## 🎯 Overview

This template provides a modern, high-performance Symfony application with FrankenPHP as the runtime. It includes everything needed to build robust REST APIs with authentication, messaging, and real-time capabilities.

**Key Highlights:**
- ⚡ Blazing-fast performance with FrankenPHP worker mode (production)
- 🔄 Hot-reload development with `--watch` mode
- 🔐 JWT authentication ready
- 📡 Real-time capabilities with Mercure
- 🐰 Async messaging with RabbitMQ
- 🐘 PostgreSQL database
- 📚 API Platform for REST/GraphQL APIs
- 🔧 Complete Makefile for common tasks

## 🏗 Architecture

### Application Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         Client                               │
└────────────────┬────────────────────────────────────────────┘
                 │ HTTPS (443) / HTTP (80)
                 ▼
┌─────────────────────────────────────────────────────────────┐
│              FrankenPHP + Caddy Server                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  • Automatic HTTPS with SSL/TLS                      │   │
│  │  • HTTP/2, HTTP/3 support                            │   │
│  │  • Mercure Hub (Real-time)                           │   │
│  │  • Reverse Proxy                                     │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│                    Symfony Application                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Controllers / API Resources                         │   │
│  └────────┬─────────────────────────────────────────────┘   │
│           │                                                  │
│  ┌────────▼──────────┐  ┌──────────────┐  ┌─────────────┐  │
│  │   API Platform    │  │   Security   │  │  Listeners  │  │
│  │  REST / GraphQL   │  │  JWT Auth    │  │  Events     │  │
│  └────────┬──────────┘  └──────┬───────┘  └──────┬──────┘  │
│           │                     │                 │          │
│  ┌────────▼─────────────────────▼─────────────────▼──────┐  │
│  │              Doctrine ORM                             │  │
│  └────────┬──────────────────────────────────────────────┘  │
└───────────┼──────────────────────────────────────────────────┘
            │                              │
            ▼                              ▼
┌───────────────────────┐      ┌──────────────────────┐
│   PostgreSQL DB       │      │    RabbitMQ          │
│   - User Data         │      │    - Async Messages  │
│   - Application Data  │      │    - Event Queue     │
└───────────────────────┘      └──────────────────────┘
```

### Container Architecture

The application runs in three main Docker containers:

1. **PHP Container (FrankenPHP)**
   - Web server + PHP runtime
   - Caddy reverse proxy
   - Mercure hub for real-time
   - Hot reload in development
   - Worker mode in production

2. **Database Container (PostgreSQL)**
   - Persistent data storage
   - Health checks enabled
   - Exposed on port 9001

3. **Message Broker (RabbitMQ)**
   - Async message handling
   - Management UI on port 9003
   - AMQP on port 9002

## 🛠 Tech Stack

### Core

- **PHP**: 8.3.15+
- **Symfony**: 7.3.*
- **FrankenPHP**: 1.x (with PHP 8.3)
- **Caddy**: 2.x (embedded in FrankenPHP)

### API & Serialization

- **API Platform**: 4.2+ (REST, GraphQL, OpenAPI)
- **Symfony Serializer**: JSON/XML serialization
- **CORS**: Nelmio CORS Bundle

### Database & ORM

- **Doctrine ORM**: 3.5+
- **Doctrine Migrations**: Database versioning
- **PostgreSQL**: Latest
- **Doctrine Extensions (Gedmo)**: Timestampable, Sluggable, etc.

### Authentication & Security

- **Lexik JWT**: JWT authentication
- **Symfony Security**: Role-based access control
- **Password Hashing**: Automatic with Symfony

### Messaging & Async

- **Symfony Messenger**: Message bus
- **AMQP Transport**: RabbitMQ integration
- **Symfony Scheduler**: Cron-like scheduling

### Development Tools

- **Doctrine Fixtures**: Test data with Faker
- **Hautelook Alice Bundle**: Fixture management
- **Symfony Maker**: Code generation
- **Webpack Encore**: Asset management
- **Monolog**: Logging

## 📁 Project Structure

```
symfony-frankenphp/
├── assets/                      # Frontend assets
│   ├── app.js                  # JavaScript entry point
│   └── styles/
│       └── app.css             # CSS entry point
│
├── bin/
│   └── console                 # Symfony console
│
├── config/                     # Application configuration
│   ├── packages/               # Bundle configurations
│   │   ├── api_platform.yaml  # API Platform settings
│   │   ├── doctrine.yaml      # Database configuration
│   │   ├── security.yaml      # Security & authentication
│   │   ├── messenger.yaml     # Async messaging
│   │   └── ...
│   ├── routes/                 # Routing configuration
│   └── services.yaml           # Service container
│
├── fixtures/                   # Data fixtures
│   └── User.yaml              # User fixtures with Faker
│
├── frankenphp/                # FrankenPHP configuration
│   ├── Caddyfile              # Caddy server config
│   ├── conf.d/                # PHP configuration
│   │   ├── 10-app.ini         # Base PHP settings
│   │   ├── 20-app.dev.ini     # Development PHP settings
│   │   └── 20-app.prod.ini    # Production PHP settings
│   └── docker-entrypoint.sh   # Container startup script
│
├── migrations/                 # Database migrations
│
├── public/                     # Web root
│   ├── index.php              # Front controller
│   └── bundles/               # Public bundle assets
│
├── src/
│   ├── ApiResource/           # API Platform resources
│   ├── Controller/            # HTTP controllers
│   ├── Entity/                # Doctrine entities
│   │   ├── Trait/            # Reusable entity traits
│   │   │   └── UuidTrait.php # UUID primary key trait
│   │   └── User.php          # User entity
│   ├── Listener/              # Event listeners
│   │   ├── UserListener.php  # User lifecycle events
│   │   └── AuthenticationSuccessListener.php
│   ├── Repository/            # Doctrine repositories
│   │   ├── AbstractRepository.php
│   │   └── UserRepository.php
│   ├── Util/                  # Utility functions
│   ├── Schedule.php           # Scheduled tasks
│   └── Kernel.php             # Application kernel
│
├── templates/                  # Twig templates
│   └── base.html.twig
│
├── var/                        # Runtime files
│   ├── cache/                 # Application cache
│   └── log/                   # Application logs
│
├── vendor/                     # Composer dependencies
│
├── compose.yaml               # Docker Compose configuration
├── compose.override.yaml      # Local overrides
├── compose.prod.yaml          # Production overrides
├── Dockerfile                 # Multi-stage Docker build
├── Makefile                   # Development commands
└── composer.json              # PHP dependencies

```

## ✅ Prerequisites

- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Make**: (usually pre-installed on macOS/Linux)

Optional for local development:
- **PHP**: 8.3+ (for IDE support)
- **Composer**: 2.0+
- **Node.js**: 18+ (for asset compilation)

## 🚀 Getting Started

### 1. Clone and Configure

```bash
# Clone the repository
git clone <your-repo-url>
cd symfony-frankenphp

# Copy environment file
cp .env.example .env
# Edit .env with your configuration
```

### 2. Build and Start

```bash
# Build Docker images
make build

# Start all services
make start

# Initialize the application (install dependencies, setup database, fixtures)
make init

# Generate JWT keys
make jwt

# Setup database
make db
```

### 3. Access the Application

- **HTTPS**: https://localhost
- **HTTP**: http://localhost
- **API Documentation**: https://localhost/api/docs
- **RabbitMQ Management**: http://localhost:9003
- **Database**: localhost:9001

### 4. Default User

After running `make db`, a default user is created from fixtures:

```
Email: user@example.com
Password: Check fixtures/User.yaml
```

## 🔧 Development Workflow

### Daily Development

```bash
# Start containers
make start

# Watch logs
docker compose logs -f php

# Stop containers
make stop

# Restart containers
make restart
```

### Database Management

```bash
# Create new migration
make migration

# Run migrations
make migrate

# Update schema directly (dev only)
make schema

# Load fixtures
make fixture

# Complete database reset
make db
```

### Code Generation

```bash
# Create new entity
make entity

# Create new message/command
make message

# Create new console command
make command

# Regenerate entity getters/setters
make regenerate
```

### Accessing Containers

```bash
# PHP container shell
make php

# Database container shell
make database

# Execute Symfony console directly
docker exec -it <project>-php php bin/console <command>
```

## 📝 Available Commands

### Makefile Commands

| Command | Description |
|---------|-------------|
| `make build` | Build Docker images from scratch |
| `make start` | Start all containers |
| `make stop` | Stop all containers |
| `make restart` | Restart containers |
| `make kill` | Force kill containers |
| `make init` | Complete project initialization |
| `make php` | Access PHP container shell |
| `make database` | Access database container shell |
| `make install` | Run composer install |
| `make update` | Run composer update |
| `make npm` | Install and build frontend assets |
| `make cache` | Clear Symfony cache |
| `make jwt` | Generate JWT keypair |
| `make db` | Reset and populate database |
| `make fabric` | Setup message transports |
| `make migration` | Create new migration |
| `make migrate` | Run migrations |
| `make fixture` | Load fixtures |
| `make schema` | Update database schema |
| `make regenerate` | Regenerate entities |
| `make entity` | Create new entity |
| `make message` | Create new message |
| `make command` | Create new console command |
| `make dotenv` | Debug environment variables |
| `make php-stan` | Run PHPStan analysis |

### Common Symfony Console Commands

```bash
# Inside PHP container
php bin/console debug:router              # List all routes
php bin/console debug:container          # List services
php bin/console debug:autowiring         # List autowirable services
php bin/console cache:clear              # Clear cache
php bin/console messenger:consume async  # Consume async messages
```

## ⚙️ Configuration

### Environment Variables

Key variables in `.env`:

```env
# Project
PROJECT_NAME=symfony-frankenphp
APP_ENV=dev
APP_SECRET=your-secret-key

# Database
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
DATABASE_URL=postgresql://postgres:postgres@database:5432/postgres

# RabbitMQ
RABBITMQ_USER=rabbitmq
RABBITMQ_PASS=rabbitmq
RABBITMQ_VHOST=/
MESSENGER_TRANSPORT_DSN=amqp://rabbitmq:rabbitmq@rabbitmq:5672/%2f/messages

# JWT
JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem
JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem
JWT_PASSPHRASE=your-jwt-passphrase

# Server
SERVER_NAME=localhost
HTTPS_PORT=443
HTTP_PORT=80

# Mercure
MERCURE_URL=http://php/.well-known/mercure
MERCURE_PUBLIC_URL=https://localhost/.well-known/mercure
MERCURE_JWT_SECRET=!ChangeThisMercureHubJWTSecretKey!
```

### Security Configuration

JWT authentication is configured for the `/api` path:

- **Login endpoint**: `POST /api/token` with `{email, password}`
- **Protected routes**: All `/api/*` routes require `ROLE_USER`
- **Public routes**: `/api/docs` is public (API documentation)

Example login:

```bash
curl -X POST https://localhost/api/token \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'
```

Response:
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh_token": "..."
}
```

Use the token:

```bash
curl https://localhost/api/me \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..."
```

### API Platform Configuration

- **Pagination**: 10 items per page (max 50)
- **Formats**: JSON-LD, JSON, HTML
- **Documentation**: Swagger UI, ReDoc, GraphiQL
- **Versioning**: API version 1.0.0

## 🎨 Features

### 1. API Platform Resources

Create API resources using PHP attributes:

```php
use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\Post;

#[ApiResource(
    operations: [
        new Get(),
        new Post(),
    ],
    normalizationContext: ['groups' => ['resource:read']],
    denormalizationContext: ['groups' => ['resource:write']]
)]
class Resource
{
    // Your entity properties
}
```

### 2. UUID Primary Keys

Entities use UUID v4 as primary keys:

```php
use App\Entity\Trait\UuidTrait;
use Symfony\Component\Uid\Uuid;

class MyEntity
{
    use UuidTrait;

    public function __construct()
    {
        $this->id = Uuid::v4();
    }
}
```

### 3. Timestampable Entities

Automatic timestamp management with Gedmo:

```php
use Gedmo\Timestampable\Traits\TimestampableEntity;

class MyEntity
{
    use TimestampableEntity;
    // Automatically adds $createdAt and $updatedAt
}
```

### 4. Event Listeners

Custom entity lifecycle listeners:

```php
use Doctrine\Bundle\DoctrineBundle\Attribute\AsDoctrineListener;
use Doctrine\ORM\Events;

#[AsDoctrineListener(event: Events::prePersist)]
class MyEntityListener
{
    public function prePersist($args): void
    {
        // Custom logic before persist
    }
}
```

### 5. Async Messaging

Send messages to RabbitMQ:

```php
use Symfony\Component\Messenger\MessageBusInterface;

class MyService
{
    public function __construct(
        private MessageBusInterface $messageBus
    ) {}

    public function doSomething(): void
    {
        $this->messageBus->dispatch(new MyMessage());
    }
}
```

### 6. Fixtures with Faker

Generate realistic test data:

```yaml
# fixtures/User.yaml
App\Entity\User:
    user_{1..10}:
        email: '<email()>'
        firstname: '<firstName()>'
        lastname: '<lastName()>'
        plainPassword: 'password'
        roles: ['ROLE_USER']
```

## 🔐 Security

### Authentication Flow

1. User sends credentials to `/api/token`
2. Server validates and returns JWT token
3. Client includes token in `Authorization: Bearer <token>` header
4. Server validates token on each request

### Password Hashing

Passwords are automatically hashed using Symfony's password hasher:

- **Algorithm**: Auto (bcrypt/argon2i based on PHP version)
- **Hashing**: Done in `UserListener` on persist/update
- **Plain passwords**: Never stored, only hashed versions

### CORS Configuration

CORS is configured to allow API access from different origins:

```yaml
# config/packages/nelmio_cors.yaml
nelmio_cors:
    defaults:
        origin_regex: true
        allow_origin: ['*']
        allow_methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
        allow_headers: ['*']
```

## 🚢 Production Deployment

### Build Production Image

```bash
# Build production image
docker build --target=frankenphp_prod -t myapp:prod .

# Or using docker compose
docker compose -f compose.yaml -f compose.prod.yaml build
```

### Production Optimizations

The production image includes:

- **FrankenPHP Worker Mode**: Keeps application in memory between requests
- **OPcache**: Optimized PHP bytecode caching
- **Composer optimizations**: Classmap authoritative, no dev dependencies
- **Environment**: Production environment variables compiled
- **No Xdebug**: Removed for performance

### Environment Variables for Production

```env
APP_ENV=prod
APP_DEBUG=0
DATABASE_URL=postgresql://user:pass@production-db:5432/dbname
MESSENGER_TRANSPORT_DSN=amqp://user:pass@production-rabbitmq:5672/%2f/messages
```

### Worker Mode Performance

FrankenPHP worker mode provides:
- **10-20x** faster response times
- **Lower memory usage** per request
- **Shared state** between requests (use with caution)

## 🔒 TLS Certificates

### Trusting the Local Certificate Authority

For local HTTPS development, trust the Caddy-generated certificate:

#### macOS

```bash
docker cp $(docker compose ps -q php):/data/caddy/pki/authorities/local/root.crt /tmp/root.crt
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /tmp/root.crt
```

#### Linux

```bash
docker cp $(docker compose ps -q php):/data/caddy/pki/authorities/local/root.crt /usr/local/share/ca-certificates/root.crt
sudo update-ca-certificates
```

#### Windows

```powershell
docker compose cp php:/data/caddy/pki/authorities/local/root.crt %TEMP%/root.crt
certutil -addstore -f "ROOT" %TEMP%/root.crt
```

## 📚 Additional Resources

- [Symfony Documentation](https://symfony.com/doc/current/index.html)
- [FrankenPHP Documentation](https://frankenphp.dev/docs/)
- [API Platform Documentation](https://api-platform.com/docs/)
- [Doctrine ORM Documentation](https://www.doctrine-project.org/projects/doctrine-orm/en/latest/)
- [Caddy Documentation](https://caddyserver.com/docs/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

**Built with ❤️ using Symfony and FrankenPHP**
