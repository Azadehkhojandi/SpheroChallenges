# Challenge 2: public/private key puzzle

## Step 1: calculate public and private key 

In this challange we want to practice RSA

1. Choose two prime numbers p, q

Pick 2 colors that you collected most tokens for example Red and Green
Use the first letter of token color you didn't pick to calculate your keys, in our sample would be Blue as a reference 

If total of Reds and total of Greens are not prime number ask your coach to give you remaining tokens. You need to specify exact number. Make sure the total of Reds * total of Greens is greater than ascci value of B


2. Calculation of Modulus And Totient:
 modulus is n=p×q, The totient of n z=(p−1)(q−1) 

3. Choose e (with e<n) that has no common factors
with z. (e, z are “relatively prime”).

4. Choose d such that ed-1 is exactly divisible by z
(in other words: ed mod z = 1 ).

5. Public key is (n,e). Private key is (n,d)

Give your Public key  and Private key to your coach

## Step 2: Send a encrypted message 

Encryption:
Use the first letter of token color you didn't pick to calculate your keys, in our sample would be Blue

m= Assci value of first letter of token color
 
c = m^e mod n

write down the value of on the paper, put it with the lock in the chariot and one blue token that present the color you chose for youe messgae. Send chariot to your coach

## Step 3

Coach will use your message and decrept it with private key you provided, if the result matches with the ascci code of the color of token you pass the test

## Winning Criteria
It's a time base challange and teams will get score based on their arrival and solving the challange.


## Reference
http://doctrina.org/How-RSA-Works-With-Examples.html
https://www.cs.drexel.edu/~jpopyack/IntroCS/HW/RSAWorksheet.html
