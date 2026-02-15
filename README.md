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

# The architecture until now

```mermaid

graph LR
    subgraph GitHub ["GitHub Ecosystem"]
        direction TB
        D[👤 Deployer] --> GH[GitHub Actions]
    end

    subgraph AWS ["AWS Cloud (us-east-1)"]
        direction TB
        TF{👷 Terraformers}
        S3_State[(🗄️ Terraform State)]
        S3_Blog[(📄 ucapistran-blog)]
    end

    GH --> TF
    TF --> S3_State
    TF --> S3_Blog

    %% Estilos mejorados
    style TF fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    style S3_Blog fill:#fff9c4,stroke:#fbc02d,stroke-width:2px
    style S3_State fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style GH fill:#eceff1,stroke:#455a64,stroke-width:2px

```
