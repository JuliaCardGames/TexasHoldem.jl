using Test
using PlayingCards
using TexasHoldem
import TexasHoldem
import Random
const TH = TexasHoldem
import Random

include("tester_bots.jl")
QuietGame(args...; kwargs...) = Game(args...; kwargs..., logger=TH.ByPassLogger())

@testset "Game: Play (invalid number of players)" begin
    @test_throws AssertionError("Invalid number of players") QuietGame(ntuple(i->Player(Bot5050(), i), 1))
    @test_throws AssertionError("Invalid number of players") QuietGame(ntuple(i->Player(Bot5050(), i), 11))
end

@testset "Game: Play (BotCheckCall)" begin
    play!(QuietGame(ntuple(i->Player(BotCheckCall(), i), 3)))
end

@testset "Game: Play (BotCheckFold)" begin
    play!(QuietGame(ntuple(i->Player(BotCheckFold(), i), 3)))
end

@testset "Game: Play (BotBetSB) - breaks lowest allowable bet" begin
    game = QuietGame((Player(BotBetSB(),1), Player(BotCheckCall(),2)))
    # Cannot raise small blind on pre-flop! The big blind is the raise min raise, so we must raise at least big-blind
    @test_throws AssertionError("Cannot raise 1. Raise must be between [4, 200]") play!(game)
end

@testset "Game: Play (BotBetBB)" begin
    play!(QuietGame((Player(BotBetBB(), 1), Player(BotCheckCall(), 2),)))
end

struct NoActionBot <: AbstractStrategy end

TH.player_option(game::Game, player::Player{NoActionBot}, ::AbstractRound, ::AbstractPlayerOptions) = nothing

@testset "Game: Play (NoActionBot)" begin
    game = QuietGame((Player(BotCheckCall(), 1), Player(NoActionBot(), 2),))
    # @test_throws AssertionError("Must take exactly 1 action.") play!(game)
    @test_throws TypeError(:typeassert, "", TH.Action, nothing) play!(game)
end

@testset "Non-valid option using BotCheckOnCallRaiseFold" begin
    game = QuietGame((Player(BotCheckCall(), 1), Player(BotCheckOnCallRaiseFold(), 2),))
    @test_throws AssertionError("a.name in (:call, :raise, :all_in, :fold)") play!(game)
end
@testset "Non-valid option using BotCheckOnCallAllInFold" begin
    game = QuietGame((Player(BotCheckOnCallAllInFold(), 1), Player(BotRaiseAlmostAllIn(), 2)))
    @test_throws AssertionError("a.name in (:call, :all_in, :fold)") play!(game)
end
@testset "Non-valid option using BotCheckOnCallFold" begin
    game = QuietGame((Player(BotCheckOnCallFold(), 1), Player(BotRaiseAllIn(), 2)))
    @test_throws AssertionError("a.name in (:call, :fold)") play!(game)
end
@testset "Non-valid option using BotCallOnCheckRaiseFold" begin
    game = QuietGame((Player(BotCheckCall(), 1), Player(BotCallOnCheckRaiseFold(), 2),))
    @test_throws AssertionError("a.name in (:check, :raise, :all_in, :fold)") play!(game)
end
@testset "Non-valid option using BotRaiseOnCallFold" begin
    game = QuietGame((Player(BotRaiseOnCallFold(), 1), Player(BotRaiseAllIn(), 2)))
    @test_throws AssertionError("a.name in (:call, :fold)") play!(game)
end

Random.seed!(1234)
# TODO: this is broken due to https://github.com/charleskawczynski/TexasHoldem.jl/issues/200
@testset "Player limps all in (seat order 1, 2 players)" begin
    for i in 1:100 # loop to ensure BotLimpAllIn wins at least one game
        logger = TH.DebugLogger()
        players = (
            Player(BotLimpAllIn(), 1; bank_roll = 1),
            Player(BotCheckCall(), 2; bank_roll = 11),
        )
        # game = Game(players; logger)
        game = QuietGame(players)
        play!(game)
    end
end

Random.seed!(1234)
# TODO: this is broken due to https://github.com/charleskawczynski/TexasHoldem.jl/issues/200
@testset "Player limps all in (seat order 2, 2 players)" begin
    for i in 1:100 # loop to ensure BotLimpAllIn wins at least one game
        logger = TH.DebugLogger()
        players = (
            Player(BotCheckCall(), 2; bank_roll = 11),
            Player(BotLimpAllIn(), 1; bank_roll = 1),
        )
        # game = Game(players; logger)
        game = QuietGame(players)
        play!(game)
    end
end

Random.seed!(1234)
# TODO: this is broken due to https://github.com/charleskawczynski/TexasHoldem.jl/issues/200
@testset "Player limps all in (seat order 2, 3 players)" begin
    for i in 1:100 # loop to ensure BotLimpAllIn wins at least one game
        logger = TH.DebugLogger()
        players = (
            Player(BotLimpAllIn(), 1; bank_roll = 1),
            Player(BotCheckCall(), 2; bank_roll = 11),
            Player(BotCheckCall(), 3; bank_roll = 11),
        )
        # game = Game(players; logger)
        game = QuietGame(players)
        play!(game)
    end
