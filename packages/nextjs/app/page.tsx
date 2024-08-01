"use client";

import { NextPage } from "next";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";
import NFTGrid from "~~/components/NFTGrid";

const Home: NextPage = () => {
  const { writeContractAsync: writeYourContractAsync } = useScaffoldWriteContract("SVGNFT");

  const { data: priceData } = useScaffoldReadContract({
    contractName: "SVGNFT",
    functionName: "price",
  });

  const { data: noOfTokens } = useScaffoldReadContract({
    contractName: "SVGNFT",
    functionName: "tokenIds",
  });

  const mintToken = async () => {
    try {
      await writeYourContractAsync({
        functionName: "mintItem",
        value: priceData,
      });
    } catch (e) {
      console.error("Error setting greeting:", e);
    }
  }

  return (
    <div className="min-h-screen bg-black text-white">
      <div className="absolute inset-0 bg-gradient-to-br from-purple-900 via-blue-900 to-black opacity-50"></div>
      <main className="relative container mx-auto px-4 py-16">
        <h1 className="text-5xl md:text-7xl font-extrabold text-center mb-12 bg-clip-text text-transparent bg-gradient-to-r from-pink-500 via-purple-500 to-indigo-500 animate-pulse">
          Optimistic Loogies NFT
        </h1>
        <div className="flex justify-center mb-24">
          <button onClick={mintToken} className="bg-gradient-to-r from-pink-500 via-purple-500 to-indigo-500 text-white font-bold py-4 px-12 rounded-full transform hover:scale-105 transition duration-300 ease-in-out shadow-xl hover:shadow-2xl text-lg">
            Mint Your Loogie
          </button>
        </div>
        <NFTGrid noOfTokens={noOfTokens} />
      </main>
    </div>
  );
};

export default Home;