require 'rails_helper'

RSpec.describe "Tops", type: :request do
  describe "GET / (toppage)" do
    it 'トップページを表示する' do
      get root_path
      expect(response).to be_successful
    end

    it '今日以外の日付のcookieは削除される' do
      cookies[:cookie_count] = "2020-01-01"
      get root_path
      expect(response).to be_successful
      expect(cookies[:cookie_count]).to be_blank
    end

    it '不正な文字列のcookieも削除される' do
      cookies[:cookie_count] = "invalid-date"
      get root_path
      expect(response).to be_successful
      expect(cookies[:cookie_count]).to be_blank
    end

    it '今日の日付のcookieは保持される' do
      cookies[:cookie_count] = Time.zone.today.to_s
      get root_path
      expect(response).to be_successful
      expect(cookies[:cookie_count]).to eq(Time.zone.today.to_s)
    end
  end

  describe "GET /policy" do
    it 'プライバシーポリシーを表示する' do
      get policy_path
      expect(response).to be_successful
    end
  end

  describe "GET /term" do
    it '利用規約を表示する' do
      get term_path
      expect(response).to be_successful
    end
  end
end