end

Random.seed!(1234)
# TODO: this is broken due to https://github.com/charleskawczynski/TexasHoldem.jl/issues/200
@testset "Player limps all in (seat order 2, 3 players)" begin
    for i in 1:100 # loop to ensure BotLimpAllIn wins at least one game
        logger = TH.DebugLogger()
        players = (
            Player(BotCheckCall(), 2; bank_roll = 11),
            Player(BotLimpAllIn(), 1; bank_roll = 1),
            Player(BotCheckCall(), 3; bank_roll = 11),
        )
        # game = Game(players; logger)
        game = QuietGame(players)
        play!(game)
    end
end


n_check_actions = [0]
n_call_actions = [0]
@testset "N-actions (3 players)" begin
    play!(QuietGame(ntuple(i->Player(BotNActions(), i), 3)))
    @test n_call_actions[1] == 2 # dealer + small blind
    # 1 check pre-flop (big blind)
    # 3 checks (flop)
    # 3 checks (turn)
    # 3 checks (river)
    @test n_check_actions[1] == 10
end

n_check_actions = [0]
n_call_actions = [0]
@testset "N-actions (4 players)" begin
    play!(QuietGame(ntuple(i->Player(BotNActions(), i), 4)))
    @test n_call_actions[1] == 3 # dealer + small blind + 1 other
    # 1 check pre-flop (big blind)
    # 4 checks (flop)
    # 4 checks (turn)
    # 4 checks (river)
    @test n_check_actions[1] == 13
end

n_check_actions = [0]
n_call_actions = [0]
@testset "N-actions (custom 1)" begin
    play!(QuietGame((
        Player(BotNActions(), 1),
        Player(BotNActions(), 2; bank_roll = 0),
        Player(BotNActions(), 3),
        Player(BotNActions(), 4; bank_roll = 0),
        Player(BotNActions(), 5),
    ); dealer_pidx = 1))

    @test n_call_actions[1] == 2 # dealer + small blind
    # 1 check pre-flop (big blind)
    # 3 checks (flop)
    # 3 checks (turn)
    # 3 checks (river)
    @test n_check_actions[1] == 10
end

n_check_actions = [0]
n_call_actions = [0]
@testset "N-actions (custom 2)" begin
    play!(QuietGame((
        Player(BotNActions(), 1; bank_roll = 195),
        Player(BotCheckCall(), 2; bank_roll = 0),
        Player(BotPreFlopRaise(7), 3; bank_roll = 256),
        Player(BotCheckCall(), 4; bank_roll = 4),
        Player(BotCheckFold(), 5; bank_roll = 45),
    ); dealer_pidx = 1))

    @test n_call_actions[1] == 2 # dealer + small blind
    # 1 check pre-flop (big blind)
    # 3 checks (flop)
    # 3 checks (turn)
    # 3 checks (river)
    @test n_check_actions[1] == 3
end

@testset "Test reward" begin
    logger=TH.InfoLogger()
    # logger=TH.ByPassLogger()
    # custom deal:
    players = (
        Player(BotCheckCall(), 1, (A♠, A♣); bank_roll = 1*100),
        Player(BotCheckCall(), 2, (K♠, K♣); bank_roll = 2*100),
        Player(BotRaiseAllIn(), 3, (Q♠, Q♣); bank_roll = 3*100),
    )
    table_cards = (A♢, K♡, Q♢, 2♠, 3♠)
    tm = TH.TransactionManager(players)
    table = Table(players;cards=table_cards,transactions=tm, logger)
    # TH._play!(QuietGame(players; dealer_pidx = 1))
    initial_brs = deepcopy(bank_roll.(players))
    TH.contribute!(table, players[2], 1, true)
    TH.contribute!(table, players[3], 2, true)
    TH._play!(Game(table); initial_brs)
    # @test players[1].game_profit == 200
    # @test players[2].game_profit == 0
    # @test players[3].game_profit == -200

    # # custom deal:
    # players = (
    #     Player(BotCheckCall(), 1, (A♠, A♣); bank_roll = 1*100),
    #     Player(BotCheckCall(), 2, (K♠, K♣); bank_roll = 2*100),
    #     Player(BotRaiseAllIn(), 3, (Q♠, Q♣); bank_roll = 3*100),
    # )
    # table_cards = (A♢, K♡, Q♢, 2♠, 3♠)
    # tm = TH.TransactionManager(players)
    # table = Table(players;cards=table_cards,transactions=tm, logger)
    # # TH._play!(QuietGame(players; dealer_pidx = 1))
    # TH._play!(Game(table))
    # @test players[1].game_profit == 200
    # @test players[2].game_profit == -100
    # @test players[3].game_profit == -100
end
