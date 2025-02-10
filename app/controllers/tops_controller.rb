class TopsController < ApplicationController
  before_action :today_or_another, only: [ :toppage ] # Cookieがあるか否かを判別

  def toppage; end
  def after_login; end
  def policy; end
  def term; end

  # Cookieが作られたのが、今日以外ならCookieを消しゲームできる
  def today_or_another
    return unless cookies[:cookie_count].present?
    begin
      cookie_date = Date.parse(cookies[:cookie_count])
      cookies.delete(:cookie_count) if cookie_date != Time.zone.today
    rescue ArgumentError
      # クッキーの日付が無効な場合（無意味な文字列などの場合）に備え、無効なクッキーを削除
      cookies.delete(:cookie_count)
    end
  end
end
