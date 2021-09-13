// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

contract RandomToken is IERC20, IERC20Metadata {
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    constructor() {
        _totalSupply = 0;
        _decimals = 18;
        _name = "RandomCoin";
        _symbol = "RND";
        
        _mint(msg.sender, 1000 * 10 ** _decimals);
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function name() external view override returns (string memory) {
        return _name;
    }
    
    function symbol() external view override returns (string memory) {
        return _symbol;
    }
    
    function decimals() external view override returns (uint8) {
        return _decimals;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        uint256 curAllowance = _allowances[sender][msg.sender];
        require(curAllowance >= amount, "Insufficient allowance");
        
         _transfer(sender, recipient, amount);
        
        unchecked {
            _approve(sender, msg.sender, curAllowance - amount);
        }

        return true;
    }
    
    function _mint(address account, uint256 amount) internal validAddress(account, address(0x0), true) {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0x0), account, amount);
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal validAddress(sender, recipient, false) {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Insufficient balance");
        
        unchecked {
            _balances[sender] = senderBalance - amount;
            _balances[recipient] += amount;
        }
        
        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address approver, address spender, uint256 amount) internal validAddress(approver, spender, false) {
        _allowances[approver][spender] = amount;
        emit Approval(approver, spender, amount);
    }
    
    modifier validAddress(address address1, address address2, bool checkOnlyFirst) {
        require(address1 != address(0x0), "Could not resolve zero address");
        if (!checkOnlyFirst) {
            require(address2 != address(0x0), "Could not resolve zero address");
        }
        _;
    }
}
