#####
##### Game
#####

export Game, play!, tournament!

mutable struct Game{T<:Table, IBRs}
    table::T
    initial_brs::IBRs
end

function Base.show(io::IO, game::Game)
    println(io, "\n----------------------- Poker game")
    show(io, game.table, false)
    for player in players_at_table(game)
        show(io, player)
    end
    println(io, "-----------------------")
end

Game(players; kwargs...) = Game(Players(players); kwargs...)
function Game(players::Players; kwargs...)
    table = Table(players; kwargs...)
    Game(table, deepcopy(bank_roll_chips.(players)))
end

players_at_table(game::Game) = players_at_table(game.table)
blinds(game::Game) = blinds(game.table)
any_actions_required(game::Game) = any_actions_required(game.table)
round(game::Game) = round(game.table)
move_buttons!(game) = move_buttons!(game.table)

print_round(table, round::PreFlop) = @cinfo table.logger "Pre-flop!"
print_round(table, round::Flop) =  @cinfo table.logger "Flop: $(repeat(" ", 44)) $(table.cards[1:3])"
print_round(table, round::Turn) =  @cinfo table.logger "Turn: $(repeat(" ", 44)) $(table.cards[4])"
print_round(table, round::River) = @cinfo table.logger "River: $(repeat(" ", 43)) $(table.cards[5])"

set_preflop_blind_raise!(table::Table, player, ::AbstractRound, i::Int) = nothing
function set_preflop_blind_raise!(table::Table, player::Player, ::PreFlop, i::Int)
    if 1 ≤ i ≤ length(players_at_table(table))
        if is_first_to_act(table, player)
            # everyone must call big blind to see flop:
            table.current_raise_amt = blinds(table).big
            table.initial_round_raise_amt = blinds(table).big
        end
    end
end
reset_round_bank_rolls!(game::Game, round::PreFlop) = nothing # called separately prior to deal
reset_round_bank_rolls!(game::Game, round::AbstractRound) = reset_round_bank_rolls!(game.table)

# TODO: compactify. Some of these cases/conditions may be redundant
function end_of_actions(table::Table, player)
    players = players_at_table(table)
    logger = table.logger
    @cdebug logger "     last_to_raise.(players) = $(last_to_raise.(players))"
    @cdebug logger "     checked.(players) = $(checked.(players))"
    @cdebug logger "     folded.(players) = $(folded.(players))"
    @cdebug logger "     action_required.(players) = $(action_required.(players))"
    @cdebug logger "     !any(action_required.(players)) = $(!any(action_required.(players)))"
    @cdebug logger "     all_playing_all_in(table) = $(all_playing_all_in(table))"
    @cdebug logger "     all_playing_checked(table) = $(all_playing_checked(table))"
    @cdebug logger "     all_all_in_or_checked(table) = $(all_all_in_or_checked(table))"
    @cdebug logger "     all_all_in_except_bank_roll_leader(table) = $(all_all_in_except_bank_roll_leader(table))"
    @cdebug logger "     all_oppononents_all_in(table, player) = $(all_oppononents_all_in(table, player))"

    case_1 = last_to_raise(player)
    case_2 = all_playing_checked(table)
    case_3 = all_playing_all_in(table)
    case_4 = all_all_in_except_bank_roll_leader(table)
    case_5 = all_all_in_or_checked(table) # TODO: likely replaceable with case_6
    case_6 = !any(x->action_required(x), players)
    case_7 = all_oppononents_all_in(table, player) && paid_current_raise_amount(table, player)
    @cdebug logger "     cases = $((case_1, case_2, case_3, case_4, case_5, case_6, case_7))"

    return any((case_1, case_2, case_3, case_4, case_5, case_6, case_7))
end

function last_player_to_raise(players)
    for player in players
        last_to_raise(player) && return player
    end
    return nothing
end

