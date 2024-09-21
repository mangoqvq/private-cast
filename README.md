# private-cast

A Human-Verified Prediction Market where votes and fund distribution stays fully private, built using Oasis Sapphire (for confidential smart contracts) and Worldcoin (for proof of humanity). 

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

## Run frontend

```
cd frontend/
pnpm install && pnpm dev
```
