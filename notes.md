To test a generator:
```
:proper_gen.sample(my_gen)
```

To call my function without going into IEx:
```
mix run -e 'Wild.match?("[cyeois", "[cyeoi?") |> IO.puts'
```

Don't forget about the `:binary` Erlang module!



Failed:


1) property should act the same as bash implementation (WildTest)
     test/wild_test.exs:53
     Property Elixir.WildTest.property should act the same as bash implementation() failed. Counter-Example is:
     [{"", "?"}]

     Counter example stored.

     code: nil
     stacktrace:
       (propcheck) lib/properties.ex:206: PropCheck.Properties.handle_check_results/4
       test/wild_test.exs:53: (test)

The random blogpost I was reading indicated that the question mark could match the empty string - however it looks like my system says otherwise


1) property should act the same as bash implementation (WildTest)
     test/wild_test.exs:58
     Property Elixir.WildTest.property should act the same as bash implementation() failed. Counter-Example is:
     [{"[cyeois", "[cyeoi?"}]

     Counter example stored.

     code: nil
     stacktrace:
       (propcheck) lib/properties.ex:206: PropCheck.Properties.handle_check_results/4
       test/wild_test.exs:58: (test)

It seems that if a class is not completed then it should not be considered a class.  Updating the tokenizer.





Hmmm, after a few tweaks it seems that everything works fine (suspicious, I thought this would be harder)

Had to crank up the `numtests` property, default is 50.  I recommend having a higher number on CircleCI and keeping a smaller number for local development to keep things quick:

config :propcheck,
  num_tests: 1000

Edit: Having these for all tests was silly, using it just on the one test.




{<<98, 0, 97, 97>>, "b?a*"}

Initial: I added some `echo` statements to my bash test script and it shows that only the first character of the input binary is being interpreted.  In this case 98 is actually "b", but nothing shows after that.  The 0 value is null so I wonder if that has something to do with it.

Turns out the null character is not allowed in filenames so I guess it is not supported by glob search?  Solution: Add a such_that so we don't get that character



{"[a", "[a"}

For effeciency I am always adding tokens to the beginning of their respective accumulators (regular tokens and class tokens).  This failing property exposed a place where I had forgotten that my tokens are reversed at the end, and was creating the "proper order" too early (because it would be reversed at the very end in the base case).



{<<2, 1, 40>>, <<2, 63, 40>>}

Some more low-ascii-value bytes.  Asking a question on StackExchange to make sure my bash-tester-script works appropriately.




{"\\", "\\"}

This looks like an actual bug: I think the input should be interpreted literally while the pattern can be escaped?




{<<1, 92>>, "?\\"}





Fixed along the way?

{"v", "[-g----]?l ub"}

{"\r", "!c[t][so-d]]e"}