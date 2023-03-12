%%%-------------------------------------------------------------------
%% @doc org public API
%% @end
%%%-------------------------------------------------------------------

-module(dist_dbase_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    dist_dbase_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
