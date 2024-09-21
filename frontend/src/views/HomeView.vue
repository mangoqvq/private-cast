<script setup lang="ts">
import { onMounted, ref } from 'vue';

import { usePrivateBettingContract, useUnwrappedMessageBox } from '../contracts';
import { Network, useEthereumStore } from '../stores/ethereum';
import { abbrAddr } from '@/utils/utils';
import AppButton from '@/components/AppButton.vue';
import MessageLoader from '@/components/MessageLoader.vue';
import JazzIcon from '@/components/JazzIcon.vue';
import { retry } from '@/utils/promise';

const eth = useEthereumStore();
const messageBox = usePrivateBettingContract();
const uwMessageBox = useUnwrappedMessageBox();

const errors = ref<string[]>([]);
const allBetsVal = ref<string[]>([]);
const outcome = ref('');
const myBetsVal = ref<string[]>([]);
const isLoading = ref(true);
const isSettingMessage = ref(false);
const isCorrectNetworkSelected = ref<Boolean>(true);

interface Message {
  allbets: string[];
  author: string;
  myBets: string[];
}

function handleError(error: Error, errorMessage: string) {
  errors.value.push(`${errorMessage}: ${error.message ?? JSON.stringify(error)}`);
  console.error(error);
}

async function fetchMessage(): Promise<Message> {
  let bets = await messageBox.value!.getAllBets();
  console.log('bets', bets);
  const author = await messageBox.value!.owner();
  const allbets = (bets).map((bet) => `${bet.user} placed a bet on ${bet.choice} for amount ${bet.amount}`);
  console.log('eth.address', eth.address);
  const filteredBets = bets.filter((bet) => bet.user.toLowerCase() === eth.address!.toLowerCase());
  const myBets = (filteredBets).map((bet) => `${bet.choice} for amount ${bet.amount}`);
  return { allbets, author, myBets };
}

async function fetchAndSetBets(): Promise<Message | null> {
  let retrievedMessage: Message | null = null;

  try {
    retrievedMessage = await fetchMessage();
    allBetsVal.value = retrievedMessage.allbets;
    myBetsVal.value = retrievedMessage.myBets;
    return retrievedMessage;
  } catch (e) {
    handleError(e as Error, 'Failed to get message');
  } finally {
    isLoading.value = false;
  }
  console.log('retrievedMessagefkf');
  return retrievedMessage;
}

async function switchNetwork() {
  await eth.switchNetwork(Network.FromConfig);
}

async function connectAndSwitchNetwork() {
  await eth.connect();
  isCorrectNetworkSelected.value = await eth.checkIsCorrectNetwork();
  if (!isCorrectNetworkSelected.value) {
    await switchNetwork();
  }
  isCorrectNetworkSelected.value = await eth.checkIsCorrectNetwork();
}

onMounted(async () => {
  await connectAndSwitchNetwork();
  await fetchAndSetBets();
});

// Assuming winners is defined somewhere in your component
const winners = ref(['Lando', 'Oscar', 'Charles']); // Example winners
const amounts = ref<{ [key: string]: number }>({});
const selectedWinner = ref<{ [key: string]: boolean | null }>({});

// Call bet when Bet button is clicked
async function bet(winner: string) {
  const amount = amounts.value[winner] || 0; // Get the entered amount
  console.log(`Placing bet on ${winner}, Amount = ${amount}`);
  try {
    errors.value.splice(0, errors.value.length);
    isSettingMessage.value = true;

    await messageBox.value!.placeBet(winner, {value: amount});

    await retry<Promise<Message | null>>(fetchAndSetBets, (retrievedMessage) => {
      return retrievedMessage;
    });
  } catch (e: any) {
    handleError(e, 'Failed to set message');
  } finally {
    isSettingMessage.value = false;
  }
}

async function claimFunds(winner: number) {
  const amount = amounts.value[winner] || 0; // Get the entered amount
  console.log(`Placing bet on ${winner}, Amount = ${amount}`);
  try {
    await messageBox.value!.claimFunds(winner, {value: amount});
  } catch (e: any) {
    handleError(e, 'Failed to set message');
  } finally {
    isSettingMessage.value = false;
  }
}

async function setOutcome(winner: string) {
  console.log(`Setting outcome ${winner}`);
  try {
    await messageBox.value!.setOutcome(winner);

  } catch (e: any) {
    handleError(e, 'Failed to set message');
  }
}
</script>

