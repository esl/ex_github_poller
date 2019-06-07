# ExGithubPoller
_not ready for use_

So … a poller for github repositories - calls the events url and pages through the results by extracting the Link HTTP header to get the URL for the next page - in order to avoid massive data usage / rate limiting it will do two things  : 
1. Pass the etag when making the first request - if you do so the request doesn’t count against your rate limit.
2. Each event has an id and created date , only fetch and/or iterate if events have an id higher than the provided id e.g. ` “created_at” => "2019-06-06T13:54:12Z", "id" => "9771612375",`

# Running 

Requires the environmental variable GITHUB_TOKEN to be set.

On application startup this variable is read and merged into the application.
config under the key :ex_github_poller, token

You can generate such tokens at : https://github.com/settings/tokens

Generate a token with minimum priv - I found that "notifications, repo" were
sufficient.

This is alpha, alpha, alpha stuff - expect the API to change.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_github_poller` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_github_poller, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_github_poller](https://hexdocs.pm/ex_github_poller).

