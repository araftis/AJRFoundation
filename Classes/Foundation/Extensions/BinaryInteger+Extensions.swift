/*
BinaryInteger+Extensions.swift
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

public extension BinaryInteger {

    var abs : Self {
        if self < 0 {
            return self * -1
        } else {
            return self
        }
    }

    /**
     Returns the GCD of receiver with value.
     */
    func gcd(_ right: Self) -> Self {
        var a = self.abs
        var b = right.abs

        if b > a {
            swap(&a, &b)
        }

        while b > 0 {
            (a, b) = (b, a % b)
        }

        return a
    }

    /**
     `true` if `n` is prime.
     */
    // Code: Adapted from https://www.geeksforgeeks.org/primitive-root-of-a-prime-number-n-modulo-n/
    var isPrime : Bool {
        // Corner cases
        if self <= 1  {
            return false
        }
        if self <= 3 {
            return true
        }

        // This is checked so that we can skip middle five numbers in below loop
        if self % 2 == 0 || self % 3 == 0 {
            return false
        }

        var i : Int = 5
        while i * i < self {
            if Int(self) % i == 0 || Int(self) % (i + 2) == 0 {
                return false
            }
            i += 6
        }

        return true
    }

    // Code: Adapted from https://www.geeksforgeeks.org/primitive-root-of-a-prime-number-n-modulo-n/
    var primeFactors : Set<Self> {
        var result = Set<Self>()
        var n = self

        // Print the number of 2s that divide n
        while n % 2 == 0 {
            result.insert(2)
            n = n / 2
        }

        // n must be odd at this point. So we can skip one element (Note i = i +2)
        var i = Self(3)
        while i <= Self(sqrt(Float(n))) {
            // While i divides n, print i and divide n
            while n % Self(i) == 0 {
                result.insert(i)
                n = n / Self(i)
            }
            i += 2
        }

        // This condition is to handle the case when
        // n is a prime number greater than 2
        if n > 2 {
            result.insert(n)
        }

        return result
    }

    // Code: Adapted from https://www.geeksforgeeks.org/primitive-root-of-a-prime-number-n-modulo-n/
    /// Smallest primitive root of receiver
    var smallestPrimitiveRoot : Self? {
        // Check if n is prime or not
        if !self.isPrime {
            return nil
        }

        // Find value of Euler Totient function of n Since n is a prime number, the value of Euler  Totient function is n-1 as there are n-1  relatively prime numbers.
        let phi = self - 1

        // Find prime factors of phi and store in a set
        let s = phi.primeFactors

        // Check for every number from 2 to phi
        for r in 2 ... Int(phi) {
            // Iterate through all prime factors of phi and check if we found a power with value 1
            var flag = false
            for it in s {
                // Check if r^((phi)/primefactors) mod n is 1 or not
                if Self(r).raise(toPower: phi / it, mod: self) == 1 {
                    flag = true
                    break
                }
             }

             // If there was no power with value 1.
            if !flag {
                return Self(r)
            }
        }

        // If no primitive root found
        return nil
    }

    /**
     Compute the modular multiplicative inverse of receiver.

     See: https://rosettacode.org/wiki/Modular_inverse#Swift
     */
    @inlinable
    func modularInverse(_ mod: Self) -> Self {
        var (m, n) = (mod, self)
        var (x, y) = (Self(0), Self(1))

        while n != 0 {
            (x, y) = (y, x - (m / n) * y)
            (m, n) = (n, m % n)
        }

        while x < 0 {
            x += mod
        }

        return x
    }

    /**
     Iterative Function to calculate (x^y)%p in O(log y)

     While this can still take a while to compute on large numbers, it's much faster than computing (x^y) % p in the standard way.

     This is compatible with `BigInt` should that ever make it into the base Swift distribution, so it's usable in cryptographic situations.

      **Note:** *Adapted from [GeekForGeeks](https://www.geeksforgeeks.org/primitive-root-of-a-prime-number-n-modulo-n/) .*

     - parameter y: Expoonent
     - parameter p: Modulo

     - returns:
     */
    func raise<T:BinaryInteger>(toPower y: T, mod p : T) -> T {
        var result = T(1) // Initialize result
        var xWork = self
        var yWork = y

        xWork = xWork % Self(p); // Update x if it is more than or equal to p

        while (yWork > 0) {
            // If y is odd, multiply x with result
            if yWork & 1 != 0 {
                result = (result * T(xWork)) % p
            }

            // y must be even now
            yWork = yWork >> 1 // y = y/2
            xWork = (xWork * xWork) % Self(p)
        }
        return result
    }

    func raise<T:BinaryInteger>(toPower y: T) -> T {
        if y < 0 {
            return T(0)
        }

        var result = T(1)
        var base = T(self)
        var exponent = y

        repeat {
            if exponent & 0x1 != 0 {
                result *= base
            }
            exponent >>= 1
            if exponent == 0 {
                break
            }
            base *= base
        } while true

        return result
    }

}

