
defmodule ExGithubPoller.Application do

  use Application

  def start(_type, _args) do
    IO.puts(:stderr, "starting")
    Confex.resolve_env!(:ex_github_poller)
    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end

end

defmodule ExGithubPoller.Param do
  defstruct last_event: nil, etag: nil
end
defmodule ExGithubPoller do


  alias ExGithubPoller.Param
  alias HTTPoison.Response
  import Logger

  @spec events(any, any, any) :: any
  def events(owner,repo, param \\ %Param{} ) do

    url = "https://api.github.com/repos/#{owner}/#{repo}/events"

    # TODO : needs handling for the following cases
    # 1. unauthorized/non-existent repo - status_code: 401
    # 2. rate limit exceeded - {"X-RateLimit-Limit", "60"}, {"X-RateLimit-Remaining", "0"}, {"X-RateLimit-Reset", "1559908212"} status_code: 403
    stream = Stream.resource(
      fn -> nil end,
      fn acc ->
        case acc do
          nil ->
            debug("#{owner}/#{repo} - start")
            data = request(url,param)
            {[data],data}
          {_,_,nil} ->
            debug("#{owner}/#{repo} - no next link")
            {:halt,nil}
          {_,_,next} ->
            # IO.puts(:stderr,"next")
            debug("#{owner}/#{repo} - next")
            data = request(next,param)
            {[data],data }
          unexpected ->
            # IO.puts(:stderr,"bad" )
            error("#{owner}/#{repo} - #{inspect(unexpected)} ")
           {:halt,nil}
        end
      end,
      fn _ -> nil end
    )

    # GOOD TO HERE...

    # require IEx ; IEx.pry()

    res = stream |> Enum.to_list |> List.flatten

    {_,headers,_}= hd(res)

    etag = Map.get( headers, "ETag")
    end_headers =  List.last( res |> Enum.map(&( elem(&1,1)   )) )
    limit_limit = String.to_integer(end_headers["X-RateLimit-Limit"])
    limit_remaining = String.to_integer(end_headers["X-RateLimit-Remaining"])
    limit_reset = String.to_integer(end_headers["X-RateLimit-Reset"])

    # # res2  = res |> Enum.flat_map_reduce([], fn({body,_,_},acc) ->  [body] ++ acc end)

    # {etag, res2}
    # stream |> Enum.to_list |> List.flatten
    # require IEx ; IEx.pry()
    ret = res |> Enum.map(&( elem(&1,0) )) |> List.flatten
      %{etag: etag,
      limit_limit: limit_limit,
      limit_remaining: limit_remaining,
      limit_reset: limit_reset,
      events: ret}
  end


  def filter(data, nil ) do
    data
  end

  def filter({events,headers,next_link} , last_event) do

    # require IEx ; IEx.pry()

    reducer = fn(event,{changed,l} = acc ) ->

      case changed do
        true -> acc
        false ->
          case String.to_integer(event["id"]) > last_event do
            true -> {false, l ++ [event]}
            false -> {true, l ++ [event]}
          end

      end


    end



    case events |> Enum.reduce({false,[]},reducer) do
      {false, events} -> {events,headers,next_link}
      {true, events}  -> {events,headers,nil}
    end


  end

  @spec request(binary,ExGithubPoller.Param.t ) :: {any, map, any}
  def request(url, param) do

    # TODO - this needs to be stored in such a way it can be dynamically updated
    # TODO - provide a plugable strategy or something.
    token = Application.get_env(:ex_github_poller,:token)

    rheaders = %{
      "Authorization" => "token #{token}"
    }

    rheaders = case param.etag do
      nil -> rheaders
      etag ->  Map.put(rheaders, "If-None-Match", etag)
    end

    case HTTPoison.get!( url,rheaders) do
        %Response{body: body, headers: headers,status_code:  200}  ->
          data = JSX.decode!(body)
          headers = Map.new(headers)
          next_link = next_link(headers)
          resp = {data,headers,next_link}
          filter(resp,param.last_event)

          %Response{headers: headers,status_code:  304}  ->
            { [],Map.new(headers),nil}

      end

      end


  defp next_link(%{"Link" => link} ) do

       for links <- String.split(link, ",") do
      Regex.named_captures(~r/<(?<link>.*)>;\s*rel=\"(?<rel>.*)\"/, links)
      |> case do
        %{"link" => link, "rel" => "next"} -> link
        _ -> nil
      end
    end
    |> Enum.filter(&(not is_nil(&1)))
    |> List.first()
  end
  defp next_link(_), do: nil

end
