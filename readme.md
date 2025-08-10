

# 🌾 YieldFarm Smart Contract

A Solidity-based **ETH staking and reward distribution** system where users can stake ETH to earn continuous rewards over time. Rewards are distributed proportionally to each staker’s share and the time they have staked.

---

## 📌 Overview

* **Purpose:** Enable ETH staking with time-based reward accrual.
* **Reward Model:** Rewards are calculated per second and distributed proportionally to stakers.
* **Owner Role:** Can deposit rewards and perform emergency withdrawals.

**Deployed & Verified on Base Sepolia:**
`0xC8aB287C70D75041E4f0f47AE67F13e0D29D1460`
🔍 [View Verified Contract on BaseScan](https://sepolia.basescan.org/address/0xC8aB287C70D75041E4f0f47AE67F13e0D29D1460#code) ✅

---

## ⚙️ Features

* **Stake ETH** and start earning rewards instantly.
* **Unstake ETH** anytime, with pending rewards paid out automatically.
* **View Pending Rewards** at any time via `pendingReward`.
* **Owner Functions:**

  * Deposit rewards into the pool.
  * Emergency withdraw all ETH from the contract.

---

## 🛠 Deployment

### Requirements

* Solidity `^0.8.19`
* Base Sepolia network
* ETH balance for deployment gas fees

### Example Deployment

```solidity
YieldFarm farm = new YieldFarm(1e15); // Reward rate: 0.001 ETH/sec
```

* `_rewardPerSecond` defines how much ETH is rewarded each second, in wei.

---

## 📜 Functions

### **stake()** (payable)

Stake ETH into the contract.

* Calculates and sends pending rewards before adding new stake.
* **Emits:** `Deposit`, `RewardClaimed` (if applicable).

---

### **unstake(uint256 \_amount)**

Withdraw staked ETH from the contract.

* Calculates and sends pending rewards before unstaking.
* **Emits:** `Withdraw`, `RewardClaimed` (if applicable).

---

### **pendingReward(address \_user)**

View pending rewards for a user.

* Returns: reward amount in wei.

---

### **depositRewards()** (payable, onlyOwner)

Deposit ETH to fund rewards.

---

### **emergencyWithdraw()** (onlyOwner)

Withdraw all ETH from the contract (both staked amounts and rewards).

---

## 🧪 Testing

To test locally using Hardhat:

```bash
npm install
npx hardhat test
```

Possible tests:

* User stakes and accrues rewards.
* Multiple users staking at different times.
* Owner deposits rewards.
* Emergency withdrawal behavior.

---

## 📄 License

MIT License – Free to use and modify.

---


