<div align="center">
    <h1>Laravel 12 API Auth System with Passport 🔑</h1>
</div>

This project is a robust API system built on **Laravel 12** that uses **Laravel Passport** for OAuth2 and personal access token-based authentication. It follows a monorepo folder structure 📂 and includes a comprehensive Docker setup 🐳 for **local (dev)**, **staging**, and **production** environments, plus a **Kubernetes (Kustomize)** setup ☸️ — including a `kind` overlay for running the whole stack on a local cluster. A GitHub Actions pipeline gates every deploy on tests, code style, static analysis, and migration checks before building and pushing images. The codebase is held to the highest standards, with **100% PSR-12** compliance ✅ and **100% test coverage** ✅ using PHPUnit 🧪.

-----

## ✨ Key Features

  - **Authentication:** Token-based authentication using **Laravel Passport**. 🛡️
  - **User Management:** Routes for user registration ✍️, login 🚪, password management ⚙️, and email verification 📧.
  - **Access Control:** Implements role-based access with custom middleware 👮, ensuring different user types (`Admin`, `User`, `Subscriber`) have the correct access.
  - **Dockerized Environment:** Separate Docker images are provided for **local (dev)** 🛠️, **staging**, and **production** 🚀, allowing for a consistent, isolated, and optimized environment.
  - **Code Quality:**
      - **100% PSR-12** compliant code style. ✅
      - **100% test coverage** verified by both unit and feature tests. ✅
      - **Static analysis** with **Larastan** 🧐 to find potential bugs and code smells early.
  - **Kubernetes:** A Kustomize `base` + per-environment `overlays` setup (`dev`, `staging`, `production`, `kind`) with health probes, HPAs, and a Gateway API scaffold — see [`k8s/overlays/kind/README.md`](k8s/overlays/kind/README.md) to run it locally. ☸️
  - **Continuous Integration & Deployment:** Five GitHub Actions workflows automate checks and deployment:
    1.  **Tests with PHPUnit:** Runs the full test suite 🧪 and verifies code coverage percentage 📊.
    2.  **Verify Migrations with SQLite:** Ensures database migrations are valid and can be run. 💾
    3.  **Code Style with PHP CS Fixer:** Checks code style to maintain PSR-12 compliance. 🎨
    4.  **Static Analysis with Larastan:** Performs static code analysis to catch common issues. 🚦
    5.  **Build, Push & Update Manifests:** Gates on all four checks above, then builds/pushes Docker images and updates the Kustomize overlay for the target environment. 🚀

-----

## 📂 Project Structure

This project follows a monorepo structure with a clear and logical directory layout. The main application code lives within the `src` folder, while all Docker-related files and configurations are in the `docker` directory.

