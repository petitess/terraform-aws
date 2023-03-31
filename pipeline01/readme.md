### Bitbucket

```yaml
image: atlassian/default-image:2

pipelines:
  default:
    - step:
        script:
          - echo "This script runs on all branches that don't have any specific pipeline assigned in 'branches'."  
  branches:
    development:
      - step:
          script:
            - echo "development scripts like lint"   
    master:        
      - step:
          name: Build to S3
          script:
            - apt-get update
            - apt-get install -y zip
            - zip -r app.zip .
            - pipe: atlassian/aws-code-deploy:0.3.2
              variables:
                AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                APPLICATION_NAME: $APPLICATION_NAME
                S3_BUCKET: $S3_BUCKET
                COMMAND: 'upload'
                ZIP_FILE: 'app.zip'
                VERSION_LABEL: 'app-1.0.0'p       
      - step:
          name: Deploy build with CodeDeploy
          script:                 
            - pipe: atlassian/aws-code-deploy:0.3.2
              variables:
                AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                APPLICATION_NAME: $APPLICATION_NAME
                DEPLOYMENT_GROUP: $DEPLOYMENT_GROUP
                S3_BUCKET: $S3_BUCKET
                COMMAND: 'deploy'
                WAIT: 'true'
                VERSION_LABEL: 'app-1.0.0'
                IGNORE_APPLICATION_STOP_FAILURES: 'true'
                FILE_EXISTS_BEHAVIOR: 'OVERWRITE'

```
This is a basic image with just terraform and aws cli installed onto it.
```yaml
image: lewisstevens1/amazon-linux-terraform

aws-login: &aws-login |-
  STS=($( \
    aws sts assume-role-with-web-identity \
      --role-session-name terraform-execution \
      --role-arn arn:aws:iam::$ACCOUNT_ID:role/identity_provider_bitbucket_assume_role \
      --web-identity-token $BITBUCKET_STEP_OIDC_TOKEN \
      --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
      --output text \
  ));

  export AWS_ACCESS_KEY_ID=${STS[0]};
  export AWS_SECRET_ACCESS_KEY=${STS[1]};
  export AWS_SESSION_TOKEN=${STS[2]};
  export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION;

pipelines:
  branches:
    master:
      - step:
          name: plan-terraform
          oidc: true
          script:
            - *aws-login
            - terraform init && terraform plan

      - step:
          name: apply-terraform
          trigger: 'manual'
          oidc: true
          script:
            - *aws-login
            - terraform init && terraform plan -out terraform.tfplan
            - terraform apply terraform.tfplan
```