<template>
  <section class="pt-5" v-if="isCorrectNetworkSelected">
    <h1 class="capitalize text-2xl text-white font-bold mb-4">Private Cast</h1>

    <h2 class="capitalize text-xl text-white font-bold mb-4">Singapore Grand Prix Winner</h2>
    <p class="text-base text-white mb-10">
      Cast your vote and the betting amount, fully private onchain.
    </p>

  <div>
    <div class="p-4 rounded-lg mb-4">
      <div v-for="winner in winners" :key="winner" class="mb-4">
        <div class="flex items-center">
          <div class="text-lg text-white">{{ winner }}</div>
          <input
            type="number"
            v-model="amounts[winner]"
            placeholder="Amount"
            class="border border-gray-300 p-1 rounded mr-2"
          />
          <AppButton type="submit" variant="primary"  @click="bet(winner)">
            <span v-if="isSettingMessage">Setting…</span>
            <span v-else>Bet</span>
          </AppButton>
        </div>
      </div>
    </div>

    <div v-if="errors.length > 0" class="text-red-500 px-3 mt-5 rounded-xl-sm">
      <span class="font-bold">Errors:</span>
      <ul class="list-disc px-8">
        <li v-for="error in errors" :key="error">{{ error }}</li>
      </ul>
    </div>
  </div>

  <div class="text-white">{{ outcome }}</div>
  <input
    type="text"
    placeholder="Outcome"
  />
  <AppButton type="submit" variant="primary"  @click="setOutcome(outcome)">
    <span>Admin: Set Outcome</span>
  </AppButton>

      <div v-if="errors.length > 0" class="text-red-500 px-3 mt-5 rounded-xl-sm">
        <span class="font-bold">Errors:</span>
        <ul class="list-disc px-8">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </div>
  </section>
  <h2 class="capitalize text-xl text-white font-bold mb-4">All bets</h2>
  <div class="message p-6 mb-6 rounded-xl border-2 border-gray-300" v-if="!isLoading">
    <div v-if="allBetsVal.length > 0">
      <div v-for="(bet, index) in allBetsVal" :key="index" class="flex items-center justify-between mb-2">
        <h2 class="text-lg lg:text-lg m-0">{{ bet }}</h2>
      </div>
    </div>
    <div v-else>
      <p>No bets found.</p>
    </div>
  </div>

  <h2 class="capitalize text-xl text-white font-bold mb-4">My Bets</h2>
  <div class="message p-6 mb-6 rounded-xl border-2 border-gray-300" v-if="!isLoading">
    <div v-if="myBetsVal.length > 0">
      <div v-for="(bet, index) in myBetsVal" :key="index" class="flex items-center justify-between mb-2">
        <h2 class="text-lg lg:text-lg m-0">{{ bet }}</h2>
        <button 
          class="ml-4 bg-blue-500 text-white px-4 py-2 rounded"
          @click="claimFunds(index)" 
        >
          Claim
        </button>
      </div>
    </div>
    <div v-else>
      <p>No bets found.</p>
    </div>
  </div>
  <div v-else>
    <div class="message p-6 pt-4 mb-6 rounded-xl border-2 border-gray-300">
      <MessageLoader />
    </div>
  </div>

  <section class="pt-5" v-else>
    <h2 class="capitalize text-white text-2xl font-bold mb-4">Invalid network detected</h2>
    <p class="text-white text-base mb-20">
      In order to continue to use the app, please switch to the correct chain, by clicking on the
      bellow "Switch network" button
    </p>

    <div class="flex justify-center">
      <AppButton variant="secondary" @click="switchNetwork">Switch network</AppButton>
    </div>
  </section>
</template>

<style scoped lang="postcss">
input {
  @apply block my-4 p-1 mx-auto text-3xl border border-gray-400 rounded-xl;
}

.form-group {
  @apply relative mb-6;
}

.form-group input,
textarea {
  @apply block rounded-xl py-6 px-5 w-full text-base text-black appearance-none focus:outline-none focus:ring-0 bg-white;
}

.form-group label {
  @apply absolute text-base text-primaryDark duration-300 transform -translate-y-5 scale-75 top-6 z-10 origin-[0] left-5;
}

.message {
  @apply bg-white rounded-xl border-primary;
  border-width: 3px;
  border-style: solid;
  box-shadow: 0 7px 7px 0 rgba(0, 0, 0, 0.17);
}
</style>
