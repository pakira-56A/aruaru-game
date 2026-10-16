require 'rails_helper'

# test環境は allow_forgery_protection=false のため、CSRF保護はこのspecの中だけ一時的に有効化する。
RSpec.describe "CSRF保護", type: :request do
  let(:user) { create(:user) }

  around do |example|
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    begin
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = original
    end
  end

  before do
    allow(OgpCreator).to receive(:build).and_return(nil)
    sign_in user
  end

  it 'トークン無しのPOST /postsは拒否され、投稿は作られない' do
    params = { post: { title: "t", aruaru_one: "1", aruaru_two: "2", aruaru_three: "3",
                       aruaru_four: "4", aruaru_five: "5", tag: "野球" } }

    expect { post posts_path, params: params }.not_to change(Post, :count)
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'トークン無しのPOST /likesは拒否され、いいねは作られない' do
    target = create(:post)

    expect { post likes_path(post_id: target.id) }.not_to change(Like, :count)
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'トークン無しのDELETE /posts/:idは拒否され、投稿は消えない' do
    own = create(:post, user: user)

    expect { delete post_path(own) }.not_to change(Post, :count)
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
