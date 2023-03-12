%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(all).      
    
 
-export([start/1

	]).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

start([_ClusterSpec,_HostSpec])->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    
    ok=setup(),
    ok=test_1(),
   
    io:format("Stop OK !!! ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    timer:sleep(2000),
  % init:stop(),
    ok.


%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
test_1()->
  io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    AllNodes=test_nodes:get_nodes(),
    [N1,N2,N3,N4]=AllNodes,
    %% Init
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
      
 %   Ping=[{X1,X2,rpc:call(X1,net_adm,ping,[X2],5000)}||X1<-AllNodes,
%						 X2<-AllNodes,
%						 X1=/=X2],
 %   io:format("Ping ~p~n",[{Ping,?MODULE,?LINE}]),
    %% N1
    ok=rpc:call(N1,application,load,[dist_dbase],5000),
    ok=rpc:call(N1,application,start,[dist_dbase],5000),
    pong=rpc:call(N1,dist_dbase,ping,[],5000),
    pong=rpc:call(N1,dist_dbase,ping_leader,[],5000),
    timer:sleep(2000),
    N1=rpc:call(N1,dist_dbase,who_is_leader,[]),
    false=rpc:call(N1,dist_dbase,am_i_leader,[node()],5000),
    true=rpc:call(N1,dist_dbase,am_i_leader,[N1],5000),
    io:format("N1 dist OK! ~p~n",[{?MODULE,?LINE}]),

    %% N2
    ok=rpc:call(N2,application,load,[dist_dbase],5000),
    ok=rpc:call(N2,application,start,[dist_dbase],5000),
    pong=rpc:call(N2,dist_dbase,ping,[],5000),
    pong=rpc:call(N2,dist_dbase,ping_leader,[],5000),
    timer:sleep(3000),
    N2=rpc:call(N1,dist_dbase,who_is_leader,[]),
    false=rpc:call(N1,dist_dbase,am_i_leader,[node()],5000),
    false=rpc:call(N1,dist_dbase,am_i_leader,[N1],5000),
    true=rpc:call(N1,dist_dbase,am_i_leader,[N2],5000),
    io:format("N2 dist_dbase OK! ~p~n",[{?MODULE,?LINE}]),

  %% N3
    ok=rpc:call(N3,application,load,[dist_dbase],5000),
    ok=rpc:call(N3,application,start,[dist_dbase],5000),
    pong=rpc:call(N3,dist_dbase,ping,[],5000),
    pong=rpc:call(N3,dist_dbase,ping_leader,[],5000),
    timer:sleep(2000),
    N3=rpc:call(N1,dist_dbase,who_is_leader,[]),
    false=rpc:call(N1,dist_dbase,am_i_leader,[node()],5000),
    false=rpc:call(N1,dist_dbase,am_i_leader,[N1],5000),
    false=rpc:call(N1,dist_dbase,am_i_leader,[N2],5000),
    true=rpc:call(N1,dist_dbase,am_i_leader,[N3],5000),
    io:format("N3 dist_dbase OK! ~p~n",[{?MODULE,?LINE}]),
  
 %% N4
    ok=rpc:call(N4,application,load,[dist_dbase],5000),
    ok=rpc:call(N4,application,start,[dist_dbase],5000),
    pong=rpc:call(N4,dist_dbase,ping,[],5000),
    pong=rpc:call(N4,dist_dbase,ping_leader,[],5000),
    timer:sleep(2000),
    N4=rpc:call(N1,dist_dbase,who_is_leader,[]),
    false=rpc:call(N1,dist_dbase,am_i_leader,[node()],5000),
    false=rpc:call(N1,dist_dbase,am_i_leader,[N1],5000),
    false=rpc:call(N1,dist_dbase,am_i_leader,[N2],5000),
    false=rpc:call(N1,dist_dbase,am_i_leader,[N3],5000),
    true=rpc:call(N1,dist_dbase,am_i_leader,[N4],5000),
    io:format("N4 dist_dbase OK! ~p~n",[{?MODULE,?LINE}]),

 %% kill N3 
    io:format("kill N3  ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    rpc:call(N3,init,stop,[],5000),
    timer:sleep(1500),
    N4=rpc:call(N1,dist_dbase,who_is_leader,[]),
    
    %% kill N4
    io:format("kill N4  ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    rpc:call(N4,init,stop,[],5000),
    timer:sleep(1500),
    N2=rpc:call(N1,dist_dbase,who_is_leader,[]),

    %% restart N3 
    %% Important
    {ok,N3}=test_nodes:start_slave("c3"),
    [rpc:call(N3,net_adm,ping,[N],5000)||N<-AllNodes],
    true=rpc:call(N3,code,add_patha,["ebin"],5000),    
    true=rpc:call(N3,code,add_patha,["tests_ebin"],5000),     
    true=rpc:call(N3,code,add_patha,["common/ebin"],5000),     
    ok=rpc:call(N3,application,start,[common],5000), 
    true=rpc:call(N3,code,add_patha,["sd/ebin"],5000),     
    ok=rpc:call(N3,application,start,[sd],5000), 
    ok=rpc:call(N3,application,start,[dist_dbase],5000), 
    pong=rpc:call(N3,dist_dbase,ping,[],5000),
    timer:sleep(2000),
    N3=rpc:call(N1,dist_dbase,who_is_leader,[]),
    false=rpc:call(N1,dist_dbase,am_i_leader,[node()],5000),
    false=rpc:call(N1,dist_dbase,am_i_leader,[N1],5000),
    false=rpc:call(N3,dist_dbase,am_i_leader,[N2],5000),
    true=rpc:call(N1,dist_dbase,am_i_leader,[N3],5000),
    io:format("restart N3 OK!  ~p~n",[{?MODULE,?LINE}]),

    %% restart N4 
    {ok,N4}=test_nodes:start_slave("c4"),
    [rpc:call(N4,net_adm,ping,[N],5000)||N<-AllNodes],
    true=rpc:call(N4,code,add_patha,["ebin"],5000),    
    true=rpc:call(N4,code,add_patha,["tests_ebin"],5000),     
    true=rpc:call(N4,code,add_patha,["common/ebin"],5000),     
    ok=rpc:call(N4,application,start,[common],5000), 
    true=rpc:call(N4,code,add_patha,["sd/ebin"],5000),     
    ok=rpc:call(N4,application,start,[sd],5000), 
    ok=rpc:call(N4,application,start,[dist_dbase],5000), 
    pong=rpc:call(N4,dist_dbase,ping,[],5000),
    timer:sleep(2000),
    N4=rpc:call(N1,dist_dbase,who_is_leader,[]),
    false=rpc:call(N1,dist_dbase,am_i_leader,[node()],5000),
    false=rpc:call(N1,dist_dbase,am_i_leader,[N1],5000),
    false=rpc:call(N3,dist_dbase,am_i_leader,[N2],5000),
    false=rpc:call(N3,dist_dbase,am_i_leader,[N3],5000),
    true=rpc:call(N1,dist_dbase,am_i_leader,[N4],5000),
    io:format("restart N4 OK!  ~p~n",[{?MODULE,?LINE}]),
    
    
  

  init:stop(),
    timer:sleep(2000),

  ok.


%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    ok=test_nodes:start_nodes(),
    [rpc:call(N,code,add_patha,["ebin"],5000)||N<-test_nodes:get_nodes()],    
%    [rpc:call(N,code,add_patha,["tests_ebin"],5000)||N<-test_nodes:get_nodes()],     
    [rpc:call(N,code,add_patha,["common/ebin"],5000)||N<-test_nodes:get_nodes()],     
    [rpc:call(N,application,start,[common],5000)||N<-test_nodes:get_nodes()], 
    [rpc:call(N,code,add_patha,["sd/ebin"],5000)||N<-test_nodes:get_nodes()],     
    [rpc:call(N,application,start,[sd],5000)||N<-test_nodes:get_nodes()], 
    
    ok.
