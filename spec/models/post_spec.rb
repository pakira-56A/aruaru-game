require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'バリデーションチェック' do
    it '設定した全バリデーションが機能してるか' do
      post = build(:post)
      expect(post).to be_valid
    end

    it 'titleがない場合、バリデーションが機能してinvalidになるか' do
      post_without_title = build(:post, title: "")
      expect(post_without_title).to be_invalid
    end

    it 'titleが41文字以上の場合、バリデーションが機能してinvalidになるか' do
      post = Post.new(title: 'a' * 41)
      expect(post).to be_invalid
    end

    context "あるあるがない場合" do
      it 'aruaru_oneがない場合、バリデーションが機能してinvalidになるか' do
        post_without_aruaru_one = build(:post, aruaru_one: "")
        expect(post_without_aruaru_one).to be_invalid
      end

      it 'aruaru_twoがない場合、バリデーションが機能してinvalidになるか' do
        post_without_aruaru_two = build(:post, aruaru_two: "")
        expect(post_without_aruaru_two).to be_invalid
      end

      it 'aruaru_threeがない場合、バリデーションが機能してinvalidになるか' do
        post_without_aruaru_three = build(:post, aruaru_three: "")
        expect(post_without_aruaru_three).to be_invalid
      end

      it 'aruaru_fourがない場合、バリデーションが機能してinvalidになるか' do
        post_without_aruaru_four = build(:post, aruaru_four: "")
        expect(post_without_aruaru_four).to be_invalid
      end

      it 'aruaru_fiveがない場合、バリデーションが機能してinvalidになるか' do
        post_without_aruaru_five = build(:post, aruaru_five: "")
        expect(post_without_aruaru_five).to be_invalid
      end
    end

    context "あるあるが41文字以上の場合" do
      it 'aruaru_oneが41文字以上の場合、バリデーションが機能してinvalidになるか' do
        post = Post.new(aruaru_one: 'a' * 41)
        expect(post).to be_invalid
      end

      it 'aruaru_twoが41文字以上の場合、バリデーションが機能してinvalidになるか' do
        post = Post.new(aruaru_two: 'a' * 41)
        expect(post).to be_invalid
      end

      it 'aruaru_threeが41文字以上の場合、バリデーションが機能してinvalidになるか' do
        post = Post.new(aruaru_three: 'a' * 41)
        expect(post).to be_invalid
      end

      it 'aruaru_fourが41文字以上の場合、バリデーションが機能してinvalidになるか' do
        post = Post.new(aruaru_four: 'a' * 41)
        expect(post).to be_invalid
      end

      it 'aruaru_fiveが41文字以上の場合、バリデーションが機能してinvalidになるか' do
        post = Post.new(aruaru_five: 'a' * 41)
        expect(post).to be_invalid
      end
    end
  end
end
