# blog-iac

This project is to build the architecture behind a severless blog using Terraform for IAC
the services included in are

- AM Policy
- AWS CDK
- AWS S3

Steps

## Install Terraform

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

## Add Autocomplete feature

```
terraform -install-autocomplete
```

# Execute the bootstrap script

```
 chmod +x bootstrap.sh
./bootstrap.sh
```

# Architecture

```mermaid
graph TD
    subgraph GitHub_Actions [🚀 GitHub Actions Pipeline]
        A["🔐 Secrets: DB_URL, AUTH_SECRET"] --> B["⚙️ Terraform Plan/Apply"]
    end

    subgraph AWS_Cloud [☁️ AWS Cloud - us-east-1]
        subgraph Storage_Layer [🪣 Storage & State]
            S1["📦 S3: Terraform State"] --- B
            S2["📦 S3: ucapistran-blog"]
        end

        subgraph IAM_Control [🛡️ IAM & Permissions]
            C["👥 Group: terraformers"] -- "Manual Policy" --> D["👑 Admin Privileges"]
            E["📜 Auth Lambda Role"] -- "🤝 Trust" --> F["⚡ Lambda Service"]
        end

        subgraph Compute_Layer [🖥️ Compute]
            F --> G["📦 Lambda: auth-handler"]
            G -- "📖 Reads" --> H["🆔 Env Vars (Cognito, Secrets)"]
        end

        subgraph Auth_Identity [🆔 Identity]
            I["👥 Cognito User Pool"] <--> J["🔑 User Pool Client"]
            G -- "🛠️ Admin Actions" --> I
        end
    end

    subgraph External [🐘 Database]
        K["💎 Neon PostgreSQL"] <--> G
    end

    B -- "🏗️ Deploys" --> G
    B -- "🔧 Configures" --> I
    B -- "✍️ Creates" --> E
    B -- "💾 Manages State in" --> S1
```
