%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(dist_dbase_server).  

-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(SERVER,?MODULE).
-define(App,dist_dbase).
%% --------------------------------------------------------------------

%% gen server API
-export([
	 start/0,
	 stop/0	
	]).



%% gen_server callbacks



-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
		is_config,
		leader_pid
	       }).

%% ====================================================================
%% External functions
%% ====================================================================


%%gen server API 
start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    {ok,LeaderPid}=leader:start(?App),
    io:format("Start ~p~n",[{node(),?MODULE,?FUNCTION_NAME}]),    
    {ok, #state{leader_pid=LeaderPid,
		is_config=false}}.   
 

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_call({is_config},_From, State) ->
    Reply=State#state.is_config,
    {reply, Reply, State};

handle_call({config},_From, State) ->
    Reply=case State#state.is_config of
	      false->
		  IntialNode=node(),
		  lib_db_etcd:dynamic_install_start(IntialNode),
		  case lib_db_etcd:config() of
		      {error,Reason}->
			  NewState=State,
			  {error,["Failed to config db_etcd :",Reason,?MODULE,?LINE]};
		      ok->
			  NewState=State#state{is_config=true},
			  ok
		  end;
	      true->
		  NewState=State,
		  {error,["Already config db_etcd :",?MODULE,?LINE]}
	  end,
    {reply, Reply, NewState};

%% Leader API functions
handle_call({am_i_leader,Node}, _From, State) ->
    Reply = leader:am_i_leader(State#state.leader_pid,Node,5000),
    {reply, Reply, State};

handle_call({who_is_leader}, _From, State) ->
    Reply = leader:who_is_leader(State#state.leader_pid,5000),
    {reply, Reply, State};

handle_call({ping_leader}, _From, State) ->
%    io:format("ping_leader ~p~n",[{?MODULE,?LINE}]),
    Reply = leader:ping(State#state.leader_pid,5000),
    {reply, Reply, State};

%% gen_server API
handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call({stop},_From, State) ->
    {stop, normal,stopped, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
%% Leader API functions
handle_cast({i_am_alive,MyNode}, State) ->
    leader:i_am_alive(State#state.leader_pid,MyNode),
    {noreply, State};

handle_cast({declare_victory,LeaderNode}, State) ->
    leader:declare_victory(State#state.leader_pid,LeaderNode),
    {noreply, State};

handle_cast({start_election}, State) ->
    leader:start_election(State#state.leader_pid),
    {noreply, State};

%% gen_server API functions

handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{Msg,?MODULE,?LINE}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(timeout, State) ->
    io:format("timeout ~p~n",[{node(),?MODULE,?LINE}]), 
    spawn(fun()->db_etcd:install() end),
    {noreply, State};

   
handle_info(Info, State) ->
    io:format("unmatched match~p~n",[{Info,?MODULE,?LINE}]), 
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
