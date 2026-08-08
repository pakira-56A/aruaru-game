require 'rails_helper'

RSpec.describe TagMap, type: :model do
  let(:post_record) { create(:post) }
  let(:tag) { create(:tag) }

  it '有効な組み合わせはvalidになる' do
    expect(TagMap.new(post: post_record, tag: tag)).to be_valid
  end

  it 'post_idがない場合、invalidになる' do
    expect(TagMap.new(post: nil, tag: tag)).to be_invalid
  end

  it 'tag_idがない場合、invalidになる' do
    expect(TagMap.new(post: post_record, tag: nil)).to be_invalid
  end
end
