var documenterSearchIndex = {"docs":
[{"location":"api/#API","page":"API","title":"API","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"TexasHoldem","category":"page"},{"location":"api/#TexasHoldem","page":"API","title":"TexasHoldem","text":"TexasHoldem\n\nA no-limit Texas Holdem simulator.\n\nTerminology\n\ngame a single \"game\", where players are dealt hands, winner(s) are declared once.\nround a point or process in the game, including PreFlop, Flop, Turn, River.\nround the process of each player deciding which actions to take, until no further actions are taking.\n\n\n\n\n\n","category":"module"},{"location":"api/#Game-level-functions","page":"API","title":"Game-level functions","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"move_buttons!\nplay!\ntournament!","category":"page"},{"location":"api/#TexasHoldem.move_buttons!","page":"API","title":"TexasHoldem.move_buttons!","text":"move_buttons!(table::Table)\n\nMove the dealer, small blind, big blind, and first-to-act buttons to the next set of players.\n\nThis is an internal method.\n\n\n\n\n\n","category":"function"},{"location":"api/#TexasHoldem.play!","page":"API","title":"TexasHoldem.play!","text":"play!(game::Game[, sf::StartFrom])\n\nPlay a game.\n\nOptionally, users can pass in a StartFrom option, to start from a game-point, specified by sf.\n\n\n\n\n\n","category":"function"},{"location":"api/#TexasHoldem.tournament!","page":"API","title":"TexasHoldem.tournament!","text":"tournament!(game::Game)\n\nPlay until a single player remains!\n\n\n\n\n\n","category":"function"},{"location":"api/#Chips","page":"API","title":"Chips","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Chips","category":"page"},{"location":"api/#TexasHoldem.Chips","page":"API","title":"TexasHoldem.Chips","text":"Chips(n, frac)\n\nA stack of chips struct. This type is backed by Ints and performs exact arithmetic operations by using Rational numbers to track remainders (fractions of a chip). frac is always internally stored as less than 1.\n\nPlayers can only bet/call with whole chips (n), and are not allowed to bet/call with a fraction of a chip.\n\nWe track the fractions of chips so that we can assert exact money conservation on the table until a player busts, at which point, that money is lost.\n\n\n\n\n\n","category":"type"},{"location":"api/#Player-type-and-methods","page":"API","title":"Player type and methods","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"AbstractStrategy\nHuman\nBot5050\nPlayer\nbank_roll\nround_bank_roll","category":"page"},{"location":"api/#TexasHoldem.AbstractStrategy","page":"API","title":"TexasHoldem.AbstractStrategy","text":"AbstractStrategy\n\nAn abstract strategy type, which users can subtype when passing to players.\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.Human","page":"API","title":"TexasHoldem.Human","text":"Human\n\nA human (terminal input) strategy. Use this strategy if you want to play \"live\" games, and not for simulating games.\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.Bot5050","page":"API","title":"TexasHoldem.Bot5050","text":"Bot5050\n\nBot5050 is a stochastic strategy that chooses all of its actions based on a coin flip.\n\nThis bot is used for fuzzing in the test suite and for quick-start game configurations for users.\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.Player","page":"API","title":"TexasHoldem.Player","text":"Player\n\nContains the poker player information:\n\nstrategy\ncards\nbank roll\npot investment\n\nTODO: some of these fields should be removed, since they're only needed for flow control logic.\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.bank_roll","page":"API","title":"TexasHoldem.bank_roll","text":"bank_roll(::Player)\n\nThe player's instantaneous bank roll.\n\nWe access the Int in Chips as the fractional chips are only handled by the TransactionManager.\n\n\n\n\n\n","category":"function"},{"location":"api/#TexasHoldem.round_bank_roll","page":"API","title":"TexasHoldem.round_bank_roll","text":"round_bank_roll(::Player)\n\nThe player's bank roll at the beginning of the round\n\nWe access the Int in Chips as the fractional chips are only handled by the TransactionManager.\n\n\n\n\n\n","category":"function"},{"location":"api/#Player-actions","page":"API","title":"Player actions","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"TexasHoldem.Action\nCheck\nFold\nCall\ncall_amount\nRaise\nAllIn\nvalid_raise_range","category":"page"},{"location":"api/#TexasHoldem.Action","page":"API","title":"TexasHoldem.Action","text":"Action\n\nAn action type, to be returned by player_option during each players turn to act. This is an internal type, but documented for user understanding.\n\nUsers are expected to return an action from player_option by calling one of Action's convenience methods:\n\nFold\nCheck\nCall\nRaise\nAllIn\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.Check","page":"API","title":"TexasHoldem.Check","text":"Check()\n\nThe check action, to be returned from player_option, when a player wants to check.\n\n\n\n\n\n","category":"function"},{"location":"api/#TexasHoldem.Fold","page":"API","title":"TexasHoldem.Fold","text":"Fold()\n\nThe fold action, to be returned from player_option, when a player wants to fold.\n\n\n\n\n\n","category":"function"},{"location":"api/#TexasHoldem.Call","page":"API","title":"TexasHoldem.Call","text":"Call(amt::Int)\nCall(table::Table, player::Player)\n\nThe call action, should be returned from player_option. when a player wants to call amount amt.\n\nUse call_amount to query how much is needed to call.\n\n\n\n\n\n","category":"function"},{"location":"api/#TexasHoldem.call_amount","page":"API","title":"TexasHoldem.call_amount","text":"call_amount(table::Table, player::Player)\n\nReturn the amount to call inside player_option.\n\n\n\n\n\n","category":"function"},{"location":"api/#TexasHoldem.Raise","page":"API","title":"TexasHoldem.Raise","text":"Raise(amt::Int)\n\nThe raise action, should be returned from player_option. when a player wants to raise to amount amt.\n\nUse valid_raise_range to query the valid range that they are allowed to raise.\n\n\n\n\n\n","category":"function"},{"location":"api/#TexasHoldem.AllIn","page":"API","title":"TexasHoldem.AllIn","text":"AllIn(amt::Int)\nAllIn(table::Table, player::Player)\n\nThe all-in action, should be returned from player_option. when a player wants to raise all in (to amount amt).\n\nUsers may call this via AllIn(last(valid_raise_range(table, player))) or use the convenience function AllIn(table, player).\n\nSee valid_raise_range for querying the valid range that they are allowed to raise.\n\n\n\n\n\n","category":"function"},{"location":"api/#TexasHoldem.valid_raise_range","page":"API","title":"TexasHoldem.valid_raise_range","text":"valid_raise_range(table::Table, player::Player)\n\nA UnitRange{Int} of valid raises. Note that sometimes the range's starting and ending values are the same when, for example, all-in is the only available option.\n\n\n\n\n\n","category":"function"},{"location":"api/#Player-options","page":"API","title":"Player options","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"TexasHoldem.AbstractPlayerOptions\nTexasHoldem.CheckRaiseFold\nTexasHoldem.CallRaiseFold\nTexasHoldem.CallAllInFold\nTexasHoldem.CallFold\nTexasHoldem.player_option","category":"page"},{"location":"api/#TexasHoldem.AbstractPlayerOptions","page":"API","title":"TexasHoldem.AbstractPlayerOptions","text":"AbstractPlayerOptions\n\nThe option super type.\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.CheckRaiseFold","page":"API","title":"TexasHoldem.CheckRaiseFold","text":"CheckRaiseFold\n\nThe option when a player is only able to check, raise, or fold.\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.CallRaiseFold","page":"API","title":"TexasHoldem.CallRaiseFold","text":"CallRaiseFold\n\nThe option when a player is only able to call, raise, or fold.\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.CallAllInFold","page":"API","title":"TexasHoldem.CallAllInFold","text":"CallAllInFold\n\nThe option when a player is only able to call, raise all-in, or fold.\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.CallFold","page":"API","title":"TexasHoldem.CallFold","text":"CallFold\n\nThe option when a player is only able to call or fold.\n\n\n\n\n\n","category":"type"},{"location":"api/#TexasHoldem.player_option","page":"API","title":"TexasHoldem.player_option","text":"player_option(game::Game, player::Player, option::AbstractPlayerOptions)\n\nReturns a valid action (see Action), given the allowable option. TexasHoldem calls player_option for each player on the table during each round. This function is entirely where the strategy logic resides.\n\nUsers may overload this method to develop their own poker bots. The option type is one of\n\nCheckRaiseFold\nCallRaiseFold\nCallAllInFold\nCallFold\n\n\n\n\n\n","category":"function"},{"location":"api/#Training","page":"API","title":"Training","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"There are additional functionalities added for training purposes","category":"page"},{"location":"api/","page":"API","title":"API","text":"TexasHoldem.recreate_game","category":"page"},{"location":"api/#TexasHoldem.recreate_game","page":"API","title":"TexasHoldem.recreate_game","text":"recreate_game(game, player)\n\nCreates an exact (deep)copy of the input game, and then re-samples the unobserved cards (i.e., the opponent cards and unobserved table cards).\n\nThis is useful for repeatedly sampling a specific scenario so that we can compute the expected value of a particular action.\n\nTODO: we could make a mutating, in-place version of this to reduce allocations.\n\n\n\n\n\n","category":"function"},{"location":"quickstart/#Quickstart","page":"Quick-start","title":"Quickstart","text":"","category":"section"},{"location":"quickstart/","page":"Quick-start","title":"Quick-start","text":"Once you've finished Installation, you can start playing games with:","category":"page"},{"location":"quickstart/","page":"Quick-start","title":"Quick-start","text":"using TexasHoldem\nimport TexasHoldem: player_option\nstruct RandomBot <: AbstractStrategy end\nfunction player_option(game::Game, player::Player{RandomBot}, ::CheckRaiseFold)\n    rand() < 0.5 && return Raise(rand(valid_raise_range(game.table, player)))\n    return Check()\nend\nfunction player_option(game::Game, player::Player{RandomBot}, ::CallRaiseFold)\n    rand() < 0.5 && return Call(game.table, player)\n    rand() < 0.5 && return Raise(rand(valid_raise_range(game.table, player)))\n    return Fold()\nend\nfunction player_option(game::Game, player::Player{RandomBot}, ::CallAllInFold)\n    rand() < 0.5 && return Call(game.table, player)\n    rand() < 0.5 && return AllIn(game.table, player)\n    return Fold()\nend\nfunction player_option(game::Game, player::Player{RandomBot}, ::CallFold)\n    rand() < 0.5 && return Call(game.table, player)\n    return Fold()\nend\n# Play against some bots!\nplayers = (Player(Human(), 1), ntuple(i->Player(RandomBot(), i+1), 4)...)\ntournament!(Game(players))","category":"page"},{"location":"installation/#Installation","page":"Installation","title":"Installation","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"All you need is Julia installed to install TexasHoldem.jl:","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"(@v1.x) pkg> add TexasHoldem","category":"page"},{"location":"#TexasHoldem.jl","page":"Home","title":"TexasHoldem.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"TexasHoldem.jl is a package for simulating no-limit Texas Holdem Poker. The package was implemented with developing reinforcement learning poker bots in mind, so some of the key design features are: abstracting away agent decisions from the game engine, performance, and user-friendliness.","category":"page"},{"location":"perf/#Performance","page":"Performance","title":"Performance","text":"","category":"section"},{"location":"perf/","page":"Performance","title":"Performance","text":"Here is a benchmark showcasing the performance of TexasHoldem:","category":"page"},{"location":"perf/","page":"Performance","title":"Performance","text":"import TexasHoldem as TH\nusing TexasHoldem\nusing BenchmarkTools\nimport Logging\nimport Random\nRandom.seed!(1234)\n\nplayers() = ntuple(i->(Player(Bot5050(), i)), 4)\n\nfunction do_work!()\n    play!(Game(players();logger=TH.ByPassLogger()))\n    return nothing\nend\n\ntrial = @benchmark do_work!()\nshow(stdout, MIME(\"text/plain\"), trial)","category":"page"},{"location":"terminology/#Terminology","page":"Terminology","title":"Terminology","text":"","category":"section"},{"location":"terminology/","page":"Terminology","title":"Terminology","text":"This page outlines some of the terminology that TexasHoldem.jl uses:","category":"page"},{"location":"terminology/","page":"Terminology","title":"Terminology","text":"Hand: a set of 5-7 cards a player has, between their own cards and the community (table) cards.\nPlayer: the people, or agents, playing in a hand\nGame: players are dealt cards, bet, and winners of that hand are declared. Tournaments are comprised of N-players who play consecutive games until they lose all their chips.\nRound: a game segment when betting is performed (preflop, flop, turn, and river)\nAction: an action refers to check-ing, fold-ing, call-ing or raise-ing.\nOption: the set of allowable actions that a player can choose from, given the situation during a round. For example, if a player is being raised all in, they may only call or fold.\nBank roll: the chips that a player has on the table, available for betting.\nAction line: a sequence of actions during the round\nReward: a player's profit after a game (their bank roll after - their bank roll before the game).","category":"page"}]
}
