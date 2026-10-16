import { Controller } from "@hotwired/stimulus"

// ブラウザの「戻る」と同じ動きをする（CSPで href="javascript:..." が使えないため）。
// 履歴が無い（直接開いた）ときはリンク先（投稿一覧）へそのまま進む。
export default class extends Controller {
  back(event) {
    if (window.history.length > 1) {
      event.preventDefault()
      window.history.back()
    }
  }
}