function all_bets_were_called(table::Table)
    players = players_at_table(table)
    lptr = last_player_to_raise(players)
    lptr===nothing && return true
    logger = table.logger

    @assert count(x->last_to_raise(x), players) == 1
    @cdebug logger "Checking if all bets were called"
    @cdebug logger "     table.winners.declared = $(table.winners.declared)"
    @cdebug logger begin
        conds_debug = map(players) do player
            sn = seat_number(player)
            cond1 = seat_number(player) == seat_number(lptr)
            cond2 = not_playing(player)
            cond3 = all_in(player)
            cond4 = pot_investment(player) == pot_investment(lptr)
            (sn, cond1, cond2, cond3, cond4)
        end
        for cond in conds_debug
            @cdebug logger "sn, cond = $(cond[1]), $(cond[2:end])"
        end
        @cdebug logger "snlptr = $(seat_number(lptr))"
    end
    return all(player-> begin
        cond1 = seat_number(player) == seat_number(lptr)
        cond2 = not_playing(player)
        cond3 = all_in(player)
        cond4 = pot_investment(player) == pot_investment(lptr)
        any((cond1, cond2, cond3, cond4))
    end, players)
end

end_preflop_actions(table, player, ::AbstractRound) = false
function end_preflop_actions(table::Table, player::Player, ::PreFlop)
    cond1 = is_big_blind(table, player)
    cond2 = checked(player)
    cond3 = still_playing(player)
    return all((cond1, cond2, cond3))
end

skip_pre_option(sf::StartFrom{StartOfGame}, _) = false
skip_option(sf::StartFrom{StartOfGame}, _) = false
skip_post_option(sf::StartFrom{StartOfGame}, _) = false

skip_pre_option(sf::StartFrom{GP}, player) where {GP <: PlayerOption} =
    true
skip_option(sf::StartFrom{GP}, player) where {GP <: PlayerOption} =
    seat_number(sf.game_point.player) ≠ seat_number(player)
skip_post_option(sf::StartFrom{GP}, player) where {GP <: PlayerOption} =
    seat_number(sf.game_point.player) ≠ seat_number(player)

function act_generic!(game::Game, round::AbstractRound, sf::StartFrom)
    table = game.table
    players = table.players
    logger = table.logger
    table.winners.declared && return
    @assert sf.game_point isa StartOfGame || sf.game_point isa PlayerOption
    if sf.game_point isa StartOfGame
        set_round!(table, round)
        print_round(table, round)
        reset_round_bank_rolls!(game, round)

        any_actions_required(game) || return
        play_out_game(table) && return
        set_play_out_game!(table)
    end
    reached_game_point = false # to support when StartFrom is not StartOfGame
    # need a bool so that we pick the recreated
    # action (in `sf.game_point.action`) once,
    # and then continue with `player_option`.
    past_game_point = false
    for (i, sn) in enumerate(circle(table, FirstToAct()))
        player = players[sn]
        if reached_game_point || !skip_pre_option(sf, player)
            @cdebug logger "Checking to see if it's $(name(player))'s turn to act"
            @cdebug logger "     not_playing(player) = $(not_playing(player))"
            @cdebug logger "     all_in(player) = $(all_in(player))"
            not_playing(player) && continue # skip players not playing
            set_preflop_blind_raise!(table, player, round, i)
            if end_of_actions(table, player)
                break
            end
            all_in(player) && continue
            @cdebug logger "$(name(player))'s turn to act"
        end
        if reached_game_point || !skip_option(sf, player)
            reached_game_point = true
            if sf.game_point isa PlayerOption && !past_game_point
                action = sf.game_point.action
                past_game_point = true
            else
                action = player_option(game, player)
            end
        end
        if reached_game_point || !skip_post_option(sf, player)
            update_given_valid_action!(table, player, action)
            table.winners.declared && break
            end_preflop_actions(table, player, round) && break
        end
        if i > n_max_actions(table)
            error("Too many actions have occurred, please open an issue.")
        end
    end
    @cinfo logger "Betting is finished."
    @assert all_bets_were_called(table)
end

skip_round(round::AbstractRound, sf::StartFrom) = skip_round(round, sf.game_point)
skip_round(round::AbstractRound, gp::StartOfGame) = false
skip_round(round::AbstractRound, po::PlayerOption) = skip_round(round, po.round)
skip_round(round::AbstractRound, ::AbstractRound) = false

# Skip to Preflop
# Nothing needed-- we automatically skip to this if `StartFrom` is not StartOfGame

# Skip to Flop
skip_round(round::PreFlop, ::Flop) = true

# Skip to Turn
skip_round(round::PreFlop, ::Turn) = true
skip_round(round::Flop, ::Turn) = true

# Skip to River
skip_round(round::PreFlop, ::River) = true
skip_round(round::Flop, ::River) = true
skip_round(round::Turn, ::River) = true

