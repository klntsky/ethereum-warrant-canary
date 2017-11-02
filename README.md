# About

> A warrant canary is a method by which a communications service provider aims to inform its users that the provider has not been served with a secret government subpoena.
> 
> Source: [Wikipedia](https://en.wikipedia.org/wiki/Warrant_canary)

In general, it can be used to spawn a public notification on some event in cases where the user is not allowed to do so, either because of law enforcements or for some other reason.

It can also be used to prove that the owner of a canary was alive at a given time.

# Why ethereum?

Because blockchain transactions are non-revesible and smart contract's state can be inspected at any time.

Even if you choose to host your own canary in form of, for example, weekly-updatable PGP-signed message, you should take care of it's availability, and no matter how much you pay for a hosting service, the server may go down, creating uncertainity. Blockchain eliminates that problem.

# Implementation

## Permission system

To control canary's operation, two-level permission system is used, which divides all users in two groups: **owners** and **confidants**.

**Owners** can:

- update canary
- add owners
- remove owners
- add confidants
- remove confidants

**Confidants** can:

- update canary

All the users, also including all the people aside (who have no permissions at all) can trigger `CanaryDied` event if the canary was not updated by the time set at `aliveUntil`.

## License

WTFPL