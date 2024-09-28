# chat completions APIを普通に使った実装
class CustomerAssistant
  attr_reader :content

  def self.call(content)
    new(content: content).reply
  end

  def initialize(content:)
    @content = content
  end

  def reply
    generate_content_with_gpt
  end

  private

  def generate_content_with_gpt
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "user", content: "macとwindowsの違いを1行で教えて" },
          { role: "assistant", content: "MacはApple社の製品で、OSはmacOSであり、デザインやユーザビリティが重視されているのに対し、WindowsはMicrosoft社の製品で、OSはWindowsであり、汎用性やゲームなどのサポートが強化されている。" },
          { role: "user", content: },
        ],
        temperature: 0.7,
      }
    )

    response.dig("choices", 0, "message", "content")
  end

  def client
    @client ||= OpenAI::Client.new(access_token: ENV.fetch("GPT_ACCESS_TOKEN", ""))
  end
end