function act!(game::Game, round::AbstractRound, sf::StartFrom)
    skip_round(round, sf) && return nothing
    act_generic!(game, round, sf)
    reset_round!(game.table)
end

metafmt(level, _module, group, id, file, line) =
    Logging.default_metafmt(level, nothing, group, id, nothing, nothing)

function pidx_from_seat_number(player, players)::Int
    for (i, p) in enumerate(players)
        if seat_number(player) == seat_number(p)
            return i
        end
    end
    error("Uncaught case")
end

function max_possible_profit(player, players, initial_brs)
    mpp = Chips(0)
    pidx = pidx_from_seat_number(player, players)
    for (oidx, opponent) in enumerate(players)
        seat_number(player) == seat_number(opponent) && continue
        mpp += min(initial_brs[pidx], initial_brs[oidx])
    end
    return mpp
end

"""
    play!(game::Game[, sf::StartFrom])

Play a game.

Optionally, users can pass in a `StartFrom`
option, to start from a game-point, specified
by `sf`.
"""
play!(game::Game, sf::StartFrom = StartFrom(StartOfGame())) =
    deal_and_play!(game::Game, sf)

"""
    deal_and_play!(game::Game[, sf::StartFrom])

Deal and play a game.

Optionally, users can pass in a `StartFrom`
option, to start from a game-point, specified
by `sf`.
"""
function deal_and_play!(game::Game, sf::StartFrom = StartFrom(StartOfGame()))
    if game.table.logger isa DebugLogger
        cl = Logging.ConsoleLogger(stderr,Logging.Debug; meta_formatter=metafmt)
        Logging.with_logger(cl) do
            _deal_and_play!(game, sf)
        end
    else
        _deal_and_play!(game, sf)
    end
end

∑bank_rolls(players) =
    mapreduce(x->bank_roll_chips(x), +, players; init=Chips(0))

function _deal!(game::Game, sf::StartFrom)
    logger = game.table.logger
    table = game.table
    winners = table.winners
    players = players_at_table(table)
    initial_brs = game.initial_brs
    if sf.game_point isa PlayerOption
        # Cannot (or, should not) play from a point
        # at which a winner has been declared
        @assert !winners.declared
    end

    if sf.game_point isa StartOfGame
        for (pidx, player) in enumerate(players)
            initial_brs[pidx] = bank_roll_chips(player)
        end
        @cinfo logger "------ Playing game!"
        set_active_status!(table)
        initial_∑brs = ∑bank_rolls(players)

        @cinfo logger "Initial bank roll summary: $(bank_roll_chips.(players))"

        did = dealer_pidx(table)
        sb = seat_number(small_blind(table))
        bb = seat_number(big_blind(table))
        f2a = seat_number(first_to_act(table))
        @cinfo logger "Buttons (dealer, small, big, 1ˢᵗToAct): ($did, $sb, $bb, $f2a)"
        @assert still_playing(dealer(table)) "The button must be placed on a non-folded player"
        @assert still_playing(small_blind(table)) "The small blind button must be placed on a non-folded player"
        @assert still_playing(big_blind(table)) "The big blind button must be placed on a non-folded player"
        @assert still_playing(first_to_act(table)) "The first-to-act button must be placed on a non-folded player"
    end

    @assert dealer_pidx(table) ≠ small_blind_pidx(table) "The button and small blind cannot coincide"
    @assert small_blind_pidx(table) ≠ big_blind_pidx(table) "The small and big blinds cannot coincide"
    @assert big_blind_pidx(table) ≠ first_to_act_pidx(table) "The big blind and first to act cannot coincide"

    if sf.game_point isa StartOfGame
        reset!(table.transactions, players)
        @assert all(p->cards(p) == nothing, players)
        @assert cards(table) == nothing
        reset_round_bank_rolls!(table) # round bank-rolls must account for blinds
        deal!(table, blinds(table))
        @assert cards(table) ≠ nothing
    end
end

