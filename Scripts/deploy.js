const { ethers } = require("hardhat");

async function main() {
  const AlgorithmicMusicCollab = await ethers.getContractFactory("AlgorithmicMusicCollab");
  const contract = await AlgorithmicMusicCollab.deploy();

  await contract.deployed();

  console.log("AlgorithmicMusicCollab deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:", error);
    process.exit(1);
  });
