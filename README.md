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

## Examples

Fetching events with a last_event filter

```text
x = ExGithubPoller.events("bryanhuntesl", "test_repo", %ExGithubPoller.Param{last_event: 9771755098} )

15:56:38.594 [debug] bryanhuntesl/test_repo - start
 
15:56:38.928 [debug] bryanhuntesl/test_repo - no next link
%{
  etag: "\"b6364b00c3926445e3b85f2c31f25576\"",
  events: [
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/31992054?",
        "display_login" => "bryanhuntesl",
        "gravatar_id" => "",
        "id" => 31992054,
        "login" => "bryanhuntesl",
        "url" => "https://api.github.com/users/bryanhuntesl"
      },
      "created_at" => "2019-06-06T14:11:17Z",
      "id" => "9771755702",
      "payload" => %{
        "before" => "7d73e4713c6d924a848f3c90fbc626139169f77e",
        "commits" => [
          %{
            "author" => %{
              "email" => "bryan.hunt@erlang-solutions.com",
              "name" => "bryan"
            },
            "distinct" => true,
            "message" => "Thu  6 Jun 2019 15:11:13 BST",
            "sha" => "5d26a333a088ebfd5704c3ed35d16b714e5be9c0",
            "url" => "https://api.github.com/repos/bryanhuntesl/test_repo/commits/5d26a333a088ebfd5704c3ed35d16b714e5be9c0"
          }
        ],
        "distinct_size" => 1,
        "head" => "5d26a333a088ebfd5704c3ed35d16b714e5be9c0",
        "push_id" => 3687315391,
        "ref" => "refs/heads/master",
        "size" => 1
      },
      "public" => true,
      "repo" => %{
        "id" => 190588048,
        "name" => "bryanhuntesl/test_repo",
        "url" => "https://api.github.com/repos/bryanhuntesl/test_repo"
      },
      "type" => "PushEvent"
    },
    %{
      "actor" => %{
        "avatar_url" => "https://avatars.githubusercontent.com/u/31992054?",
        "display_login" => "bryanhuntesl",
        "gravatar_id" => "",
        "id" => 31992054,
        "login" => "bryanhuntesl",
        "url" => "https://api.github.com/users/bryanhuntesl"
      },
      "created_at" => "2019-06-06T14:11:13Z",
      "id" => "9771755098",
      "payload" => %{
        "before" => "7512b2aa7a17937f24a30eddc179f8388841a843",
        "commits" => [
          %{
            "author" => %{
              "email" => "bryan.hunt@erlang-solutions.com",
              "name" => "bryan"
            },
            "distinct" => true,
            "message" => "Thu  6 Jun 2019 15:11:08 BST",
            "sha" => "7d73e4713c6d924a848f3c90fbc626139169f77e",
            "url" => "https://api.github.com/repos/bryanhuntesl/test_repo/commits/7d73e4713c6d924a848f3c90fbc626139169f77e"
          }
        ],
        "distinct_size" => 1,
        "head" => "7d73e4713c6d924a848f3c90fbc626139169f77e",
        "push_id" => 3687315054,
        "ref" => "refs/heads/master",
        "size" => 1
      },
      "public" => true,
      "repo" => %{
        "id" => 190588048,
        "name" => "bryanhuntesl/test_repo",
        "url" => "https://api.github.com/repos/bryanhuntesl/test_repo"
      },
      "type" => "PushEvent"
    }
  ],
  limit_limit: 5000,
  limit_remaining: 4999,
  limit_reset: 1559922999
}
```

## Fetching events - using a prior ETag to set the conditional 'If-None-Match' HTTP header :

Demonstrate zero ratelimit cost.

First invocation :

```elixir
iex(39)> x = ExGithubPoller.events("bryanhuntesl", "test_repo", %ExGithubPoller.Param{last_event: 9771755098, etag: etag}) 

16:36:46.475 [debug] bryanhuntesl/test_repo - start
 
16:36:46.871 [debug] bryanhuntesl/test_repo - no next link
%{
  etag: "\"b6364b00c3926445e3b85f2c31f25576\"",
  events: [],
  limit_limit: 5000,
  limit_remaining: 4989,
  limit_reset: 1559925407 
}

```

Second invocation - note the unchanged rate limit :

```Elixir

iex(40)> x = ExGithubPoller.events("bryanhuntesl", "test_repo", %ExGithubPoller.Param{last_event: 9771755098, etag: etag}) 

16:36:50.156 [debug] bryanhuntesl/test_repo - start

16:36:50.521 [debug] bryanhuntesl/test_repo - no next link
%{
  etag: "\"b6364b00c3926445e3b85f2c31f25576\"",
  events: [],
  limit_limit: 5000,
  limit_remaining: 4989,
  limit_reset: 1559925410 
}
```

