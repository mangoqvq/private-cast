# private-cast

A Human-Verified Prediction Market where votes and fund distribution stays fully private, built using Oasis Sapphire (for confidential smart contracts) and Worldcoin (for proof of humanity). 

## Deploy smart contract

Set up cli wallet with test tokens following [here](https://github.com/oasisprotocol/cli), used for deployment, deploy smart contract following [here](https://github.com/oasisprotocol/demo-starter). 

```
cd backend/
pnpm build
export PRIVATE_KEY=0x...  # from `oasis wallet show`
pnpm run build
npx hardhat deploy --network sapphire-testnet
```

To test:

```
npx hardhat compile
npx hardhat test
```

## Run frontend

```
cd frontend/
pnpm install && pnpm dev
```
