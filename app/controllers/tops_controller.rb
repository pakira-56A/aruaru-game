class TopsController < ApplicationController
  before_action :today_or_another, only: [ :toppage ] # Cookieがあるか否かを判別

  def toppage; end
  def after_login; end
  def policy; end
  def term; end

  # Cookieが作られたのが、今日以外ならCookieを消しゲームできる
  def today_or_another
    # クッキーが存在しない場合は、リターンして処理を終了
    return unless cookies[:cookie_count].present?
    begin
      # 日本時間でクッキーの日付を取得
      cookie_date = Date.parse(cookies[:cookie_count])
      # 日付が今日以外なら、cookie_countを消す
      cookies.delete(:cookie_count) if cookie_date != Time.zone.today
    rescue ArgumentError
      # クッキーの日付が無効な場合（無意味な文字列などの場合）に備え、無効なクッキーを削除す
      cookies.delete(:cookie_count)
    end
  end
end
