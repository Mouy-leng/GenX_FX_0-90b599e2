#!/usr/bin/env python3
"""
Setup Validation Script for GenX FX Trading Platform
Verifies that all dependencies and configurations are properly set up.
"""

import sys
import os
import subprocess
from pathlib import Path


class Colors:
    """ANSI color codes for terminal output"""
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'


def print_header(text):
    """Print a formatted header"""
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'=' * 60}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{text.center(60)}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'=' * 60}{Colors.RESET}\n")


def print_success(text):
    """Print success message"""
    print(f"{Colors.GREEN}✓ {text}{Colors.RESET}")


def print_warning(text):
    """Print warning message"""
    print(f"{Colors.YELLOW}⚠ {text}{Colors.RESET}")


def print_error(text):
    """Print error message"""
    print(f"{Colors.RED}✗ {text}{Colors.RESET}")


def print_info(text):
    """Print info message"""
    print(f"{Colors.BLUE}ℹ {text}{Colors.RESET}")


def check_python_version():
    """Check Python version"""
    print_info("Checking Python version...")
    version = sys.version_info
    version_str = f"{version.major}.{version.minor}.{version.micro}"
    
    if version.major == 3 and version.minor >= 11:
        print_success(f"Python {version_str} - OK")
        return True
    else:
        print_error(f"Python {version_str} - Required: Python 3.11+")
        return False


def check_python_packages():
    """Check if key Python packages are installed"""
    print_info("Checking Python packages...")
    required_packages = [
        ('fastapi', 'fastapi'),
        ('uvicorn', 'uvicorn'),
        ('pandas', 'pandas'),
        ('numpy', 'numpy'),
        ('scikit-learn', 'sklearn'),
        ('xgboost', 'xgboost'),
        ('lightgbm', 'lightgbm'),
        ('pytest', 'pytest'),
    ]
    
    missing = []
    for display_name, import_name in required_packages:
        try:
            __import__(import_name)
            print_success(f"{display_name} - Installed")
        except ImportError:
            print_error(f"{display_name} - Missing")
            missing.append(display_name)
    
    if missing:
        print_warning(f"Missing packages: {', '.join(missing)}")
        print_info("Run: pip install -r requirements.txt")
        return False
    
    return True


def check_node_version():
    """Check Node.js version"""
    print_info("Checking Node.js version...")
    try:
        result = subprocess.run(['node', '--version'], 
                              capture_output=True, text=True, check=True)
        version = result.stdout.strip()
        major_version = int(version.split('.')[0].replace('v', ''))
        
        if major_version >= 18:
            print_success(f"Node.js {version} - OK")
            return True
        else:
            print_error(f"Node.js {version} - Required: Node.js 18+")
            return False
    except (subprocess.CalledProcessError, FileNotFoundError):
        print_error("Node.js not found")
        return False


def check_npm_packages():
    """Check if npm packages are installed"""
    print_info("Checking npm packages...")
    node_modules = Path('node_modules')
    
    if not node_modules.exists():
        print_error("node_modules not found")
        print_info("Run: npm install")
        return False
    
    # Check for key packages
    key_packages = [
        'react',
        'vite',
        'express',
        '@tanstack/react-query',
        'tailwindcss'
    ]
    
    missing = []
    for package in key_packages:
        package_dir = node_modules / package
        if not package_dir.exists():
            print_error(f"{package} - Missing")
            missing.append(package)
        else:
            print_success(f"{package} - Installed")
    
    if missing:
        print_warning(f"Missing packages: {', '.join(missing)}")
        print_info("Run: npm install")
        return False
    
    return True


def check_env_file():
    """Check if .env file exists"""
    print_info("Checking environment configuration...")
    env_file = Path('.env')
    env_example = Path('.env.example')
    
    if not env_file.exists():
        print_warning(".env file not found")
        if env_example.exists():
            print_info("Copy .env.example to .env and configure your API keys")
            print_info("Run: cp .env.example .env")
        return False
    else:
        print_success(".env file exists")
        
        # Check for required variables (just check if they're defined, not if they have values)
        required_vars = ['GEMINI_API_KEY', 'LOG_LEVEL', 'PORT']
        with open(env_file) as f:
            content = f.read()
        
        missing_vars = []
        for var in required_vars:
            if var not in content:
                missing_vars.append(var)
        
        if missing_vars:
            print_warning(f"Missing variables: {', '.join(missing_vars)}")
            return False
        
        # Check if key variables have values (warn but don't fail)
        empty_vars = []
        for var in ['GEMINI_API_KEY']:
            if f"{var}=" in content:
                value = content.split(f"{var}=")[1].split('\n')[0].strip()
                if not value or value == "":
                    empty_vars.append(var)
        
        if empty_vars:
            print_info(f"Note: Configure these variables before running: {', '.join(empty_vars)}")
        
        return True


