pragma solidity >= 0.4.0 < 0.6.0;

    contract mailService {
        
        constructor() public {
            roles[0] = "SysAdmin";   
            roles[1] = "Admin";   
            roles[2] = "Postman";
            roles[3] = "User"; 
            _creatUser("Калтахин Василий Викторович", "г. Дмитров, ул. Инженерная, д.5", 0, msg.sender, "" );
            _creatUser("Говтян Зухра Копрофиловна", "г. Дмитров, ул. Маркова, д.33" , 1, address(0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C), "");
            _creatUser("Петров Иван Андреевич", "г. Москва, Зубовский бульвар, д.2", 2, address(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB), "141");
            _creatUser("Шариков Нектар Садамазович", "г. Дмитров, ул. Маркова, д.8", 3, address(0x583031D1113aD414F02576BD6afaBfb302140225), "");
        }
        
        modifier checkRole(uint _roles) {
            require(_roles == 0 || _roles == 1, "Acces error");
            _;
        }
        
        modifier chechActive(address userAddr) {
            for(uint i=0; i<users.length; i++) {
            if(userAddr == users[i].user) {
               require(users[i].active == true, "error, user is not active"); 
                }
            }
            _;
        }
        
        struct mailing {
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
        
        struct remittance {
            address payable sender;
            address payable recipientMoney;
            uint sumMoney;
            uint timeOfLife;
            bool status;
        }
        
        struct roleAttributes {
            string name;
            string homeAddress;
            uint role;
            address user;
            string postalIndex;
            bool active;
        }
        
        roleAttributes[] users;
        remittance[] transfers;
        mailing[] mails; 
        
        mapping(uint=>string) roles;
        mapping(address=>uint) getRole;
        mapping(uint=>uint[]) getPath;
        
        function _creatUser(string memory _name, string memory _homeAddress, uint _role, address _user, string memory _postalIndex) private {
            users.push(roleAttributes(_name, _homeAddress, _role, _user, _postalIndex, true));
            getRole[_user] = _role;
        }
        
        function chengePrivInfo(string calldata _name, string calldata _homeAddress, uint _id) external {
            require(users[_id].user == msg.sender, "Wrong user"); 
            users[_id].name = _name;
            users[_id].homeAddress = _homeAddress;
        }
        
        function pay(address payable  _to, uint256 _eth) public payable {
            require (msg.value >= _eth);
            _to.transfer(_eth);
        }
        
        function createByAdmin(string memory _name, string memory _homeAddress, uint _role, address _user, string memory _postalIndex) public checkRole(getRole[msg.sender]) chechActive(msg.sender) {        
            if(_role == 2) {
                require(1 == getRole[msg.sender], "User is not Admin");
                _creatUser(_name, _homeAddress, _role, _user, _postalIndex);
            }  
            if(_role == 1) {
                require(0 == getRole[msg.sender], "User is not SysAdmin");
                _creatUser(_name, _homeAddress, 1, _user, "" );
            }
        }
        
        function deactivateUser(uint _id) external chechActive(msg.sender) {
             if(users[_id].role == 1) {
                require(0 == getRole[msg.sender], "User is not SysAdmin");
                users[_id].active = false;
             }
             if(users[_id].role == 2) {
                require(1 == getRole[msg.sender], "User is not Admin");
                users[_id].active = false;
             }
        }
        
        function registration(string calldata _name, string calldata  _homeAddress) external {
            for(uint i=0; i<users.length; i++) {
                require(msg.sender != users[i].user, "Account already created");
            }
            _creatUser(_name, _homeAddress, 3, msg.sender, "");
        }
        
        function createTransfer(address payable _recipientMoney, uint _sumMoney, uint _timeOfLife) external payable {
            require (msg.value >= _sumMoney, "not enoght money");
            uint deadLine = now;
            deadLine += _timeOfLife * 1 days;
            transfers.push(remittance(msg.sender, _recipientMoney, _sumMoney * 1 ether, _sumMoney, true));
        }
        
        function getTransfer(uint _id) external {
            if(transfers[_id].timeOfLife <= now && transfers[_id].status == true) {
                transfers[_id].status = false;
                transfers[_id].sender.transfer(transfers[_id].sumMoney);
            }
            require (transfers[_id].status == true, "You already got the money");
            require(msg.sender == transfers[_id].recipientMoney, "You are not recipient");  
            msg.sender.transfer(transfers[_id].sumMoney);
            transfers[_id].status = false;
        }
        
        function cancelTransfer(uint _id) external {
            require(transfers[_id].status == true, "Transfer is not active");
            require(transfers[_id].recipientMoney == msg.sender || transfers[_id].sender == msg.sender, "You doesn't have permision");
            transfers[_id].sender.transfer(transfers[_id].sumMoney);
            transfers[_id].status = false;
        }
        
        function creationOfMail(string calldata _trackNumber, address _recipient, uint _types, uint _departureClass, uint _weight, uint _declaredValue, uint _destinationAddress, uint departureAddress) external {
            require(_weight <= 10, "too much weight");
            require(_declaredValue >= 0, "value is too low");
            uint tp = _types;
            uint _totalValue;
            uint _eth;
            uint _lifetime;
            if (_types == 0) {
                tp = 3;
            }
            if(_types == 3) {
                _eth = 100 finney;
                _lifetime = 15;
            }else if (_types == 2) {
                _eth = 300 finney;
                _lifetime = 10;
            }else if (_types == 1) {
                _eth = 500 finney;
                _lifetime = 5;
            }
            _totalValue = _types * _weight + _declaredValue * _eth;
            mails.push(mailing(_trackNumber, _recipient, _types, _departureClass, _eth, _weight, _declaredValue, _totalValue, _destinationAddress, _departureClass));
        }
        function viewOfMail(uint _id) public view returns(string memory, address, uint, uint, uint, uint, uint, uint, uint, uint) {
            mailing memory z = mails[_id];
            return(z.trackNumber, z.recipient, z.types, z.departureClass, z.costOfDelivery, z.weight, z.declaredValue, z.totalValue, z.destinationAddress, z.departureClass);
        }
        function viewUser(uint _id) view public returns(string memory, string memory, uint, address, string memory, bool) {
            roleAttributes memory a = users[_id];
            return(a.name, a.homeAddress, a.role, a.user, a.postalIndex, a.active);
        }
        
        function viewMoney() public view checkRole(getRole[msg.sender]) returns(uint)  {
            return address(this).balance;   
        }
        
        function viewTransfer(uint _id) public view returns(address, address payable, uint, uint, bool) {
            remittance memory b = transfers[_id];
            return(b.sender, b.recipientMoney, b.sumMoney, b.timeOfLife, b.status);
        }
    }
