import React from "react";
import Link from "next/link";
import { hardhat } from "viem/chains";
import { CurrencyDollarIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import { SwitchTheme } from "~~/components/SwitchTheme";
import { Faucet } from "~~/components/scaffold-eth";
import { useTargetNetwork } from "~~/hooks/scaffold-eth/useTargetNetwork";
import { useGlobalState } from "~~/services/store/store";

export const Footer = () => {
  const nativeCurrencyPrice = useGlobalState(state => state.nativeCurrency.price);
  const { targetNetwork } = useTargetNetwork();
  const isLocalNetwork = targetNetwork.id === hardhat.id;

  return (
    <footer className="relative w-full py-4">
      <div className="absolute inset-0 bg-gradient-to-t from-purple-900 via-blue-900 to-transparent opacity-50"></div>
      <div className="relative container mx-auto px-4">
        <div className="flex flex-col md:flex-row justify-between items-center gap-4">
          <div className="flex flex-wrap gap-2 items-center">
            {nativeCurrencyPrice > 0 && (
              <div className="btn btn-sm font-normal gap-1 cursor-auto bg-gradient-to-r from-pink-500 via-purple-500 to-indigo-500 text-white border-none hover:brightness-110 transition-all">
                <CurrencyDollarIcon className="h-4 w-4" />
                <span>{nativeCurrencyPrice.toFixed(2)}</span>
              </div>
            )}
            {isLocalNetwork && (
              <>
                <Faucet />
                <Link
                  href="/blockexplorer"
                  className="btn btn-sm font-normal gap-1 bg-gradient-to-r from-pink-500 via-purple-500 to-indigo-500 text-white border-none hover:brightness-110 transition-all"
                >
                  <MagnifyingGlassIcon className="h-4 w-4" />
                  <span>Block Explorer</span>
                </Link>
              </>
            )}
          </div>
          <div className="text-center">
            <p className="text-sm font-semibold bg-clip-text text-transparent bg-gradient-to-r from-pink-500 via-purple-500 to-indigo-500">
              &copy; 2024 Optimistic Loogies NFT. All rights reserved.
            </p>
          </div>
          <SwitchTheme className="bg-gradient-to-r from-pink-500 via-purple-500 to-indigo-500 rounded-full p-1 hover:brightness-110 transition-all" />
        </div>
      </div>
    </footer>
  );
};
