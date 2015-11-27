ExUnit.start

defmodule Gmail.MessageTest do

  use ExUnit.Case
  import Mock

  setup do
    message_id = "23443513177"
    thread_id = "234234234"
    message = %{"id" => message_id,
      "threadId" => thread_id,
      "labelIds" => ["INBOX", "CATEGORY_PERSONAL"],
      "snippet" => "This is a message snippet",
      "historyId" => "12123",
      "payload" => %{"mimeType" => "text/html",
        "filename" => "",
        "headers" => ["header-1", "header-2"],
        "body" => %{"data" => "the actual body", "size" => 234},
        "parts" => []},
      "sizeEstimate" => 23433
    }

    expected_result = %Gmail.Message{history_id: "12123", id: message_id,
      label_ids: ["INBOX", "CATEGORY_PERSONAL"],
      payload: %Gmail.Payload{body: %Gmail.Body{data: "the actual body",
          size: 234}, filename: "", headers: ["header-1", "header-2"],
        mime_type: "text/html", part_id: "", parts: []}, raw: "",
      size_estimate: 23433, snippet: "This is a message snippet",
      thread_id: thread_id}

    access_token = "xxx-xxx-xxx"
    access_token_rec = %{access_token: access_token}

    {:ok,
      message_id: message_id,
      message: message,
      access_token: access_token,
      access_token_rec: access_token_rec,
      expected_result: expected_result
    }
  end

  test "gets a message", context do
    with_mock Gmail.HTTP, [ get: fn _at, _url -> { :ok, context[:message] } end] do
      with_mock Gmail.OAuth2.Client, [ get_config: fn -> context[:access_token_rec] end ] do
        message = Gmail.Message.get(context[:message_id])
        assert message = context[:expected_result]
        assert called Gmail.OAuth2.Client.get_config
        assert called Gmail.HTTP.get(context[:access_token], Gmail.Base.base_url <> "users/me/messages/" <> context[:message_id] <> "?format=full")
      end
    end
  end

  test "gets a message for a specified user", context do
    with_mock Gmail.HTTP, [ get: fn _at, _url -> { :ok, context[:message] } end] do
      with_mock Gmail.OAuth2.Client, [ get_config: fn -> context[:access_token_rec] end ] do
        message = Gmail.Message.get("user@example.com", context[:message_id])
        assert message = context[:expected_result]
        assert called Gmail.OAuth2.Client.get_config
        assert called Gmail.HTTP.get(context[:access_token], Gmail.Base.base_url <> "users/user@example.com/messages/" <> context[:message_id] <> "?format=full")
      end
    end
  end

  test "performs a message search", context do
    with_mock Gmail.HTTP, [ get: fn _at, _url -> { :ok, context[:message] } end] do
      with_mock Gmail.OAuth2.Client, [ get_config: fn -> context[:access_token_rec] end ] do
        results = Gmail.Message.search("in:Inbox")
        IO.inspect results: results
        assert results = context[:expected_result]
        assert called Gmail.OAuth2.Client.get_config
        assert called Gmail.HTTP.get(context[:access_token], Gmail.Base.base_url <> "users/me/messages?q=in:Inbox")
      end
    end
  end

  test "performs a message search for a specified user", context do
    with_mock Gmail.HTTP, [ get: fn _at, _url -> { :ok, context[:message] } end] do
      with_mock Gmail.OAuth2.Client, [ get_config: fn -> context[:access_token_rec] end ] do
        results = Gmail.Message.search("user@example.com", "in:Inbox")
        assert called Gmail.OAuth2.Client.get_config
        assert called Gmail.HTTP.get(context[:access_token], Gmail.Base.base_url <> "users/user@example.com/messages?q=in:Inbox")
      end
    end
  end

  test "gets a list of messages", context do
    with_mock Gmail.HTTP, [ get: fn _at, _url -> { :ok, context[:message] } end] do
      with_mock Gmail.OAuth2.Client, [ get_config: fn -> context[:access_token_rec] end ] do
        results = Gmail.Message.list
        # TODO need to test results
        assert called Gmail.OAuth2.Client.get_config
        assert called Gmail.HTTP.get(context[:access_token], Gmail.Base.base_url <> "users/me/messages")
      end
    end
  end


end
