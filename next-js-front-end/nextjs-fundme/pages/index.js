import Head from "next/head";
import Image from "next/image";
import { Bonheur_Royale, Bruno_Ace, Inter } from "next/font/google";
import styles from "@/styles/Home.module.css";
import { useState } from "react";
import { ethers } from "ethers";
const inter = Inter({ subsets: ["latin"] });

export default function Home() {

  const [isConnected, setIsConnected] = useState(false);
  const [signer, setSigner] = useState();
  const [isOwner, setIsOwner] = useState(false);
  const contractAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
  const provider = new ethers.providers.JsonRpcProvider('http://127.0.0.1:8545');


  async function connect() {
    if (typeof window.ethereum !== "undefined") {
      try {
        await ethereum.request({ method: "eth_requestAccounts" });
        setIsConnected(true);
        let connectedProvider = new ethers.providers.Web3Provider(window.ethereum);
        console.log(connectedProvider);
        setSigner(connectedProvider.getSigner());
      } catch (e) {
        console.log(e);
      }
    } else {
      setIsConnected(false);
    }
  }

  async function fund() {
    const abi = require("./../abi/FundMe.json");
    const contract = new ethers.Contract(contractAddress, abi, signer);
    try {
      await contract.fund({ value: ethers.utils.parseEther('1') });
      console.log("Transaction successful");
    } catch (e) {
      console.log(e);
    }
  }

  async function checkContractBalance() {
    const abi = require("./../abi/FundMe.json");
    const contract = new ethers.Contract(contractAddress, abi, signer);
    try {
      const balance = await provider.getBalance(contractAddress);
      console.log(ethers.utils.formatEther(balance));
    } catch (e) {
      console.log(e);
    }
  }

  async function withdraw() {
    const abi = require("./../abi/FundMe.json");
    const contract = new ethers.Contract(contractAddress, abi, signer);
    try {
      await contract.cheaperWithdraw();
    }
    catch (e) {
      console.log(e);
    }
  }

  return (
    <>
      <div className={styles.container}>
        WEB3!!

      </div>
      {isConnected ? <button onClick={() => fund()}>Fund</button>
        :
        <button onClick={() => connect()}>Connect</button>}
      <br />
      <button onClick={() => checkContractBalance()}>Get Balance</button>
      <br />
      <button onClick={() => withdraw()}>Withdraw</button>
    </>
  );
}
