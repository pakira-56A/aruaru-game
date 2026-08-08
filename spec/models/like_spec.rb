require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:user) { create(:user) }
  let(:post_record) { create(:post) }

  it '有効な組み合わせはvalidになる' do
    expect(build(:like, user: user, post: post_record)).to be_valid
  end

  it '同じユーザーが同じ投稿を二重にいいねするとinvalidになる' do
    create(:like, user: user, post: post_record)
    expect(build(:like, user: user, post: post_record)).to be_invalid
  end

  it '別ユーザーなら同じ投稿をいいねできる' do
    create(:like, user: user, post: post_record)
    expect(build(:like, user: create(:user), post: post_record)).to be_valid
  end
end
