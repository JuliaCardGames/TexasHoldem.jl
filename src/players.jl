"""
    Players

A collection of players. This collection may
be a Tuple or a vector:

    (player[1], player[2], player[3])
    [player[1], player[2], player[3]]

These indices correspond to the player index (`pidx`).

Both the player's seat number and index
must be unique, but they need not be equal:

    pidx                 : (player[1], player[2], player[3])
    seat_number.(players): (   6     ,    3     ,    2     )

Also, the seat number need not be consecutive
when sorted, whereas the player indexes must
be consecutive when sorted.

Since players are allowed to have different
composition, we provide iterators over the
players index, rather than the players
themselves, for type-stability.

The player index is considered internal, and
the seat number is considered external.

We internally sort the players by the seat number
so that, when we iterate through the table, both
coincide.
"""
struct Players{PS<:Union{Tuple,AbstractArray}}
    players::PS
    function Players(players)
        @assert !isempty(players)
        @assert players[1] isa Player
        @assert allunique(map(x->seat_number(x), players))
        spbsn = sortperm_by_seat_number(players)
        splayers = map(sp->players[sp], spbsn)
        @assert issorted(map(x->seat_number(x), splayers))
        return new{typeof(splayers)}(splayers)
    end
end
Players(players...) = Players(players)

sortperm_by_seat_number(players::Tuple) = TupleTools.sortperm(map(x->seat_number(x), players))
sortperm_by_seat_number(players) = Base.sortperm(map(x->seat_number(x), players))

"""
    cyclic_player_index(::Players, pidx)
    cyclic_player_index(n_players, pidx)

A circular index for indexing into `players`.
`pidx = 1` corresponds to `player[1]`.
"""
cyclic_player_index(players::Players, i) =
    cyclic_player_index(length(players.players), i)
cyclic_player_index(n_players, i) = mod(i-1, n_players)+1

Base.length(p::Players) = length(p.players)
Base.iterate(players::Players, ncpidx = 1) =
    Base.iterate(players.players, ncpidx)
Base.@propagate_inbounds Base.getindex(players::Players, i::Int) =
    Base.getindex(players.players, i)
Base.filter(fn, players::Players) = Base.filter(fn, players.players)
Base.findfirst(fn::Function, players::Players) =
    Base.findfirst(fn, players.players)

function Base.sort!(players::Players{<:AbstractArray})
    Base.sort!(players.players; by=x->bank_roll(x))
    return nothing
end
n_players(players::Players) = length(players)

import TupleTools
Base.sortperm(players::Players{<:AbstractArray}) =
    Base.sortperm(map(x->bank_roll(x), players.players))

Base.sortperm(players::Players{<:Tuple}) =
    TupleTools.sortperm(map(x->bank_roll(x), players.players))
