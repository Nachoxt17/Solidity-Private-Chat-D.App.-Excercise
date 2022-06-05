async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Database = await ethers.getContractFactory(
    "Database"
  );
  const database = await BaseSmartContract.deploy();

  console.log("Database Contract Address:", database.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