function _play!(game::Game, sf::StartFrom = StartFrom(StartOfGame());
        initial_brs,
    )
    initial_∑brs = sum(initial_brs)
    logger = game.table.logger
    table = game.table
    winners = table.winners
    players = players_at_table(table)
    winners.declared || act!(game, PreFlop(), sf)   # Pre-flop bet/check/raise
    winners.declared || act!(game, Flop(), sf)      # Deal flop , then bet/check/raise
    winners.declared || act!(game, Turn(), sf)      # Deal turn , then bet/check/raise
    winners.declared || act!(game, River(), sf)     # Deal river, then bet/check/raise

    distribute_winnings!(players, table.transactions, cards(table), logger)
    winners.declared = true

    @cdebug logger "amounts.(table.transactions.side_pots) = $(amounts.(table.transactions.side_pots))"
    @cdebug logger "initial_∑brs = $(initial_∑brs)"
    @cdebug logger "sum(bank_roll.(players)) = $(sum(bank_roll.(players)))"
    @cdebug logger "initial_brs = $(initial_brs)"
    @cdebug logger "bank_roll_chips.(players) = $(bank_roll_chips.(players))"

    if sf.game_point isa StartOfGame
        if !(logger isa ByPassLogger)
            if initial_∑brs ≠ ∑bank_rolls(players)
                @cinfo logger "initial_∑brs=$initial_∑brs, brs=$(bank_roll_chips.(players))"
            end
        end
        @assert initial_∑brs == ∑bank_rolls(players) "initial_∑brs = $(initial_∑brs), ∑bank_rolls = $(∑bank_rolls(players))"
    end
    @assert sum(sp->sum(amounts(sp)), table.transactions.side_pots) == 0
    for (player, initial_br) in zip(players, initial_brs)
        mpp = max_possible_profit(player, players, initial_brs)
        prof = bank_roll_chips(player) - initial_br
        br = map(x->bank_roll_chips(x), players)
        # TODO: this is broken due to https://github.com/charleskawczynski/TexasHoldem.jl/issues/200
        @assert prof ≤ mpp string("Over-winning occurred:\n",
              "    Player $(name(player))\n",
              "    Initial BRs $(initial_brs)\n",
              "    BRs $br\n",
              "    profit $prof\n",
              "    profit.n $(prof.n)\n",
              "    cond $(prof.n ≤ mpp.n)\n",
              "    max possible profit $mpp")
    end

    @cinfo logger "Final bank roll summary: $(bank_roll_chips.(players))"
    @assert winners.declared
    for player in players
        notify_reward(player)
    end

    @cinfo logger "------ Finished game!"
    return winners
end

function _deal_and_play!(game::Game, sf::StartFrom)
    logger = game.table.logger
    table = game.table
    players = players_at_table(table)

    initial_brs = game.initial_brs
    if sf.game_point isa StartOfGame
        for (pidx, player) in enumerate(players)
            initial_brs[pidx] = bank_roll(player)
        end
    end
    _deal!(game, sf)
    _play!(game, sf; initial_brs)
end

function set_active_status!(table::Table)
    players = players_at_table(table)
    for player in players
        if zero_bank_roll(player)
            player.active = false
            player.folded = true
            player.action_required = false
        else
            player.active = true
            player.folded = false
            player.action_required = true
        end
    end
end

function reset_game!(game::Game)
    table = game.table
    logger = table.logger
    players = players_at_table(table)

    game.table = Table(players;
        dealer_pidx=dealer_pidx(table),
        blinds=table.blinds,
        logger=logger,
    )
    PlayingCards.reset!(game.table.deck)
    table = game.table
    players = players_at_table(table)
    for player in players
        player.cards = nothing
        player.pot_investment = 0
        player.game_profit = Chips(0)
        player.all_in = false
        player.round_bank_roll = bank_roll_chips(player)
        player.checked = false
        player.last_to_raise = false
        player.round_contribution = 0
        player.active = true
    end
    set_active_status!(table)
    table.play_out_game = false
end

"""
    tournament!(game::Game)

Play until a single player remains!
"""
function tournament!(game::Game)
    logger = game.table.logger
    @cinfo logger "********************************"
    @cinfo logger "******************************** Playing tournament!"
    @cinfo logger "********************************"
    table = game.table
    players = players_at_table(table)
    while length(players) > 1
        play!(game)
        n_players_remaining = count(x->!(bank_roll(x) == 0), players)
        if n_players_remaining ≤ 1
            @cinfo logger "Victor emerges!"
            break
        end
        reset_game!(game)
        move_buttons!(game)
    end
    @cinfo logger "********************************"
    @cinfo logger "******************************** Finished tournament!"
    @cinfo logger "********************************"
    return game.table.winners
end

