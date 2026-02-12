# Vercel Sandbox Setup Guide

## Overview

Vercel Sandbox allows you to run arbitrary code in isolated, ephemeral Linux VMs. This can be useful for:
- Testing trading strategies in isolated environments
- Running AI models without affecting the main system
- Safely executing user-provided code
- Testing code changes before deploying to production

## Prerequisites

1. **Vercel Account**: You need a Vercel account with Sandbox access
2. **Node.js 22+**: Required for running the Sandbox SDK

## Installation

The `@vercel/sandbox` package has already been installed in this project.

```bash
# Already installed in package.json
npm install @vercel/sandbox
```

## Authentication

### Method 1: OIDC Token (Recommended for Development)

1. Link your project to Vercel (if not already done):
```bash
vercel link
```

2. Pull your authentication token:
```bash
vercel env pull
```

This creates a `.env.local` file with `VERCEL_OIDC_TOKEN`. The token expires after 12 hours, so you'll need to run `vercel env pull` again when it expires.

### Method 2: Access Token (For Production or Custom Setups)

1. Go to your team settings and copy the team ID
2. Go to your project's settings and copy the project ID
3. Go to your [Vercel account settings](https://vercel.com/account/settings/tokens) and create a token scoped to your team

Add these to your `.env` file:
```
VERCEL_TEAM_ID=your_team_id
VERCEL_PROJECT_ID=your_project_id
VERCEL_TOKEN=your_access_token
```

## Basic Usage Example

Create a file `examples/sandbox-test.mts`:

```typescript
import { Sandbox } from "@vercel/sandbox";

async function testSandbox() {
  // Create a sandbox with Node.js 24 runtime
  const sandbox = await Sandbox.create({
    source: {
      url: "https://github.com/your-repo/your-project.git",
      type: "git",
    },
    resources: { vcpus: 2 },
    runtime: "node24",
    timeout: 300000, // 5 minutes
  });

  console.log("Sandbox created successfully!");

  // Run a command in the sandbox
  const result = await sandbox.runCommand({
    cmd: "node",
    args: ["--version"],
    stdout: process.stdout,
    stderr: process.stderr,
  });

  console.log(`Command exit code: ${result.exitCode}`);

  // Cleanup
  await sandbox.destroy();
}

testSandbox().catch(console.error);
```

Run it:
```bash
node --experimental-strip-types --env-file .env.local examples/sandbox-test.mts
```

## Use Cases for Trading Platform

### 1. Testing Trading Strategies

```typescript
import { Sandbox } from "@vercel/sandbox";

async function testStrategy(strategyCode: string) {
  const sandbox = await Sandbox.create({
    runtime: "python3.13",
    resources: { vcpus: 2 },
  });

  // Write strategy code to the sandbox
  await sandbox.fs.writeFile("/vercel/sandbox/strategy.py", strategyCode);

  // Run the strategy with test data
  const result = await sandbox.runCommand({
    cmd: "python",
    args: ["/vercel/sandbox/strategy.py"],
    stdout: process.stdout,
    stderr: process.stderr,
  });

  await sandbox.destroy();
  return result.exitCode === 0;
}
```

### 2. Running AI Model Training

```typescript
import { Sandbox } from "@vercel/sandbox";

async function trainModel() {
  const sandbox = await Sandbox.create({
    source: {
      url: "https://github.com/A6-9V/GenX_FX.git",
      type: "git",
    },
    runtime: "python3.13",
    resources: { vcpus: 4 }, // More resources for training
    timeout: 3600000, // 1 hour
  });

  // Install dependencies
  await sandbox.runCommand({
    cmd: "pip",
    args: ["install", "-r", "requirements.txt"],
    stdout: process.stdout,
    stderr: process.stderr,
  });

  // Run training script
  await sandbox.runCommand({
    cmd: "python",
    args: ["scripts/train_model.py"],
    stdout: process.stdout,
    stderr: process.stderr,
  });

  await sandbox.destroy();
}
```

### 3. Safe Execution of User Code

```typescript
import { Sandbox } from "@vercel/sandbox";

async function executeUserCode(userCode: string) {
  const sandbox = await Sandbox.create({
    runtime: "node24",
    resources: { vcpus: 1 },
    timeout: 60000, // 1 minute max
  });

  try {
    await sandbox.fs.writeFile("/vercel/sandbox/user-code.js", userCode);
    
    const result = await sandbox.runCommand({
      cmd: "node",
      args: ["/vercel/sandbox/user-code.js"],
      stdout: process.stdout,
      stderr: process.stderr,
    });

    return { success: result.exitCode === 0, exitCode: result.exitCode };
  } finally {
    await sandbox.destroy();
  }
}
```

## Limitations

- **Max Resources**: 8 vCPUs (2048 MB memory per vCPU)
- **Timeout**: 
  - Hobby: 45 minutes max
  - Pro/Enterprise: 5 hours max
  - Default: 5 minutes
- **Network**: Sandboxes have internet access

## Resources

- [Official Documentation](https://vercel.com/docs/vercel-sandbox)
- [SDK Reference](https://vercel.com/docs/vercel-sandbox/sdk-reference)
- [CLI Reference](https://vercel.com/docs/vercel-sandbox/cli-reference)
- [GitHub Repository](https://github.com/vercel/sandbox)

## Troubleshooting

### Token Expired
If you see authentication errors, your OIDC token may have expired:
```bash
vercel env pull
```

### Sandbox Creation Fails
Check your Vercel account has Sandbox access enabled and you have sufficient quota.

### Network Issues
Ensure your Vercel project has the necessary permissions and the sandbox runtime supports your use case.
