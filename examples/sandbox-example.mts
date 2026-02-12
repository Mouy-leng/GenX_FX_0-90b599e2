/**
 * Vercel Sandbox Example
 * 
 * This example demonstrates how to use Vercel Sandbox to run code in an isolated environment.
 * 
 * Prerequisites:
 * 1. Run `vercel link` to link this project to Vercel
 * 2. Run `vercel env pull` to get the VERCEL_OIDC_TOKEN
 * 
 * Usage:
 * node --experimental-strip-types --env-file .env.local examples/sandbox-example.mts
 */

import { Sandbox } from "@vercel/sandbox";

async function main() {
  console.log("Creating Vercel Sandbox...");
  
  try {
    // Create a sandbox with Node.js 24 runtime
    const sandbox = await Sandbox.create({
      runtime: "node24",
      resources: { vcpus: 2 },
      timeout: 300000, // 5 minutes
    });

    console.log("✅ Sandbox created successfully!");
    console.log(`Sandbox ID: ${sandbox.id}`);

    // Example 1: Check Node.js version
    console.log("\n📦 Checking Node.js version...");
    const nodeVersion = await sandbox.runCommand({
      cmd: "node",
      args: ["--version"],
      stdout: process.stdout,
      stderr: process.stderr,
    });

    // Example 2: Write and execute a simple script
    console.log("\n📝 Creating and running a test script...");
    const testScript = `
      console.log("Hello from Vercel Sandbox!");
      console.log("Current directory:", process.cwd());
      console.log("Node version:", process.version);
      console.log("Platform:", process.platform);
    `;
    
    await sandbox.fs.writeFile("/vercel/sandbox/test.js", testScript);
    
    const scriptResult = await sandbox.runCommand({
      cmd: "node",
      args: ["/vercel/sandbox/test.js"],
      stdout: process.stdout,
      stderr: process.stderr,
    });

    console.log(`\n✅ Script execution completed with exit code: ${scriptResult.exitCode}`);

    // Example 3: Test Python runtime (if available)
    console.log("\n🐍 Testing Python availability...");
    const pythonTest = await sandbox.runCommand({
      cmd: "which",
      args: ["python3"],
      stdout: process.stdout,
      stderr: process.stderr,
    });

    // Cleanup
    console.log("\n🧹 Destroying sandbox...");
    await sandbox.destroy();
    console.log("✅ Sandbox destroyed successfully!");

  } catch (error) {
    console.error("❌ Error:", error);
    if (error instanceof Error) {
      console.error("Message:", error.message);
      if (error.message.includes("VERCEL_OIDC_TOKEN")) {
        console.error("\n💡 Tip: Run 'vercel env pull' to get your authentication token");
      }
    }
    process.exit(1);
  }
}

// Run the example
main().catch(console.error);
