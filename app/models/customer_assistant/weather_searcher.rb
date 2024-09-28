# chat completions APIでfunction callingも使った実装
class CustomerAssistant::WeatherSearcher
  attr_reader :content # 今日の東京都の天気を教えて

  def self.call(content:)
    new(content:).search
  end

  def initialize(content:)
    @content = content
  end

  def search
    content = request_gpt_with_function_calling(messages)
    puts content
  end

  private

  def request_gpt_with_function_calling(messages)
    assistant_message = request_gpt(messages)
    tool_calls = assistant_message.dig("tool_calls")
    return assistant_message.dig("content") unless tool_calls

    arguments = JSON.parse(tool_calls[0]["function"]["arguments"], symbolize_names: true)
    weathre_data = get_weather_by_prefecture(arguments[:prefecture])
    set_message(assistant_message)
    set_message({
      role: "tool",
      name: "get_weather_by_prefecture",
      content: weathre_data.to_json,
      tool_call_id: tool_calls[0]["id"]
    })

    assistant_message = request_gpt(messages)
    assistant_message.dig("content")
  end

  def request_gpt(messages)
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [system_message] + messages,
        tools: [function_definition],
      }
    )

    response.dig("choices", 0, "message")
  end

  response = client.chat(
    parameters: {
      model: "gpt-4o-mini",
      response_format: { type: "json_object" },
      messages: [
        { role: "user", content: "じゃがりこはいつ販売された? jsonで出力して" }
      ],
    }
  )

  def client
    @client ||= OpenAI::Client.new(access_token: ENV.fetch("GPT_ACCESS_TOKEN", ""))
  end

  def system_message
    { role: "system", content: "あなたは親切なお天気を教えてくれるアシスタントです。付属のツールを使ってユーザーをサポートしてください。" }
  end

  def function_definition
    {
      type: "function",
      function: {
        name: "get_weather_by_prefecture",
        description: "今日以降のある都道府県の天気情報を取得します。天気情報を知る必要がある時はいつでもこれを呼び出します。",
        parameters: {
          type: "object",
          properties: {
            prefecture: {
              type: "string",
              description: "検索対象の都道府県"
            }
          },
          required: ["prefecture"], # デフォルトでは、properties キーワードで定義されたプロパティは必須ではない。requiredを設定すると、それのプロパティを必須プロパティにする
          additionalProperties: false
          # additionalProperties は、JSON スキーマで定義されていない追加のキー/値をオブジェクトに含めることを許可するかどうかを制御する
          # 構造化出力は、指定されたキー/値の生成のみをサポートしているため、構造化出力を選択するには、開発者に additionalProperties: false を設定するよう求める。
        }
      },
      strict: true
    }
  end

  def get_weather_by_prefecture(prefecture)
    prefecture_id = prefecture_mapping[prefecture]
    # https://weather.tsukumijima.net/
    uri = URI("https://weather.tsukumijima.net/api/forecast?city=#{prefecture_id}")

    # https://ruby-doc.org/stdlib-2.7.0/libdoc/net/http/rdoc/Net/HTTP.html
    response = Net::HTTP.get(uri)
    response_hash = JSON.parse(response, symbolize_names: true)
    response_hash[:forecasts].filter { _1[:date] == Date.current.to_s }.first
  end

  def prefecture_mapping
    # https://weather.tsukumijima.net/primary_area.xml
    { "東京都" => 130010 }
  end

  def messages
    @messages ||= [
      {
        role: "user",
        content:
      }
    ]
  end

  def set_message(message)
    messages << message
  end
end
