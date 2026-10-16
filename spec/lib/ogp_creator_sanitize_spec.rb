require 'rails_helper'

RSpec.describe OgpCreator, ".sanitize" do
  it '引用符は全角に置き換える' do
    expect(described_class.sanitize(%(a'b"c))).to eq("a’b’c")
  end

  it 'バックスラッシュ・%・制御文字を取り除く' do
    expect(described_class.sanitize("a\\b%c\x01d")).to eq("abcd")
  end

  it '行頭の@を取り除く（ファイル読み込みの記法を無効にする）' do
    expect(described_class.sanitize("@/etc/hosts\n @x")).to eq("/etc/hosts\nx")
  end

  it '連続する@と、@の間の空白をすべて取り除く' do
    expect(described_class.sanitize("@@@x\n@ @ y")).to eq("x\n y")
  end

  it '20文字で分割した後の2行目以降の先頭の@も取り除く' do
    text = ("a" * 20) + "@@" + ("b" * 5)
    expect(described_class.prepare_text(text)).to eq(("a" * 20) + "\n" + ("b" * 5))
  end

  it '改行は残し、長さを上限で切る' do
    expect(described_class.sanitize("a\nb")).to eq("a\nb")
    expect(described_class.sanitize("あ" * 1000).length).to eq(OgpCreator::MAX_TEXT_LENGTH)
  end

  it 'nil でも落ちない' do
    expect(described_class.sanitize(nil)).to eq("")
  end
end
