#!/usr/bin/env python3
"""
Environment Variable Validator
Validates environment variables against a YAML/JSON schema.
"""

import os
import sys
import re
import json
import argparse
from pathlib import Path
from typing import Any

import yaml

# Colors for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def log_info(msg: str) -> None:
    print(f"{Colors.GREEN}[✓]{Colors.NC} {msg}")

def log_warn(msg: str) -> None:
    print(f"{Colors.YELLOW}[!]{Colors.NC} {msg}")

def log_error(msg: str) -> None:
    print(f"{Colors.RED}[✗]{Colors.NC} {msg}")

def log_section(msg: str) -> None:
    print(f"\n{Colors.BLUE}==={Colors.NC} {msg} {Colors.BLUE}==={Colors.NC}")

def load_schema(schema_path: str) -> dict:
    """Load schema from YAML or JSON file."""
    path = Path(schema_path)

    if not path.exists():
        raise FileNotFoundError(f"Schema file not found: {schema_path}")

    with open(path, 'r') as f:
        if path.suffix in ['.yaml', '.yml']:
            return yaml.safe_load(f)
        elif path.suffix == '.json':
            return json.load(f)
        else:
            # Try YAML first, then JSON
            try:
                return yaml.safe_load(f)
            except:
                f.seek(0)
                return json.load(f)

def validate_type(value: str, expected_type: str) -> tuple[bool, str]:
    """Validate value against expected type."""
    if expected_type == 'string':
        return True, ""

    elif expected_type == 'integer':
        try:
            int(value)
            return True, ""
        except ValueError:
            return False, f"Expected integer, got '{value}'"

    elif expected_type == 'float' or expected_type == 'number':
        try:
            float(value)
            return True, ""
        except ValueError:
            return False, f"Expected number, got '{value}'"

    elif expected_type == 'boolean':
        if value.lower() in ['true', 'false', '1', '0', 'yes', 'no']:
            return True, ""
        return False, f"Expected boolean, got '{value}'"

    elif expected_type == 'url':
        url_pattern = re.compile(
            r'^https?://'
            r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'
            r'localhost|'
            r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'
            r'(?::\d+)?'
            r'(?:/?|[/?]\S+)$', re.IGNORECASE)
        if url_pattern.match(value):
            return True, ""
        return False, f"Invalid URL format: '{value}'"

    elif expected_type == 'email':
        email_pattern = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        if email_pattern.match(value):
            return True, ""
        return False, f"Invalid email format: '{value}'"

    elif expected_type == 'port':
        try:
            port = int(value)
            if 1 <= port <= 65535:
                return True, ""
            return False, f"Port must be between 1 and 65535, got {port}"
        except ValueError:
            return False, f"Expected port number, got '{value}'"

    elif expected_type == 'ip':
        ip_pattern = re.compile(r'^(\d{1,3}\.){3}\d{1,3}$')
        if ip_pattern.match(value):
            parts = value.split('.')
            if all(0 <= int(p) <= 255 for p in parts):
                return True, ""
        return False, f"Invalid IP address: '{value}'"

    return True, ""

def validate_pattern(value: str, pattern: str) -> tuple[bool, str]:
    """Validate value against regex pattern."""
    try:
        if re.match(pattern, value):
            return True, ""
        return False, f"Value '{value}' does not match pattern '{pattern}'"
    except re.error as e:
        return False, f"Invalid regex pattern: {e}"

def validate_enum(value: str, allowed: list) -> tuple[bool, str]:
    """Validate value is in allowed list."""
    if value in allowed:
        return True, ""
    return False, f"Value '{value}' not in allowed values: {allowed}"

def validate_length(value: str, min_len: int = None, max_len: int = None) -> tuple[bool, str]:
    """Validate string length."""
    length = len(value)

    if min_len is not None and length < min_len:
        return False, f"Length {length} is less than minimum {min_len}"

    if max_len is not None and length > max_len:
        return False, f"Length {length} exceeds maximum {max_len}"

    return True, ""

def validate_variable(name: str, spec: dict, env_vars: dict) -> tuple[bool, list[str]]:
    """Validate a single environment variable against its spec."""
    errors = []
    value = env_vars.get(name)

    # Check if required
    required = spec.get('required', True)
    if value is None or value == '':
        if required:
            errors.append(f"Required variable is missing or empty")
            return False, errors
        else:
            return True, []

    # Check type
    if 'type' in spec:
        valid, error = validate_type(value, spec['type'])
        if not valid:
            errors.append(error)

    # Check pattern
    if 'pattern' in spec:
        valid, error = validate_pattern(value, spec['pattern'])
        if not valid:
            errors.append(error)

    # Check enum
    if 'enum' in spec:
        valid, error = validate_enum(value, spec['enum'])
        if not valid:
            errors.append(error)

    # Check length
    if 'min_length' in spec or 'max_length' in spec:
        valid, error = validate_length(
            value,
            spec.get('min_length'),
            spec.get('max_length')
        )
        if not valid:
            errors.append(error)

    return len(errors) == 0, errors

