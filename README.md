Randomex
========

![roll plz](logo.gif)

+/- True Random generator for Elixir

```

Randomex.get_seed
#=> {15926, 11492, 1827}

MobCasApi.apply_seed
#=> :ok

```

Helpers:

```
Randomex.range(0, 100) # Generate random number from "a" to "b" 
#=> 48 

Randomex.range(0, 100)
#=> 15 

Randomex.range(0, 100)
#=> 0

Randomex.range(0, 100)
#=> 100



Randomex.event(60) # Generate true or false for selected percent
#=> true

Randomex.event(60)
#=> true

Randomex.event(60)
#=> false


```
