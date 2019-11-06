pragma solidity >= 0.4.0 < 0.6.0;

    contract mailService {
        
        constructor() public{
            roles[0] = "SysAdmin";   
            roles[1] = "Admin";   
            roles[2] = "Postman";
            roles[3] = "User"; 
            _creatUser("Admin", 1, 0, msg.sender, "" );
        }
        modifier checkRole(uint _roles) {
            require(_roles == 0, "Acces error");
            _;
        }
        
        struct mailing 
        {
            string trackNumber;
            address recipient;
            uint types;
            uint departureClass;
            uint costOfDelivery;
            uint weight;
            uint declaredValue;
            uint totalValue;
            uint destinationAddress;
            uint departureAddress;
        }
        struct remittance 
        {
            address sender;
            address recipientMoney;
            uint sumMoney;
            uint timeOfLife;
            bool status;
        }
        struct roleAttributes
        {
            string name;
            uint homeAddress;
            uint role;
            address user;
            string postalIndex;
        }
        roleAttributes[] users;
        uint countOfUsers = 0;
        
        mapping(uint=>string) roles;
        mapping(address=>uint) getRole;
        
        function _creatUser(string memory _name, uint _homeAddress, uint _role, address _user, string memory _postalIndex) private {
            users.push(roleAttributes(_name, _homeAddress, _role, _user, _postalIndex));
            countOfUsers++;
            getRole[_user] = _role;
        }
        function pay(address payable  _to, uint256 _eth) public payable
        {
            require (msg.value >= _eth);
            _to.transfer(_eth);
        }
        function createByAdmin(string memory _name, uint _homeAddress, uint _role, address _user, string memory _postalIndex) public checkRole(_role)
        {        
            if(_role == 2) { 
                _creatUser(_name, _homeAddress, _role, _user, _postalIndex);
            }else{
                _creatUser(_name, _homeAddress, _role, _user, "");
                
            }
        }
        function registration(string calldata _name, uint _homeAddress) external {
            for(uint i=0; i<countOfUsers; i++) {
                require(msg.sender != users[i].user, "Account already created");
            }
            _creatUser(_name, _homeAddress, 3, msg.sender, "");
        }
        
        //function creationOfMail(uint weight) 

    }
