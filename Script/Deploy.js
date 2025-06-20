const { ethers } = require("hardhat");

async function main() {
  try {
    console.log("Starting deployment of SolarPanelRegistry contract...");
    
    // Get the contract factory
    const SolarPanelRegistry = await ethers.getContractFactory("SolarPanelRegistry");
    
    // Deploy the contract
    console.log("Deploying SolarPanelRegistry...");
    const solarPanelRegistry = await SolarPanelRegistry.deploy();
    
    // Wait for deployment to complete
    await solarPanelRegistry.deployed();
    
    console.log("✅ SolarPanelRegistry deployed successfully!");
    console.log("📄 Contract Address:", solarPanelRegistry.address);
    console.log("🔗 Network: Core Blockchain Testnet");
    console.log("⛽ Deployment Gas Used:", (await solarPanelRegistry.deployTransaction.wait()).gasUsed.toString());
    
    // Display contract information
    console.log("\n📋 Contract Information:");
    console.log("Contract Name: SolarPanelRegistry");
    console.log("Compiler Version: 0.8.17");
    console.log("Network ID: 1114");
    console.log("RPC URL: https://rpc.test2.btcs.network");
    
    // Verify initial state
    console.log("\n🔍 Initial Contract State:");
    const totalPanels = await solarPanelRegistry.totalRegisteredPanels();
    const totalEnergy = await solarPanelRegistry.totalEnergyGenerated();
    const nextId = await solarPanelRegistry.nextPanelId();
    
    console.log("Total Registered Panels:", totalPanels.toString());
    console.log("Total Energy Generated:", totalEnergy.toString(), "kWh");
    console.log("Next Panel ID:", nextId.toString());
    
    console.log("\n🎉 Deployment completed successfully!");
    console.log("You can now interact with the SolarPanelRegistry contract at:", solarPanelRegistry.address);
    
  } catch (error) {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  }
}

// Execute the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Script execution failed:", error);
    process.exit(1);
  });
