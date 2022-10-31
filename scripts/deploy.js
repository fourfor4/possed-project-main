// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // We get the contract to deploy
  const PossedNFTMinter = await hre.ethers.getContractFactory(
    "PossedNFTMinter"
  );
  const minter = await PossedNFTMinter.deploy();

  await minter.deployed();
  console.log("PossedNFTMinter deployed to:", minter.address);
  console.log(`npx hardhat verify ${minter.address}`);

  const PossedNFT = await hre.ethers.getContractFactory("PossedNFT");
  const nft = await PossedNFT.deploy();

  await nft.deployed();
  console.log("PossedNFT deployed to:", nft.address);
  console.log(`npx hardhat verify ${nft.address}`);

  await (await nft.addMinter(minter.address)).wait();
  await (await minter.setPossedNFT(nft.address)).wait();

  await hre.run("verify:verify", {
    address: minter.address,
    constructorArguments: [],
  });
  await hre.run("verify:verify", {
    address: nft.address,
    constructorArguments: [],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
