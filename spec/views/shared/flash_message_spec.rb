require 'rails_helper'

RSpec.describe "shared/_flash_message", type: :view do
  it 'アラートの改行は<br>で表示し、文言に含まれるHTMLはエスケープする' do
    flash[:alert] = "1行目<b>太字</b>\n2行目"

    render partial: "shared/flash_message"

    expect(rendered).to include("1行目&lt;b&gt;太字&lt;/b&gt;<br>2行目")
    expect(rendered).not_to include("<b>太字</b>")
  end
end
