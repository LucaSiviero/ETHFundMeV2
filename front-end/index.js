const { ethers } = require("ethers");

async function connect() {
    if (typeof window.ethereum !== "undefined") {
        await ethereum.request({ method: "eth_requestAccounts" });
    }
}

async function fund() {
    //To interact with a contract we need
    //Address
    //ABI
    //Function
    const contractAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
    const abi = require("./abi/FundMe.json");
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(contractAddress, abi, signer);

    //Node connection (Metamask)
    //The provider is actually the MetaMask component
    //The signer is the address that is signing the transaction (we take it from the current MetaMask Account)
    await contract.fund({ value: ethers.utils.parseEther('1') });
}

async function checkBalance() {
    const contractAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
    const provider = new ethers.providers.Web3Provider(window.ethereum);

    var bigBalance = await provider.getBalance(contractAddress);
    var balance = ethers.utils.formatEther(bigBalance);
    console.log(balance);
}

module.exports = {
    connect,
    fund,
    checkBalance
}