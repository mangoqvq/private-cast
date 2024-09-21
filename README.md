# private-cast

A Human-Verified Prediction Market where votes and fund distribution stays fully private, built using Oasis Sapphire (for confidential smart contracts) and Worldcoin (for proof of humanity). 

## Deploy smart contract
Set up cli wallet with test tokens following [here](https://github.com/oasisprotocol/cli), then deploy smart contract following [here](https://github.com/oasisprotocol/demo-starter). 

```
cd backend/
pnpm build
export PRIVATE_KEY=0x
npx hardhat deploy --network sapphire-testnet
```

## Run frontend
```
cd frontend/
pnpm install && 