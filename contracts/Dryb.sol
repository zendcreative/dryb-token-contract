pragma solidity ^0.4.17;

contract Dryb {

  // the owner can add multiple admin
  // the admin can add multiple approver
  address owner;

  struct Admin {
    address _address;
    string name;
    uint256 addedAt;
  }

  struct Approver {
    address _address;
    string name;
    Admin addedBy;
    uint256 addedAt;
  }

  mapping(address => Admin) admins;
  address[] public adminList;

  mapping(address => Approver) approvers;
  address[] public approverList;


  uint public baseFare;
  uint public pricePerKm;
  uint public pricePerMinute;

  enum RideType { Taxi, Regular, Premium, Premium6Plus, ExpressVan, Bus, Tricycle, Motorcycle, Delivery }
  enum RideStatus { Requested, PickUp, InTransit, CancelledByDriver, CancelledByPassenger, Completed }

  struct Fare {
    bytes32 _id;
    RideType rideType;
    uint256 baseFare;
    uint256 perDistance;
    uint256 perTime;
    uint256 perWaitingTime;
    uint256 specialDiscount;
  }

  struct Driver {
    address _address;
    string firstname;
    string lastname;
    string longitude;
    string latitude;
    uint256 earnings;
    bool isVerified;
  }

  mapping(address => Driver) drivers;
  address[] public driverList;

  struct Passenger {
    address _address;
    string name;
    string mobile;
    bool isActive;
  }

  mapping(address => Passenger) passengers;
  address[] passengerList;

  struct Ride {
    bytes32 _id;
    address driver;
    address passenger;
    uint256 distance;
    uint256 time;
    uint256 price;
    string status;
  }

  mapping(bytes32 => Ride) rides;
  bytes32[] public rideList;

  /*
    ====================
    ===== EVENTS =======
    ====================
  */
  event FareChanged(address admin, string message, uint256 from, uint256 to, uint256 date);
  event DriverAdded(address admin, string message, address driver, string firstname, string lastname, uint256 date);


  /*
    ==========================
    =======  MODIFIERS =======
    ==========================
  */

  modifier isOwner() {
     require(msg.sender == owner);
     _;
  }

  modifier isAdmin() {
    require(admins[msg.sender]._address != 0x0);
    _;
  }

  modifier isApprover() {
    require(approvers[msg.sender]._address != 0x0);
    _;
  }

  modifier isAdminisitrativeUser() {
    require(approvers[msg.sender]._address != 0x0 || admins[msg.sender]._address != 0x0 || owner == msg.sender);
    _;
  }

  modifier isDriver() {
    require(drivers[msg.sender]._address != 0x0);
    _;
  }

  modifier diverNotExist(address _address) {
    if (drivers[_address]._address != 0x0) revert();
    _;
  }

  modifier driverExist(address _address) {
    require(drivers[_address]._address != 0x0);
    _;
  }

  modifier passengerNotExist(address _address) {
    if (passengers[_address]._address != 0x0) revert();
    _;
  }

  modifier passengerExist(address _address) {
    require(passengers[_address]._address != 0x0);
    _;
  }

  modifier rideExist(bytes32 rideId) {
    require(rides[rideId]._id == rideId);
    _;
  }

  modifier rideNotExist(bytes32 rideId) {
    if (rides[rideId]._id != rideId) revert();
    _;
  }

  modifier rideUsers(bytes32 rideId) {
    require(rides[rideId].driver == msg.sender || rides[rideId].passenger == msg.sender || owner == msg.sender);
    _;
  }

  modifier isRidePassenger(bytes32 rideId) {
    require(rides[rideId].passenger == msg.sender);
    _;
  }

  modifier isRideDriver(bytes32 rideId) {
    require(rides[rideId].driver == msg.sender);
    _;
  }


  /*
    ==========================
    ======  CONSTRUCTOR ======
    ==========================
  */

  function Dryb() public {
    owner = msg.sender;
    baseFare = 25;
    pricePerKm = 5;
    pricePerMinute = 2;
    admins[owner] = Admin(owner, 'Admin', now);
    adminList.push(owner);
  }


  /*
    ==========================
    =======  METHODS =========
    ==========================
  */

  // // // // // // // //
  // Admin Management //
  // // // // // // //

  function addAdmin(address _address, string name) public isOwner returns (bool success) {
    require(admins[_address]._address == 0x0);
    admins[_address] = Admin(_address, name, now);
    adminList.push(_address);
    return true;
  }

  function getAdmins() constant public isOwner returns (address[]) {
    return adminList;
  }

  function addApprover(address _address, string name) public isAdmin returns (bool success) {
    require(approvers[_address]._address == 0x0);
    approvers[_address] = Approver(_address, name, admins[msg.sender], now);
    approverList.push(_address);
    return true;
  }

  function getApprovers() public constant isAdmin returns (address[]) {
    return approverList;
  }

  // // // // // // // //
  // Fare management  //
  // // // // // // //

  function setBaseFare(uint256 fare) public isAdmin returns (bool success) {
    FareChanged(msg.sender, 'Updated Base Fare', baseFare, fare, now);
    baseFare = fare;
    return true;
  }

  function setPricePerMinute(uint256 price) public isAdmin returns (bool success) {
    FareChanged(msg.sender, 'Updated Price per Minute', pricePerMinute, price, now);
    pricePerMinute = price;
    return true;
  }

  function setPricePerKM(uint256 price) public isAdmin returns (bool success) {
    FareChanged(msg.sender, 'Updated Price per KM', pricePerKm, price, now);
    pricePerKm = price;
    return true;
  }

  // // // // // // // //
  // Driver Management //
  // // // // // // // //

  function addDriver(address driverAddress, string firstname, string lastname) public isAdmin diverNotExist(driverAddress) returns (bool success) {
    drivers[driverAddress] = Driver(driverAddress, firstname, lastname, '0', '0', 0, false);
    driverList.push(driverAddress);
    DriverAdded(msg.sender, 'Added Driver', driverAddress, firstname, lastname, now);
    return true;
  }

  function verifyDriver(address driverAddress) public isAdmin driverExist(driverAddress) returns (bool success) {
    drivers[driverAddress].isVerified = true;
    return true;
  }

  function getDriver(address _address) public constant driverExist(_address) returns(address, string, string, string, string, bool) {
    return (drivers[_address]._address, drivers[_address].firstname, drivers[_address].lastname,drivers[_address].longitude, drivers[_address].latitude, drivers[_address].isVerified);
  }

  function getDrivers() public constant returns (address[]) {
    return driverList;
  }

  function getEarnings() public constant isDriver returns (uint256) {
    return drivers[msg.sender].earnings;
  }

  // // // // // // // // //
  // Passenger Management //
  // // // // // // // // //

  function addPassenger(address _address, string name, string mobile) public isAdmin passengerNotExist(_address) returns (bool success) {
    passengers[_address] = Passenger(_address, name, mobile, false);
    passengerList.push(_address);
    return true;
  }

  function getPassenger(address _address) public constant passengerExist(_address) returns (address, string, string, bool) {
    return (passengers[_address]._address, passengers[_address].name, passengers[_address].mobile, passengers[_address].isActive);
  }

  function getPassengers() public constant returns (address[]) {
    return passengerList;
  }

  // // // // // // // //
  // Ride Management //
  // // // // // // //

  function createRide(bytes32 rideId, address driver, address passenger) public rideNotExist(rideId) returns (bool success) {
    rides[rideId] = Ride(rideId, driver, passenger, 0, 0, 0, 'initialized');
    rideList.push(rideId);
    return true;
  }

  function computeFare(bytes32 rideId ,uint256 distance, uint256 time) public rideExist(rideId) returns(uint256 fare) {
    rides[rideId].distance = distance;
    rides[rideId].time = time;
    rides[rideId].price = baseFare + (distance * pricePerKm) + (time * pricePerMinute);
    rides[rideId].status = 'inprogress';
    return rides[rideId].price;
  }

  function cancelRide(bytes32 rideId) public rideExist(rideId) rideUsers(rideId) returns (bool success) {
    rides[rideId].status = 'cancelled';
    return true;
  }

  function payRide(bytes32 rideId, uint256 price) public rideExist(rideId) returns (bool success, uint256 change) {
    if (rides[rideId].price > price) {
      revert();
    }
    uint256 _change = rides[rideId].price - price;
    rides[rideId].status = 'completed';
    drivers[rides[rideId].driver].earnings += price;
    return (true, _change);
  }

}
