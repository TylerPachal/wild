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




1) property should act the same as bash implementation (WildTest)
     test/wild_test.exs:53
     Property Elixir.WildTest.property should act the same as bash implementation() failed. Counter-Example is:
     [{<<98, 0, 97, 97>>, "b?a*"}]

     Counter example stored.

     code: nil
     stacktrace:
       (propcheck) lib/properties.ex:206: PropCheck.Properties.handle_check_results/4
       test/wild_test.exs:53: (test)

Initial: I added some `echo` statements to my bash test script and it shows that only the first character of the input binary is being interpreted.  In this case 98 is actually "b", but nothing shows after that.  The 0 value is null so I wonder if that has something to do with it.

Turns out the null character is not allowed in filenames so I guess it is not supported by glob search?  Solution: Add a such_that so we don't get that character




1) property should act the same as bash implementation (WildTest)
     test/wild_test.exs:59
     Property Elixir.WildTest.property should act the same as bash implementation() failed. Counter-Example is:
     [{<<2, 1, 40>>, <<2, 63, 40>>}]

     Counter example stored.

     code: nil
     stacktrace:
       (propcheck) lib/properties.ex:206: PropCheck.Properties.handle_check_results/4
       test/wild_test.exs:59: (test)

Some more low-ascii-value bytes.  Asking a question on StackExchange to make sure my bash-tester-script works appropriately.




1) property should act the same as bash implementation (WildTest)
     test/wild_test.exs:59
     Property Elixir.WildTest.property should act the same as bash implementation() failed. Counter-Example is:
     [{"\\", "\\"}]

     Counter example stored.

     code: nil
     stacktrace:
       (propcheck) lib/properties.ex:206: PropCheck.Properties.handle_check_results/4
       test/wild_test.exs:59: (test)

This looks like an actual bug: I think the input should be interpreted literally while the pattern can be escaped?




1) property should act the same as bash implementation (WildTest)
     test/wild_test.exs:53
     Property Elixir.WildTest.property should act the same as bash implementation() failed with an error: {:error, :cant_generate}
     code: nil
     stacktrace:
       (propcheck) lib/properties.ex:185: PropCheck.Properties.handle_check_results/4
       test/wild_test.exs:53: (test)


1) property should act the same as bash implementation (WildTest)
     test/wild_test.exs:21
     Property Elixir.WildTest.property should act the same as bash implementation() failed. Counter-Example is:
     [{"v", "[-g----]?l ub"}]

     Consider running `MIX_ENV=test mix propcheck.clean` if a bug in a generator was
     identified and fixed. PropCheck cannot identify changes to generators. See
     https://github.com/alfert/propcheck/issues/30 for more details.


1) property match - property tests should act the same as bash implementation (Wild.ByteTest)
    test/wild/byte_test.exs:105
    Property Elixir.Wild.ByteTest.property match - property tests should act the same as bash implementation() failed. Counter-Example is:
    [{"\r", "!c[t][so-d]]e"}]

    Counter example stored.

    code: nil
    stacktrace:
      (propcheck) lib/properties.ex:206: PropCheck.Properties.handle_check_results/4
      test/wild/byte_test.exs:105: (test)