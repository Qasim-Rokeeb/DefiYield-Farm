// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract YieldFarm {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 stakingTime;
    }
    
    mapping(address => UserInfo) public userInfo;
    
    uint256 public totalStaked;
    uint256 public rewardPerSecond;
    uint256 public accRewardPerShare;
    uint256 public lastRewardTime;
    uint256 public constant PRECISION = 1e12;
    
    address public owner;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    constructor(uint256 _rewardPerSecond) {
        owner = msg.sender;
        rewardPerSecond = _rewardPerSecond;
        lastRewardTime = block.timestamp;
    }
    
    function updatePool() public {
        if (block.timestamp <= lastRewardTime) {
            return;
        }
        
        if (totalStaked == 0) {
            lastRewardTime = block.timestamp;
            return;
        }
        
        uint256 timeElapsed = block.timestamp - lastRewardTime;
        uint256 reward = timeElapsed * rewardPerSecond;
        accRewardPerShare += (reward * PRECISION) / totalStaked;
        lastRewardTime = block.timestamp;
    }
    
    function stake() external payable {
        require(msg.value > 0, "Cannot stake 0");
        
        updatePool();
        
        UserInfo storage user = userInfo[msg.sender];
        
        if (user.amount > 0) {
            uint256 pending = (user.amount * accRewardPerShare) / PRECISION - user.rewardDebt;
            if (pending > 0) {
                payable(msg.sender).transfer(pending);
                emit RewardClaimed(msg.sender, pending);
            }
        }
        
        user.amount += msg.value;
        user.stakingTime = block.timestamp;
        totalStaked += msg.value;
        user.rewardDebt = (user.amount * accRewardPerShare) / PRECISION;
        
        emit Deposit(msg.sender, msg.value);
    }
    
    function unstake(uint256 _amount) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Insufficient staked amount");
        
        updatePool();
        
        uint256 pending = (user.amount * accRewardPerShare) / PRECISION - user.rewardDebt;
        if (pending > 0) {
            payable(msg.sender).transfer(pending);
            emit RewardClaimed(msg.sender, pending);
        }
        
        user.amount -= _amount;
        totalStaked -= _amount;
        user.rewardDebt = (user.amount * accRewardPerShare) / PRECISION;
        
        payable(msg.sender).transfer(_amount);
        
        emit Withdraw(msg.sender, _amount);
    }
    
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 _accRewardPerShare = accRewardPerShare;
        
        if (block.timestamp > lastRewardTime && totalStaked != 0) {
            uint256 timeElapsed = block.timestamp - lastRewardTime;
            uint256 reward = timeElapsed * rewardPerSecond;
            _accRewardPerShare += (reward * PRECISION) / totalStaked;
        }
        
        return (user.amount * _accRewardPerShare) / PRECISION - user.rewardDebt;
    }
    
    function depositRewards() external payable onlyOwner {}
    
    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