def validate_env(schema: dict, env_vars: dict = None) -> tuple[bool, dict]:
    """Validate all environment variables against schema."""
    if env_vars is None:
        env_vars = dict(os.environ)

    results = {
        'valid': [],
        'invalid': [],
        'missing': [],
        'warnings': []
    }

    variables = schema.get('variables', schema)

    for var_name, spec in variables.items():
        if isinstance(spec, str):
            # Simple format: VAR_NAME: type
            spec = {'type': spec}

        valid, errors = validate_variable(var_name, spec, env_vars)

        if valid:
            if var_name in env_vars and env_vars[var_name]:
                results['valid'].append(var_name)
            elif not spec.get('required', True):
                results['warnings'].append(f"{var_name}: Optional variable not set")
        else:
            if env_vars.get(var_name) is None:
                results['missing'].append({'name': var_name, 'errors': errors})
            else:
                results['invalid'].append({'name': var_name, 'value': env_vars.get(var_name), 'errors': errors})

    return len(results['invalid']) == 0 and len(results['missing']) == 0, results

def print_results(results: dict, verbose: bool = False) -> None:
    """Print validation results."""
    log_section("Validation Results")

    # Valid variables
    if results['valid']:
        log_info(f"{len(results['valid'])} variables passed validation")
        if verbose:
            for var in results['valid']:
                print(f"    {var}")

    # Warnings
    if results['warnings']:
        log_warn(f"{len(results['warnings'])} warnings")
        for warning in results['warnings']:
            print(f"    {warning}")

    # Missing variables
    if results['missing']:
        log_error(f"{len(results['missing'])} required variables missing")
        for item in results['missing']:
            print(f"    {item['name']}: {', '.join(item['errors'])}")

    # Invalid variables
    if results['invalid']:
        log_error(f"{len(results['invalid'])} variables failed validation")
        for item in results['invalid']:
            print(f"    {item['name']}={item['value']}")
            for error in item['errors']:
                print(f"        └─ {error}")

def generate_example_schema() -> str:
    """Generate an example schema."""
    return """# Environment Variable Schema
# Supported types: string, integer, float, boolean, url, email, port, ip

variables:
  # Required string variable
  DATABASE_URL:
    type: url
    required: true
    description: Database connection URL

  # Required with enum values
  NODE_ENV:
    type: string
    required: true
    enum: [development, staging, production]
    description: Application environment

  # Optional with default
  PORT:
    type: port
    required: false
    description: Server port

  # Pattern matching
  API_KEY:
    type: string
    required: true
    pattern: "^[a-zA-Z0-9]{32}$"
    min_length: 32
    max_length: 32
    description: API key (32 alphanumeric characters)

  # Email validation
  ADMIN_EMAIL:
    type: email
    required: true
    description: Administrator email

  # Boolean
  DEBUG:
    type: boolean
    required: false
    description: Enable debug mode

  # Integer with no additional validation
  MAX_CONNECTIONS:
    type: integer
    required: false
    description: Maximum number of connections
"""

def main():
    parser = argparse.ArgumentParser(
        description='Validate environment variables against a schema',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -s schema.yaml
  %(prog)s -s schema.json --verbose
  %(prog)s --generate-example > schema.yaml
        """
    )
    parser.add_argument(
        '-s', '--schema',
        help='Path to schema file (YAML or JSON)'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Show detailed output'
    )
    parser.add_argument(
        '--generate-example',
        action='store_true',
        help='Generate example schema and exit'
    )
    parser.add_argument(
        '--env-file',
        help='Load environment from .env file'
    )

    args = parser.parse_args()

    if args.generate_example:
        print(generate_example_schema())
        return 0

    if not args.schema:
        # Try default paths
        default_paths = ['env.schema.yaml', 'env.schema.yml', 'env.schema.json', '.env.schema']
        for path in default_paths:
            if Path(path).exists():
                args.schema = path
                break

        if not args.schema:
            parser.error("Schema file required. Use -s/--schema or create env.schema.yaml")

    # Load environment from file if specified
    env_vars = dict(os.environ)
    if args.env_file:
        env_path = Path(args.env_file)
        if env_path.exists():
            with open(env_path) as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, _, value = line.partition('=')
                        env_vars[key.strip()] = value.strip().strip('"\'')

    print(f"{Colors.BLUE}Environment Variable Validator{Colors.NC}")
    print(f"Schema: {args.schema}")

    try:
        schema = load_schema(args.schema)
        valid, results = validate_env(schema, env_vars)
        print_results(results, args.verbose)

        print()
        if valid:
            log_info("All validations passed!")
            return 0
        else:
            log_error("Validation failed!")
            return 1

    except FileNotFoundError as e:
        log_error(str(e))
        return 1
    except Exception as e:
        log_error(f"Error: {e}")
        return 1

if __name__ == '__main__':
    sys.exit(main())
