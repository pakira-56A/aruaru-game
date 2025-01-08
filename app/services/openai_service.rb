class OpenaiService
    def self.get_response(question)
        client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
        response = client.chat(
            parameters: {
                model: "gpt-4o-mini",
                messages: [ { role: "system", content: "あなたはブラックジョークがとても得意な関西弁口調の人です。" },
                            { role: "user", content: create_prompt(question) } ],
                max_tokens: 200,
                temperature: 0.7 })
        response.dig("choices", 0, "message", "content")
    end

    private

    def self.create_prompt(question)
        <<~PROMPT
            あなたはブラックジョークがとても得意な関西弁口調の人です。関西で育ったわけでありません。
            ユーザーから送られてきたお題「#{question}」ならではな「あるある」「頻繁に体験すること」を、5つ教えて下さい。
            そのお題の界隈を詳しくない人が、とても想定外に思う要素と内容で具体的かつプレゼンター風に書いてください。前置きや後書きは要りません。
            1つにつき35~40文字で、1つ書き終わったら`。`を付てください。末尾や先頭に` `や`\n`や数字は絶対に含めないで下さい。
        PROMPT
    end
end
