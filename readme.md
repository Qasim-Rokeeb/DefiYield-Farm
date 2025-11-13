

# 🌾 YieldFarm Smart Contract

A Solidity-powered **ETH staking and reward distribution** system where users can stake ETH and earn rewards continuously over time.
Rewards are calculated per second and distributed proportionally based on each staker’s share and staking duration.

---

## 📌 Overview

* **Purpose:** Provide a secure ETH staking mechanism with automatic, time-based reward accrual.
* **Reward Model:** Rewards are generated every second and distributed proportionally to stakers.
* **Owner Role:** Able to deposit rewards and perform emergency withdrawals.

**Deployed & Verified on Base Sepolia:**
`0xC8aB287C70D75041E4f0f47AE67F13e0D29D1460`
🔍 [View Verified Contract on BaseScan](https://sepolia.basescan.org/address/0xC8aB287C70D75041E4f0f47AE67F13e0D29D1460#code) ✅

---

## ⚙️ Key Features

* **Stake ETH** and start earning rewards instantly.
* **Unstake ETH** anytime, with automatic payout of pending rewards.
* **View Pending Rewards** via the `pendingReward` function.
* **Owner Controls:**

  * Deposit ETH rewards into the pool.
  * Emergency withdraw all ETH from the contract.

---

## 🛠 Deployment

### Requirements

* Solidity `^0.8.19`
* Base Sepolia network
* ETH for deployment gas fees

### Example Deployment

```solidity
YieldFarm farm = new YieldFarm(1e15); // 0.001 ETH rewarded per second
```

> `_rewardPerSecond` specifies the ETH reward rate in **wei** per second.

---

## 📜 Function Summary

### **stake()** (payable)

Stake ETH into the contract.

* Updates reward distribution before adding the new stake.
* **Emits:** `Deposit`, `RewardClaimed` (if rewards are due).

---

### **unstake(uint256 \_amount)**

Withdraw staked ETH.

* Updates reward distribution before unstaking.
* **Emits:** `Withdraw`, `RewardClaimed` (if rewards are due).

---

### **pendingReward(address \_user)**

View the pending ETH rewards for a specific address.

* **Returns:** Amount in wei.

---

### **depositRewards()** (payable, onlyOwner)

Deposit ETH to fund staking rewards.

---

### **emergencyWithdraw()** (onlyOwner)

Withdraw **all ETH** from the contract — both staked funds and rewards.

---

## 🧪 Testing

Run local tests using **Hardhat**:

```bash
npm install
npx hardhat test
```

**Recommended test cases:**

* Single user stakes and earns rewards.
* Multiple users staking at different time
* Owner deposits additional rewards.
* Emergency withdrawal by the owner.

---

## 📄 License

MIT License – Free to use and modify.

---

--