def check_directories():
    """Check if required directories exist"""
    print_info("Checking directory structure...")
    required_dirs = [
        'api',
        'core',
        'ai_models',
        'client',
        'services',
        'tests',
        'docs'
    ]
    
    all_exist = True
    for dir_name in required_dirs:
        dir_path = Path(dir_name)
        if dir_path.exists():
            print_success(f"{dir_name}/ - OK")
        else:
            print_error(f"{dir_name}/ - Missing")
            all_exist = False
    
    return all_exist


def check_git_repo():
    """Check if git repository is properly initialized"""
    print_info("Checking git repository...")
    git_dir = Path('.git')
    
    if not git_dir.exists():
        print_warning("Not a git repository")
        return False
    
    try:
        result = subprocess.run(['git', 'status'], 
                              capture_output=True, text=True, check=True)
        print_success("Git repository - OK")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print_error("Git command failed")
        return False


def check_docker():
    """Check if Docker is available (optional)"""
    print_info("Checking Docker (optional)...")
    try:
        result = subprocess.run(['docker', '--version'], 
                              capture_output=True, text=True, check=True)
        version = result.stdout.strip()
        print_success(f"{version} - Available")
        
        # Check docker-compose
        try:
            result = subprocess.run(['docker-compose', '--version'], 
                                  capture_output=True, text=True, check=True)
            compose_version = result.stdout.strip()
            print_success(f"{compose_version} - Available")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print_warning("docker-compose not found (optional)")
        
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print_warning("Docker not found (optional for development)")
        return False


def run_quick_test():
    """Run a quick test to verify the setup"""
    print_info("Running quick test...")
    try:
        result = subprocess.run(
            ['python', '-m', 'pytest', 'tests/test_basic.py', '-v'],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            print_success("Basic tests passed")
            return True
        else:
            print_error("Basic tests failed")
            print_info("Output:")
            print(result.stdout)
            print(result.stderr)
            return False
    except subprocess.TimeoutExpired:
        print_error("Tests timed out")
        return False
    except Exception as e:
        print_error(f"Test execution failed: {e}")
        return False


def main():
    """Main validation function"""
    print_header("GenX FX Setup Validation")
    
    checks = {
        "Python Version": check_python_version,
        "Python Packages": check_python_packages,
        "Node.js Version": check_node_version,
        "npm Packages": check_npm_packages,
        "Environment File": check_env_file,
        "Directory Structure": check_directories,
        "Git Repository": check_git_repo,
        "Docker": check_docker,
        "Quick Test": run_quick_test,
    }
    
    results = {}
    
    for check_name, check_func in checks.items():
        print(f"\n{Colors.BOLD}→ {check_name}{Colors.RESET}")
        results[check_name] = check_func()
    
    # Summary
    print_header("Validation Summary")
    
    passed = sum(1 for result in results.values() if result)
    total = len(results)
    
    for check_name, result in results.items():
        status = f"{Colors.GREEN}✓ PASS{Colors.RESET}" if result else f"{Colors.RED}✗ FAIL{Colors.RESET}"
        print(f"{check_name:.<40} {status}")
    
    print(f"\n{Colors.BOLD}Result: {passed}/{total} checks passed{Colors.RESET}")
    
    if passed == total:
        print_success("\n🎉 All checks passed! Your setup is ready.")
        print_info("Next steps:")
        print_info("  1. Configure your .env file with API keys")
        print_info("  2. Run 'npm run dev' to start the development server")
        print_info("  3. Visit http://localhost:5173 to access the application")
        return 0
    else:
        print_warning("\n⚠️  Some checks failed. Please review the errors above.")
        print_info("For help, see SETUP.md or visit:")
        print_info("  https://github.com/Mouy-leng/GenX_FX_0/issues")
        return 1


if __name__ == "__main__":
    sys.exit(main())
