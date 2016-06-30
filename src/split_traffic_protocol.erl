-module(split_traffic_protocol).

-behaviour(gen_server).
-behaviour(ranch_protocol).

%% API.
-export([start_link/4]).

%% gen_server.
-export([init/1, init/4,
          handle_call/3,
          handle_cast/2,
          handle_info/2,
          terminate/2,
          code_change/3]).

-define(TIMEOUT, 5000).

-record(state, {socket, transport}).

%% API.

start_link(Ref, Socket, Transport, Opts) ->
    proc_lib:start_link(?MODULE, init, [Ref, Socket, Transport, Opts]).

%% gen_server.

%% This function is never called. We only define it so that
%% we can use the -behaviour(gen_server) attribute.
init([]) -> {ok, undefined}.

init(Ref, Socket, Transport, _Opts = []) ->
    ok = proc_lib:init_ack({ok, self()}),
    ok = ranch:accept_ack(Ref),
    ok = Transport:setopts(Socket, [{active, once}]),
    gen_server:enter_loop(?MODULE, [],
        #state{socket=Socket, transport=Transport},
        ?TIMEOUT).

handle_info({tcp, Socket, _Data}, State=#state{
        socket=Socket, transport=Transport}) ->
    Transport:setopts(Socket, [{active, once}]),
    % do something here.
    %Transport:send(Socket, reverse_binary(Data)),
    {noreply, State, ?TIMEOUT};
handle_info({tcp_closed, _Socket}, State) ->
    {stop, normal, State};
handle_info({tcp_error, _, Reason}, State) ->
    {stop, Reason, State};
handle_info(timeout, State) ->
    {stop, normal, State};
handle_info(_Info, State) ->
    {stop, normal, State}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal.
