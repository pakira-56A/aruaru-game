require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'バリデーションチェック' do
    it '設定した全バリデーションが機能してるか' do end

    it 'titleがない場合、バリデーションが機能してinvalidになるか' do end

    it 'titleが41文字以上の場合、バリデーションが機能してinvalidになるか' do end

    context "あるあるがない場合" do
      it 'aruaru_oneがない場合、バリデーションが機能してinvalidになるか'  do end

      it 'aruaru_twoがない場合、バリデーションが機能してinvalidになるか' do end

      it 'aruaru_threeがない場合、バリデーションが機能してinvalidになるか' do end

      it 'aruaru_fourがない場合、バリデーションが機能してinvalidになるか'  do end

      it 'aruaru_fiveがない場合、バリデーションが機能してinvalidになるか'  do end
    end

    context "あるあるが41文字以上の場合" do
      it 'aruaru_oneが41文字以上の場合、バリデーションが機能してinvalidになるか' do end

      it 'aruaru_twoが41文字以上の場合、バリデーションが機能してinvalidになるか' do end

      it 'aruaru_threeが41文字以上の場合、バリデーションが機能してinvalidになるか' do end

      it 'aruaru_fourが41文字以上の場合、バリデーションが機能してinvalidになるか' do end

      it 'aruaru_fiveが41文字以上の場合、バリデーションが機能してinvalidになるか' do end
    end
  end
end