```bash
.
📦passport_token_auth
 ┣ 📂.github
 ┃ ┗ 📂workflows
 ┃ ┃ ┣ 📜build.yml               # Build, push & update Kustomize manifests
 ┃ ┃ ┣ 📜code-style.yml
 ┃ ┃ ┣ 📜static-analysis.yml
 ┃ ┃ ┣ 📜tests.yml
 ┃ ┃ ┗ 📜verify-migrations.yml
 ┣ 📂.vscode
 ┃ ┗ 📜launch.json
 ┣ 📂docker
 ┃ ┣ 📂nginx
 ┃ ┃ ┣ 📂html
 ┃ ┃ ┃ ┗ 📜maintenance.html
 ┃ ┃ ┣ 📂templates
 ┃ ┃ ┃ ┗ 📜default.conf.template
 ┃ ┃ ┗ 📜Dockerfile
 ┃ ┗ 📂php-fpm
 ┃ ┃ ┣ 📜Dockerfile
 ┃ ┃ ┣ 📜entrypoint.sh
 ┃ ┃ ┗ 📜supervisor.conf
 ┣ 📂k8s                          # Kustomize base + per-environment overlays
 ┃ ┣ 📂base
 ┃ ┃ ┣ 📜app-deployment.yaml
 ┃ ┃ ┣ 📜app-service.yaml
 ┃ ┃ ┣ 📜app-supervisor-logs-pvc.yaml
 ┃ ┃ ┣ 📜gateway.yaml
 ┃ ┃ ┣ 📜kustomization.yaml
 ┃ ┃ ┣ 📜mysql-data-pvc.yaml
 ┃ ┃ ┣ 📜mysql-deployment.yaml
 ┃ ┃ ┣ 📜mysql-service.yaml
 ┃ ┃ ┣ 📜nginx-deployment.yaml
 ┃ ┃ ┣ 📜nginx-httproute.yaml
 ┃ ┃ ┗ 📜nginx-service.yaml
 ┃ ┗ 📂overlays
 ┃ ┃ ┣ 📂dev
 ┃ ┃ ┣ 📂kind                    # includes its own README.md — run it locally
 ┃ ┃ ┣ 📂local
 ┃ ┃ ┣ 📂production
 ┃ ┃ ┗ 📂staging
 ┣ 📂src
 ┃ ┣ 📂app
 ┃ ┃ ┣ 📂Http
 ┃ ┃ ┃ ┣ 📂Controllers
 ┃ ┃ ┃ ┣ 📂Middleware
 ┃ ┃ ┃ ┗ 📂Requests
 ┃ ┃ ┣ 📂Logging
 ┃ ┃ ┣ 📂Mixins
 ┃ ┃ ┣ 📂Models
 ┃ ┃ ┗ 📂Providers
 ┃ ┣ 📂bootstrap
 ┃ ┣ 📂config
 ┃ ┣ 📂coverage-html
 ┃ ┣ 📂database
 ┃ ┃ ┣ 📂factories
 ┃ ┃ ┣ 📂migrations
 ┃ ┃ ┣ 📂seeders
 ┃ ┃ ┗ 📜.gitignore
 ┃ ┣ 📂lang
 ┃ ┣ 📂public
 ┃ ┣ 📂resources
 ┃ ┣ 📂routes
 ┃ ┣ 📂storage
 ┃ ┃ ┣ 📂app
 ┃ ┃ ┃ ┗ 📂public
 ┃ ┃ ┣ 📂framework
 ┃ ┃ ┗ 📂logs
 ┃ ┣ 📂tests
 ┃ ┃ ┣ 📂Feature
 ┃ ┃ ┗ 📂Unit
 ┃ ┣ 📂vendor
 ┃ ┣ 📜.env.dev
 ┃ ┣ 📜.env.example
 ┃ ┣ 📜.env.kind
 ┃ ┣ 📜.env.local
 ┃ ┣ 📜.env.prod
 ┃ ┣ 📜.env.staging
 ┃ ┣ 📜.gitignore
 ┃ ┣ 📜artisan
 ┃ ┣ 📜composer.json
 ┃ ┣ 📜composer.lock
 ┃ ┣ 📜package.json
 ┃ ┣ 📜phpstan.neon
 ┃ ┣ 📜phpunit.xml
 ┃ ┗ 📜Passport Token Auth.postman_collection.json
 ┣ 📜.gitattributes
 ┣ 📜.gitignore
 ┣ 📜docker-compose.dev.yml       # server-style image, baked config, local mysql
 ┣ 📜docker-compose.kind.yml      # same, for testing the "kind" k8s overlay's image
 ┣ 📜docker-compose.local.yml     # bind-mounted source, hot reload, local mysql
 ┣ 📜docker-compose.prod.yml      # server-style image, external DB required
 ┣ 📜docker-compose.staging.yml   # server-style image, external DB required
 ┣ 📜docker-compose.yml           # ad-hoc local smoke-test stack
 ┗ 📜README.md
```

This structure helps maintain a clear separation of concerns, making the project easier to navigate and scale.

-----

## ➡️ API Routes

The API is versioned under the `/v1` prefix.

### 🔓 Public Routes (`/v1/auth`)

These routes are publicly accessible and do not require a token.

| Method | Path | Description |
| :---: | :---: | :---: |
| `POST` | `/v1/auth/register` | Registers a new user account. 📝 |
| `POST` | `/v1/auth/login` | Authenticates a user and returns a Passport token. 🔑 |
| `POST` | `/v1/auth/forgot-password` | Initiates the password reset process. ❓ |
| `POST` | `/v1/auth/reset-password` | Resets a user's password using a valid token. 🔄 |
| `POST` | `/v1/auth/resend-verification-email` | Resends the email verification link. 📧 |
| `POST` | `/v1/auth/verify-email/{id}/{hash}` | Verifies a user's email address. ✅ |
| `GET` | `/v1/health` | A simple health check endpoint. ❤️‍🩹 |

### 🔒 Protected Routes (`/v1/auth`)

These routes require a valid Passport token and a verified email address (`auth:api` and `verified` middleware).

