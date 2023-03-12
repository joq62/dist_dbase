%% Author: uabjle
%% Created: 10 dec 2012
%% Description: TODO: Add description to application_org
-module(dist_dbase).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(SERVER,dist_dbase_server).
%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------

%% External exports

%% Application API
-export([
	 is_config/0,
	 config/0
	]).

%% gen_server API
-export([
	 ping/0
	]).

%% Leader API
-export([
	 start_election/0,declare_victory/1,i_am_alive/1,
	 who_is_leader/0,am_i_leader/1,
	 ping_leader/0
	]).



%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% API Functions
%% --------------------------------------------------------------------


%% Application API

is_config()-> gen_server:call(?SERVER, {is_config}).
config()-> gen_server:call(?SERVER, {config}).

%% gen_server API 
ping() -> gen_server:call(?SERVER, {ping}).

%% API for leader 
who_is_leader()-> gen_server:call(?SERVER,{who_is_leader},infinity).
am_i_leader(Node)-> gen_server:call(?SERVER,{am_i_leader,Node},infinity).
ping_leader()-> gen_server:call(?SERVER,{ping_leader},infinity).    

%% election callbacks
start_election()-> gen_server:cast(?SERVER,{start_election}).
declare_victory(LeaderNode)-> gen_server:cast(?SERVER,{declare_victory,LeaderNode}).
i_am_alive(MyNode)-> gen_server:cast(?SERVER,{i_am_alive,MyNode}).



%% ====================================================================!
%% External functions
%% ====================================================================!


%% ====================================================================
%% Internal functions
%% ====================================================================
