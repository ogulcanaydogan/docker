#!/usr/bin/env python3
import os
import sys
import json

def get_aws_secret(secret_name, region):
    """Fetch secret from AWS Secrets Manager"""
    import boto3
    from botocore.exceptions import ClientError

    client = boto3.client('secretsmanager', region_name=region)

    try:
        response = client.get_secret_value(SecretId=secret_name)
        if 'SecretString' in response:
            return json.loads(response['SecretString'])
        return None
    except ClientError as e:
        print(f"Error fetching secret: {e}")
        sys.exit(1)

def get_vault_secret(secret_path, vault_addr, vault_token):
    """Fetch secret from HashiCorp Vault"""
    import hvac

    client = hvac.Client(url=vault_addr, token=vault_token)

    if not client.is_authenticated():
        print("Error: Vault authentication failed")
        sys.exit(1)

    try:
        secret = client.secrets.kv.v2.read_secret_version(path=secret_path)
        return secret['data']['data']
    except Exception as e:
        print(f"Error fetching secret: {e}")
        sys.exit(1)

def write_env_file(secrets, output_file):
    """Write secrets to .env file"""
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    with open(output_file, 'w') as f:
        for key, value in secrets.items():
            f.write(f'{key}={value}\n')

    print(f"Secrets written to {output_file}")

def main():
    provider = os.environ.get('SECRETS_PROVIDER', 'aws')
    output_file = os.environ.get('OUTPUT_FILE', '/secrets/.env')

    if provider == 'aws':
        secret_name = os.environ.get('SECRET_NAME')
        region = os.environ.get('AWS_REGION', 'us-east-1')

        if not secret_name:
            print("Error: SECRET_NAME is required for AWS provider")
            sys.exit(1)

        print(f"Fetching secret '{secret_name}' from AWS Secrets Manager")
        secrets = get_aws_secret(secret_name, region)

    elif provider == 'vault':
        secret_path = os.environ.get('VAULT_SECRET_PATH')
        vault_addr = os.environ.get('VAULT_ADDR')
        vault_token = os.environ.get('VAULT_TOKEN')

        if not all([secret_path, vault_addr, vault_token]):
            print("Error: VAULT_SECRET_PATH, VAULT_ADDR, and VAULT_TOKEN are required for Vault provider")
            sys.exit(1)

        print(f"Fetching secret from Vault: {secret_path}")
        secrets = get_vault_secret(secret_path, vault_addr, vault_token)
    else:
        print(f"Error: Unknown provider '{provider}'")
        sys.exit(1)

    if secrets:
        write_env_file(secrets, output_file)
        print("Secrets init complete")
    else:
        print("Error: No secrets retrieved")
        sys.exit(1)

if __name__ == '__main__':
    main()
