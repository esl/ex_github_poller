defmodule ExGithubPollerTest do
  use ExUnit.Case
  # doctest ExGithubPoller

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "list events - filtering by last event" do
    ExVCR.Config.filter_request_headers("Authorization")
    use_cassette "list_events_filtering_by_last_event" , match_requests_on: [:query] do
      x = ExGithubPoller.events("bryanhuntesl", "test_repo", %ExGithubPoller.Param{last_event: 9771755098} )
      assert length(x.events) == 2
    end
  end

  test "list events - no filtering" do
    ExVCR.Config.filter_request_headers("Authorization")
    use_cassette "list_events_no_filtering" , match_requests_on: [:query] do
      x = ExGithubPoller.events("bryanhuntesl", "test_repo", %ExGithubPoller.Param{} )
      assert length(x.events) == 152
    end
  end

  # test "list events etag " do
  #   ExVCR.Config.filter_request_headers("Authorization")
  #   use_cassette "list_events_etag" , match_requests_on: [ :headers, :query , :request_body ] do

  #     etag = "\"b6364b00c3926445e3b85f2c31f25576\""

  #     y = ExGithubPoller.events("bryanhuntesl", "test_repo", %ExGithubPoller.Param{etag: etag} )
  #     assert length(y.events) == 0
  #     # assert y[:limit_remaining] == x[:limit_remaining]

  #   end
  # end







  # test "greets the world" do
  #   assert true == true
  # end
end
