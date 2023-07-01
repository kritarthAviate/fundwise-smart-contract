const networks = {
  goerli: {
    LENDING_POOL_PROVIDER_ADDRESS: "0x5E52dEc931FFb32f609681B8438A51c675cc232d",
    AAVE_V2_ADDRESS: "0x3bd3a20Ac9Ff1dda1D99C0dFCE6D65C4960B3627",
    AAVE_ATOKEN_ADDRESS: "0x22404B0e2a7067068AcdaDd8f9D586F834cCe2c5",
  },
  mainnet: {
    LENDING_POOL_PROVIDER_ADDRESS: "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5",
    AAVE_V2_ADDRESS: "0xEFFC18fC3b7eb8E676dac549E0c693ad50D1Ce31",
    AAVE_ATOKEN_ADDRESS: "0x030bA81f1c18d280636F32af80b9AAd02Cf0854e",
  },
  polygon: {
    LENDING_POOL_PROVIDER_ADDRESS: "0xd05e3E715d945B59290df0ae8eF85c1BdB684744",
    AAVE_V2_ADDRESS: "0xAeBF56223F044a73A513FAD7E148A9075227eD9b",
    AAVE_ATOKEN_ADDRESS: "0x28424507fefb6f7f8E9D3860F56504E4e5f5f390",
  },
};
module.exports = {
  ...networks,
  hardhat: {
    ...networks.mainnet,
  },
};
