# chat completions APIでfunction callingも使った実装
module CustomerAssistant
  class OrderDeliveryDateCalcurator
    def self.call
      new.calculate
    end

    def calculate
      content = request_gpt_with_function_calling(messages)
      puts content
    end

    private

    def request_gpt_with_function_calling(messages)
      assistant_message = request_gpt(messages)
      tool_calls = assistant_message.dig("tool_calls")
      return assistant_message.dig("content") unless tool_calls

      arguments = JSON.parse(tool_calls[0]["function"]["arguments"], symbolize_names: true)
      delivery_date = get_delivery_date_by_order_id(arguments[:order_id].to_i)
      set_message(assistant_message)
      # 関数を呼び出した後もモデルとやり取りしたいなら、関数を呼び出した結果を、role: toolのメッセージオブジェクトとしてGPTに渡す必要がある
      set_message({
        role: "tool",
        name: "get_delivery_date_by_order_id",
        content: delivery_date,
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
          tools: [function_definition], # toolsで関数定義を渡している
          # completion apiを呼び出す際に、tool_choiceを指定すれば、関数を呼び出すのか呼び出さないのかを制御できる。noneは呼び出されない
          # tool_choice: "none"
        }
      )

      response.dig("choices", 0, "message")
    end

    def client
      @client ||= OpenAI::Client.new(access_token: ENV.fetch("GPT_ACCESS_TOKEN", ""))
    end

    def system_message
      { role: "system", content: "あなたは親切なカスタマーサポートアシスタントです。付属のツールを使ってユーザーをサポートしてください。" }
    end

    def function_definition
      {
        type: "function",
        function: {
          name: "get_delivery_date_by_order_id",
          description: "顧客の注文の配達日を取得します。配達日を知る必要がある時はいつでもこれを呼び出します。",
          # ここは確かJSON schemaの仕様に基づいて描いてた
          # このスキーマを見て引数を生成する
          parameters: {
            type: "object",
            properties: {
              order_id: {
                type: "string",
                description: "顧客の注文ID"
              }
            },
            required: ["order_id"],
            additionalProperties: false
          }
        },
        strict: true # スキーマと正確に一致することを保証したいなら、strict: trueを指定する
      }
    end

    def get_delivery_date_by_order_id(order_id)
      order_ids = [12345]
      return nil unless order_ids.include?(order_id)

      Date.new(2024, 9, 1).to_s
    end

    def messages
      @messages ||= [
        {
          role: "user",
          content: "私の注文の配達日を教えてもらえますか?"
        },
        {
          role: "assistant",
          content: "こんにちは！ お手伝いできます。 ご注文IDをお教えください。"
        },
        {
          role: "user",
          content: "注文IDは12345だと思う。"
        }
      ]
    end

    def set_message(message)
      messages << message
    end
  end
end
