// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title YieldFarm
 * @dev A simple ETH staking (yield farming) contract that rewards stakers over time.
 */
contract YieldFarm {
    // Stores user staking info
    struct UserInfo {
        uint256 amount;        // How much ETH the user has staked
        uint256 rewardDebt;    // Tracks rewards already paid out (to avoid double paying)
        uint256 stakingTime;   // Timestamp when the user last staked
    }
    
    // Mapping of user address to their staking information
    mapping(address => UserInfo) public userInfo;
    
    // Total ETH staked in the contract
    uint256 public totalStaked;

    // Reward rate in ETH per second
    uint256 public rewardPerSecond;

    // Accumulated rewards per staked ETH, scaled up by PRECISION
    uint256 public accRewardPerShare;

    // Last timestamp when rewards were updated
    uint256 public lastRewardTime;

    // Precision factor to avoid rounding errors in division
    uint256 public constant PRECISION = 1e12;
    
    // Owner of the contract (can deposit rewards and perform emergency withdrawals)
    address public owner;
    
    // Events for front-end or external tracking
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    
    // Restricts certain functions to be called only by the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    /**
     * @dev Constructor sets the reward rate and initializes owner.
     * @param _rewardPerSecond ETH reward given per second for all stakers combined.
     */
    constructor(uint256 _rewardPerSecond) {
        owner = msg.sender;
        rewardPerSecond = _rewardPerSecond;
        lastRewardTime = block.timestamp; // Start tracking from deployment time
    }
    
    /**
     * @dev Updates reward variables to be up-to-date before any staking/unstaking action.
     */
    function updatePool() public {
        // If no time has passed, no update needed
        if (block.timestamp <= lastRewardTime) {
            return;
        }
        
        // If nothing is staked, just move lastRewardTime forward
        if (totalStaked == 0) {
            lastRewardTime = block.timestamp;
            return;
        }
        
        // Calculate rewards for the elapsed time
        uint256 timeElapsed = block.timestamp - lastRewardTime;
        uint256 reward = timeElapsed * rewardPerSecond;

        // Update accumulated rewards per staked ETH
        accRewardPerShare += (reward * PRECISION) / totalStaked;

        // Update last reward calculation time
        lastRewardTime = block.timestamp;
    }
    
    /**
     * @dev Stake ETH to start earning rewards.
     */
    function stake() external payable {
        require(msg.value > 0, "Cannot stake 0");
        
        updatePool(); // Make sure rewards are updated before staking
        
        UserInfo storage user = userInfo[msg.sender];
        
        // If the user already has staked ETH, calculate and send pending rewards
        if (user.amount > 0) {
            uint256 pending = (user.amount * accRewardPerShare) / PRECISION - user.rewardDebt;
            if (pending > 0) {
                payable(msg.sender).transfer(pending);
                emit RewardClaimed(msg.sender, pending);
            }
        }
        
        // Increase user stake and total stake
        user.amount += msg.value;
        user.stakingTime = block.timestamp;
        totalStaked += msg.value;

        // Update reward debt to current accumulated rewards
        user.rewardDebt = (user.amount * accRewardPerShare) / PRECISION;
        
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Withdraw staked ETH and claim rewards.
     * @param _amount Amount of ETH to unstake.
     */
    function unstake(uint256 _amount) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Insufficient staked amount");
        
        updatePool();
        
        // Calculate pending rewards and send them to the user
        uint256 pending = (user.amount * accRewardPerShare) / PRECISION - user.rewardDebt;
        if (pending > 0) {
            payable(msg.sender).transfer(pending);
            emit RewardClaimed(msg.sender, pending);
        }
        
        // Reduce user stake and total stake
        user.amount -= _amount;
        totalStaked -= _amount;

        // Update reward debt to current accumulated rewards
        user.rewardDebt = (user.amount * accRewardPerShare) / PRECISION;
        
        // Send unstaked ETH back to the user
        payable(msg.sender).transfer(_amount);
        
        emit Withdraw(msg.sender, _amount);
    }
    
    /**
     * @dev View function to see pending rewards for a specific user.
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 _accRewardPerShare = accRewardPerShare;
        
        // Simulate reward update if time has passed
        if (block.timestamp > lastRewardTime && totalStaked != 0) {
            uint256 timeElapsed = block.timestamp - lastRewardTime;
            uint256 reward = timeElapsed * rewardPerSecond;
            _accRewardPerShare += (reward * PRECISION) / totalStaked;
        }
        
        return (user.amount * _accRewardPerShare) / PRECISION - user.rewardDebt;
    }
    
    /**
     * @dev Owner can deposit ETH to fund rewards.
     */
    function depositRewards() external payable onlyOwner {}
    
    /**
     * @dev Owner can withdraw all ETH from the contract (emergency use only).
     */
    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
