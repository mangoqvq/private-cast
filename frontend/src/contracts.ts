import type { ComputedRef } from 'vue';
import { computed } from 'vue';

import { type PrivateBettingContract, PrivateBettingContract__factory } from '@oasisprotocol/demo-starter-backend';
export type { PrivateBettingContract } from '@oasisprotocol/demo-starter-backend';

import { useEthereumStore } from './stores/ethereum';
import { type ContractRunner, VoidSigner } from 'ethers';

const addr = import.meta.env.VITE_MESSAGE_BOX_ADDR!;

export function useMessageBox(): ComputedRef<PrivateBettingContract | null> {
  const eth = useEthereumStore();

  return computed(() => {
    if (!eth) {
      console.error('[useMessageBox] Ethereum Store not initialized');
      return null;
    }

    if (!eth.signer) {
      console.error('[useMessageBox] Signer is not initialized');
      return null;
    }

    return PrivateBettingContract__factory.connect(addr, eth.signer as ContractRunner);
  });
}

function initializeSigner(eth: ReturnType<typeof useEthereumStore>) {
  let signer = eth.unwrappedSigner;
  if (!signer && eth.unwrappedProvider) {
    signer = new VoidSigner(eth.address!, eth.unwrappedProvider);
  }
  return signer;
}

export function useUnwrappedMessageBox(): ComputedRef<PrivateBettingContract | null> {
  const eth = useEthereumStore();
  return computed(() => {
    if (!eth) {
      console.error('[useMessageBox] Ethereum Store not initialized');
      return null;
    }

    const signer = initializeSigner(eth);
    if (!signer) {
      console.error('[useMessageBox] Signer not initialized');
      return null;
    }

    return PrivateBettingContract__factory.connect(addr, signer);
  });
}
