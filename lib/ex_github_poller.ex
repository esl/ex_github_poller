defmodule ExGithubPoller do
  @moduledoc """
  Documentation for ExGithubPoller.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExGithubPoller.hello()
      :world

  """

  defmodule ExGithubPoller.Param do
    defstruct since: nil, etag: nil, auth: nil
  end

  alias ExGithubPoller.Param
  alias HTTPoison.Response



  def events(owner,repo, param \\ %Param{} ) do

    # {"Authorization", "token #{token}"}
    url = "https://api.github.com/repos/#{owner}/#{repo}/events"
    # x = Tentacat.get("repos/bryanhuntesl/test_repo/events", %Tentacat.Client{}, [], [pagination: :manual])
    # stream = get("repos/#{owner}/#{repo}/events", client, [], [pagination: :stream])
    # stream |> Stream.take_while(fn(x) -> String.to_integer(x["id"])  >  latest_event_id end) |> Enum.to_list


    stream = Stream.resource(
      fn -> nil end,
      fn acc ->
        case acc do
          nil ->
            data = request(url)
            {[data],data}
          {_,_,nil} ->
            # IO.puts(:stderr,"nil")
            {:halt,nil}
          {_,_,next} ->
            # IO.puts(:stderr,"next")
            data = request(next)
            {[data],data }
          _ ->
            # IO.puts(:stderr,"bad" )
           {:halt,nil}
        end
      end,
      fn _ -> nil end
    )

    # GOOD TO HERE...gg

    res = stream |> Enum.to_list |> List.flatten

    {_,headers,_}= hd(res)
    etag = Map.get( headers, "ETag")

    # # res2  = res |> Enum.flat_map_reduce([], fn({body,_,_},acc) ->  [body] ++ acc end)

    # {etag, res2}
    # stream |> Enum.to_list |> List.flatten

  end

  def request(url) do
    rheaders = %{
      "Authorization" => "token 02422f0112e3e315fb004d26876eae8318de4ae7"
    }
    %Response{body: body, headers: headers,status_code:  200}  =
      HTTPoison.get!( url,rheaders)

      body = JSX.decode!(body)
      headers = Map.new(headers)
      next_link = next_link(headers)

      {body,headers,next_link}
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
