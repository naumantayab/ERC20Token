// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20TokenInterface} from './IERC20.sol';
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ERC20 is ERC20TokenInterface{
    using SafeMath for uint256;
    string internal tName;
    string internal tSymbol;
    uint256 internal tTotalSupply;
    uint256 internal  tdecimals;
    address internal owner;
    uint256 internal capAmount;
    uint256 internal lockTransaction;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allownce;

    constructor(string memory _tokenName,string memory _symbol,uint256 _totalSupply,uint256 _decimals,uint256 _cappedAmount)public{
        tName = _tokenName;
        tSymbol = _symbol;
        balances[msg.sender] += _totalSupply;
        tTotalSupply = _totalSupply* 10**uint256(_decimals);
        tdecimals = _decimals;
        capAmount = _cappedAmount;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this method");
        _;
    }


    function name() override public view returns(string memory) { return tName;}
    function symbol() override public view returns(string memory) { return tSymbol;}
    function totalSupply()override  public view returns(uint256) { return tTotalSupply;}
    function decimals() override public view returns(uint256) { return tdecimals;}

    function balanceOf(address tokenOwner) override public view returns(uint256){ return balances[tokenOwner]; }

    function transfer(address to, uint token) override public  returns(bool success){
        require(balances[msg.sender] >= token, "you should have some token");
        require(msg.sender != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(lockTransaction < block.timestamp, "transaction is currently locked");

        balances[msg.sender] = balances[msg.sender].sub(token);
        balances[to] = balances[to].add(token);
        emit Transfer(msg.sender,to,token);
        return true;
    }
    function approve(address spender, uint tokens) override public returns(bool success) {
        require((tokens == 0) || (allownce[msg.sender][spender] == 0));
        allownce[msg.sender][spender] =  allownce[msg.sender][spender].add(tokens);
        emit Approval(msg.sender, spender,tokens);
        return true;

    }
    function allowance(address _owner, address spender) override public view returns(uint){
        return allownce[_owner][spender];
    }
    function transferFrom(address from, address to, uint tokens) override public returns(bool success) {
        require(balances[from] >= tokens);
        require(allownce[from][msg.sender] >= tokens);
        require(lockTransaction < block.timestamp, "transaction is currently locked");
        require(to != address(0), "Transfer to the zero address");

        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allownce[from][msg.sender] = allownce[from][msg.sender].sub(tokens);
        emit Transfer(from,to,tokens);
        return true;

    }

    function mint_token(address _address,uint256 _amount) public onlyOwner{
        require(_address != address(0), "invailed address");
        require(_amount > 0,"invailed Amount");
        require(tTotalSupply.add(_amount) > capAmount, "amount exceed the limit");
        balances[_address] = balances[_address].add(_amount);
        tTotalSupply = tTotalSupply.add(_amount);
    }

    function lock_trans(uint256 time) onlyOwner public{
        require(time > 0 && time > block.timestamp ,"invailed Time");
        lockTransaction = time;

    }

}

