# 🚀 blog-iac

This project manages the **Serverless Infrastructure as Code (IaC)** for the blog. It utilizes Terraform to orchestrate a high-performance, event-driven architecture based on AWS best practices.

## 🛠️ Stack & Services

- **Infrastructure:** Terraform (S3 Backend for State)
- **Identity:** Amazon Cognito (User Pools & Clients)
- **Compute:** AWS Lambda (Node.js 22 - Post-Confirmation Trigger)
- **Database:** Amazon DynamoDB (Single Table Design)
- **Frontend Hosting:** AWS S3 + CloudFront (Static Web Hosting)

## 🏗️ Installation & Setup

### 1. Install Terraform

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### 2. Bootstrap the environment

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

### 🗺️ Infrastructure Architecture

In this version, we removed external dependencies (Neon DB) to favor a fully AWS-native ecosystem. Red nodes indicate the core of the new identity-to-data synchronization flow.

```mermaid
graph TD
    subgraph External_User [🌐 Internet]
        User["💻 User (Next.js App)"]
    end

    subgraph GitHub_Actions [🚀 GitHub Actions Pipeline]
        Runner["🍊 Orange Pi Runner (Node 23)"]
        B["⚙️ Terraform Plan/Apply"]
        Runner --> B
        S1["📦 S3: Terraform State"] --- B
    end

    subgraph AWS_Cloud [☁️ AWS Cloud - us-east-1]

        subgraph Entry_Point [🌐 API & Gateway]
            AGW["🔗 API Gateway (HTTP API)"]
        end

        subgraph Auth_Identity [🆔 Identity]
            I["👥 Cognito User Pool"]
            J["🔑 User Pool Client"]
            I <--> J
        end

        subgraph Compute_Layer [🖥️ Compute]
            L_AUTH["⚡ Lambda (Node): blog-auth-handler"]
            L_POSTS["🐍 Lambda (Python): blog-posts-handler"]

            I -- "Trigger: Post-Confirmation" --> L_AUTH
        end

        subgraph Storage_Layer [📦 Data Persistence]
            DB["💎 DynamoDB: blog-website-table"]
            GSI["🔍 GSI: SlugIndex"]
            DB --- GSI
        end

        subgraph IAM_Control [🛡️ IAM & Permissions]
            RoleA["📜 Auth IAM Role"]
            RoleP["📜 Posts IAM Role"]
            PolP["✅ Policy: DynamoDB Index Query"]

            L_AUTH --- RoleA
            L_POSTS --- RoleP
            RoleP --- PolP
        end
    end

    %% Flow Connections
    User -- "1. API Requests" --> AGW
    AGW -- "/signup" --> L_AUTH
    AGW -- "/posts" --> L_POSTS
    L_AUTH -- "2. Sync Profile" --> DB
    L_POSTS -- "3. CRUD & Slug Query" --> DB

    %% Highlighted Changes (RED) for the new Post Infrastructure
    style AGW fill:#000,stroke:#ff0000,stroke-width:3px,color:#ff0000
    style L_POSTS fill:#000,stroke:#ff0000,stroke-width:3px,color:#ff0000
    style RoleP fill:#000,stroke:#ff0000,stroke-width:3px,color:#ff0000
    style PolP fill:#000,stroke:#ff0000,stroke-width:3px,color:#ff0000
    style GSI fill:#000,stroke:#ff0000,stroke-width:3px,color:#ff0000
    style Runner fill:#000,stroke:#ff0000,stroke-width:3px,color:#ff0000
```

### 📝 Key Infrastructure Notes

Identity-First: Users are only persisted to DynamoDB after successful Cognito confirmation.

No RDS/Secrets Manager: Simplified security model using IAM Roles instead of database credentials.

Node.js 22 Runtime: Optimized Lambda environment with AWS SDK v3 pre-installed.
