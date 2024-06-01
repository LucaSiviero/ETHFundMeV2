import Image from "next/image";
import styles from "./page.module.css";
import { useWeb3React } from "@web3-react/core";

export default function Home() {
  const { active, libary: provider } = useWeb3React();
  return (
    <div className={styles.container}>WEB3!!!</div>
  );
}
