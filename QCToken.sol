pragma solidity ^0.4.0;

import "browser/ERC20.sol";

contract MyFirstToken is ERC20 {
    string public constant symbol = "CR";
    string public constant name = "CryptoLight Token";
    uint8 public constant decimals = 18;
    uint public price = 10;
    address public creater;
    
    uint private constant __totalSupply = 1000;
    mapping (address => uint) private __balanceOf;
    mapping (address => mapping (address => uint)) private __allowances;
    
    modifier lockTime(){
        require(now >= 1536296099);
        _;
    }
    
    modifier onlyOwner(address _addr){
        require(_addr == msg.sender);
        _;
    }
    
    function MyFirstToken() {
            __balanceOf[msg.sender] = __totalSupply;
            creater = msg.sender;
    }
    
    function totalSupply() constant returns (uint _totalSupply)  {
        _totalSupply = __totalSupply;
    }
    
    function balanceOf(address _addr) constant returns (uint balance) {
        return __balanceOf[_addr];
        // return _addr.balance;
    }
    
    function transfer(address _to, uint _value) public lockTime returns (bool success) {
        if (_value > 0 && _value <= balanceOf(msg.sender)) {
            __balanceOf[msg.sender] -= _value;
            __balanceOf[_to] += _value;
            return true;
        }
        return false;
    }
    
    function transferFrom(address _from, address _to, uint _value) public lockTime returns (bool success) {
        if (__allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            __allowances[_from][msg.sender] >= _value && 
            __balanceOf[_from] >= _value) {
            __balanceOf[_from] -= _value;
            __balanceOf[_to] += _value;
            // Missed from the video
            __allowances[_from][msg.sender] -= _value;
            return true;
        }
        return false;
    }
    
    
    
    function approve(address _spender, uint _value) public lockTime returns (bool success) {
        __allowances[msg.sender][_spender] = _value;
        return true;
    }
    
    function allowance(address _owner, address _spender) lockTime constant returns (uint remaining) {
        return __allowances[_owner][_spender];
    }
 

    function buy() payable returns (uint amount){
        amount = msg.value / (price*10**16);
        if(__balanceOf[creater]>amount&&amount>0){
            __balanceOf[creater] -=amount;
            __balanceOf[msg.sender] +=amount;
            return amount;   
        }
    }
        

    function sell(uint amount) returns (uint revenue){
        require(__balanceOf[msg.sender] >= amount);         // checks if the sender has enough to sell
        __balanceOf[this] += amount;                        // adds the amount to owner's balance
        __balanceOf[msg.sender] -= amount;                  // subtracts the amount from seller's balance
        revenue = amount * price*10**16;
        msg.sender.transfer(revenue);                     // sends ether to the seller: it's important to do this last to prevent recursion attacks
        Transfer(msg.sender, creater, amount);               // executes an event reflecting on the change
        return revenue;                                   // ends function and returns
    }
                                
}