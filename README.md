# private-cast

A Human-Verified Prediction Market where votes and fund distribution stays fully private, built with Oasis Sapphire (for confidential smart contracts) and Worldcoin (for proof of humanity). 

## Deploy smart contract

Set up cli wallet with test tokens following [here](https://github.com/oasisprotocol/cli), used for deployment, deploy smart contract following [here](https://github.com/oasisprotocol/demo-starter). 

```
cd backend/
export PRIVATE_KEY=0x...  # from `oasis wallet show`
pnpm install
pnpm run build
npx hardhat deploy --network sapphire-testnet
```

If deployed is successful, find contract in console, e.g:

```
privateBetting address: 0x8D2590Cd6a283D9F62B81d7c5Ef5079A18E5cEA2
```

Put this value at `.env.development`:

```
VITE_MESSAGE_BOX_ADDR=0x8D2590Cd6a283D9F62B81d7c5Ef5079A18E5cEA2
```

To test:

```
npx hardhat compile
npx hardhat test
```

## Custom deploy for Worldcoin

Since Worldcoin is not officially deployed on Oasis Sapphire, an identical contract is deployed on Ethereum Sepolia to fully simulate the onchain proof verify function, whereas on the contract deployed on Oasis Sapphire, the verify call is disabled. (Per instructed after discussing with the folks at Worldcoin booth!)

```
cd backend/contracts/

forge build

forge create --rpc-url https://eth-sepolia.g.alchemy.com/v2/KWfOK-fU4mMPJ4BEQa3pJibaUygfHT9I --private-key 0x... src/PrivateBettingContract.sol:PrivateBettingContract --constructor-args 0x469449f251692e0779667583026b5a1e99512157 app_staging_f72dd6bf077c6464c43c5016d2b9cec5 place-bet

Deployer: 0x25F101BD751f4915694880a5Ef8b3D9e765a03aB
Deployed to: 0x636680ec68C513cFBd64e46eB8368a4d40f4248e
Transaction hash: 0xf906fd62c36c47e065480a9dce24301f8d9ffa13a5d0c3c2f476ecae2d50b712
```

## Run frontend

```
cd frontend/
pnpm install && pnpm dev
```

## Deployed site

https://aesthetic-centaur-ad2524.netlify.app/#/

Example transaction: https://explorer.stg.oasis.io/testnet/sapphire/tx/0xe6fcc95d52611a7275d187dc6e29b075f449285809f8de921b065bf5d73a4098