| Method | Path | Description |
| :---: | :---: | :---: |
| `POST` | `/v1/auth/refresh-token` | Generates a new token for the authenticated user. 🔄 |
| `POST` | `/v1/auth/logout` | Revokes the current API token. 🚪 |

### 🛡️ Role-Based Access Routes

These routes require both a valid token and a specific role.

| Method | Path | Required Role(s) |
| :---: | :---: | :---: |
| `GET` | `/v1/admin` | `Admin` or `Super Admin` 👑 |
| `GET` | `/v1/user` | `User` 🧑‍💻 |
| `GET` | `/v1/subscriber` | `Subscriber` 🔔 |

-----

## 🚀 Getting Started

### ⚙️ Prerequisites

  - Docker and Docker Compose 🐳
  - Git 🐙

### 🛠️ Installation Steps

1.  **Clone the repository:**

    ```bash
    git clone [repository-url]
    cd [project-directory]
    ```

2.  **Pick the compose file for what you're doing** — each one is standalone, run directly
    with `-f`, no copying needed:

    | File | Use case |
    | :--- | :--- |
    | `docker-compose.local.yml` | **Day-to-day development.** Bind-mounted source, hot reload, `composer install`/`migrate` run automatically on boot. |
    | `docker-compose.dev.yml` | Server-style baked image with a local mysql, for testing the "dev" build closer to how it deploys. |
    | `docker-compose.kind.yml` | Same, matching what the `k8s/overlays/kind` cluster runs — see [its README](k8s/overlays/kind/README.md). |
    | `docker-compose.staging.yml` / `docker-compose.prod.yml` | Server-style image, **no local mysql** — point them at a real database via env vars. |

    For local development:

    ```bash
    docker compose -f docker-compose.local.yml up -d --build
    ```

3.  **Install Passport** (migrations already ran automatically for you):

    ```bash
    docker compose -f docker-compose.local.yml exec app php artisan passport:keys --no-interaction
    docker compose -f docker-compose.local.yml exec app php artisan passport:client --personal --no-interaction
    ```

The API will now be running and accessible at `http://localhost:8000`. 🎉

-----

## ☸️ Kubernetes (Local Testing)

Want to run this app on a real local Kubernetes cluster instead of plain Docker Compose?
See [`k8s/overlays/kind/README.md`](k8s/overlays/kind/README.md) for the full walkthrough —
cluster setup, image loading, day-to-day commands, and a `k9s` cheat sheet.

-----

## 📬 Postman Collection

A **Postman Collection** is included at:

```
src/Passport Token Auth.postman_collection.json
```

You can import this collection into Postman and test the full authentication flow

-----

## 🧪 Running Tests & Code Quality Checks

To run the full test suite and code quality checks, execute the following commands.

### **PHPUnit**

To run the full test suite and check code coverage, execute the following command:

```bash
docker compose -f docker-compose.local.yml exec app vendor/bin/phpunit --testdox --coverage-html
```

To generate an HTML report of the code coverage, which will be saved in the `src/coverage-html` directory, use this command:

```bash
docker compose -f docker-compose.local.yml exec app vendor/bin/phpunit --testdox --coverage-html=coverage-html
```
To check coverage open `coverage-html/index.html` in a browser.


### **PHP-CS-Fixer** 🎨

PHP-CS-Fixer checks and fixes code style to ensure PSR-12 compliance.

  * **Check for code style violations:**
    ```bash
    docker compose -f docker-compose.local.yml exec app vendor/bin/php-cs-fixer fix app --dry-run --diff --verbose
    ```
  * **Fix all code style violations:**
    ```bash
    docker compose -f docker-compose.local.yml exec app vendor/bin/php-cs-fixer fix app
    ```

### **Larastan (PHPStan)** 🧐

Larastan performs static analysis to find potential bugs and code smells.

  * **Run a full static analysis:**
    ```bash
    docker compose -f docker-compose.local.yml exec app vendor/bin/phpstan analyse
    ```
  * **Generate a baseline to ignore existing errors:**
    ```bash
    docker compose -f docker-compose.local.yml exec app vendor/bin/phpstan analyse --generate-baseline
    ```

-----

## 🤝 Contributing

We welcome contributions\! 🙏 Please ensure your pull requests meet the following criteria:

  - Adhere to **100% PSR-12** standards. ✅
  - Include comprehensive tests to maintain **100% test coverage**. ✅🧪
  - Ensure all **GitHub Actions** workflows pass successfully. 🚦

-----

## 📜 License

This project is open-sourced software licensed under the **MIT license**. 📄