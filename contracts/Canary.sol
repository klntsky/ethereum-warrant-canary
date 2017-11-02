pragma solidity ^0.4.13;

// Two-level system of privileges.
contract Privileges {
  mapping (address => bool) owners;
  mapping (address => bool) confidants;
  uint32 ownersCount = 0;
  uint32 confidantsCount = 0;

  function Owned () {
    owners[msg.sender] = true;
  }

  function Trusted () {
    confidants[msg.sender] = true;
  }

  // Returns false iff the given owner is already added.
  function addOwner (address addr) onlyOwners returns (bool) {
    if (owners[addr]) {
      return false;
    }
    owners[addr] = true;
    ownersCount += 1;
    return true;
  }

  // Returns false iff the given owner does not exist.
  function removeOwner (address addr) onlyOwners returns (bool) {
    if (!owners[addr]) {
      return false;
    }
    owners[addr] = false;
    ownersCount -= 1;
    return true;
  }

  // Returns false iff the given confidant is already added.
  function addConfidant (address addr) onlyOwners returns (bool) {
    if (confidants[addr]) {
      return false;
    }
    confidants[addr] = true;
    confidantsCount += 1;
    return true;
  }

  // Returns false iff the given confidant does not exist.
  function removeConfidant (address addr) onlyOwners returns (bool) {
    if (!confidants[addr]) {
      return false;
    }
    confidants[addr] = false;
    confidantsCount -= 1;
    return true;
  }

  modifier onlyOwners {
    if (owners[msg.sender]) {
      _;
    }
  }

  modifier onlyTrusted {
    if (owners[msg.sender] || confidants[msg.sender]) {
      _;
    }
  }
}

contract Canary is Privileges {

  uint updateInterval;
  uint aliveUntil;
  uint lastUpdate;
  string description;
  bool isDeathNotificationIssued = false;

  event CanaryUpdated(address indexed initiator, string indexed message);
  event UpdateIntervalChanged(address indexed initiator, uint from, uint to);
  event CanaryDied(address indexed initiator, uint wasAliveUntil, uint _lastUpdate);

  function Canary (uint _updateInterval,
                   string _description) Privileges() {
    updateInterval = _updateInterval;
    description = _description;
    aliveUntil = now + updateInterval;
    lastUpdate = now;
    owners[msg.sender] = true;
    ownersCount = 1;
  }

  function update () onlyTrusted alive returns (bool success) {
    aliveUntil = now + updateInterval;
    lastUpdate = now;
    return true;
  }

  function setUpdateInterval (uint interval) onlyOwners {
    UpdateIntervalChanged(msg.sender, updateInterval, interval);
    updateInterval = interval;
  }

  function getDeathTime () constant returns (uint) {
    return aliveUntil;
  }

  function spawnDeathNotification () {
    if (aliveUntil < now && !isDeathNotificationIssued) {
      CanaryDied(msg.sender, aliveUntil, lastUpdate);
      isDeathNotificationIssued = true;
    }
  }

  modifier alive {
    if (aliveUntil > now) {
      _;
    }
  }

  function () payable {
    revert();
  }
}
