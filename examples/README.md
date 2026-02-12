# Vercel Sandbox Examples

This directory contains examples demonstrating how to use Vercel Sandbox in the GenX Trading Platform.

## Prerequisites

1. **Vercel Account**: You need a Vercel account with Sandbox access
2. **Node.js 22+**: Required for running these examples
3. **Vercel CLI**: Install with `npm i -g vercel`

## Setup

1. Link this project to Vercel:
```bash
vercel link
```

2. Pull your authentication token:
```bash
vercel env pull
```

This will create a `.env.local` file with your `VERCEL_OIDC_TOKEN`.

## Examples

### sandbox-example.mts

A basic example demonstrating:
- Creating a sandbox with Node.js 24 runtime
- Running commands in the sandbox
- Writing and executing files in the sandbox
- Properly cleaning up sandbox resources

**Run it:**
```bash
node --experimental-strip-types --env-file .env.local examples/sandbox-example.mts
```

## Use Cases in Trading Platform

1. **Isolated Strategy Testing**: Test new trading strategies without affecting production
2. **Safe AI Model Training**: Train models in isolated environments with dedicated resources
3. **User Code Execution**: Safely execute user-provided trading scripts
4. **Testing Environment**: Create reproducible test environments for CI/CD

## Troubleshooting

### "VERCEL_OIDC_TOKEN is required"

Your authentication token is missing or expired. Run:
```bash
vercel env pull
```

### Sandbox Creation Timeout

Check your network connection and Vercel account status. The sandbox may take 10-30 seconds to initialize.

### Permission Denied

Ensure your Vercel account has Sandbox feature enabled. This may require a Pro or Enterprise plan.

## Resources

- [Vercel Sandbox Documentation](https://vercel.com/docs/vercel-sandbox)
- [Setup Guide](../docs/VERCEL_SANDBOX_SETUP.md)
- [GitHub Repository](https://github.com/vercel/sandbox)
